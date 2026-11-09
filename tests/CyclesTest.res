let rows = [
  Harness.row(["cycles"], "A1 = 1\nB1 = A1\n", 0, "no cycles\n", ""),
  Harness.row(["cycles"], "A1 = A1\n", 0, "cycle A1\n", ""),
  Harness.row(["cycles"], "A1 = B1\nB1 = A1\n", 0, "cycle A1 B1\n", ""),
  Harness.row(["cycles"], "A1 = B1\nB1 = C1\nC1 = A1\nA2 = A1\n", 0, "cycle A1 B1 C1\n", ""),
  Harness.row(["cycles"], "A1 = SUM(B1:B2)\nB2 = A1\n", 0, "cycle A1 B2\n", ""),
  Harness.row(["cycles"], "", 0, "no cycles\n", ""),
  Harness.row(["cycles"], "D2 = D2\nA1 = B2\nB2 = A1\n", 0, "cycle A1 B2\ncycle D2\n", ""),
  Harness.row(["cycles"], "A1 = IF(0, A1, 3)\n", 0, "cycle A1\n", ""),
  Harness.row(["cycles"], "A1 = SUM(A1:B1)\nB1 = 1\n", 0, "cycle A1\n", ""),
]

Harness.run(rows)
