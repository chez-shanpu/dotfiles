# dotfiles

Personal configuration files managed with chezmoi

## Secret scanning

`git push` runs [betterleaks](https://github.com/betterleaks/betterleaks) on the commits being pushed via `.githooks/pre-push`, and blocks the push if it finds a secret.

- betterleaks is installed by aqua (`aqua i -l` at the repository root).
- `chezmoi apply` sets `core.hooksPath` to `.githooks` once via `run_once_after_set-git-hooks-path.sh.tmpl`.
- Add the fingerprint of a false positive to `.betterleaksignore`, or skip the check with `git push --no-verify`.
