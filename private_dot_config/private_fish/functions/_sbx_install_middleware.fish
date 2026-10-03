function _sbx_install_middleware --description "Install middleware packages inside a sandbox"
    set -l name $argv[1]
    # Callers pass their own name so warnings match the surrounding idiom.
    set -l label sbx
    test (count $argv) -ge 2; and set label $argv[2]
    set -l packages direnv

    # command -v is a cheap probe that assumes the package name matches the
    # command name. It exists to skip a network round trip on every launch,
    # not for idempotency.
    set -l missing
    for pkg in $packages
        sbx exec $name sh -c "command -v $pkg" >/dev/null 2>&1; or set -a missing $pkg
    end
    test (count $missing) -gt 0; or return 0

    echo "$label: installing $missing" >&2
    # A fresh sandbox ships with empty apt lists and refreshes them from a
    # background apt-get at boot, so the first attempt both misses the package
    # and loses the lists lock. Retry until that settles and keep the transient
    # errors quiet; only a run that never succeeds is worth reporting.
    set -l log (mktemp)
    sbx exec -u root $name sh -c "export DEBIAN_FRONTEND=noninteractive
        attempt=0
        until apt-get install -y --no-install-recommends $missing; do
            attempt=\$((attempt + 1))
            [ \$attempt -ge 5 ] && exit 1
            sleep 2
            apt-get update || true
        done" >$log 2>&1
    or begin
        echo "$label: failed to install $missing; continuing without it" >&2
        cat $log >&2
    end
    command rm -f $log

    # Middleware is best-effort; never block the agent from starting.
    return 0
end
