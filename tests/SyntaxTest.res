let rows = [
  Harness.row(["fmt"], "A1 = 1 $ 2\n", 1, "", "cellspan: line 1: unexpected character $\n"),
  Harness.row(["fmt"], "A1 = 1 = 2\n", 1, "", "cellspan: line 1: unexpected character =\n"),
  Harness.row(["fmt"], "A1 = 123456789\n", 0, "A1 = 123456789\n", ""),
  Harness.row(["fmt"], "A1 = 1234567890\n", 1, "", "cellspan: line 1: number too large: 1234567890\n"),
  Harness.row(["fmt"], "A1 = 1 +\n", 1, "", "cellspan: line 1: unexpected end of expression\n"),
  Harness.row(["fmt"], "A1 =\n", 1, "", "cellspan: line 1: unexpected end of expression\n"),
  Harness.row(["fmt"], "A1 = * 2\n", 1, "", "cellspan: line 1: unexpected *\n"),
  Harness.row(["fmt"], "A1 = (1\n", 1, "", "cellspan: line 1: unexpected end of expression\n"),
  Harness.row(["fmt"], "A1 = 1)\n", 1, "", "cellspan: line 1: unexpected )\n"),
  Harness.row(["fmt"], "B1 = 5\nA1 = B1 B1\n", 1, "", "cellspan: line 2: unexpected B1\n"),
  Harness.row(["fmt"], "A1 = 7x\n", 1, "", "cellspan: line 1: unexpected x\n"),
  Harness.row(["fmt"], "A1 = 1 +\u00e9\n", 1, "", "cellspan: line 1: unexpected character \u00e9\n"),
]

Harness.run(rows)
