// Formats ReScript files through `rescript format --stdin` and compares or writes them with LF line ends.
// `rescript format` writes CRLF on Windows, so an LF file never passes `rescript format --check` there; this script strips the CR on both sides.
// The row files tests/*Test.res are data tables, one row per line however long: they are not formatted (the formatter would break a long row over several lines).
// usage: node scripts/format.mjs [--check] [FILE...]   (no file: every .res and .resi file under src and tests, except tests/*Test.res)
import { spawnSync } from "node:child_process";
import { readdirSync, readFileSync, statSync, writeFileSync } from "node:fs";
import { createRequire } from "node:module";
import { dirname, extname, join } from "node:path";

const require = createRequire(import.meta.url);
const cli = join(dirname(require.resolve("rescript/package.json")), "cli", "rescript.js");
const args = process.argv.slice(2);
const check = args.includes("--check");
const given = args.filter((a) => a !== "--check");

function walk(dir) {
  const out = [];
  for (const name of readdirSync(dir).sort()) {
    const path = join(dir, name);
    if (statSync(path).isDirectory()) out.push(...walk(path));
    else if (name.endsWith(".res") || name.endsWith(".resi")) out.push(path);
  }
  return out;
}

const rowFile = (file) => /Test\.resi?$/.test(file);
const files = (given.length > 0 ? given : ["src", "tests"].flatMap(walk)).filter((file) => !rowFile(file));
const lf = (text) => text.replace(/\r\n/g, "\n");
let bad = 0;
for (const file of files) {
  const source = lf(readFileSync(file, "utf8"));
  const run = spawnSync(process.execPath, [cli, "format", "--stdin", extname(file)], { input: source, encoding: "utf8" });
  if (run.status !== 0) {
    process.stderr.write(`${file}: rescript format failed\n${run.stdout}${run.stderr}`);
    bad += 1;
    continue;
  }
  const formatted = lf(run.stdout);
  if (formatted === source) continue;
  if (check) {
    process.stdout.write(`[format check] ${file}\n`);
    bad += 1;
  } else {
    writeFileSync(file, formatted);
  }
}
if (check && bad > 0) {
  process.stderr.write(`${bad} file${bad === 1 ? "" : "s"} listed above need formatting\n`);
}
process.exit(bad > 0 ? 1 : 0);
