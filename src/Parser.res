type rec expr =
  | Number(int)
  | Reference(Cell.t)
  | Unary(string, expr)
  | Binary(string, expr, expr)
  | Call(string, array<argument>)
and argument =
  | Expression(expr)
  | Range(Cell.t, Cell.t)

let fail = message => raise(Types.Stop({code: 1, message}))

let parse = (text: string): expr => {
  let lexer = Lexer.make(text)

  let peek = () => Lexer.peek(lexer)
  let take = () => Lexer.next(lexer)
  let unexpected = (token: Lexer.token) =>
    if token.kind == Lexer.End {
      fail("unexpected end of expression")
    } else {
      fail("unexpected " ++ token.text)
    }
  let expectSymbol = expected => {
    let token = peek()
    if token.kind == Lexer.Symbol && token.text == expected {
      ignore(take())
    } else {
      unexpected(token)
    }
  }

  let rec parseCompare = (seed: option<expr>): expr => {
    let left = parseSum(seed)
    parseChain(left, ["==", "!=", "<=", ">=", "<", ">"], parseSum)
  }
  and parseSum = (seed: option<expr>): expr => {
    let left = parseProduct(seed)
    parseChain(left, ["+", "-"], parseProduct)
  }
  and parseProduct = (seed: option<expr>): expr => {
    let left = switch seed {
    | Some(value) => value
    | None => parseUnary()
    }
    parseChain(left, ["*", "/", "%"], _ => parseUnary())
  }
  and parseChain = (
    left: expr,
    operators: array<string>,
    parseRight: option<expr> => expr,
  ): expr => {
    let token = peek()
    if token.kind == Lexer.Symbol && operators->Array.includes(token.text) {
      ignore(take())
      let right = parseRight(None)
      parseChain(Binary(token.text, left, right), operators, parseRight)
    } else {
      left
    }
  }
  and parseUnary = (): expr => {
    let token = peek()
    if token.kind == Lexer.Symbol && token.text == "-" {
      ignore(take())
      Unary("-", parseUnary())
    } else {
      parsePrimary()
    }
  }
  and parsePrimary = (): expr => {
    let token = take()
    switch token.kind {
    | Lexer.Number => Number(Int.fromString(token.text)->Option.getOr(0))
    | Lexer.Word =>
      let following = peek()
      if following.kind == Lexer.Symbol && following.text == "(" {
        parseCall(token.text)
      } else {
        switch Cell.parse(token.text) {
        | Some(cell) => Reference(cell)
        | None => fail("bad cell reference " ++ token.text)
        }
      }
    | Lexer.Symbol if token.text == "(" =>
      let value = parseCompare(None)
      expectSymbol(")")
      value
    | _ => unexpected(token)
    }
  }
  and parseCall = (name: string): expr => {
    if (
      name != "SUM" &&
      name != "MIN" &&
      name != "MAX" &&
      name != "COUNT" &&
      name != "ABS" &&
      name != "IF"
    ) {
      fail("unknown function " ++ name)
    }
    expectSymbol("(")
    let rangesAllowed = name == "SUM" || name == "MIN" || name == "MAX" || name == "COUNT"
    let args = if peek().kind == Lexer.Symbol && peek().text == ")" {
      ignore(take())
      []
    } else {
      parseArguments(rangesAllowed, [])
    }
    let count = args->Array.length
    if (name == "SUM" || name == "MIN" || name == "MAX" || name == "COUNT") && count == 0 {
      fail(name ++ " takes at least 1 argument")
    }
    if name == "ABS" && count != 1 {
      fail("ABS takes 1 argument")
    }
    if name == "IF" && count != 3 {
      fail("IF takes 3 arguments")
    }
    Call(name, args)
  }
  and parseArguments = (rangesAllowed: bool, acc: array<argument>): array<argument> => {
    let arg = parseArgument(rangesAllowed)
    let next = peek()
    if next.kind == Lexer.Symbol && next.text == "," {
      ignore(take())
      parseArguments(rangesAllowed, acc->Array.concat([arg]))
    } else if next.kind == Lexer.Symbol && next.text == ")" {
      ignore(take())
      acc->Array.concat([arg])
    } else {
      unexpected(next)
    }
  }
  and parseArgument = (rangesAllowed: bool): argument => {
    let start = peek()
    if start.kind == Lexer.Word {
      switch Cell.parse(start.text) {
      | Some(first) =>
        ignore(take())
        let after = peek()
        if after.kind == Lexer.Symbol && after.text == "(" {
          Expression(parseCall(start.text))
        } else if after.kind == Lexer.Symbol && after.text == ":" {
          if !rangesAllowed {
            fail("unexpected :")
          }
          ignore(take())
          let endpoint = take()
          let second = if endpoint.kind == Lexer.Word {
            Cell.parse(endpoint.text)
          } else {
            None
          }
          switch second {
          | None =>
            if (
              endpoint.kind == Lexer.End ||
              endpoint.kind == Lexer.Symbol ||
              endpoint.kind == Lexer.Number
            ) {
              fail("bad range")
            } else {
              fail("bad range")
            }
          | Some(last) =>
            let delimiter = peek()
            if delimiter.kind == Lexer.Symbol && (delimiter.text == "," || delimiter.text == ")") {
              Range(first, last)
            } else {
              unexpected(delimiter)
            }
          }
        } else {
          Expression(parseCompare(Some(Reference(first))))
        }
      | None => Expression(parseCompare(None))
      }
    } else {
      Expression(parseCompare(None))
    }
  }

  let result = parseCompare(None)
  let final = peek()
  if final.kind != Lexer.End {
    unexpected(final)
  }
  result
}
