let rows = [
  Harness.row(["fmt"], "A1=1+2\n", 0, "A1 = 1 + 2\n", ""),
  Harness.row(["fmt"], "A1 = (1 + 2) * 3\nB1 = ((4))\nC1 = (1) + (2)\n", 0, "A1 = (1 + 2) * 3\nB1 = 4\nC1 = 1 + 2\n", ""),
  Harness.row(["fmt"], "A1 = 1 - (2 - 3)\nB1 = (1 - 2) - 3\nC1 = 1 - (2 + 3)\n", 0, "A1 = 1 - (2 - 3)\nB1 = 1 - 2 - 3\nC1 = 1 - (2 + 3)\n", ""),
  Harness.row(["fmt"], "A1 = 2 * (3 + 4)\nB1 = (2 * 3) + 4\nC1 = 2 * (3 * 4)\nD1 = (2 * 3) * 4\n", 0, "A1 = 2 * (3 + 4)\nB1 = 2 * 3 + 4\nC1 = 2 * (3 * 4)\nD1 = 2 * 3 * 4\n", ""),
  Harness.row(["fmt"], "A1 = -(-5)\nB1 = -(1 + 2)\nC1 = (-3) * 2\nD1 = 1 - -2\n", 0, "A1 = --5\nB1 = -(1 + 2)\nC1 = -3 * 2\nD1 = 1 - -2\n", ""),
  Harness.row(["fmt"], "A1 = 1 < (2 < 3)\nB1 = (1 < 2) < 3\nC1 = (1 + 2) == 3\n", 0, "A1 = 1 < (2 < 3)\nB1 = 1 < 2 < 3\nC1 = 1 + 2 == 3\n", ""),
  Harness.row(["fmt"], "A1=SUM(B3:A1,3,B2:C9)\n", 0, "A1 = SUM(A1:B3, 3, B2:C9)\n", ""),
  Harness.row(["fmt"], "A1 = IF( B1 ,SUM(1,2) ,ABS( -3 ))\n", 0, "A1 = IF(B1, SUM(1, 2), ABS(-3))\n", ""),
  Harness.row(["fmt"], "# note\n\nB2 = 007 + 0\nA1 = 12   *   3\n", 0, "B2 = 7 + 0\nA1 = 12 * 3\n", ""),
  Harness.row(["fmt"], "B1 = 2\nA1 = 1\nB1 = 3\n", 1, "", "cellspan: line 3: cell B1 defined twice (first on line 1)\n"),
  Harness.row(["fmt"], "Z9 = A1 / (B2 % C3) - D4 % (E5 / F6)\n", 0, "Z9 = A1 / (B2 % C3) - D4 % (E5 / F6)\n", ""),
  Harness.row(["fmt"], "", 0, "", ""),
]

Harness.run(rows)
