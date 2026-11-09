// cellspan: the test helper. A row is Harness.row(ARGS, STDIN, EXIT, OUT, ERR): the command line words, the standard input,
// the exit status, the standard output and the standard error the program gives for them, through Cli.run.
@module("vitest") external test: (string, unit => unit) => unit = "test"
@module("vitest") external expect: 'a => {"toEqual": 'b => unit} = "expect"

type row = {args: array<string>, stdin: string, exit: int, out: string, err: string}

let row = (args: array<string>, stdin: string, exit: int, out: string, err: string): row => {
  args,
  stdin,
  exit,
  out,
  err,
}

let show = (text: string) =>
  text
  ->String.replaceAll("\\", "\\\\")
  ->String.replaceAll("\n", "\\n")
  ->String.replaceAll("\t", "\\t")

let check = (row: row, index: int): option<string> => {
  let actual = Cli.run(row.args, row.stdin)
  if actual.exit == row.exit && actual.out == row.out && actual.err == row.err {
    None
  } else {
    Some(
      "row " ++
      Int.toString(index + 1) ++
      " [" ++
      row.args->Array.join(" ") ++
      "] stdin [" ++
      show(row.stdin) ++
      "] gave exit " ++
      Int.toString(actual.exit) ++
      " out [" ++
      show(actual.out) ++
      "] err [" ++
      show(actual.err) ++ "]",
    )
  }
}

let run = (rows: array<row>) =>
  test("rows", () => {
    let failures = rows->Array.mapWithIndex(check)->Array.filterMap(failure => failure)
    expect(failures)["toEqual"]([])
  })
