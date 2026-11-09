let rows = [
  Harness.row(["deps", "A1"], "A1 = B1 + C1 * B1\nB1 = 1\nC1 = 2\n", 0, "A1 -> B1 C1\nA1 <- -\n", ""),
  Harness.row(["deps", "B1"], "A1 = B1 + C1\nB1 = 1\nC1 = A1 + B1\n", 0, "B1 -> -\nB1 <- A1 C1\n", ""),
  Harness.row(["deps", "A1"], "A1 = 5\n", 0, "A1 -> -\nA1 <- -\n", ""),
  Harness.row(["deps", "A1"], "A1 = SUM(B2:C3, B1)\nB1 = 1\n", 0, "A1 -> B1 B2 C2 B3 C3\nA1 <- -\n", ""),
  Harness.row(["deps", "A1"], "A1 = A1 + 1\n", 0, "A1 -> A1\nA1 <- A1\n", ""),
  Harness.row(["deps", "D4"], "A1 = 1\n", 1, "", "cellspan: cell D4 is not defined\n"),
  Harness.row(["deps", "A2"], "A2 = C1 + A1 + B3\n", 0, "A2 -> A1 C1 B3\nA2 <- -\n", ""),
  Harness.row(["deps", "A1"], "B1 = 2\nC9 = A1 - A1\nA1 = IF(Z2, 1, 2)\n", 0, "A1 -> Z2\nA1 <- C9\n", ""),
]

Harness.run(rows)
