let rows = [
  Harness.row(["eval", "-x"], "", 2, "", "cellspan: unknown option -x\n"),
  Harness.row(["eval", "--Cell", "A1"], "", 2, "", "cellspan: unknown option --Cell\n"),
  Harness.row(["eval", "--cell", "A1", "--cell", "B2"], "", 2, "", "cellspan: --cell given twice\n"),
  Harness.row(["eval", "--cell"], "", 2, "", "cellspan: --cell needs a cell reference\n"),
  Harness.row(["eval", "--cell", ""], "", 2, "", "cellspan: --cell needs a cell reference\n"),
  Harness.row(["eval", "--cell", "a1"], "", 2, "", "cellspan: bad cell reference a1\n"),
  Harness.row(["eval", "--cell", "A0"], "", 2, "", "cellspan: bad cell reference A0\n"),
  Harness.row(["eval", "--cell", "--cell"], "", 2, "", "cellspan: bad cell reference --cell\n"),
  Harness.row(["eval", "extra"], "", 2, "", "cellspan: unexpected argument extra\n"),
  Harness.row(["eval", "-"], "", 2, "", "cellspan: unexpected argument -\n"),
  Harness.row(["deps"], "", 2, "", "cellspan: deps needs REF\n"),
  Harness.row(["deps", "A1", "B1"], "", 2, "", "cellspan: unexpected argument B1\n"),
  Harness.row(["deps", "a1"], "", 2, "", "cellspan: bad cell reference a1\n"),
]

Harness.run(rows)
