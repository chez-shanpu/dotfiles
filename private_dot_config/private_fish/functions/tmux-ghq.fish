function tmux-ghq
    set -l repo (ghq root)/(ghq list | peco)
    test -z "$repo"; and return

    # 最後の2要素（org/repo）を取得して _ で結合
    set -l session (echo $repo | awk -F/ '{ print $(NF-1) "_" $NF }')

    if not tmux list-sessions -F "#{session_name}" 2>/dev/null | grep -q -E "^$session\$"
        tmux new-session -d -c "$repo" -s "$session"
    end

    if test -n "$TMUX"
        tmux switch-client -t "$session"
    else
        tmux attach-session -t "$session"
    end
end
