function _sbx_ctx --description "Build a sandbox name and additional workspace list"
    # Print the name first, followed by any additional workspaces.
    set -l cwd (pwd)
    set -l name_parts (basename $cwd)
    set -l extra_ws

    set -l common (git rev-parse --path-format=absolute --git-common-dir 2>/dev/null)
    set -l gitdir (git rev-parse --path-format=absolute --git-dir 2>/dev/null)
    set -l top (git rev-parse --show-toplevel 2>/dev/null)

    if test -n "$common" -a -n "$top"
        # Include the owner to distinguish repositories with the same name.
        set -l root (string replace -r '/\.git/?$' '' -- $common)
        set -l parts (string split / -- (string trim -r -c / -- $root))
        if test (count $parts) -ge 2
            set name_parts (string join - -- $parts[-2..-1])
        else
            set name_parts $parts[-1]
        end

        # Add linked-worktree and subdirectory context to the name.
        test "$gitdir" != "$common"; and set -a name_parts (basename $top)
        test "$cwd" != "$top"; and set -a name_parts (string replace -- "$top/" '' $cwd)

        # Linked worktrees need the writable common Git directory. Mount it only
        # at the worktree root; doing this for a subdirectory exposes the wrong index.
        if test "$cwd" = "$top"; and not string match -q -- "$cwd/*" $common
            set -a extra_ws $common
        end
    end

    set -l slug (string join - -- $name_parts | string lower \
        | string replace -ra '[^a-z0-9.-]+' - | string replace -ra '^-+|-+$' '')
    test -n "$slug"; or set slug sandbox

    # Keep the full name within the 64-character container hostname limit.
    set -l max 57
    if test (string length -- $slug) -gt $max
        set -l h (printf %s $cwd | shasum -a 256 2>/dev/null | string sub -l 8)
        if test -n "$h"
            set slug (string sub -l (math $max - 9) -- $slug | string replace -ra -- '-+$' '')-$h
        else
            set slug (string sub -l $max -- $slug | string replace -ra -- '-+$' '')
        end
    end

    echo $slug
    for w in $extra_ws
        echo $w
    end
end
