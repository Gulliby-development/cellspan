type kind = Number | Word | Symbol | End

type token = {kind: kind, text: string}

type t = {
  input: string,
  mutable cursor: int,
  mutable cached: option<token>,
}

@send external charCodeAt: (string, int) => int = "charCodeAt"
@send external codePointAt: (string, int) => int = "codePointAt"
@send external slice: (string, int, int) => string = "slice"

let make = input => {input, cursor: 0, cached: None}

let isDigit = code => code >= 48 && code <= 57
let isLetter = code => (code >= 65 && code <= 90) || (code >= 97 && code <= 122)
let isSpace = code => code == 32 || code == 9

let stop = message => raise(Types.Stop({code: 1, message}))

let scan = state => {
  let length = state.input->String.length
  while state.cursor < length && isSpace(charCodeAt(state.input, state.cursor)) {
    state.cursor = state.cursor + 1
  }

  if state.cursor >= length {
    {kind: End, text: ""}
  } else {
    let start = state.cursor
    let code = charCodeAt(state.input, state.cursor)
    if isDigit(code) {
      while state.cursor < length && isDigit(charCodeAt(state.input, state.cursor)) {
        state.cursor = state.cursor + 1
      }
      let text = slice(state.input, start, state.cursor)
      if state.cursor - start > 9 {
        stop("number too large: " ++ text)
      }
      {kind: Number, text}
    } else if isLetter(code) {
      while state.cursor < length && isLetter(charCodeAt(state.input, state.cursor)) {
        state.cursor = state.cursor + 1
      }
      while state.cursor < length && isDigit(charCodeAt(state.input, state.cursor)) {
        state.cursor = state.cursor + 1
      }
      {kind: Word, text: slice(state.input, start, state.cursor)}
    } else {
      let pair = slice(state.input, start, start + 2)
      let symbol = if pair == "==" || pair == "!=" || pair == "<=" || pair == ">=" {
        state.cursor = state.cursor + 2
        pair
      } else if (
        code == 43 ||
        code == 45 ||
        code == 42 ||
        code == 47 ||
        code == 37 ||
        code == 40 ||
        code == 41 ||
        code == 44 ||
        code == 58 ||
        code == 60 ||
        code == 62
      ) {
        state.cursor = state.cursor + 1
        slice(state.input, start, state.cursor)
      } else {
        let width = if codePointAt(state.input, state.cursor) > 65535 {
          2
        } else {
          1
        }
        state.cursor = state.cursor + width
        stop("unexpected character " ++ slice(state.input, start, start + width))
      }

      {kind: Symbol, text: symbol}
    }
  }
}

let peek = state =>
  switch state.cached {
  | Some(token) => token
  | None =>
    let token = scan(state)
    state.cached = Some(token)
    token
  }

let next = state => {
  let token = peek(state)
  switch token.kind {
  | End => ()
  | _ => state.cached = None
  }
  token
}
