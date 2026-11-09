type graph = {
  cells: array<Cell.t>,
  dependencies: Js.Dict.t<array<Cell.t>>,
  reverse: Js.Dict.t<array<Cell.t>>,
  cycles: array<array<Cell.t>>,
}

let key = Cell.show

let addUnique = (items: array<Cell.t>, cell: Cell.t): array<Cell.t> =>
  if items->Array.some(item => Cell.compare(item, cell) == 0) {
    items
  } else {
    items->Array.concat([cell])
  }

let rec collect = (expr: Parser.expr, acc: array<Cell.t>): array<Cell.t> =>
  switch expr {
  | Parser.Number(_) => acc
  | Parser.Reference(cell) => addUnique(acc, cell)
  | Parser.Unary(_, child) => collect(child, acc)
  | Parser.Binary(_, left, right) => collect(right, collect(left, acc))
  | Parser.Call(_, args) =>
    args->Array.reduce(acc, (found, arg) =>
      switch arg {
      | Parser.Expression(value) => collect(value, found)
      | Parser.Range(first, last) =>
        let minRow = min(first.row, last.row)
        let maxRow = max(first.row, last.row)
        let minCol = min(first.col, last.col)
        let maxCol = max(first.col, last.col)
        let result = ref(found)
        let row = ref(minRow)
        while row.contents <= maxRow {
          let col = ref(minCol)
          while col.contents <= maxCol {
            result := addUnique(result.contents, {row: row.contents, col: col.contents})
            col := col.contents + 1
          }
          row := row.contents + 1
        }
        result.contents
      }
    )
  }

let defined = (sheet: Sheet.t, cell: Cell.t): bool =>
  Js.Dict.get(sheet.byCell, key(cell))->Option.isSome

let rec makeGraph = (sheet: Sheet.t): graph => {
  let cells = sheet.definitions->Array.map(definition => definition.cell)->Cell.sorted
  let dependencies: Js.Dict.t<array<Cell.t>> = Js.Dict.empty()
  let reverse: Js.Dict.t<array<Cell.t>> = Js.Dict.empty()
  cells->Array.forEach(cell => Js.Dict.set(reverse, key(cell), []))
  sheet.definitions->Array.forEach(definition => {
    let refs = collect(definition.expr, [])->Cell.sorted
    Js.Dict.set(dependencies, key(definition.cell), refs)
    refs->Array.forEach(reference =>
      if defined(sheet, reference) {
        let name = key(reference)
        let previous = Js.Dict.get(reverse, name)->Option.getOr([])
        Js.Dict.set(reverse, name, addUnique(previous, definition.cell))
      }
    )
  })
  reverse
  ->Js.Dict.keys
  ->Array.forEach(name =>
    switch Js.Dict.get(reverse, name) {
    | Some(items) => Js.Dict.set(reverse, name, Cell.sorted(items))
    | None => ()
    }
  )
  {cells, dependencies, reverse, cycles: findCycles(cells, dependencies)}
}

and findCycles = (cells: array<Cell.t>, dependencies: Js.Dict.t<array<Cell.t>>): array<
  array<Cell.t>,
> => {
  let indices: Js.Dict.t<int> = Js.Dict.empty()
  let lows: Js.Dict.t<int> = Js.Dict.empty()
  let onStack: Js.Dict.t<bool> = Js.Dict.empty()
  let stack: ref<array<Cell.t>> = ref([])
  let next = ref(0)
  let groups: ref<array<array<Cell.t>>> = ref([])
  let rec visit = (cell: Cell.t) => {
    let name = key(cell)
    Js.Dict.set(indices, name, next.contents)
    Js.Dict.set(lows, name, next.contents)
    next := next.contents + 1
    stack := stack.contents->Array.concat([cell])
    Js.Dict.set(onStack, name, true)
    let edges = Js.Dict.get(dependencies, name)->Option.getOr([])
    edges->Array.forEach(target =>
      if cells->Array.some(candidate => Cell.compare(candidate, target) == 0) {
        let targetName = key(target)
        switch Js.Dict.get(indices, targetName) {
        | None =>
          visit(target)
          let low = Js.Dict.get(lows, name)->Option.getOr(0)
          let childLow = Js.Dict.get(lows, targetName)->Option.getOr(0)
          Js.Dict.set(lows, name, min(low, childLow))
        | Some(index) if Js.Dict.get(onStack, targetName)->Option.getOr(false) =>
          let low = Js.Dict.get(lows, name)->Option.getOr(0)
          Js.Dict.set(lows, name, min(low, index))
        | _ => ()
        }
      }
    )
    if Js.Dict.get(lows, name) == Js.Dict.get(indices, name) {
      let component = ref([])
      let done = ref(false)
      while !done.contents {
        let lastIndex = stack.contents->Array.length - 1
        let member = stack.contents[lastIndex]->Option.getOr(cell)
        stack := stack.contents->Array.slice(~start=0, ~end=lastIndex)
        Js.Dict.set(onStack, key(member), false)
        component := component.contents->Array.concat([member])
        if Cell.compare(member, cell) == 0 {
          done := true
        }
      }
      let sorted = Cell.sorted(component.contents)
      let selfLoop =
        Js.Dict.get(dependencies, key(cell))
        ->Option.getOr([])
        ->Array.some(item => Cell.compare(item, cell) == 0)
      if sorted->Array.length > 1 || selfLoop {
        groups := groups.contents->Array.concat([sorted])
      }
    }
  }
  cells->Array.forEach(cell =>
    if Js.Dict.get(indices, key(cell))->Option.isNone {
      visit(cell)
    }
  )
  groups.contents->Array.toSorted((left, right) => {
    let firstLeft = left[0]->Option.getOr({col: 1, row: 1})
    let firstRight = right[0]->Option.getOr({col: 1, row: 1})
    let result = Cell.compare(firstLeft, firstRight)
    if result < 0 {
      -1.0
    } else if result > 0 {
      1.0
    } else {
      0.0
    }
  })
}

let parse = (invocation: Types.invocation): result<Sheet.t, Types.failure> =>
  Sheet.parse(invocation.input)

let deps = (invocation: Types.invocation): result<string, Types.failure> =>
  switch parse(invocation) {
  | Error(problem) => Error(problem)
  | Ok(sheet) =>
    let requested = invocation.args[0]->Option.getOr("")
    switch Js.Dict.get(sheet.byCell, requested) {
    | None => Types.fail(1, "cell " ++ requested ++ " is not defined")
    | Some(_) =>
      let graph = makeGraph(sheet)
      let forward = Js.Dict.get(graph.dependencies, requested)->Option.getOr([])
      let backward = Js.Dict.get(graph.reverse, requested)->Option.getOr([])
      let showList = items =>
        if items->Array.length == 0 {
          "-"
        } else {
          items->Array.map(key)->Array.join(" ")
        }
      Ok(
        requested ++
        " -> " ++
        showList(forward) ++
        "\n" ++
        requested ++
        " <- " ++
        showList(backward) ++ "\n",
      )
    }
  }

let order = (invocation: Types.invocation): result<string, Types.failure> =>
  switch parse(invocation) {
  | Error(problem) => Error(problem)
  | Ok(sheet) =>
    let graph = makeGraph(sheet)
    switch graph.cycles[0] {
    | Some(component) =>
      Types.fail(1, "cycle through " ++ component->Array.map(key)->Array.join(" "))
    | None =>
      let remaining = ref(graph.cells)
      let output = ref([])
      while remaining.contents->Array.length > 0 {
        let ready =
          remaining.contents
          ->Array.filter(cell =>
            Js.Dict.get(graph.dependencies, key(cell))
            ->Option.getOr([])
            ->Array.every(reference =>
              !defined(sheet, reference) ||
              output.contents->Array.some(done => Cell.compare(done, reference) == 0)
            )
          )
          ->Cell.sorted
        switch ready[0] {
        | None => remaining := []
        | Some(cell) =>
          output := output.contents->Array.concat([cell])
          remaining := remaining.contents->Array.filter(item => Cell.compare(item, cell) != 0)
        }
      }
      let text = output.contents->Array.map(key)->Array.join("\n")
      Ok(
        if text == "" {
          ""
        } else {
          text ++ "\n"
        },
      )
    }
  }

let cycles = (invocation: Types.invocation): result<string, Types.failure> =>
  switch parse(invocation) {
  | Error(problem) => Error(problem)
  | Ok(sheet) =>
    let groups = makeGraph(sheet).cycles
    if groups->Array.length == 0 {
      Ok("no cycles\n")
    } else {
      Ok(
        groups
        ->Array.map(group => "cycle " ++ group->Array.map(key)->Array.join(" ") ++ "\n")
        ->Array.join(""),
      )
    }
  }
