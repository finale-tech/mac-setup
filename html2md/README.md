# html2md

A tiny local HTML → Markdown converter. It wraps [Turndown](https://github.com/mixmark-io/turndown),
the same library that `codebeautify.org/html-to-markdown` runs in the browser. By default it also
enables GitHub-Flavored Markdown (tables, strikethrough, task lists); for byte-for-byte parity with
that website, use `--no-gfm`.

## Setup

From this folder (one time):

```bash
npm install
```

That installs `turndown` and `turndown-plugin-gfm` (for tables/strikethrough/task lists).

## Usage

By default, converting a file writes the Markdown into the **current directory**, using the
input's name with a `.md` extension. For example, running `html2md report.html` produces
`./report.md`.

```bash
# convert a file -> writes ./input.md in the current directory
node html2md.js input.html

# convert a file, write to a specific path instead of the default
node html2md.js input.html -o docs/out.md

# read HTML from stdin (no filename, so it prints to stdout)
cat page.html | node html2md.js

# convert whatever HTML is on your clipboard (macOS)
pbpaste | node html2md.js > out.md

# GFM extras (tables, ~~strikethrough~~, task lists) are ON by default;
# disable them for plain CommonMark that matches the website:
node html2md.js --no-gfm input.html
```

The output path is printed to stderr (e.g. `Wrote /path/to/report.md`) so it won't pollute pipes.

## Optional: install as a global command

To run `html2md` from anywhere instead of `node html2md.js`:

```bash
npm install -g .
# then, from any directory:
html2md input.html          # writes ./input.md in whatever folder you're in
pbpaste | html2md
```

(`npm link` works too, and is easier to undo — see Uninstall.)

## Uninstall

Pick the line matching how you installed it:

```bash
# if you used `npm install -g .`
npm uninstall -g html2md

# if you used `npm link`
npm rm -g html2md      # remove the global symlink
npm unlink             # run this inside the project folder to clear its link
```

Then, to remove it completely, delete this project folder (which also removes the local
`node_modules`):

```bash
rm -rf /Users/work/Documents/gits/mac-setup/arnaud-claude-plugins/html2md
```

Verify it's gone — this should print nothing:

```bash
which html2md
```

If you only ever ran it as `node html2md.js` (no global install), there's nothing to uninstall —
just delete the folder.

## Notes

- Default heading style is `setext` (h1/h2 underlined with `=`/`-`, h3+ as `#`), matching Turndown's
  default and the codebeautify website. Code blocks are emitted fenced (```) rather than indented.
- GitHub-Flavored Markdown (tables, `~~strikethrough~~`, task lists) is **on by default**. Pass
  `--no-gfm` for plain CommonMark that matches the codebeautify website (which does not enable GFM).
  Note: complex tables (colspan/rowspan, nested tables) may not convert cleanly under GFM.
- Everything runs locally and offline; nothing is sent to a server.
