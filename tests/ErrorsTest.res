let rows = [
  Harness.row(["eval"], "A1 = 1 / 0\n", 0, "A1 = #DIV\n", ""),
  Harness.row(["eval"], "A1 = 1 / 0\nB1 = A1 + 1\nC1 = -B1\n", 0, "A1 = #DIV\nB1 = #DIV\nC1 = #DIV\n", ""),
  Harness.row(["eval"], "A1 = 999999999 + 1\n", 0, "A1 = #NUM\n", ""),
  Harness.row(["eval"], "A1 = 31623 * 31623\n", 0, "A1 = #NUM\n", ""),
  Harness.row(["eval"], "A1 = SUM(999999999, 999999999, 999999999, 999999999, 999999999)\n", 0, "A1 = #NUM\n", ""),
  Harness.row(["eval"], "A1 = SUM(999999999, 5, -999999999)\n", 0, "A1 = 5\n", ""),
  Harness.row(["eval"], "A1 = (999999999 + 1) + (1 / 0)\n", 0, "A1 = #NUM\n", ""),
  Harness.row(["eval"], "A1 = 100000 * 10000\nB1 = A1 + 1\nC1 = A1 / 0\n", 0, "A1 = #NUM\nB1 = #NUM\nC1 = #NUM\n", ""),
  Harness.row(["eval"], "A1 = 46341 * 46341\n", 0, "A1 = #NUM\n", ""),
  Harness.row(["eval"], "A1 = MAX(B1:B2, 1 / 0)\nB1 = 999999999 * 2\nB2 = 1\n", 0, "A1 = #NUM\nB1 = #NUM\nB2 = 1\n", ""),
  Harness.row(["eval"], "A1 = B1\nB1 = A1\nC1 = A1 + 1\nD1 = 5\n", 0, "A1 = #CYCLE\nB1 = #CYCLE\nC1 = #CYCLE\nD1 = 5\n", ""),
  Harness.row(["eval"], "A1 = 1 / 0\nB1 = C1\nC1 = B1 + A1\n", 0, "A1 = #DIV\nB1 = #CYCLE\nC1 = #CYCLE\n", ""),
  Harness.row(["eval"], "A1 = IF(1, 5, A1)\nB1 = A1\n", 0, "A1 = #CYCLE\nB1 = #CYCLE\n", ""),
  Harness.row(["eval"], "A1 = B1 + 1 / 0\nB1 = A1\n", 0, "A1 = #CYCLE\nB1 = #CYCLE\n", ""),
]

Harness.run(rows)
