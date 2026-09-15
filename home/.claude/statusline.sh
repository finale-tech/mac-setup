#!/usr/bin/env bash
set -u

# --- locate jq ---
JQ_BIN="jq"
if ! command -v jq >/dev/null 2>&1; then
  for candidate in /opt/homebrew/bin/jq /usr/local/bin/jq /usr/bin/jq; do
    if [[ -x "$candidate" ]]; then
      JQ_BIN="$candidate"
      break
    fi
  done
fi

# --- read stdin once ---
INPUT="$(cat)"

# --- colors ---
GREEN=$'\033[32m'
YELLOW=$'\033[33m'
RED=$'\033[31m'
DIM=$'\033[2m'
RESET=$'\033[0m'

# --- single jq call, tab-separated output ---
line="$("$JQ_BIN" -r '
  [
    (.workspace.current_dir // .cwd // ""),
    (.model.display_name // ""),
    (.effort.level // ""),
    ((.context_window.used_percentage // 0) | round),
    (if .prompt_cache != null then "1" else "0" end),
    ((.prompt_cache.warm // false) | tostring),
    (if .prompt_cache.hit_ratio != null then ((.prompt_cache.hit_ratio * 100) | round | tostring) else "" end),
    ((.prompt_cache.misses // 0) | tostring),
    (.prompt_cache.last_miss_cause.causes[0] // ""),
    ((((.cost.total_cost_usd // 0) * 100) | round) | tostring),
    (if .rate_limits != null then "1" else "0" end),
    (if .rate_limits.five_hour.used_percentage != null then (.rate_limits.five_hour.used_percentage | round | tostring) else "" end),
    (if .rate_limits.seven_day.used_percentage != null then (.rate_limits.seven_day.used_percentage | round | tostring) else "" end),
    ((.context_window.total_input_tokens // 0) | round | tostring),
    ((.context_window.total_output_tokens // 0) | round | tostring)
  ] | map(tostring) | join("\u001f")
' <<< "$INPUT" 2>/dev/null)"

# 0x1F (unit separator) instead of tab: bash collapses runs of whitespace IFS
# chars, so an empty field would shift every later field left.
IFS=$'\x1f' read -r raw_cwd model effort used_pct has_cache warm hit_pct misses cause cost_cents has_rl five_h seven_d tok_in tok_out <<< "$line"

# --- set -u safe defaults ---
raw_cwd="${raw_cwd:-}"
model="${model:-}"
effort="${effort:-}"
used_pct="${used_pct:-0}"
has_cache="${has_cache:-0}"
warm="${warm:-false}"
hit_pct="${hit_pct:-}"
misses="${misses:-0}"
cause="${cause:-}"
cost_cents="${cost_cents:-0}"
has_rl="${has_rl:-0}"
five_h="${five_h:-}"
seven_d="${seven_d:-}"
tok_in="${tok_in:-0}"
tok_out="${tok_out:-0}"

# 999 → 999, 15500 → 15.5k, 1234567 → 1.2M  (integer math; bash has no floats)
fmt_tokens() {
  local n=$1
  if (( n >= 1000000 )); then printf '%d.%dM' $(( n / 1000000 )) $(( (n % 1000000) / 100000 ))
  elif (( n >= 1000 ));  then printf '%d.%dk' $(( n / 1000 ))    $(( (n % 1000) / 100 ))
  else                        printf '%d' "$n"
  fi
}

# --- 1. cwd: abbreviate $HOME, then last two path segments ---
display_cwd="$raw_cwd"
if [[ "$display_cwd" == "$HOME" ]]; then
  display_cwd="~"
elif [[ "$display_cwd" == "$HOME"/* ]]; then
  display_cwd="~${display_cwd#$HOME}"
fi

IFS='/' read -r -a parts <<< "$display_cwd"
n=${#parts[@]}
if (( n >= 2 )); then
  display_cwd="${parts[$((n-2))]}/${parts[$((n-1))]}"
elif (( n == 1 )); then
  display_cwd="${parts[0]}"
fi

# --- 2. model + effort ---
model_segment="🤖 ${model}"
if [[ -n "$effort" ]]; then
  model_segment="${model_segment} (${effort})"
fi

# --- 3. context bar ---
[[ "$used_pct" =~ ^[0-9]+$ ]] || used_pct=0
filled=$(( used_pct / 10 ))
(( filled > 10 )) && filled=10
(( filled < 0 )) && filled=0
empty=$(( 10 - filled ))

printf -v filled_spaces '%*s' "$filled" ''
printf -v empty_spaces '%*s' "$empty" ''
bar="${filled_spaces// /█}${empty_spaces// /░}"

if (( used_pct < 70 )); then
  bar_color="$GREEN"
elif (( used_pct < 90 )); then
  bar_color="$YELLOW"
else
  bar_color="$RED"
fi
context_segment="${bar_color}${bar}${RESET} ${used_pct}%"

# --- 3b. per-request tokens: sent on the last API call / received in its response ---
# total_input_tokens = uncached + cache write + cache read, i.e. current context size.
# Empty until the first API response (both 0), like the cache segment.
[[ "$tok_in"  =~ ^[0-9]+$ ]] || tok_in=0
[[ "$tok_out" =~ ^[0-9]+$ ]] || tok_out=0
tokens_segment=""
if (( tok_in > 0 || tok_out > 0 )); then
  tokens_segment="↑$(fmt_tokens "$tok_in") ↓$(fmt_tokens "$tok_out")"
fi

# --- 4. git branch + diff stat (only inside a git repo) ---
git_segment=""
if [[ -n "$raw_cwd" ]] && git -C "$raw_cwd" --no-optional-locks rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  branch="$(git -C "$raw_cwd" --no-optional-locks branch --show-current 2>/dev/null)"
  git_segment="🌿 ${branch}"
  shortstat="$(git -C "$raw_cwd" --no-optional-locks diff --shortstat 2>/dev/null)"
  if [[ -n "$shortstat" ]]; then
    ins=0
    del=0
    [[ "$shortstat" =~ ([0-9]+)\ insertion ]] && ins="${BASH_REMATCH[1]}"
    [[ "$shortstat" =~ ([0-9]+)\ deletion ]] && del="${BASH_REMATCH[1]}"
    if (( ins > 0 || del > 0 )); then
      git_segment="${git_segment} ${DIM}+${ins}/-${del}${RESET}"
    fi
  fi
fi

# --- 5. prompt cache (absent until first API response) ---
cache_segment=""
if [[ "$has_cache" == "1" ]]; then
  if [[ "$warm" == "true" ]]; then
    icon="🔥"
  else
    icon="❄️"
  fi
  if [[ -n "$hit_pct" ]]; then
    hit_display="${hit_pct}%"
  else
    hit_display="–%"
  fi
  cache_segment="${icon} ${hit_display}"
  [[ "$misses" =~ ^[0-9]+$ ]] || misses=0
  if (( misses > 0 )); then
    if [[ -n "$cause" ]]; then
      cache_segment="${cache_segment} ✗${misses} ${cause}"
    else
      cache_segment="${cache_segment} ✗${misses}"
    fi
  fi
fi

# --- 6. cost ---
[[ "$cost_cents" =~ ^[0-9]+$ ]] || cost_cents=0
dollars=$(( cost_cents / 100 ))
cents=$(( cost_cents % 100 ))
printf -v cost_str '%d.%02d' "$dollars" "$cents"
cost_segment="💰 \$${cost_str}"

# --- 7. rate limits ---
rl_segment=""
if [[ "$has_rl" == "1" ]]; then
  if [[ -n "$five_h" && -n "$seven_d" ]]; then
    rl_segment="5h ${five_h}% · 7d ${seven_d}%"
  elif [[ -n "$five_h" ]]; then
    rl_segment="5h ${five_h}%"
  elif [[ -n "$seven_d" ]]; then
    rl_segment="7d ${seven_d}%"
  fi
fi

# --- assemble final line ---
out="📁 ${display_cwd} · ${model_segment} · ${context_segment}"
[[ -n "$tokens_segment" ]] && out="${out} · ${tokens_segment}"
[[ -n "$git_segment" ]] && out="${out} · ${git_segment}"
[[ -n "$cache_segment" ]] && out="${out} · ${cache_segment}"
out="${out} · ${cost_segment}"
[[ -n "$rl_segment" ]] && out="${out} · ${rl_segment}"

printf '%s\n' "$out"
