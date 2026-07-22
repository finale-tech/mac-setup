#!/usr/bin/env node
'use strict';

/*
 * html2md — convert HTML to Markdown locally using Turndown.
 *
 * This is the same engine (Turndown) that codebeautify.org/html-to-markdown
 * runs in the browser, using the same default options.
 *
 * Usage:
 *   node html2md.js input.html                 # writes ./input.md (current directory)
 *   node html2md.js input.html -o out.md       # write to a specific file
 *   cat page.html | node html2md.js            # read HTML from stdin, print to stdout
 *   pbpaste | node html2md.js > out.md         # convert clipboard (macOS)
 *   node html2md.js --no-gfm input.html        # plain CommonMark (matches the website)
 *
 * GitHub-Flavored Markdown (tables, ~~strikethrough~~, task lists) is ON by default.
 * If installed globally (npm install -g .), use `html2md` instead of `node html2md.js`.
 */

const fs = require('fs');
const path = require('path');
const TurndownService = require('turndown');

const HELP = `html2md — HTML to Markdown (Turndown)

Usage:
  html2md <input.html> [-o out.md] [--no-gfm]

By default the Markdown is written to the current directory using the input's
name with a .md extension (e.g. report.html -> ./report.md). GitHub-Flavored
Markdown (tables, ~~strikethrough~~, task lists) is enabled by default.

  cat page.html | html2md              read HTML from stdin, print to stdout
  pbpaste | html2md > out.md           convert clipboard (macOS)

Options:
  -o, --output <file>   write to a specific file instead of the default
  --no-gfm              disable GitHub-Flavored extras (plain CommonMark, matches the website)
  -h, --help            show this help
`;

function parseArgs(argv) {
  const args = { input: null, output: null, gfm: true, help: false };
  for (let i = 0; i < argv.length; i++) {
    const a = argv[i];
    if (a === '-h' || a === '--help') args.help = true;
    else if (a === '--gfm') args.gfm = true;        // accepted, on by default
    else if (a === '--no-gfm') args.gfm = false;
    else if (a === '-o' || a === '--output') args.output = argv[++i];
    else if (!args.input) args.input = a;
    else { process.stderr.write(`Unexpected argument: ${a}\n`); process.exit(1); }
  }
  return args;
}

// Read all of stdin via the stream API. Using fs.readFileSync(0) breaks on
// macOS, where the stdin pipe fd is non-blocking and a sync read can throw
// EAGAIN ("resource temporarily unavailable") instead of waiting for data.
function readStdin() {
  return new Promise((resolve, reject) => {
    let data = '';
    process.stdin.setEncoding('utf8');
    process.stdin.on('data', (chunk) => { data += chunk; });
    process.stdin.on('end', () => resolve(data));
    process.stdin.on('error', reject);
  });
}

async function main() {
  const args = parseArgs(process.argv.slice(2));
  if (args.help) { process.stdout.write(HELP); return; }

  let html;
  if (args.input) {
    html = fs.readFileSync(args.input, 'utf8');
  } else if (!process.stdin.isTTY) {
    html = await readStdin(); // piped / clipboard input
  } else {
    process.stderr.write(HELP);
    process.exit(1);
  }

  // headingStyle 'setext' is Turndown's default and matches the website's output.
  const td = new TurndownService({ headingStyle: 'setext', codeBlockStyle: 'fenced' });

  if (args.gfm) {
    try {
      const { gfm } = require('turndown-plugin-gfm');
      td.use(gfm);
    } catch (e) {
      process.stderr.write('error: GFM support needs turndown-plugin-gfm. Run: npm install\n');
      process.stderr.write('       (or pass --no-gfm to convert without tables/strikethrough)\n');
      process.exit(1);
    }
  }

  const md = td.turndown(html);
  const out = md.endsWith('\n') ? md : md + '\n';

  // Decide where the Markdown goes:
  //  - explicit -o wins
  //  - a file input defaults to <cwd>/<input-basename>.md
  //  - stdin (no input, no -o) prints to stdout
  let outputPath = args.output;
  if (!outputPath && args.input) {
    const base = path.basename(args.input, path.extname(args.input));
    outputPath = path.join(process.cwd(), base + '.md');
  }

  if (outputPath) {
    fs.writeFileSync(outputPath, out);
    process.stderr.write(`Wrote ${outputPath}\n`);
  } else {
    process.stdout.write(out);
  }
}

main().catch((err) => {
  process.stderr.write(`error: ${err.message}\n`);
  process.exit(1);
});
