# herdr のタブ名を tmux の automatic-rename（#W）のように自動で付ける。
# コマンド実行中はそのコマンド名、プロンプトに戻ったらカレントディレクトリ名にする。
# herdr のタブには自動命名の設定がないため、ペインに渡される HERDR_TAB_ID を使って fish から rename する。
# 注意: 手動で付けたタブ名（prefix+shift+t）も次のコマンド実行で上書きされる。

status is-interactive; or exit
set -q HERDR_TAB_ID; or exit

function __herdr_tab_rename -a label
    # 同じ名前なら呼ばない（herdr tab rename は 1 回数 ms だが、毎プロンプトの無駄を避ける）
    test "$label" = "$__herdr_tab_label"; and return
    set -g __herdr_tab_label $label
    command herdr tab rename $HERDR_TAB_ID $label >/dev/null 2>&1
end

function __herdr_tab_dir_label
    if test "$PWD" = "$HOME"
        echo '~'
    else
        path basename -- $PWD
    end
end

function __herdr_tab_preexec --on-event fish_preexec
    # 先頭の VAR=value や sudo などのラッパーとそのオプション（-E など）を飛ばして、実行するコマンド名を取り出す。
    # herdr tab rename は -- を受け付けないので、ここで - 始まりの語を除いておく
    set -l words (string split -n ' ' -- (string trim -- $argv[1]))
    while set -q words[1]; and string match -qr '^(-|\w+=|sudo$|env$|command$|builtin$|exec$|time$|nohup$)' -- $words[1]
        set -e words[1]
    end
    set -q words[1]; or return
    __herdr_tab_rename (path basename -- $words[1])
end

function __herdr_tab_postexec --on-event fish_postexec
    __herdr_tab_rename (__herdr_tab_dir_label)
end

# 起動直後（まだ何も実行していないとき）もディレクトリ名にしておく
__herdr_tab_rename (__herdr_tab_dir_label)
