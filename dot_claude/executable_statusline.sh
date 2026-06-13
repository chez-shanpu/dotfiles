#!/bin/bash
#
# Claude Code Statusline Script
#
# Output preview:
#   mynewshq/src on feat/branch | Opus | ctx: 42% | remain 5h: 85%(22m) 7d: 61%(1d18h)
#   ~~~~~~~~~~~~ ~~~~~~~~~~~~~   ~~~~   ~~~~~~~~   ~~~~~~ ~~~~~~~~~~~~ ~~~~~~~~~~~~~~
#   dir(cyan)    branch(orange)  model  context           5h-remaining 7d-remaining
#                                (pink) (g/y/r)           (g/y/r)      (g/y/r)
#
# Colors: green(<50%), yellow(50-79%), red(>=80%)
#
# "remain~" (with tilde) means the values come from the last session's cache
# (~/.claude/.statusline-usage-cache); rate_limits is absent from the input
# until the session's first API response.
#
# Usage: Run with --test to see test cases

# Numeric parsing (printf %.0f) must not depend on the user's locale:
# comma-decimal locales (e.g. de_DE) reject "85.5" and yield 0
export LC_ALL=C

# Test mode: run with --test
if [ "$1" = "--test" ]; then
    run_test() {
        local name="$1"
        local json="$2"
        echo "=== $name ==="
        echo "$json" | /bin/bash "$0"
        echo ""
    }

    # Use a throwaway cache so tests neither pollute nor depend on the real one
    STATUSLINE_USAGE_CACHE="$(mktemp -d)/usage-cache"
    export STATUSLINE_USAGE_CACHE

    run_test "git repo root" '{"workspace":{"current_dir":"'"$HOME"'/ghq/github.com/user/project","project_dir":"'"$HOME"'/ghq/github.com/user/project"},"model":{"display_name":"Opus"},"output_style":{"name":"default"},"context_window":{"used_percentage":15}}'

    run_test "git repo subdir" '{"workspace":{"current_dir":"'"$HOME"'/ghq/github.com/user/project/src/lib","project_dir":"'"$HOME"'/ghq/github.com/user/project"},"model":{"display_name":"Opus"},"output_style":{"name":"default"},"context_window":{"used_percentage":45}}'

    run_test "no project (null)" '{"workspace":{"current_dir":"'"$HOME"'/Downloads/folder","project_dir":null},"model":{"display_name":"Sonnet"},"output_style":{"name":"default"},"context_window":{"used_percentage":55}}'

    run_test "no project (empty)" '{"workspace":{"current_dir":"'"$HOME"'/tmp/deep/path","project_dir":""},"model":{"display_name":"Haiku"},"output_style":{"name":"default"},"context_window":{"used_percentage":85}}'

    run_test "glob chars in path" '{"workspace":{"current_dir":"'"$HOME"'/dev/proj[1]/src","project_dir":"'"$HOME"'/dev/proj[1]"},"model":{"display_name":"Opus"},"output_style":{"name":"default"},"context_window":{"used_percentage":15}}'

    run_test "cwd outside project" '{"workspace":{"current_dir":"/tmp/scratch","project_dir":"'"$HOME"'/proj"},"model":{"display_name":"Opus"},"output_style":{"name":"default"},"context_window":{"used_percentage":15}}'

    run_test "null model/dir" '{"workspace":{"current_dir":null,"project_dir":null},"model":{},"output_style":{"name":"default"},"context_window":{"used_percentage":15}}'

    run_test "invalid input" 'not json'

    run_test "ctx 50% (yellow)" '{"workspace":{"current_dir":"'"$HOME"'/test","project_dir":"'"$HOME"'/test"},"model":{"display_name":"Opus"},"output_style":{"name":"default"},"context_window":{"used_percentage":50}}'

    run_test "ctx 80% (red)" '{"workspace":{"current_dir":"'"$HOME"'/test","project_dir":"'"$HOME"'/test"},"model":{"display_name":"Opus"},"output_style":{"name":"default"},"context_window":{"used_percentage":80}}'

    now=$(date +%s)
    run_test "rate limits" '{"workspace":{"current_dir":"'"$HOME"'/test","project_dir":"'"$HOME"'/test"},"model":{"display_name":"Opus"},"output_style":{"name":"default"},"context_window":{"used_percentage":15},"rate_limits":{"five_hour":{"used_percentage":23.5,"resets_at":'$((now + 1320))'},"seven_day":{"used_percentage":41.2,"resets_at":'$((now + 151200))'}}}'

    # 5h-only payload must NOT clobber the cached 7d value from the previous test
    run_test "rate limits (5h only, 7d kept from cache)" '{"workspace":{"current_dir":"'"$HOME"'/test","project_dir":"'"$HOME"'/test"},"model":{"display_name":"Opus"},"output_style":{"name":"default"},"context_window":{"used_percentage":15},"rate_limits":{"five_hour":{"used_percentage":85,"resets_at":'$((now + 600))'}}}'

    # Reset 30s away rounds up to 1m, not 0m
    run_test "reset in 30s (shows 1m)" '{"workspace":{"current_dir":"'"$HOME"'/test","project_dir":"'"$HOME"'/test"},"model":{"display_name":"Opus"},"output_style":{"name":"default"},"context_window":{"used_percentage":15},"rate_limits":{"five_hour":{"used_percentage":85,"resets_at":'$((now + 30))'}}}'

    # No rate_limits in input -> fall back to cache written by the previous tests (shown as "remain~")
    run_test "cached usage" '{"workspace":{"current_dir":"'"$HOME"'/test","project_dir":"'"$HOME"'/test"},"model":{"display_name":"Opus"},"output_style":{"name":"default"},"context_window":{"used_percentage":15}}'

    # Expired cache entries are dropped
    printf 'five_pct=85\nfive_reset=%s\nseven_pct=41.2\nseven_reset=%s\n' "$((now - 10))" "$((now + 151200))" > "$STATUSLINE_USAGE_CACHE"
    run_test "cached usage (5h expired, 7d kept)" '{"workspace":{"current_dir":"'"$HOME"'/test","project_dir":"'"$HOME"'/test"},"model":{"display_name":"Opus"},"output_style":{"name":"default"},"context_window":{"used_percentage":15}}'

    # A corrupt cache must not poison arithmetic or execute as shell code
    printf 'five_pct=85\nfive_reset=2026-06-12T03:00:00Z\nseven_pct=41.2\nseven_reset=%s\n' "$((now + 151200))" > "$STATUSLINE_USAGE_CACHE"
    run_test "corrupt cache (5h reset garbage, 7d kept)" '{"workspace":{"current_dir":"'"$HOME"'/test","project_dir":"'"$HOME"'/test"},"model":{"display_name":"Opus"},"output_style":{"name":"default"},"context_window":{"used_percentage":15}}'

    exit 0
fi

# Color constants
RESET=$'\033[0m'
RED=$'\033[91m'
YELLOW=$'\033[93m'
GREEN=$'\033[92m'
CYAN=$'\033[36m'
ORANGE=$'\033[38;5;208m'
PINK=$'\033[95m'

get_usage_color() {
    local pct=$1
    if [ "$pct" -ge 80 ]; then
        echo "$RED"
    elif [ "$pct" -ge 50 ]; then
        echo "$YELLOW"
    else
        echo "$GREEN"
    fi
}

# Non-negative number (int or float)?
is_num() {
    case "$1" in
        '' | . | *[!0-9.]* | *.*.*) return 1 ;;
        *) return 0 ;;
    esac
}

# Round a numeric string to an integer; empty if not a number
round_pct() {
    is_num "$1" && printf '%.0f' "$1"
}

format_remaining() {
    local remaining=$1
    if [ "$remaining" -le 0 ]; then
        echo ""
    elif [ "$remaining" -ge 86400 ]; then
        echo "$((remaining / 86400))d$(((remaining % 86400) / 3600))h"
    elif [ "$remaining" -ge 3600 ]; then
        echo "$((remaining / 3600))h$(((remaining % 3600) / 60))m"
    else
        # Round up so 1-59s shows "1m" instead of a misleading "0m"
        echo "$(((remaining + 59) / 60))m"
    fi
}

usage_part() {
    local label=$1 pct=$2 reset=$3
    local pct_int color reset_time=""
    pct_int=$(round_pct "$pct")
    [ -n "$pct_int" ] || return
    color=$(get_usage_color "$pct_int")
    if [ -n "$reset" ]; then
        reset_time=$(format_remaining $((reset - now)))
        [ -n "$reset_time" ] && reset_time="(${reset_time})"
    fi
    printf "%s: %s%d%%%s%s" "$label" "$color" "$((100 - pct_int))" "$RESET" "$reset_time"
}

# Normalize five_reset/seven_reset to integer epochs (blank if garbage) and
# drop entries whose reset time has passed (usage resets, so the value is wrong)
drop_expired() {
    five_reset=${five_reset%%.*}
    case "$five_reset" in '' | *[!0-9]*) five_reset="" ;; esac
    if [ -n "$five_reset" ] && [ "$five_reset" -le "$now" ]; then
        five_pct="" five_reset=""
    fi
    seven_reset=${seven_reset%%.*}
    case "$seven_reset" in '' | *[!0-9]*) seven_reset="" ;; esac
    if [ -n "$seven_reset" ] && [ "$seven_reset" -le "$now" ]; then
        seven_pct="" seven_reset=""
    fi
}

# Read the cache into c_* variables (parse, don't source: a corrupt or torn
# cache file must not execute as shell code)
read_cache() {
    c_five_pct="" c_five_reset="" c_seven_pct="" c_seven_reset=""
    [ -f "$cache_file" ] || return 0
    local key val
    while IFS='=' read -r key val; do
        case "$key" in
            five_pct) c_five_pct=$val ;;
            five_reset) c_five_reset=$val ;;
            seven_pct) c_seven_pct=$val ;;
            seven_reset) c_seven_reset=$val ;;
        esac
    done < "$cache_file"
    is_num "$c_five_pct" || c_five_pct=""
    is_num "$c_seven_pct" || c_seven_pct=""
}

# Extract all values in a single jq call reading stdin directly. The output is
# captured and eval'd only on success, so invalid JSON or a missing jq can't
# leave half-assigned variables or spray stderr into the statusline.
assignments=$(jq -r '
    @sh "cwd=\(.workspace.current_dir // "")",
    @sh "project_dir=\(.workspace.project_dir // "")",
    @sh "model=\(.model.display_name // "")",
    @sh "used_pct=\(.context_window.used_percentage // "")",
    @sh "five_pct=\(.rate_limits.five_hour.used_percentage // "")",
    @sh "five_reset=\(.rate_limits.five_hour.resets_at // "")",
    @sh "seven_pct=\(.rate_limits.seven_day.used_percentage // "")",
    @sh "seven_reset=\(.rate_limits.seven_day.resets_at // "")"
' 2>/dev/null)
if [ -z "$assignments" ]; then
    echo "(statusline: invalid input)"
    exit 0
fi
cwd="" project_dir="" model="" used_pct="" five_pct="" five_reset="" seven_pct="" seven_reset=""
eval "$assignments"

now=$(date +%s)

# Format directory: project name + project-relative path when cwd is inside
# the project, home-relative path otherwise
dir_display="${cwd/#"$HOME"/~}"
if [ -n "$project_dir" ]; then
    case "$cwd" in
        "$project_dir" | "$project_dir"/*)
            dir_display="${project_dir##*/}${cwd#"$project_dir"}"
            ;;
    esac
fi

# Get git info (disable fsmonitor/untracked-cache so we never take repo locks)
git_info=""
if [ -n "$cwd" ]; then
    git_cmd=(git -C "$cwd" -c core.useBuiltinFSMonitor=false -c core.untrackedCache=false)
    branch=$("${git_cmd[@]}" branch --show-current 2>/dev/null)
    # --show-current exits 0 with empty output on detached HEAD; fall back to the short SHA
    [ -n "$branch" ] || branch=$("${git_cmd[@]}" rev-parse --short HEAD 2>/dev/null)
    if [ -n "$branch" ]; then
        git_info=" ${ORANGE}on${RESET} ${ORANGE}${branch}${RESET}"
    fi
fi

# Add model info
model_info=""
[ -n "$model" ] && model_info=" | ${PINK}${model}${RESET}"

# Calculate context usage if available
context_info=""
used_int=$(round_pct "$used_pct")
if [ -n "$used_int" ]; then
    ctx_color=$(get_usage_color "$used_int")
    context_info=" | ctx: ${ctx_color}${used_int}%${RESET}"
fi

# Claude subscription usage from official rate_limits in stdin JSON
# (Pro/Max only, absent until the first API response;
#  five_hour / seven_day may be independently absent)
#
# Cache last-known rate_limits so new sessions (which don't receive
# rate_limits until the first API response) can still show usage.
# Cached values are marked with "~" (remain~) and dropped once their
# reset time has passed.
cache_file="${STATUSLINE_USAGE_CACHE:-$HOME/.claude/.statusline-usage-cache}"
usage_cached=""
is_num "$five_pct" || { five_pct="" five_reset=""; }
is_num "$seven_pct" || { seven_pct="" seven_reset=""; }

if [ -n "$five_pct" ] || [ -n "$seven_pct" ]; then
    # A payload may carry only one window; merge with the cache so the other
    # window's still-valid value isn't clobbered
    if [ -z "$five_pct" ] || [ -z "$seven_pct" ]; then
        read_cache
        [ -n "$five_pct" ] || { five_pct=$c_five_pct five_reset=$c_five_reset; }
        [ -n "$seven_pct" ] || { seven_pct=$c_seven_pct seven_reset=$c_seven_reset; }
    fi
    drop_expired
    new_cache="five_pct=$five_pct
five_reset=$five_reset
seven_pct=$seven_pct
seven_reset=$seven_reset"
    # The statusline re-runs constantly: skip the write when nothing changed,
    # and use a per-process tmp name so concurrent sessions don't race on it
    if [ "$new_cache" != "$(cat "$cache_file" 2>/dev/null)" ]; then
        tmp_file="${cache_file}.tmp.$$"
        printf '%s\n' "$new_cache" > "$tmp_file" && mv "$tmp_file" "$cache_file"
    fi
elif [ -f "$cache_file" ]; then
    read_cache
    five_pct=$c_five_pct five_reset=$c_five_reset
    seven_pct=$c_seven_pct seven_reset=$c_seven_reset
    usage_cached=1
    drop_expired
fi

usage_info=""
five_part=$(usage_part "5h" "$five_pct" "$five_reset")
seven_part=$(usage_part "7d" "$seven_pct" "$seven_reset")
if [ -n "$five_part" ] || [ -n "$seven_part" ]; then
    usage_info=" | remain${usage_cached:+~}${five_part:+ $five_part}${seven_part:+ $seven_part}"
fi

# Build status line (Starship-style: dir + git + model + context + usage)
printf "%s%s%s%s%s%s%s\n" "$CYAN" "$dir_display" "$RESET" "$git_info" "$model_info" "$context_info" "$usage_info"
