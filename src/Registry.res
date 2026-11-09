// cellspan: the usage text and the command table.
let usage = "usage: cellspan eval [--cell REF]\n       cellspan deps REF\n       cellspan order\n       cellspan cycles\n       cellspan fmt\n"

let commands: array<Types.command> = [
  {name: "eval", option: Some("--cell"), positional: 0, needs: "", run: Evaluate.run},
  {name: "deps", option: None, positional: 1, needs: "REF", run: Graph.deps},
  {name: "order", option: None, positional: 0, needs: "", run: Graph.order},
  {name: "cycles", option: None, positional: 0, needs: "", run: Graph.cycles},
  {name: "fmt", option: None, positional: 0, needs: "", run: Printer.run},
]

// True when the first word is a command: only then does the program read standard input.
let readsStdin = (args: array<string>) =>
  switch args[0] {
  | Some(word) => commands->Array.some(c => c.name == word)
  | None => false
  }
