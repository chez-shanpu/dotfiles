# リポジトリ管理

- リポジトリは [ghq](https://github.com/x-motemen/ghq) で管理しており、`~/ghq/<host>/<owner>/<repo>`（ghq の標準ルール）に clone される。ローカル参照時もこのパスを想定してよい。
- 外部リポジトリ（OSS など）の実装を調べるときは、`gh api` や WebFetch で断片的に覗くのではなく `ghq get <url>` で clone してローカルで読んでよい。clone したリポジトリは勝手に消さない。

# プライバシー / ファイルアクセス

- ホームディレクトリのファイルを `Glob` や `Read` で直接参照しない。
  既存スキルの例を見たい場合は、ユーザーに内容を共有してもらうか、ドキュメントを参照する。

# Git / コミット運用

- `git commit` / `git push` / PR 作成は自動で実行しない。コード変更後は提案コミットメッセージを提示するに留め、実行はユーザーに委ねる。
- **GitHub の PR / Issue へ自動で投稿しない**: `gh pr comment`, `gh issue comment`, `gh pr review --comment` などユーザー名義で公開される投稿コマンドは実行しない。返信はチャットにテキスト（コードブロック）で提示し、投稿はユーザーに委ねる。Slack やメーリングリストなど他チャネルも同様。読み取り専用の `gh`（`gh pr view`, `gh pr checks`, `gh api .../pulls/...`）は可。
  **Why:** 公開される GitHub 会話（特に upstream OSS）での発言は本人が完全にコントロールしたい。

# 作業フロー

- **計画を先に立てる**: 複数ファイルにまたがる変更（依存バージョンの bump、ワークフロー修正など、一見単純なものを含む）では、編集を始める前に plan を作成し承認を得る。`/plan` モードまたは plan ファイルを書いてから実装する。
- **根本原因を特定してから直す**: バグや不具合に対して、原因が明確になる前にコード変更（"とりあえずの workaround" を含む）を行わない。まず調査と診断を行い、原因確定後に修正案を提案する。
- **調査結果は先にファイル化する**: 調査・監査タスクでは、結果を Markdown ファイルに書き出してから実装に進む。後から参照可能な記録として残すため。

# コードスタイル / 実装方針

- **冪等な操作は事前チェックなしで実行する**: `kind delete cluster` や `kubectl delete --ignore-not-found` のように冪等な操作は、存在チェックを挟まず直接実行する。`if exists; then delete; fi` のようなパターンは避け、必要なら `|| true` でエラーを抑制する。

# ドキュメント / 言語

- **「コメント翻訳して」依頼ではファイルを編集しない**: コードコメントの翻訳依頼があった場合、原文と訳文を対比できる形でチャット上に提示するだけにする（Edit/Write は使わない）。「ファイルも書き換えますか?」と確認するのは可。
- **番号表記に `#` プレフィックスを使わない**: 「指摘 #1」「項目 #6」のように番号の前に `#` を付けない（GitHub に貼ると issue/PR への自動リンクと誤解釈される）。「指摘 1」「項目 6」「No.1」などにする。ただし `owner/repo#368` のような本物の issue/PR 参照はそのまま残す。
  **How to apply:** コードレビュー結果、調査メモ、plan ファイル、PR description ドラフトなど GitHub に貼られる可能性のあるテキスト全般に適用。

# シェル / ツール選好

- **YAML 処理は `yq` を優先**: シェルから YAML を読み書き・検証するときは `yq` コマンドを優先する。Python (PyYAML) や Ruby (YAML.load_file) を持ち出さない。
  **How to apply:** GitHub Actions の workflow YAML、Kubernetes manifest、Helm values など CI/インフラ YAML を構造的に検査するときは最初から `yq` を使う。jq 構文ベース（例: `yq -r '.jobs.e2e.strategy.matrix.include | length' file.yaml`）。
- **テキスト / コード検索は `rg` (ripgrep) を優先**: `grep`, `grep -r`, `find ... | xargs grep` の代わりに `rg` を使う。`-l`(filenames only), `-e PAT1 -e PAT2`, `-t yaml`/`-t go`, glob などを活用する。Read/Edit で済む既知パスへの単発アクセスはそのまま使う。Go のシンボル解決は gopls(LSP) の方が正確。
- **Python 製 CLI の導入・実行は `uv` / `uvx`**: `pipx` ではなく `uv tool install <pkg>`（永続、bin は `~/.local/bin/`）/ `uvx <pkg>`（使い捨て）を使う。
- **`unzip -FF`（復旧モード）を使わない**: 破損 zip の推測復元は信頼できないため使わない。再ダウンロード、`gh api --header` での再取得、`python -m zipfile -e` など別手段で対応する。

# Kubernetes

- **Pod 設定の Service 参照に `.cluster.local` サフィックスは付けない**: 
  **Why:** クラスタ内 Pod の `/etc/resolv.conf` には `svc.cluster.local` 等の search domain が設定されているため短名で解決される。`.cluster.local` の付与は冗長。
  **How to apply:** Pod spec、env vars、ConfigMap などで Service を参照する際は短形式を使う。`.cluster.local` が無いことを不整合として指摘しない。
