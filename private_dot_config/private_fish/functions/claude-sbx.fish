function claude-sbx --description "Run Claude Code in a Docker Sandbox with the host's global config injected"
    if not type -q sbx
        echo "claude-sbx: sbx not found" >&2
        return 127
    end

    # The skills store is shared with running agents. Importing here exposes
    # transient *.tmp directories to Codex's skill watcher in other sandboxes.
    # Run `sbx skills import -f` manually while all sandboxes are stopped.

    # The proxy normalizes host.docker.internal to localhost for policy checks.
    if not sbx policy check network localhost:8428 >/dev/null 2>&1
        echo "claude-sbx: allowing cc-o11y egress for all sandboxes" >&2
        sbx policy allow network "localhost:8428,localhost:4318"; or return
    end

    set -l ctx (_sbx_ctx)
    set -l name "claude-$ctx[1]"
    set -e ctx[1]
    set -l extra_ws $ctx

    # Pass arguments after -- to Claude; all others belong to sbx.
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

    set -l stage (mktemp -d); or return
    set -l host_settings $HOME/.claude/settings.json
    set -l settings_path /home/agent/.claude/host-settings.json

    # Protect bind-mounted workspaces even when sbx uses bypassPermissions.
    if not printf '%s\n' '{
  "permissions": {
    "deny": [
      "Bash(git pu:*)",
      "Bash(git push:*)",
      "Bash(gh issue comment:*)",
      "Bash(gh pr comment:*)",
      "Bash(gh pr create:*)"
    ]
  }
}' >$stage/settings.json
        echo "claude-sbx: failed to create sandbox settings" >&2
        command rm -rf $stage
        return 1
    end

    # Rebuild the host status line with a sandbox-safe telemetry endpoint.
    set -l o11y_src $HOME/ghq/github.com/chez-shanpu/cc-o11y-stack/scripts/statusline.sh
    set -l statusline_cmd ""
    if test -f $HOME/.claude/statusline.sh
        set statusline_cmd "~/.claude/statusline.sh"
        if test -f $o11y_src
            set statusline_cmd "CC_O11Y_PUSH_URL=http://host.docker.internal:8428/api/v1/import/prometheus ~/.claude/cc-o11y-statusline.sh | $statusline_cmd"
        end
    end

    # Only plugins whose marketplace is a GitHub source can be reproduced in the
    # sandbox; the host install cache records host-absolute paths, so let the CLI
    # re-fetch instead of copying it. Enablement rides along in the settings.
    set -l marketplace_repos
    set -l plugin_ids
    set -l enabled_plugins '{}'
    set -l known_marketplaces $HOME/.claude/plugins/known_marketplaces.json
    if not set -q CLAUDE_SBX_SKIP_PLUGINS; and test -f $host_settings; and test -f $known_marketplaces; and type -q jq
        for line in (jq -rn --slurpfile s $host_settings --slurpfile k $known_marketplaces '
                (($k[0] // {}) | with_entries(select(.value.source.source == "github"))) as $mk
                | (($s[0].enabledPlugins // {})) as $ep
                | ($ep | with_entries((.key | split("@") | last) as $m | select($mk[$m] != null))) as $known
                | [$ep | keys_unsorted[] | . as $key | select($known | has($key) | not)] as $skip
                | [($known | to_entries[] | select(.value == true) | .key)] as $install
                | ($skip[] | "skip=" + .),
                  ($install | map(split("@") | last) | unique | .[] | "marketplace=" + $mk[.].source.repo),
                  ($install[] | "plugin=" + .),
                  ("enabled=" + ($known | tojson))')
            switch $line
                case 'marketplace=*'
                    set -a marketplace_repos (string replace marketplace= '' -- $line)
                case 'plugin=*'
                    set -a plugin_ids (string replace plugin= '' -- $line)
                case 'enabled=*'
                    set enabled_plugins (string replace enabled= '' -- $line)
                case 'skip=*'
                    echo "claude-sbx: skipping plugin "(string replace skip= '' -- $line)"; its marketplace is not a known GitHub source" >&2
            end
        end
    end

    set -l env_args
    if test -f $host_settings; and type -q jq
        # Import only settings that are portable to the sandbox.
        if jq --slurpfile sandbox_settings $stage/settings.json --arg sl "$statusline_cmd" --argjson ep "$enabled_plugins" '
                $sandbox_settings[0]
                + {model, language, effortLevel, skipAutoPermissionPrompt}
                + (if $sl != "" then {statusLine: {type: "command", command: $sl, refreshInterval: 30}} else {} end)
                + (if ($ep | length) > 0 then {enabledPlugins: $ep} else {} end)
                | with_entries(select(.value != null))' \
                $host_settings >$stage/settings.json.tmp
            command mv $stage/settings.json.tmp $stage/settings.json
        else
            command rm -f $stage/settings.json.tmp
            echo "claude-sbx: failed to import host settings; using the minimal settings" >&2
        end

        # Pass telemetry at startup and use HTTP so it can cross the proxy.
        for kv in (jq -r '(.env // {}) as $e
                | ($e | {CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS, CLAUDE_CODE_ENABLE_TELEMETRY, OTEL_METRICS_EXPORTER, OTEL_LOGS_EXPORTER}
                   | with_entries(select(.value != null)))
                + (if $e.OTEL_EXPORTER_OTLP_ENDPOINT
                   then {OTEL_EXPORTER_OTLP_PROTOCOL: "http/protobuf",
                         OTEL_EXPORTER_OTLP_ENDPOINT: "http://host.docker.internal:4318"}
                   else {} end)
                | to_entries[] | "\(.key)=\(.value)"' $host_settings 2>/dev/null)
            set -a env_args -e $kv
        end
    end

    # Append sandbox-specific exceptions to the global instructions.
    if test -f $HOME/.claude/CLAUDE.md
        cp $HOME/.claude/CLAUDE.md $stage/CLAUDE.md
        printf '\n%s\n' '# Sandbox overrides (added by claude-sbx)

- **`~/ghq/<host>/<owner>/<repo>` のパス前提は無効**: ghq ツリーは存在しない。
  参照できるのはマウントされた workspace だけ。外部リポジトリは `git clone` して読む。' >>$stage/CLAUDE.md
    end

    if not contains -- $name (sbx ls -q)
        sbx create claude --name $name $env_args (pwd) $extra_ws $sbx_args
        set -l create_status $status
        if test $create_status -ne 0
            command rm -rf $stage
            return $create_status
        end
    end

    _sbx_install_middleware $name claude-sbx

    # Replace copied directories to avoid nesting and stale files.
    sbx exec -u root $name rm -rf /home/agent/.claude/agents /home/agent/.claude/commands

    # Never start in bypassPermissions mode without the deny rules.
    sbx cp $stage/settings.json $name:$settings_path
    set -l settings_cp_status $status
    if test $settings_cp_status -ne 0
        command rm -rf $stage
        return $settings_cp_status
    end
    test -f $stage/CLAUDE.md; and sbx cp $stage/CLAUDE.md $name:/home/agent/.claude/CLAUDE.md
    test -d $HOME/.claude/agents; and sbx cp $HOME/.claude/agents $name:/home/agent/.claude/agents
    test -d $HOME/.claude/commands; and sbx cp $HOME/.claude/commands $name:/home/agent/.claude/commands
    test -f $HOME/.claude/statusline.sh; and sbx cp $HOME/.claude/statusline.sh $name:/home/agent/.claude/statusline.sh
    test -f $o11y_src; and sbx cp $o11y_src $name:/home/agent/.claude/cc-o11y-statusline.sh

    # sbx cp preserves the host UID, so restore sandbox ownership and modes.
    sbx exec -u root $name chown -R agent:agent /home/agent/.claude/CLAUDE.md /home/agent/.claude/host-settings.json /home/agent/.claude/agents /home/agent/.claude/commands /home/agent/.claude/statusline.sh /home/agent/.claude/cc-o11y-statusline.sh 2>/dev/null
    sbx exec -u root $name chmod +x /home/agent/.claude/statusline.sh /home/agent/.claude/cc-o11y-statusline.sh 2>/dev/null

    command rm -rf $stage

    echo "claude-sbx: updating Claude Code" >&2
    sbx exec $name claude update
    set -l update_status $status
    if test $update_status -ne 0
        echo "claude-sbx: CLI update failed; aborting startup" >&2
        return $update_status
    end

    # Re-registering is how the sandbox learns about host-side plugin changes, so
    # tolerate the error an already-registered marketplace reports. There is no
    # --yes for marketplace add; close stdin so a prompt fails instead of hanging.
    for repo in $marketplace_repos
        echo "claude-sbx: registering marketplace $repo" >&2
        sbx exec $name claude plugin marketplace add $repo </dev/null; or true
    end
    for plugin_id in $plugin_ids
        sbx exec $name claude plugin install -y $plugin_id </dev/null; or true
    end

    sbx run claude --name $name $env_args $sbx_args -- --settings $settings_path $agent_args
end
