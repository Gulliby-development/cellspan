let precedence = operator =>
  if (
    operator == "==" ||
    operator == "!=" ||
    operator == "<=" ||
    operator == ">=" ||
    operator == "<" ||
    operator == ">"
  ) {
    1
  } else if operator == "+" || operator == "-" {
    2
  } else {
    3
  }

let normalizedRange = (first: Cell.t, second: Cell.t): string => {
  let top = if first.row < second.row {
    first.row
  } else {
    second.row
  }
  let left = if first.col < second.col {
    first.col
  } else {
    second.col
  }
  let bottom = if first.row > second.row {
    first.row
  } else {
    second.row
  }
  let right = if first.col > second.col {
    first.col
  } else {
    second.col
  }
  Cell.show({col: left, row: top}) ++ ":" ++ Cell.show({col: right, row: bottom})
}

let rec render = (expression: Parser.expr, parentPrecedence: int, isRight: bool): string => {
  let rendered = switch expression {
  | Parser.Number(value) => Int.toString(value)
  | Parser.Reference(cell) => Cell.show(cell)
  | Parser.Unary("-", operand) => "-" ++ render(operand, 4, false)
  | Parser.Unary(operator, operand) => operator ++ render(operand, 4, false)
  | Parser.Binary(operator, left, right) =>
    let ownPrecedence = precedence(operator)
    render(left, ownPrecedence, false) ++
    " " ++
    operator ++
    " " ++
    render(right, ownPrecedence, true)
  | Parser.Call(name, arguments) =>
    name ++ "(" ++ arguments->Array.map(renderArgument)->Array.join(", ") ++ ")"
  }
  switch expression {
  | Parser.Binary(operator, _, _) =>
    let ownPrecedence = precedence(operator)
    if ownPrecedence < parentPrecedence || (isRight && ownPrecedence == parentPrecedence) {
      "(" ++ rendered ++ ")"
    } else {
      rendered
    }
  | _ => rendered
  }
}
and renderArgument = argument =>
  switch argument {
  | Parser.Expression(expression) => render(expression, 0, false)
  | Parser.Range(first, second) => normalizedRange(first, second)
  }

let run = (invocation: Types.invocation): result<string, Types.failure> =>
  switch Sheet.parse(invocation.input) {
  | Error(problem) => Error(problem)
  | Ok(sheet) =>
    Ok(
      sheet.definitions
      ->Array.map(definition =>
        Cell.show(definition.cell) ++ " = " ++ render(definition.expr, 0, false) ++ "\n"
      )
      ->Array.join(""),
    )
  }
