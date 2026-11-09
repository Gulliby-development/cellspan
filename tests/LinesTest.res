let rows = [
  Harness.row(["fmt"], "A1 = 1\nB1 = 2\n", 0, "A1 = 1\nB1 = 2\n", ""),
  Harness.row(["fmt"], "A1 = 1\r\nB1 = 2\r\n", 0, "A1 = 1\nB1 = 2\n", ""),
  Harness.row(["fmt"], "A1 = 1\nB1 = 2", 0, "A1 = 1\nB1 = 2\n", ""),
  Harness.row(["fmt"], "# a comment\n\n  # indented comment\n\t\nA1 = 1\n", 0, "A1 = 1\n", ""),
  Harness.row(["fmt"], "  A1\t=\t7  \n", 0, "A1 = 7\n", ""),
  Harness.row(["fmt"], "A1=1\nB1=A1\n", 0, "A1 = 1\nB1 = A1\n", ""),
  Harness.row(["fmt"], "a1 = 1\n", 1, "", "cellspan: line 1: expected CELL = EXPRESSION\n"),
  Harness.row(["fmt"], "A1 2\n", 1, "", "cellspan: line 1: expected CELL = EXPRESSION\n"),
  Harness.row(["fmt"], "A0 = 1\n", 1, "", "cellspan: line 1: expected CELL = EXPRESSION\n"),
  Harness.row(["fmt"], "A1 = 1\n\n# c\n= 3\n", 1, "", "cellspan: line 4: expected CELL = EXPRESSION\n"),
  Harness.row(["fmt"], "A1 = 1\nB1 = 2\nA1 = 3\n", 1, "", "cellspan: line 3: cell A1 defined twice (first on line 1)\n"),
  Harness.row(["fmt"], "# x\nC3 = 1\n\nC3 = 2\n", 1, "", "cellspan: line 4: cell C3 defined twice (first on line 2)\n"),
]

Harness.run(rows)
