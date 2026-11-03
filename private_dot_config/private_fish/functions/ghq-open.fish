function ghq-open
    # herdr / tmux の中ならそれを使い、どちらの外なら GHQ_MUX（未設定なら herdr）に従う
    set -l mux herdr
    if set -q HERDR_ENV
        set mux herdr
    else if set -q TMUX
        set mux tmux
    else if set -q GHQ_MUX
        set mux $GHQ_MUX
    end

    switch $mux
        case tmux
            tmux-ghq
        case '*'
            herdr-ghq
    end
    commandline -f repaint
end
