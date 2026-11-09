let rows = [
  Harness.row(["eval"], "C2 = 3\nA2 = 2\nB1 = 5\nA1 = 1\nZ1 = 26\n", 0, "A1 = 1\nB1 = 5\nZ1 = 26\nA2 = 2\nC2 = 3\n", ""),
  Harness.row(["eval", "--cell", "B2"], "A1 = 1\nB2 = 2 * 21\n", 0, "42\n", ""),
  Harness.row(["eval", "--cell", "A1"], "A1 = 7 / 0\n", 0, "#DIV\n", ""),
  Harness.row(["eval", "--cell", "C3"], "A1 = 1\n", 1, "", "cellspan: cell C3 is not defined\n"),
  Harness.row(["eval"], "", 0, "", ""),
  Harness.row(["eval"], "A1 = B1 + C1\n", 0, "A1 = 0\n", ""),
  Harness.row(["eval", "--cell", "A1"], "A1 = B7\nB7 = 4\n", 0, "4\n", ""),
  Harness.row(["eval", "--cell", "B1"], "A1 = B1\nB1 = A1\n", 0, "#CYCLE\n", ""),
]

Harness.run(rows)
