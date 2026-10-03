function codex-sbx --description "Run Codex in a Docker Sandbox with the host's global config injected"
    if not type -q sbx
        echo "codex-sbx: sbx not found" >&2
        return 127
    end

    # The skills store is shared with running agents. Importing here exposes
    # transient *.tmp directories to Codex's skill watcher in other sandboxes.
    # Run `sbx skills import -f` manually while all sandboxes are stopped.

    set -l ctx (_sbx_ctx)
    set -l name "codex-$ctx[1]"
    set -e ctx[1]
    set -l extra_ws $ctx

    # Pass arguments after -- to Codex; all others belong to sbx.
    set -l sbx_args
    set -l agent_args
    set -l after_sep 0
    for a in $argv
        if test $after_sep -eq 1
            set -a agent_args $a
        else if test "$a" = --
            set after_sep 1
        else if contains -- $a . ./ (pwd)
            # The current directory is already the primary workspace.
        else
            set -a sbx_args $a
        end
    end

    # Preserve sbx authentication and import only portable host settings.
    set -l cfg_overrides
    set -l plugins_to_install
    if test -f $HOME/.codex/config.toml; and not set -q CODEX_SBX_SKIP_CONFIG
        for line in (awk '/^\[/{exit} /^[[:space:]]*(model|model_reasoning_effort|plan_mode_reasoning_effort)[[:space:]]*=/{print}' $HOME/.codex/config.toml)
            set -a cfg_overrides -c (string replace -r '^\s*([a-z_]+)\s*=\s*(.*?)\s*$' '$1=$2' -- $line)
        end
        for line in (awk '/^\[tui\]/{f=1;next} f&&/^\[/{exit} f&&/^[[:space:]]*(status_line|status_line_use_colors)[[:space:]]*=/{print}' $HOME/.codex/config.toml)
            set -a cfg_overrides -c "tui."(string replace -r '^\s*([a-z_]+)\s*=\s*(.*?)\s*$' '$1=$2' -- $line)
        end
    end

    # Installed plugins need both their cache and their enablement/tool policies.
    # Parse TOML so quoted plugin IDs and multiline values survive CLI overrides.
    if test -f $HOME/.codex/config.toml
        set -l plugin_overrides (python3 -c '
import json
import sys
try:
    import tomllib
except ImportError:
    import tomli as tomllib

def toml(value):
    if isinstance(value, dict):
        return "{" + ", ".join(json.dumps(k) + " = " + toml(v) for k, v in value.items()) + "}"
    if isinstance(value, list):
        return "[" + ", ".join(map(toml, value)) + "]"
    return json.dumps(value, ensure_ascii=False)

with open(sys.argv[1], "rb") as source:
    config = tomllib.load(source)
# These MCP launchers require macOS apps that do not exist in Docker Sandbox.
# Explicit false values also override any existing sandbox enablement.
plugins = config.setdefault("plugins", {})
for plugin_id in ("unified-computer-use@openai-bundled", "computer-use@openai-bundled"):
    plugins.setdefault(plugin_id, {})["enabled"] = False
print("plugins=" + toml(plugins))
# Local marketplace sources contain host-only paths; Git sources are portable.
git_marketplaces = {}
for name, marketplace in config.get("marketplaces", {}).items():
    if marketplace.get("source_type") == "git":
        git_marketplaces[name] = marketplace
        for plugin_id, settings in config.get("plugins", {}).items():
            if plugin_id.endswith("@" + name) and settings.get("enabled", False):
                print("plugin-install=" + plugin_id)
if git_marketplaces:
    print("marketplaces=" + toml(git_marketplaces))
for feature in ("plugins", "remote_plugin"):
    if feature in config.get("features", {}):
        print("features." + feature + "=" + toml(config["features"][feature]))
' $HOME/.codex/config.toml)
        or begin
            echo "codex-sbx: failed to import plugin settings (requires Python 3.11+ or tomli)" >&2
            return 1
        end
        for override in $plugin_overrides
            if string match -q 'plugin-install=*' -- $override
                set -a plugins_to_install (string replace 'plugin-install=' '' -- $override)
            else
                set -a cfg_overrides -c $override
            end
        end
    end

    if not contains -- $name (sbx ls -q)
        sbx create codex --name $name (pwd) $extra_ws $sbx_args; or return $status
    end

    _sbx_install_middleware $name codex-sbx

    # Leave sbx-owned auth.json and config.toml untouched.
    set -l sandbox_codex_dir (sbx exec $name sh -c 'printf %s "$CODEX_HOME"' 2>/dev/null)
    test -n "$sandbox_codex_dir"; or set sandbox_codex_dir /home/agent/.codex
    if test -f $HOME/.codex/AGENTS.md; or test -d $HOME/.codex/prompts
        # Replace directories to avoid nested copies, then restore ownership.
        test -d $HOME/.codex/prompts; and sbx exec -u root $name rm -rf $sandbox_codex_dir/prompts
        test -f $HOME/.codex/AGENTS.md; and sbx cp $HOME/.codex/AGENTS.md $name:$sandbox_codex_dir/AGENTS.md
        test -d $HOME/.codex/prompts; and sbx cp $HOME/.codex/prompts $name:$sandbox_codex_dir/prompts
        sbx exec -u root $name chown -R agent:agent $sandbox_codex_dir/AGENTS.md $sandbox_codex_dir/prompts 2>/dev/null
    end

    if test -d $HOME/.codex/plugins/cache
        # Cache paths are relative to CODEX_HOME; keep sandbox plugin data intact.
        sbx exec -u root $name mkdir -p $sandbox_codex_dir/plugins; or return $status
        sbx exec -u root $name rm -rf $sandbox_codex_dir/plugins/cache; or return $status
        sbx cp $HOME/.codex/plugins/cache $name:$sandbox_codex_dir/plugins/cache; or return $status
        sbx exec -u root $name chown -R agent:agent $sandbox_codex_dir/plugins/cache; or return $status
    end

    # Git marketplace discovery also needs its catalog checkout, not just the
    # installed plugin cache. Preserve unrelated sandbox marketplace snapshots.
    for marketplace in $HOME/.codex/.tmp/marketplaces/*
        test -d $marketplace; or continue
        set -l destination $sandbox_codex_dir/.tmp/marketplaces/(basename $marketplace)
        sbx exec -u root $name mkdir -p $sandbox_codex_dir/.tmp/marketplaces; or return $status
        sbx exec -u root $name rm -rf $destination; or return $status
        sbx cp $marketplace $name:$destination; or return $status
        sbx exec -u root $name chown -R agent:agent $destination; or return $status
    end

    echo "codex-sbx: updating Codex CLI to latest" >&2
    sbx exec $name npm install -g @openai/codex@latest
    set -l update_status $status
    if test $update_status -ne 0
        echo "codex-sbx: CLI update failed; aborting startup" >&2
        return $update_status
    end

    # CLI installation records enablement in the sandbox's config as well.
    for plugin_id in $plugins_to_install
        sbx exec $name codex $cfg_overrides plugin add $plugin_id; or return $status
    end

    sbx run codex --name $name $sbx_args -- $cfg_overrides $agent_args
end
