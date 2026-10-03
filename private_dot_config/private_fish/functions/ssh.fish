function ssh
    if set -q SSH_CONFIG
        command ssh -F $SSH_CONFIG $argv
    else
        command ssh $argv
    end
end
