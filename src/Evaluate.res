type value = Number(int) | Div | Num | Cycle

let render = value =>
  switch value {
  | Number(number) => Int.toString(number)
  | Div => "#DIV"
  | Num => "#NUM"
  | Cycle => "#CYCLE"
  }

let rec integerRange = (start: int, finish: int): array<int> =>
  if start >= finish {
    []
  } else {
    [start]->Array.concat(integerRange(start + 1, finish))
  }

let bound = 999999999
let key = cell => Cell.show(cell)
let findDefinitionIndex = (definitions: array<Sheet.definition>, cell: Cell.t): option<int> => {
  let index = definitions->Array.findIndex(item => key(item.cell) == key(cell))
  if index < 0 {
    None
  } else {
    Some(index)
  }
}

let rec references = (expr: Parser.expr): array<Cell.t> =>
  switch expr {
  | Parser.Number(_) => []
  | Parser.Reference(cell) => [cell]
  | Parser.Unary(_, value) => references(value)
  | Parser.Binary(_, left, right) => references(left)->Array.concat(references(right))
  | Parser.Call(_name, args) =>
    args->Array.flatMap(argument =>
      switch argument {
      | Parser.Expression(value) => references(value)
      | Parser.Range(first, last) =>
        let minRow = min(first.row, last.row)
        let maxRow = max(first.row, last.row)
        let minCol = min(first.col, last.col)
        let maxCol = max(first.col, last.col)
        integerRange(minRow, maxRow + 1)->Array.flatMap(row =>
          integerRange(minCol, maxCol + 1)->Array.map((col): Cell.t => {col, row})
        )
      }
    )
  }

let inBounds = number => number >= -bound && number <= bound
let exact = number =>
  if inBounds(number) {
    Number(number)
  } else {
    Num
  }

let exactAdd = (left, right) =>
  if (right > 0 && left > bound - right) || (right < 0 && left < -bound - right) {
    Num
  } else {
    Number(left + right)
  }

let exactSubtract = (left, right) =>
  if (right < 0 && left > bound + right) || (right > 0 && left < -bound + right) {
    Num
  } else {
    Number(left - right)
  }

let exactMultiply = (left, right) =>
  if left == 0 || right == 0 {
    Number(0)
  } else if abs(left) > bound / abs(right) {
    Num
  } else {
    Number(left * right)
  }

let run = (invocation: Types.invocation): result<string, Types.failure> =>
  switch Sheet.parse(invocation.input) {
  | Error(failure) => Error(failure)
  | Ok(sheet) =>
    let definitions = sheet.definitions
    let count = definitions->Array.length
    let adjacency = Array.make(~length=count, [])
    definitions->Array.forEachWithIndex((definition, index) => {
      let refs = references(definition.expr)
      adjacency[index] =
        refs
        ->Array.filterMap(cell => findDefinitionIndex(definitions, cell))
        ->Array.toSorted((a, b) =>
          if a < b {
            -1.0
          } else if a > b {
            1.0
          } else {
            0.0
          }
        )
    })
    let cycle = Array.make(~length=count, false)
    let indices = Array.make(~length=count, -1)
    let lows = Array.make(~length=count, 0)
    let stack: ref<array<int>> = ref([])
    let onStack = Array.make(~length=count, false)
    let nextIndex = ref(0)
    let rec visit = node => {
      indices[node] = nextIndex.contents
      lows[node] = nextIndex.contents
      nextIndex := nextIndex.contents + 1
      stack := stack.contents->Array.concat([node])
      onStack[node] = true
      adjacency[node]
      ->Option.getOr([])
      ->Array.forEach(target => {
        if indices[target]->Option.getOr(-1) == -1 {
          visit(target)
          lows[node] = min(lows[node]->Option.getOr(0), lows[target]->Option.getOr(0))
        } else if onStack[target]->Option.getOr(false) {
          lows[node] = min(lows[node]->Option.getOr(0), indices[target]->Option.getOr(0))
        }
      })
      if lows[node]->Option.getOr(0) == indices[node]->Option.getOr(-1) {
        let component: ref<array<int>> = ref([])
        let done = ref(false)
        while !done.contents {
          switch stack.contents->Array.pop {
          | None => done := true
          | Some(member) =>
            onStack[member] = false
            component := component.contents->Array.concat([member])
            if member == node {
              done := true
            }
          }
        }
        let selfLoop =
          component.contents->Array.length == 1 &&
            adjacency[node]->Option.getOr([])->Array.includes(node)
        if component.contents->Array.length > 1 || selfLoop {
          component.contents->Array.forEach(member => cycle[member] = true)
        }
      }
    }
    integerRange(0, count)->Array.forEach(index =>
      if indices[index]->Option.getOr(-1) == -1 {
        visit(index)
      }
    )
    let memo: array<option<value>> = Array.make(~length=count, None)
    let rec evaluateCell = index =>
      switch memo[index]->Option.getOr(None) {
      | Some(value) => value
      | None =>
        let result = if cycle[index]->Option.getOr(false) {
          Cycle
        } else {
          let definition = switch definitions[index] {
          | Some(value) => value
          | None => {cell: {col: 1, row: 1}, expr: Parser.Number(0), line: 0}
          }
          evaluateExpr(definition.expr)
        }
        memo[index] = Some(result)
        result
      }
    and evaluateExpr = expr =>
      switch expr {
      | Parser.Number(number) => Number(number)
      | Parser.Reference(cell) =>
        switch findDefinitionIndex(definitions, cell) {
        | Some(index) => evaluateCell(index)
        | None => Number(0)
        }
      | Parser.Unary(_, value) =>
        switch evaluateExpr(value) {
        | Number(number) => exact(-number)
        | error => error
        }
      | Parser.Binary(operator, left, right) =>
        let leftValue = evaluateExpr(left)
        switch leftValue {
        | Number(a) =>
          switch evaluateExpr(right) {
          | Number(b) =>
            switch operator {
            | "+" => exactAdd(a, b)
            | "-" => exactSubtract(a, b)
            | "*" => exactMultiply(a, b)
            | "/" =>
              if b == 0 {
                Div
              } else {
                Number(a / b)
              }
            | "%" =>
              if b == 0 {
                Div
              } else {
                Number(a % b)
              }
            | "==" =>
              Number(
                if a == b {
                  1
                } else {
                  0
                },
              )
            | "!=" =>
              Number(
                if a != b {
                  1
                } else {
                  0
                },
              )
            | "<" =>
              Number(
                if a < b {
                  1
                } else {
                  0
                },
              )
            | ">" =>
              Number(
                if a > b {
                  1
                } else {
                  0
                },
              )
            | "<=" =>
              Number(
                if a <= b {
                  1
                } else {
                  0
                },
              )
            | ">=" =>
              Number(
                if a >= b {
                  1
                } else {
                  0
                },
              )
            | _ => Num
            }
          | error => error
          }
        | error => error
        }
      | Parser.Call("IF", args) =>
        let condition = switch args[0]->Option.getOr(Parser.Expression(Parser.Number(0))) {
        | Parser.Expression(value) => evaluateExpr(value)
        | _ => Number(0)
        }
        switch condition {
        | Number(value) =>
          let chosen = if value != 0 {
            args[1]->Option.getOr(Parser.Expression(Parser.Number(0)))
          } else {
            args[2]->Option.getOr(Parser.Expression(Parser.Number(0)))
          }
          switch chosen {
          | Parser.Expression(value) => evaluateExpr(value)
          | _ => Number(0)
          }
        | error => error
        }
      | Parser.Call("ABS", args) =>
        switch args[0]->Option.getOr(Parser.Expression(Parser.Number(0))) {
        | Parser.Expression(value) =>
          switch evaluateExpr(value) {
          | Number(number) => exact(abs(number))
          | error => error
          }
        | _ => Number(0)
        }
      | Parser.Call(name, args) =>
        let values: ref<array<value>> = ref([])
        let failed: ref<option<value>> = ref(None)
        args->Array.forEach(argument => {
          if Option.isNone(failed.contents) {
            let next = switch argument {
            | Parser.Expression(value) => [evaluateExpr(value)]
            | Parser.Range(first, last) =>
              let rows = integerRange(min(first.row, last.row), max(first.row, last.row) + 1)
              let cols = integerRange(min(first.col, last.col), max(first.col, last.col) + 1)
              rows->Array.flatMap(row =>
                cols->Array.filterMap(
                  col =>
                    switch findDefinitionIndex(definitions, {row, col}) {
                    | Some(index) => Some(evaluateCell(index))
                    | None => None
                    },
                )
              )
            }
            next->Array.forEach(value =>
              switch value {
              | Number(_) => values := values.contents->Array.concat([value])
              | error =>
                if Option.isNone(failed.contents) {
                  failed := Some(error)
                }
              }
            )
          }
        })
        switch failed.contents {
        | Some(error) => error
        | None =>
          let nums = values.contents->Array.map(value =>
            switch value {
            | Number(n) => n
            | _ => 0
            }
          )
          if name == "COUNT" {
            exact(nums->Array.length)
          } else if name == "SUM" {
            let total =
              nums->Array.reduce(0n, (sum, value) => BigInt.add(sum, BigInt.fromInt(value)))
            if total < BigInt.fromInt(-bound) || total > BigInt.fromInt(bound) {
              Num
            } else {
              Number(BigInt.toInt(total))
            }
          } else if nums->Array.length == 0 {
            Number(0)
          } else if name == "MIN" {
            Number(nums->Array.reduce(nums[0]->Option.getOr(0), min))
          } else {
            Number(nums->Array.reduce(nums[0]->Option.getOr(0), max))
          }
        }
      }
    let selected = invocation.options->Array.findMap(((option, value)) =>
      if option == "--cell" {
        Cell.parse(value)
      } else {
        None
      }
    )
    switch selected {
    | Some(cell) =>
      switch findDefinitionIndex(definitions, cell) {
      | None => Types.fail(1, "cell " ++ key(cell) ++ " is not defined")
      | Some(index) => Ok(render(evaluateCell(index)) ++ "\n")
      }
    | None =>
      Cell.sorted(definitions->Array.map(definition => definition.cell))
      ->Array.map(cell => {
        let index = findDefinitionIndex(definitions, cell)->Option.getOr(0)
        key(cell) ++ " = " ++ render(evaluateCell(index)) ++ "\n"
      })
      ->Array.join("")
      ->Ok
    }
  }
