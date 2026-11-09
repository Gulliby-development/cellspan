<p align="center"><img src="docs/logo.svg" width="96" alt="" /></p>

# cellspan

[![CI](https://github.com/Gulliby-development/cellspan/actions/workflows/ci.yml/badge.svg)](https://github.com/Gulliby-development/cellspan/actions/workflows/ci.yml) [![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)

cellspan is a small text-spreadsheet evaluator for people who keep budgets, schedules, and test tables in version control. It reads a sheet from standard input and can evaluate its cells, explain dependencies, produce a safe evaluation order, report cycles, or print a canonical version of the sheet. It is written in ReScript 12 and runs on Node.js 20 or newer.

The application is designed to build and run on Windows, macOS, and Linux. The examples below use POSIX shell `printf` only to provide convenient inline input; `printf` is not a build dependency. The application itself uses the ReScript standard library and Node.js built-ins.

## Build and run

Install the development dependencies and compile the ReScript sources:

```sh
bun install
bun run build
```

Then run the compiled entry point with a sheet file redirected to standard input:

```sh
node src/Main.res.mjs eval < budget.sheet
```

The source entry point is `src/Main.res`; the build emits `src/Main.res.mjs`. Commands that read sheets consume all of standard input.

## Commands

```text
usage: cellspan eval [--cell REF]
       cellspan deps REF
       cellspan order
       cellspan cycles
       cellspan fmt
```

The compiled program is invoked locally as `node src/Main.res.mjs COMMAND`. It does not require a globally installed `cellspan` executable.

- `eval` prints every defined cell's value in row-major cell order. `eval --cell REF` prints only that cell's value; the selected cell must be defined.
- `deps REF` prints the selected cell's unique dependencies and the defined cells that depend on it.
- `order` prints defined cells in deterministic topological order. A cycle prevents an order from being produced.
- `cycles` prints each cyclic group; cells that merely lead to a cycle are not members of that group.
- `fmt` prints the sheet in canonical form while preserving the order of its definitions.

If the first word is `help`, `-h`, or `--help`, usage is printed and all following words are ignored. If the first word is `--version`, `cellspan 0.1.0` is printed and all following words are ignored. Both cases exit 0. With no words, usage is written to standard error and the program exits with status 2. Other first words are treated as case-sensitive command names.

After a command, words are checked from left to right before the sheet is parsed. A word beginning with `-` and containing more than that one character is an option; every other word is positional, including the empty word and the lone `-`. `--cell` is the only option and is accepted only by `eval`. It consumes the next word as its value even when that word begins with `-`; if the value is missing or empty, the error is `cellspan: --cell needs a cell reference`. An unsupported option is reported as `cellspan: unknown option WORD`; a repeated supported option is `cellspan: WORD given twice`; an extra positional word is `cellspan: unexpected argument WORD`. These errors are reported as soon as encountered. Reference validation is deferred until all words have been processed: an invalid `--cell` value or `deps` target reports `cellspan: bad cell reference TEXT` only if no earlier option or positional error occurred. For example, an invalid reference followed by an unsupported option reports the unsupported option first.

References must be one uppercase column letter A–Z followed by a row from 1 to 99 without leading zeroes (for example, `A1` and `Z99`). Cell order is by row first, then column, so `Z1` precedes `A2`. Command names and function names are case-sensitive.

On success, results go to standard output, standard error is empty, and exit status is 0. A command-line error exits 2; a sheet or requested-cell failure exits 1. Failures write no standard output and one prefixed message line to standard error. Calculation errors such as `#DIV`, `#NUM`, and `#CYCLE` are values, not command failures, so they appear in normal output with exit status 0. Empty sheets produce no output for `eval`, `order`, and `fmt`; `cycles` prints `no cycles`.

### Worked examples

Each command and output below was exercised against the compiled program. These shell pipelines use inline sheets so they can be copied without creating a file.

**Evaluate cells**

```sh
printf 'A1 = 2\\nB1 = A1 + 3\\n' | node src/Main.res.mjs eval
```

```text
A1 = 2
B1 = 5
```

**Show dependencies**

```sh
printf 'A1 = 2\\nB1 = A1 + 3\\n' | node src/Main.res.mjs deps B1
```

```text
B1 -> A1
B1 <- -
```

**Choose an evaluation order**

```sh
printf 'B1 = A1 + 3\\nA1 = 2\\n' | node src/Main.res.mjs order
```

```text
A1
B1
```

**Report dependency cycles**

```sh
printf 'A1 = B1\\nB1 = A1\\n' | node src/Main.res.mjs cycles
```

```text
cycle A1 B1
```

**Format a sheet**

```sh
printf 'A1=2\\nB1=A1+3\\n' | node src/Main.res.mjs fmt
```

```text
A1 = 2
B1 = A1 + 3
```

## Sheet language

A nonblank, noncomment line defines a cell in the form `REF = EXPRESSION`. Spaces and tabs may surround the reference, equals sign, and expression. Blank lines and lines whose first nonblank character is `#` are ignored. Input is split at line feeds; a carriage return immediately before a line feed (or at the end of the final line) is removed. A final unterminated line is still read if it contains text.

Expressions support decimal integers, cell references, parentheses, unary minus, arithmetic, comparisons, function calls, and restricted rectangular ranges:

```text
expression = compare
compare    = sum { ("==" | "!=" | "<=" | ">=" | "<" | ">") sum }
sum        = product { ("+" | "-") product }
product    = unary { ("*" | "/" | "%") unary }
unary      = "-" unary | primary
primary    = NUMBER | REF | "(" expression ")" | FUNC "(" [ argument { "," argument } ] ")"
```

Operators at each level associate left to right. Precedence from weakest to strongest is comparisons, addition/subtraction, multiplication/division/remainder, then unary minus. Comparisons return 1 or 0. Numbers may contain at most nine decimal digits, including leading zeroes; their numeric value is used. Words consist of letters followed by digits. A word followed by an opening parenthesis is a function name; otherwise it must be a valid cell reference.

The supported functions are `SUM`, `MIN`, `MAX`, `COUNT`, `ABS`, and `IF`. The first four accept one or more arguments, `ABS` accepts one, and `IF` accepts three. A range such as `A1:B3` is permitted only as an entire argument to `SUM`, `MIN`, `MAX`, or `COUNT`; its corners may be given in either order.

## Values, evaluation, and graph behavior

Numbers are integers from -999999999 through 999999999. Addition, subtraction, and multiplication use exact results and yield `#NUM` if the result is out of bounds. Division truncates toward zero; remainder has the sign of its left operand. Division or remainder by zero yields `#DIV`. Aggregate sums are accumulated exactly and checked only after the final sum. `MIN` and `MAX` return the smallest or largest argument value; empty ranges yield zero, and `COUNT` counts defined cells and expression arguments. `ABS` returns an absolute value.

An undefined cell reference evaluates to zero when used directly, but undefined cells are skipped in ranges. `IF(condition, yes, no)` evaluates its condition and only the selected branch. Operands and aggregate values are evaluated in written order; the first error value encountered propagates. Static cycle detection considers all references, including references in an unselected `IF` branch. Every member of a cycle is `#CYCLE`; cells depending on a cycle receive that error through ordinary propagation.

Dependencies include all references and every cell in a range, whether defined or not. The `deps` command lists unique dependencies in cell order and defined reverse dependents in cell order; an empty list is shown as a hyphen. `order` repeatedly chooses the first row-major cell whose defined prerequisites are already emitted. Cycles are strongly connected groups, including self-references; downstream cells are excluded. `cycles` sorts members and groups by their first cell. If `order` finds cycles, it reports the first group and prints no partial order.

Canonical formatting drops comments and blank lines, retains definition order, normalizes numbers and range corners, and uses consistent operator and argument spacing. Parentheses remain where needed to preserve the parsed structure, including equal-precedence right operands and binary expressions under unary minus.

## Diagnostics

Every failure message is prefixed with `cellspan: `. Command-line failures have exit status 2; sheet parsing and undefined selected-cell failures have exit status 1. Sheet diagnostics include the original one-based input line number, counting ignored lines. The command-line templates are:

- `cellspan: unknown command WORD`
- `cellspan: unknown option WORD`
- `cellspan: WORD given twice`
- `cellspan: WORD needs a cell reference`
- `cellspan: unexpected argument WORD`
- `cellspan: deps needs REF`
- `cellspan: bad cell reference TEXT`

Sheet-level diagnostics (all have the form `cellspan: line N: DETAIL`) are:

- `expected CELL = EXPRESSION` when a definition line does not begin with a valid cell and equals sign; a malformed left-side reference is also reported this way.
- `cell REF defined twice (first on line M)` for a repeated definition, after its expression parses successfully.
- `number too large: DIGITS` when a digit run exceeds nine digits.
- `unexpected character C` for a character that is not a token.
- `bad cell reference WORD` for an invalid reference-shaped word, and `unknown function WORD` for an unsupported function.
- `unexpected end of expression` when the expression ends where another token is required.
- `unexpected TOKEN` when a token cannot occur at that position or remains after a complete expression.
- `bad range` when a range argument's colon is not followed by a reference.
- `NAME takes at least 1 argument` for an empty `SUM`, `MIN`, `MAX`, or `COUNT` call; `ABS takes 1 argument` and `IF takes 3 arguments` describe wrong fixed arities.

A selected but undefined cell or an undefined `deps` target reports `cellspan: cell REF is not defined` (exit 1). A cyclic order reports `cellspan: cycle through CELL...` (exit 1). Neither failures nor parse errors produce partial standard output.

## Development

The package pins ReScript 12.3.1 and Vitest 3.2.4. Run the project checks and formatter with:

```sh
bun run typecheck
bun run format
bun run format:check
bun run test
```

The test suite runs the 150 supplied literal command rows across fourteen topic files, plus the scaffold test. The row tests exercise the CLI boundary through `Cli.run`. Process, filesystem, and console access for the application is confined to `src/Main.res`; command and sheet logic return structured outcomes for that entry point to render.

See [LICENSE](LICENSE) for the MIT license terms.

---

Built with [BAKED](https://github.com/Gulliby-development/baked), an open-source coding agent (bench round R85).
