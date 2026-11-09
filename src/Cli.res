let failure = (message: string): Types.outcome => {
  exit: 2,
  out: "",
  err: "cellspan: " ++ message ++ "\n",
}

let dispatch = (
  command: Types.command,
  options: array<(string, string)>,
  args: array<string>,
  input: string,
): Types.outcome => {
  let invocation: Types.invocation = {options, args, input}
  switch command.run(invocation) {
  | Ok(text) => {exit: 0, out: text, err: ""}
  | Error(error) => {
      exit: error.code,
      out: "",
      err: "cellspan: " ++ error.message ++ "\n",
    }
  }
}

let run = (args: array<string>, input: string): Types.outcome => {
  switch args[0] {
  | None => {
      exit: 2,
      out: "",
      err: Registry.usage,
    }
  | Some("help" | "-h" | "--help") => {
      exit: 0,
      out: Registry.usage,
      err: "",
    }
  | Some("--version") => {exit: 0, out: "cellspan 0.1.0\n", err: ""}
  | Some(name) =>
    switch Registry.commands->Array.find(command => command.name == name) {
    | None => failure("unknown command " ++ name)
    | Some(command) => {
        let words = args->Array.slice(~start=1)
        let rec scan = (
          index,
          options: array<(string, string)>,
          positionals: array<string>,
        ): result<(array<(string, string)>, array<string>), string> =>
          switch words[index] {
          | None => Ok((options, positionals))
          | Some(word) if word->String.startsWith("-") && word->String.length > 1 =>
            switch command.option {
            | Some(allowed) if word == allowed =>
              if options->Array.some(((option, _value)) => option == word) {
                Error(word ++ " given twice")
              } else {
                switch words[index + 1] {
                | None => Error(word ++ " needs a cell reference")
                | Some(value) if value == "" => Error(word ++ " needs a cell reference")
                | Some(value) =>
                  scan(index + 2, options->Array.concat([(word, value)]), positionals)
                }
              }
            | _ => Error("unknown option " ++ word)
            }
          | Some(word) =>
            if positionals->Array.length >= command.positional {
              Error("unexpected argument " ++ word)
            } else {
              scan(index + 1, options, positionals->Array.concat([word]))
            }
          }
        switch scan(0, [], []) {
        | Error(message) => failure(message)
        | Ok((options, positionals)) =>
          if positionals->Array.length < command.positional {
            failure(command.name ++ " needs " ++ command.needs)
          } else {
            let reference = switch command.option {
            | Some(option) =>
              options->Array.findMap(((name, value)) =>
                if name == option {
                  Some(value)
                } else {
                  None
                }
              )
            | None =>
              if command.needs == "REF" {
                positionals[0]
              } else {
                None
              }
            }
            switch reference {
            | Some(value) if !Cell.isRef(value) => failure("bad cell reference " ++ value)
            | _ => dispatch(command, options, positionals, input)
            }
          }
        }
      }
    }
  }
}
