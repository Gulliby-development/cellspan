type t = {col: int, row: int}

let letters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"

let parseRow = (text: string): option<int> => {
  let length = text->String.length
  let first = text->String.slice(~start=0, ~end=1)
  let second = text->String.slice(~start=1)
  let digits = "0123456789"
  let hasOnlyDigits =
    length > 0 &&
    digits->String.indexOf(first) >= 0 &&
    (length == 1 || digits->String.indexOf(second) >= 0)
  if !hasOnlyDigits || length > 2 || (length > 1 && first == "0") {
    None
  } else {
    let value = Int.fromString(text)
    switch value {
    | Some(row) if row >= 1 && row <= 99 => Some(row)
    | _ => None
    }
  }
}

let parse = (text: string): option<t> => {
  if text->String.length < 2 {
    None
  } else {
    let first = text->String.slice(~start=0, ~end=1)
    let colIndex = letters->String.indexOf(first)
    let rowText = text->String.slice(~start=1)
    switch (colIndex, parseRow(rowText)) {
    | (col, Some(row)) if col >= 0 => Some({col: col + 1, row})
    | _ => None
    }
  }
}

let isRef = (text: string): bool => parse(text)->Option.isSome

let show = (cell: t): string =>
  letters->String.slice(~start=cell.col - 1, ~end=cell.col) ++ Int.toString(cell.row)

let compare = (left: t, right: t): int =>
  if left.row < right.row {
    -1
  } else if left.row > right.row {
    1
  } else if left.col < right.col {
    -1
  } else if left.col > right.col {
    1
  } else {
    0
  }

let sorted = (cells: array<t>): array<t> =>
  cells->Array.toSorted((left, right) =>
    switch compare(left, right) {
    | value if value < 0 => -1.0
    | value if value > 0 => 1.0
    | _ => 0.0
    }
  )
