@module("vitest") external test: (string, unit => unit) => unit = "test"

test("scaffold", () => ())
