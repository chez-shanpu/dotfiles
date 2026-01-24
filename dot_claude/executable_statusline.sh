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
# Environment variables:
#   CLAUDE_STATUSLINE_NO_USAGE=1  Disable usage fetch (skips keychain access)
#
# Usage: Run with --test to see test cases
#

# Test mode: run with --test
if [ "$1" = "--test" ]; then
    run_test() {
        local name="$1"
        local json="$2"
        echo "=== $name ==="
        echo "$json" | /bin/bash "$0"
        echo ""
    }

    run_test "git repo root" '{"workspace":{"current_dir":"/Users/korosuke613/ghq/github.com/user/project","project_dir":"/Users/korosuke613/ghq/github.com/user/project"},"model":{"display_name":"Opus"},"output_style":{"name":"default"},"context_window":{"used_percentage":15}}'

    run_test "git repo subdir" '{"workspace":{"current_dir":"/Users/korosuke613/ghq/github.com/user/project/src/lib","project_dir":"/Users/korosuke613/ghq/github.com/user/project"},"model":{"display_name":"Opus"},"output_style":{"name":"default"},"context_window":{"used_percentage":45}}'

    run_test "no project (null)" '{"workspace":{"current_dir":"/Users/korosuke613/Downloads/folder","project_dir":null},"model":{"display_name":"Sonnet"},"output_style":{"name":"default"},"context_window":{"used_percentage":55}}'

    run_test "no project (empty)" '{"workspace":{"current_dir":"/Users/korosuke613/tmp/deep/path","project_dir":""},"model":{"display_name":"Haiku"},"output_style":{"name":"default"},"context_window":{"used_percentage":85}}'

    run_test "ctx 50% (yellow)" '{"workspace":{"current_dir":"/Users/korosuke613/test","project_dir":"/Users/korosuke613/test"},"model":{"display_name":"Opus"},"output_style":{"name":"default"},"context_window":{"used_percentage":50}}'

    run_test "ctx 80% (red)" '{"workspace":{"current_dir":"/Users/korosuke613/test","project_dir":"/Users/korosuke613/test"},"model":{"display_name":"Opus"},"output_style":{"name":"default"},"context_window":{"used_percentage":80}}'

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

# Read JSON input
input=$(cat)

# Extract all values in single jq call
eval "$(echo "$input" | jq -r '
    @sh "cwd=\(.workspace.current_dir)",
    @sh "project_dir=\(.workspace.project_dir // "")",
    @sh "model=\(.model.display_name)",
    @sh "output_style=\(.output_style.name)",
    @sh "used_pct=\(.context_window.used_percentage // "")"
')"

# Format directory (show relative to project root)
if [ -n "$project_dir" ] && [ "$project_dir" != "null" ] && [ "$cwd" != "$project_dir" ]; then
    # Get project name (last component of project_dir)
    project_name="${project_dir##*/}"
    # Get relative path from project_dir
    relative_path="${cwd#$project_dir}"
    dir_display="${project_name}${relative_path}"
elif [ -n "$project_dir" ] && [ "$project_dir" != "null" ]; then
    # At project root
    dir_display="${project_dir##*/}"
else
    # Fallback to home-relative path
    dir_display="${cwd/#$HOME/~}"
fi

# Get git info (skip locks for safety)
git_info=""
if git -C "$cwd" rev-parse --git-dir &>/dev/null; then
    branch=$(git -C "$cwd" -c core.useBuiltinFSMonitor=false -c core.untrackedCache=false branch --show-current 2>/dev/null || git -C "$cwd" -c core.useBuiltinFSMonitor=false -c core.untrackedCache=false rev-parse --short HEAD 2>/dev/null)
    if [ -n "$branch" ]; then
        git_info=" ${ORANGE}on${RESET} ${ORANGE}${branch}${RESET}"
    fi
fi

# Add model info
model_info=" | ${PINK}${model}${RESET}"

# Calculate context usage if available (used_pct already extracted above)
context_info=""
if [ -n "$used_pct" ]; then
    used_int=$(printf "%.0f" "$used_pct")
    ctx_color=$(get_usage_color "$used_int")
    context_info=" | ctx: ${ctx_color}${used_int}%${RESET}"
fi

# Fetch Claude subscription usage (with cache)
# Set CLAUDE_STATUSLINE_NO_USAGE=1 to disable usage fetch (avoids keychain access)
usage_info=""

if [ "$CLAUDE_STATUSLINE_NO_USAGE" = "1" ]; then
    : # Skip usage fetch
else

CACHE_FILE="/tmp/claude-usage-cache.json"
CACHE_MAX_AGE=300  # 5 minutes

fetch_usage() {
    TOKEN=$(security find-generic-password -s "Claude Code-credentials" -w 2>/dev/null | jq -r '.claudeAiOauth.accessToken // empty')
    if [ -n "$TOKEN" ]; then
        curl -s --max-time 3 \
            -H "Authorization: Bearer $TOKEN" \
            -H "anthropic-beta: oauth-2025-04-20" \
            -H "Content-Type: application/json" \
            "https://api.anthropic.com/api/oauth/usage" 2>/dev/null
    fi
    # Example response:
    # {
    #   "five_hour": {
    #     "utilization": 7.0,
    #     "resets_at": "2026-01-20T08:00:00.425335+00:00"
    #   },
    #   "seven_day": {
    #     "utilization": 38.0,
    #     "resets_at": "2026-01-22T02:00:00.425356+00:00"
    #   },
    #   "seven_day_oauth_apps": null,
    #   "seven_day_opus": null,
    #   "seven_day_sonnet": {
    #     "utilization": 36.0,
    #     "resets_at": "2026-01-25T07:00:00.425364+00:00"
    #   },
    #   "iguana_necktie": null,
    #   "extra_usage": {
    #     "is_enabled": false,
    #     "monthly_limit": null,
    #     "used_credits": null,
    #     "utilization": null
    #   }
    # }
}

get_usage() {
    local now=$(date +%s)
    local cache_time=0

    # Check cache
    if [ -f "$CACHE_FILE" ]; then
        cache_time=$(stat -f %m "$CACHE_FILE" 2>/dev/null || echo 0)
        local age=$((now - cache_time))
        if [ $age -lt $CACHE_MAX_AGE ]; then
            cat "$CACHE_FILE"
            return
        fi
    fi

    # Fetch fresh data
    local usage=$(fetch_usage)
    if [ -n "$usage" ] && echo "$usage" | jq -e '.five_hour' >/dev/null 2>&1; then
        echo "$usage" > "$CACHE_FILE"
        echo "$usage"
    elif [ -f "$CACHE_FILE" ]; then
        # Use stale cache on error
        cat "$CACHE_FILE"
    fi
}

usage_data=$(get_usage)
if [ -n "$usage_data" ]; then
    five_hour=$(echo "$usage_data" | jq -r '.five_hour.utilization // empty')
    five_hour_reset=$(echo "$usage_data" | jq -r '.five_hour.resets_at // empty')
    seven_day=$(echo "$usage_data" | jq -r '.seven_day.utilization // empty')
    seven_day_reset=$(echo "$usage_data" | jq -r '.seven_day.resets_at // empty')

    if [ -n "$five_hour" ] && [ -n "$seven_day" ]; then
        five_int=$(printf "%.0f" "$five_hour")
        seven_int=$(printf "%.0f" "$seven_day")
        now_epoch=$(date +%s)

        # Calculate remaining time until 5h reset
        five_reset_time=""
        if [ -n "$five_hour_reset" ]; then
            utc_time="${five_hour_reset%%.*}+0000"
            reset_epoch=$(date -j -f "%Y-%m-%dT%H:%M:%S%z" "$utc_time" "+%s" 2>/dev/null)
            if [ -n "$reset_epoch" ]; then
                remaining=$((reset_epoch - now_epoch))
                if [ $remaining -gt 0 ]; then
                    hours=$((remaining / 3600))
                    minutes=$(((remaining % 3600) / 60))
                    if [ $hours -gt 0 ]; then
                        five_reset_time="${hours}h${minutes}m"
                    else
                        five_reset_time="${minutes}m"
                    fi
                fi
            fi
        fi

        # Calculate remaining time until 7d reset
        seven_reset_time=""
        if [ -n "$seven_day_reset" ]; then
            utc_time="${seven_day_reset%%.*}+0000"
            reset_epoch=$(date -j -f "%Y-%m-%dT%H:%M:%S%z" "$utc_time" "+%s" 2>/dev/null)
            if [ -n "$reset_epoch" ]; then
                remaining=$((reset_epoch - now_epoch))
                if [ $remaining -gt 0 ]; then
                    days=$((remaining / 86400))
                    hours=$(((remaining % 86400) / 3600))
                    if [ $days -gt 0 ]; then
                        seven_reset_time="${days}d${hours}h"
                    else
                        seven_reset_time="${hours}h"
                    fi
                fi
            fi
        fi

        # Convert to remaining percentage
        five_remain=$((100 - five_int))
        seven_remain=$((100 - seven_int))
        five_color=$(get_usage_color "$five_int")
        seven_color=$(get_usage_color "$seven_int")
        usage_info=" | remain 5h: ${five_color}${five_remain}%${RESET}(${five_reset_time}) 7d: ${seven_color}${seven_remain}%${RESET}(${seven_reset_time})"
    fi
fi

fi  # end of CLAUDE_STATUSLINE_NO_USAGE check

# Build status line (Starship-style: dir + git + model + context + usage)
printf "%s%s%s%s%s%s%s" "$CYAN" "$dir_display" "$RESET" "$git_info" "$model_info" "$context_info" "$usage_info"
