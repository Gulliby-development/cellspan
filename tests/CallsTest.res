let rows = [
  Harness.row(["fmt"], "A1 = SUM()\n", 1, "", "cellspan: line 1: SUM takes at least 1 argument\n"),
  Harness.row(["fmt"], "A1 = SUM(1,)\n", 1, "", "cellspan: line 1: unexpected )\n"),
  Harness.row(["fmt"], "A1 = sum(1)\n", 1, "", "cellspan: line 1: unknown function sum\n"),
  Harness.row(["fmt"], "A1 = MEAN(1, 2)\n", 1, "", "cellspan: line 1: unknown function MEAN\n"),
  Harness.row(["fmt"], "A1 = ABS(1, 2)\n", 1, "", "cellspan: line 1: ABS takes 1 argument\n"),
  Harness.row(["fmt"], "A1 = IF(1, 2)\n", 1, "", "cellspan: line 1: IF takes 3 arguments\n"),
  Harness.row(["fmt"], "A1 = SUM (3, 4)\n", 0, "A1 = SUM(3, 4)\n", ""),
  Harness.row(["fmt"], "A1 = SUM(A1:)\n", 1, "", "cellspan: line 1: bad range\n"),
  Harness.row(["fmt"], "A1 = SUM(B2:C3 + 1)\n", 1, "", "cellspan: line 1: unexpected +\n"),
  Harness.row(["fmt"], "A1 = ABS(B1:C2)\n", 1, "", "cellspan: line 1: unexpected :\n"),
  Harness.row(["fmt"], "A1 = B1:C2\n", 1, "", "cellspan: line 1: unexpected :\n"),
  Harness.row(["fmt"], "A1 = SUM(B2 : C3, 1)\n", 0, "A1 = SUM(B2:C3, 1)\n", ""),
  Harness.row(["fmt"], "A1 = A0 + 1\n", 1, "", "cellspan: line 1: bad cell reference A0\n"),
]

Harness.run(rows)
