# ~/.zshrc — reference copy: mac-setup/home/.zshrc

# --- PATH ---
export PATH="$HOME/.local/bin:$PATH"   # Claude Code (native), uv, other user CLIs
# Per-user pip scripts; site.USER_BASE stays correct across Python upgrades
export PATH="$(python3 -c 'import site; print(site.USER_BASE)')/bin:$PATH"

# --- Shell tools: brew install zoxide fzf zsh-autosuggestions ---
command -v zoxide >/dev/null && eval "$(zoxide init zsh)"   # z foo → jump to dir
command -v fzf    >/dev/null && source <(fzf --zsh)          # Ctrl-T, Ctrl-R, Alt-C, **<Tab>
_as=/opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh
[ -f "$_as" ] && source "$_as"                                # grey inline suggestion, → accepts
unset _as

# --- History ---
HISTSIZE=1000000
SAVEHIST=1000000
setopt HIST_IGNORE_ALL_DUPS HIST_FIND_NO_DUPS SHARE_HISTORY
setopt HIST_IGNORE_SPACE HIST_REDUCE_BLANKS EXTENDED_HISTORY

# --- Claude Code ---
[ -f ~/.claude/claude.local.zsh ] && source ~/.claude/claude.local.zsh   # machine-only overrides

# --- Prompt: current dir in cyan ---
PROMPT='%F{cyan}%1~%f %# '
