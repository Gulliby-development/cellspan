let rows = [
  Harness.row(["eval"], "A1 = 1\nB1 = 2\nA2 = 3\nB2 = 4\nC1 = SUM(A1:B2)\n", 0, "A1 = 1\nB1 = 2\nC1 = 10\nA2 = 3\nB2 = 4\n", ""),
  Harness.row(["eval"], "A1 = 1\nB1 = 2\nA2 = 3\nB2 = 4\nC1 = SUM(B2:A1)\n", 0, "A1 = 1\nB1 = 2\nC1 = 10\nA2 = 3\nB2 = 4\n", ""),
  Harness.row(["eval"], "A1 = 5\nA2 = 9\nA3 = 2\nB1 = MIN(A1:A3)\nB2 = MAX(A1:A3)\n", 0, "A1 = 5\nB1 = 2\nA2 = 9\nB2 = 9\nA3 = 2\n", ""),
  Harness.row(["eval"], "A1 = 5\nB1 = SUM(A1:A9)\n", 0, "A1 = 5\nB1 = 5\n", ""),
  Harness.row(["eval"], "A1 = SUM(C5:D6)\nB1 = MIN(C5:D6)\nC1 = MAX(C5:D6)\n", 0, "A1 = 0\nB1 = 0\nC1 = 0\n", ""),
  Harness.row(["eval"], "A1 = COUNT(B1:B5)\nB2 = 0\nB4 = 7\n", 0, "A1 = 2\nB2 = 0\nB4 = 7\n", ""),
  Harness.row(["eval"], "B1 = 4\nC1 = 6\nA1 = COUNT(B1:C1, 5, 2 + 2)\n", 0, "A1 = 4\nB1 = 4\nC1 = 6\n", ""),
  Harness.row(["eval"], "A1 = SUM(5, B1:B2, 10)\nB1 = 100\nB2 = 1000\n", 0, "A1 = 1115\nB1 = 100\nB2 = 1000\n", ""),
  Harness.row(["eval"], "A1 = MAX(-3, -8)\nB1 = MIN(-3, -8, 4)\n", 0, "A1 = -3\nB1 = -8\n", ""),
  Harness.row(["eval"], "A1 = SUM(B1:B2)\nB1 = 6 / 0\nB2 = 3\n", 0, "A1 = #DIV\nB1 = #DIV\nB2 = 3\n", ""),
]

Harness.run(rows)
