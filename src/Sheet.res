type definition = {cell: Cell.t, expr: Parser.expr, line: int}
type t = {definitions: array<definition>, byCell: Js.Dict.t<definition>}

let isBlank = (char: string): bool => char == " " || char == "\t"

let trimBlanks = (text: string): string => {
  let length = text->String.length
  let rec startAt = index =>
    if index < length && isBlank(text->String.slice(~start=index, ~end=index + 1)) {
      startAt(index + 1)
    } else {
      index
    }
  let rec endAt = index =>
    if index > 0 && isBlank(text->String.slice(~start=index - 1, ~end=index)) {
      endAt(index - 1)
    } else {
      index
    }
  let start = startAt(0)
  let finish = endAt(length)
  text->String.slice(~start, ~end=finish)
}

let dropCr = (text: string): string => {
  let length = text->String.length
  if length > 0 && text->String.slice(~start=length - 1) == "\r" {
    text->String.slice(~start=0, ~end=length - 1)
  } else {
    text
  }
}

let physicalLines = (input: string): array<string> => {
  let length = input->String.length
  let rec collect = (index: int, start: int, acc: array<string>): array<string> =>
    if index == length {
      if start < length {
        acc->Array.concat([dropCr(input->String.slice(~start))])
      } else {
        acc
      }
    } else if input->String.slice(~start=index, ~end=index + 1) == "\n" {
      let line = dropCr(input->String.slice(~start, ~end=index))
      collect(index + 1, index + 1, acc->Array.concat([line]))
    } else {
      collect(index + 1, start, acc)
    }
  collect(0, 0, [])
}

let parseDefinition = (line: string): option<(Cell.t, string)> => {
  let length = line->String.length
  let rec findEquals = index =>
    if index < length {
      let char = line->String.slice(~start=index, ~end=index + 1)
      if char == "=" {
        Some(index)
      } else {
        findEquals(index + 1)
      }
    } else {
      None
    }
  switch findEquals(0) {
  | None => None
  | Some(index) =>
    let reference = trimBlanks(line->String.slice(~start=0, ~end=index))
    switch Cell.parse(reference) {
    | None => None
    | Some(cell) => Some((cell, trimBlanks(line->String.slice(~start=index + 1))))
    }
  }
}

let parse = (input: string): result<t, Types.failure> => {
  let lines = physicalLines(input)
  let definitions: ref<array<definition>> = ref([])
  let byCell: Js.Dict.t<definition> = Js.Dict.empty()
  let firstLines: Js.Dict.t<int> = Js.Dict.empty()
  let failure: ref<option<Types.failure>> = ref(None)
  lines->Array.forEachWithIndex((line, index) => {
    if Option.isNone(failure.contents) {
      let number = index + 1
      let content = trimBlanks(line)
      if content != "" && content->String.slice(~start=0, ~end=1) != "#" {
        switch parseDefinition(line) {
        | None =>
          failure :=
            Some({
              code: 1,
              message: "line " ++ Int.toString(number) ++ ": expected CELL = EXPRESSION",
            })
        | Some((cell, expression)) =>
          try {
            let expr = Parser.parse(expression)
            let key = Cell.show(cell)
            switch Js.Dict.get(firstLines, key) {
            | Some(firstLine) =>
              failure :=
                Some({
                  code: 1,
                  message: "line " ++
                  Int.toString(number) ++
                  ": cell " ++
                  key ++
                  " defined twice (first on line " ++
                  Int.toString(firstLine) ++ ")",
                })
            | None =>
              let definition = {cell, expr, line: number}
              definitions := definitions.contents->Array.concat([definition])
              Js.Dict.set(byCell, key, definition)
              Js.Dict.set(firstLines, key, number)
            }
          } catch {
          | Types.Stop(problem) =>
            failure :=
              Some({
                code: problem.code,
                message: "line " ++ Int.toString(number) ++ ": " ++ problem.message,
              })
          }
        }
      }
    }
  })
  switch failure.contents {
  | Some(problem) => Error(problem)
  | None => Ok({definitions: definitions.contents, byCell})
  }
}
