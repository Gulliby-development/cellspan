let rows = [
  Harness.row(["eval"], "A1 = 3 < 4\nB1 = 4 < 3\nC1 = 3 == 3\nD1 = 3 != 3\n", 0, "A1 = 1\nB1 = 0\nC1 = 1\nD1 = 0\n", ""),
  Harness.row(["eval"], "A1 = 4 <= 4\nB1 = 5 >= 6\n", 0, "A1 = 1\nB1 = 0\n", ""),
  Harness.row(["eval"], "A1 = 1 < 2 < 3\nB1 = 3 > 2 > 1\n", 0, "A1 = 1\nB1 = 0\n", ""),
  Harness.row(["eval"], "A1 = IF(1, 10, 20)\nB1 = IF(0, 10, 20)\nC1 = IF(-5, 10, 20)\n", 0, "A1 = 10\nB1 = 20\nC1 = 10\n", ""),
  Harness.row(["eval"], "A1 = IF(1, 7, 1 / 0)\n", 0, "A1 = 7\n", ""),
  Harness.row(["eval"], "A1 = IF(0, 1 / 0, 8)\n", 0, "A1 = 8\n", ""),
  Harness.row(["eval"], "A1 = IF(1 / 0, 1, 2)\n", 0, "A1 = #DIV\n", ""),
  Harness.row(["eval"], "A1 = ABS(-9)\nB1 = ABS(9)\nC1 = ABS(0 - 12 / 4)\n", 0, "A1 = 9\nB1 = 9\nC1 = 3\n", ""),
  Harness.row(["eval"], "A1 = IF(IF(0, 1, 2) > 1, 100, 200)\n", 0, "A1 = 100\n", ""),
  Harness.row(["eval"], "A1 = IF(B1, 1, 2)\nB1 = 5 - 5\n", 0, "A1 = 2\nB1 = 0\n", ""),
]

Harness.run(rows)
