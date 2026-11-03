function herdr-ghq
    set -l rel (ghq list | peco)
    test -z "$rel"; and return
    set -l repo (ghq root)/$rel

    # tmux-ghq と同じく最後の2要素（org/repo）をワークスペース名にする
    set -l label (string join / (string split / -- $rel)[-2..-1])

    # herdr の外から呼ばれ、サーバーが止まっていれば裏で起動しておく
    if not set -q HERDR_ENV
        if not herdr status server 2>/dev/null | string match -q 'status: running'
            command herdr server >/dev/null 2>&1 &
            disown
            for i in (seq 50)
                herdr status server 2>/dev/null | string match -q 'status: running'; and break
                sleep 0.1
            end
        end
    end

    set -l id (herdr workspace list | jq -r --arg l "$label" '.result.workspaces[] | select(.label == $l) | .workspace_id' | head -n1)
    if test -n "$id"
        herdr workspace focus $id >/dev/null
    else
        herdr workspace create --cwd $repo --label $label --focus >/dev/null
    end

    # herdr の外からなら最後に attach する
    set -q HERDR_ENV; or herdr
end
