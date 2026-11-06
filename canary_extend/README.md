# Canary + Extend

Canary matrix typing plus an Extend layer on Caps Lock. macOS does the typing; one small Swift binary does the layer.

## Files

- `~/Library/Keyboard Layouts/Canary.keylayout`: layout `canary` (id -27002, group 126, ANSI)
- `~/canary_extend/canary_extend.swift`: Extend source
- `~/.zshrc`: `alias canary='~/canary_extend/canary_extend'`

## Extend (hold Caps)

- **IJKL:** arrows. **Space:** Delete. **Return:** end of line, then `;`
- **Symbols:** Q `!` W `{` E `}` R `&` A `_` S `(` D `)` F `=` Z `*` X `[` C `]` V `|` M `.` P `=`. Shift makes no difference
- **Tap Caps alone** (no other key while held): toggles real Caps Lock
- **Cmd held too:** letter keys (not IJKL) act as QWERTY, e.g. Caps+Cmd+A = Select All
- **How:** `hidutil` maps Caps to F18. The binary adds an Option flag on symbol keys, and the layout's Option map types the symbol.

## Setup

1. Install the layout file; log out and in. Add **canary** in Input Sources and remove any old "Canary". Keep "switch to a document's input source" off.
2. Build: `swiftc -O canary_extend.swift -o canary_extend && codesign -s - -f canary_extend`
3. Add the alias. Run `canary` in Terminal (Ctrl-C or `pkill canary_extend` stops it and restores Caps).
4. Give **Terminal** Accessibility and Input Monitoring, then rerun.
   Accessibility pane: `open "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility"`

## Notes

- Extend stops during secure input (password fields); Canary typing doesn't.
- An edited layout may not load under the same ID. Change `name` / `id` and re-add it.
- It must run from Terminal. A LaunchAgent or app needs its own permission entry, which never appeared.
- Rebuilding can reset permissions.
- Manual Caps restore: `hidutil property --set '{"UserKeyMapping":[]}'`

## Canary layout

Letters by physical QWERTY key. Everything else (digits, punctuation, Return/Tab/Space/Delete/Esc, arrows, Home/End/PgUp/PgDn) is as U.S.

```
W L Y P K   Z X O U ;
 C R S T B   F N E I A
  J V D G Q   M H / , .
```

Maps (modifier → map index):

- **None, Cmd → 0:** as above
- **Shift → 1:** uppercase; `;` → `:`  `/` → `?`  `,` → `<`  `.` → `>`
- **Caps → 2:** uppercase letters, symbols as base. The other maps ignore Caps Lock (`caps?`), so Shift, Control and Extend behave the same with it on
- **Control → 3:** each Canary letter sends its control character (key typing `c` = Ctrl-C)
- **Option → 4:** as map 0, except the Extend symbols above
- **Option+Shift → 5:** as map 1, with the same Extend symbols as map 4

Rebuild by copying any `.keylayout` (or using Ukelele) and filling these maps.
