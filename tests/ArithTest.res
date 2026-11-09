let rows = [
  Harness.row(["eval"], "A1 = 1 + 2 * 3\n", 0, "A1 = 7\n", ""),
  Harness.row(["eval"], "A1 = (1 + 2) * 3\n", 0, "A1 = 9\n", ""),
  Harness.row(["eval"], "A1 = 10 - 4 - 3\n", 0, "A1 = 3\n", ""),
  Harness.row(["eval"], "A1 = 7 / 2\n", 0, "A1 = 3\n", ""),
  Harness.row(["eval"], "A1 = -7 / 2\n", 0, "A1 = -3\n", ""),
  Harness.row(["eval"], "A1 = 7 / -2\n", 0, "A1 = -3\n", ""),
  Harness.row(["eval"], "A1 = 7 % 3\n", 0, "A1 = 1\n", ""),
  Harness.row(["eval"], "A1 = -7 % 3\n", 0, "A1 = -1\n", ""),
  Harness.row(["eval"], "A1 = --5\n", 0, "A1 = 5\n", ""),
  Harness.row(["eval"], "A1 = 2 - -3\n", 0, "A1 = 5\n", ""),
  Harness.row(["eval"], "A1 = 007 + 1\n", 0, "A1 = 8\n", ""),
  Harness.row(["eval"], "A1 = 999999999\n", 0, "A1 = 999999999\n", ""),
  Harness.row(["eval"], "A1 = 12 * 34 + 56 % 7 - 8 / 3\n", 0, "A1 = 406\n", ""),
]

Harness.run(rows)
