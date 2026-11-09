let rows = [
  Harness.row(["order"], "B1 = A1\nA1 = 1\nA2 = B1 + C3\n", 0, "A1\nB1\nA2\n", ""),
  Harness.row(["order"], "C1 = 1\nB1 = 2\nA1 = 3\n", 0, "A1\nB1\nC1\n", ""),
  Harness.row(["order"], "A1 = B2\nB2 = C3\nC3 = 1\nA2 = 1\n", 0, "A2\nC3\nB2\nA1\n", ""),
  Harness.row(["order"], "A1 = SUM(B1:B3)\nB2 = 1\nB3 = 2\nB1 = 3\n", 0, "B1\nB2\nB3\nA1\n", ""),
  Harness.row(["order"], "", 0, "", ""),
  Harness.row(["order"], "A1 = B1\nB1 = A1\n", 1, "", "cellspan: cycle through A1 B1\n"),
  Harness.row(["order"], "A1 = 1\nB1 = C1\nC1 = B1\n", 1, "", "cellspan: cycle through B1 C1\n"),
  Harness.row(["order"], "D1 = 1\nC1 = D1\nB1 = D1\nA1 = B1 + C1\n", 0, "D1\nB1\nC1\nA1\n", ""),
]

Harness.run(rows)
