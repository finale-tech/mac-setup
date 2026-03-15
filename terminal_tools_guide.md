# Terminal Tools Guide

## The Stack

```
┌─────────────────────────────────────────────────┐
│  Layer 0: NETWORK — Tailscale                   │
│  How your devices find each other anywhere       │
├─────────────────────────────────────────────────┤
│  Layer 1: PROTOCOL — SSH                        │
│  Secure communication between devices            │
├─────────────────────────────────────────────────┤
│  Layer 2: CLIENT APP                            │
│  Ghostty (Mac) / Termius (iPhone)               │
│  The "TV" — draws text, accepts input            │
├─────────────────────────────────────────────────┤
│  Layer 3: MULTIPLEXER — Zellij                  │
│  Manages panes, tabs, and persistent sessions    │
│  Lives on the Mac as a process                   │
├─────────────────────────────────────────────────┤
│  Layer 4: SHELL — zsh                           │
│  Where you actually type commands                │
└─────────────────────────────────────────────────┘
```

## What Does What

### Terminal Emulators (the "TV")

These are the app windows that render text and forward your keystrokes. They don't manage sessions or survive disconnects. If you close the window, everything inside dies (unless a multiplexer is keeping it alive).

| | Terminal.app | iTerm2 | Ghostty |
|---|---|---|---|
| **What it is** | macOS built-in terminal | Free, feature-rich replacement | GPU-accelerated, fast + feature-rich |
| **Rendering** | CPU | CPU | GPU-accelerated |
| **Split panes** | No | Yes (Cmd+D, Cmd+Shift+D) | Yes (Cmd+D, Cmd+Shift+D) |
| **Search** | Basic | Regex, highlights all matches | Built-in search |
| **Hotkey window** | No | Yes (system-wide summon) | Yes (Quick Terminal) |
| **Shell integration** | No | Yes (prompt navigation, command status) | Yes (auto-detected) |
| **Config** | None | GUI preferences | Plain text file |
| **Themes** | Limited | Profiles + color presets | Hundreds built-in, auto light/dark |
| **Platform** | macOS only | macOS only | macOS + Linux |
| **Bottom line** | Fine for occasional use | Mature, feature-deep | Fast, modern, our choice |

### Terminal Multiplexers (session managers)

These run *inside* a terminal emulator. They manage panes, tabs, and sessions. Their killer feature is **session persistence** — detach, disconnect, reattach later, everything still running.

| | tmux | Zellij |
|---|---|---|
| **What it is** | The established standard (~2009) | Modern alternative (Rust-based) |
| **Availability on servers** | Nearly universal | Often needs manual install |
| **Learning curve** | Steep (memorize keybindings) | Gentle (status bar shows keys) |
| **Config required** | Medium-high (needs .tmux.conf) | Low (good defaults out of the box) |
| **Scriptability** | Excellent | Growing |
| **Plugin system** | Shell scripts (hacky) | WASM-based (proper architecture) |
| **Floating panes** | Limited (popup windows) | Native support |
| **Layout files** | Via tmuxinator (YAML) | Built-in (KDL format) |
| **iTerm2 native integration** | Yes (-CC mode, renders as native tabs) | No (not needed — Ghostty is fast enough) |
| **Bottom line** | Pick if you need ubiquity/scripting | Pick if starting fresh (our choice) |

### The Key Concept: "TV" Analogy

- **Ghostty / Termius** = the TV screen. Displays whatever signal it receives, forwards your remote control presses (keystrokes). Doesn't produce content.
- **Zellij** = the device plugged into the TV. Produces the signal, manages everything. Doesn't care which TV is showing it.
- **Detach/reattach** = unplugging the TV. Zellij keeps running. Plug any TV back in (Ghostty at your desk, Termius on your phone) and it sends its current state to whatever screen connected.

```
At your Mac:       Ghostty (TV) ←→ Zellij ←→ your shells
From iPhone:       Termius (TV) ←→ SSH/Tailscale ←→ Zellij ←→ your shells
```

Zellij's side is identical in both cases. Only the screen changes.

## Our Setup

- **Ghostty** as the terminal emulator on Mac (over iTerm2 — GPU-accelerated, faster rendering, plain text config)
- **Zellij** as the multiplexer (over tmux — better defaults, easier to learn)
- **Tailscale** for networking (so iPhone can reach Mac from anywhere)
- **Termius** as the SSH client on iPhone

---

## Ghostty Setup & Shortcuts

### Config File

All configuration lives in a single plain text file:
```
~/.config/ghostty/config
```

Format is `key = value`, one per line. Reload anytime with **Cmd+Shift+,** — no restart needed.

### Our Config

```
# Theme — auto-switches with macOS appearance
theme = dark:Builtin Solarized Dark,light:Builtin Solarized Light

# Shell integration (auto-detects zsh)
shell-integration = detect

# Confirm before closing a session with running processes
confirm-close-surface = true

# macOS native tabs
macos-titlebar-style = tabs

# Copy on highlight
copy-on-select = clipboard

# Hide mouse while typing
mouse-hide-while-typing = true

# Warn before pasting suspicious content
clipboard-paste-protection = true

# URLs are clickable (Cmd+click)
link-url = true
```

### Built-in Shortcuts

| Shortcut | What it does |
|---|---|
| Cmd+D | Split pane right (vertical) |
| Cmd+Shift+D | Split pane down (horizontal) |
| Cmd+[ / Cmd+] | Move focus between panes |
| Cmd+T | New tab |
| Cmd+1, Cmd+2, etc. | Jump to specific tab |
| Cmd+W | Close current pane/tab |
| Cmd+N | New window |
| Cmd+Shift+, | Reload config |
| Cmd+, | Open config file in editor |
| Cmd+click | Open URL |

### Themes

Browse all built-in themes:
```bash
ghostty +list-themes
```

Auto light/dark switching:
```
theme = dark:YourDarkTheme,light:YourLightTheme
```

### Shell Integration

Auto-detected for zsh — no manual setup needed. Enables:
- Prompt detection (smart close confirmation)
- New terminals open in previous terminal's working directory
- Cursor styling at prompts

### Why Ghostty over iTerm2

- **GPU-accelerated rendering** — smoother scrolling, lower input latency
- **Plain text config** — version-controllable, no GUI digging
- **Hundreds of built-in themes** with auto light/dark switching
- **Cross-platform** — same config works on Linux
- **Zero config to start** — good defaults out of the box
- **Native macOS app** — feels native, supports native tabs

---

## Zellij Usage

### Install

```bash
brew install zellij
```

### Starting and Session Management

| Command | What it does |
|---|---|
| `zellij` | Start a new unnamed session |
| `zellij -s work` | Start a named session called "work" |
| `zellij attach` | Reattach to last session |
| `zellij attach work` | Reattach to session named "work" |
| `zellij list-sessions` | List all running sessions |

### Modes

Zellij uses a mode system. You enter a mode, perform an action, and return to normal. The **status bar at the bottom always shows your current mode and available keys**.

- **Normal mode** — keystrokes go to your shell as usual
- **Pane mode** (Ctrl+P) — manage panes
- **Tab mode** (Ctrl+T) — manage tabs
- **Resize mode** (Ctrl+N) — resize current pane
- **Session mode** (Ctrl+O) — detach, etc.

### Shortcuts

| Shortcut | What it does |
|---|---|
| **Panes** | |
| Ctrl+P, r | Split right (vertical) |
| Ctrl+P, d | Split down (horizontal) |
| Ctrl+P, x | Close current pane |
| Alt+Arrow keys | Move focus between panes (no mode needed) |
| **Tabs** | |
| Ctrl+T, n | New tab |
| Ctrl+T, x | Close tab |
| Alt+1, Alt+2, etc. | Jump to tab by number (no mode needed) |
| **Session** | |
| Ctrl+O, d | Detach from session |

### The Detach/Reattach Workflow

1. Start Zellij with `zellij -s mywork`
2. Set up panes, run processes
3. Detach: Ctrl+O then d (or just close the terminal / lose SSH connection)
4. Later, reattach: `zellij attach mywork`
5. Everything is exactly as you left it
