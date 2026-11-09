let rows = [
  Harness.row([], "", 2, "", "usage: cellspan eval [--cell REF]\n       cellspan deps REF\n       cellspan order\n       cellspan cycles\n       cellspan fmt\n"),
  Harness.row(["help"], "", 0, "usage: cellspan eval [--cell REF]\n       cellspan deps REF\n       cellspan order\n       cellspan cycles\n       cellspan fmt\n", ""),
  Harness.row(["-h", "eval", "--bogus"], "", 0, "usage: cellspan eval [--cell REF]\n       cellspan deps REF\n       cellspan order\n       cellspan cycles\n       cellspan fmt\n", ""),
  Harness.row(["--help"], "", 0, "usage: cellspan eval [--cell REF]\n       cellspan deps REF\n       cellspan order\n       cellspan cycles\n       cellspan fmt\n", ""),
  Harness.row(["--version"], "", 0, "cellspan 0.1.0\n", ""),
  Harness.row(["--version", "x"], "", 0, "cellspan 0.1.0\n", ""),
  Harness.row(["frob"], "", 2, "", "cellspan: unknown command frob\n"),
  Harness.row([""], "", 2, "", "cellspan: unknown command \n"),
]

Harness.run(rows)
