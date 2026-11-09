// cellspan: the program entry point. Standard input is read only when the first word is a command.
type process

@val external process: process = "process"
@get external argv: process => array<string> = "argv"
@set external setExitCode: (process, int) => unit = "exitCode"
@val @scope(("process", "stdout")) external writeOut: string => unit = "write"
@val @scope(("process", "stderr")) external writeErr: string => unit = "write"
@module("node:fs") external readFileSync: (int, string) => string = "readFileSync"

let args = process->argv->Array.slice(~start=2)

let input = if Registry.readsStdin(args) {
  try readFileSync(0, "utf8") catch {
  | _ => ""
  }
} else {
  ""
}

let outcome = Cli.run(args, input)

if outcome.out != "" {
  writeOut(outcome.out)
}

if outcome.err != "" {
  writeErr(outcome.err)
}

process->setExitCode(outcome.exit)
