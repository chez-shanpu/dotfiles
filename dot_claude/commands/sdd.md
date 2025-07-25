---
description: "spec-driven development"
---

spec-driven developmentを行います。
以下の各フェーズに従ってソフトウェアの仕様を定義し、実装計画を作成します。


# 1. 事前準備フェーズ

- ユーザに開発したい機能の概要を質問する。
- @docs/specs ディレクトリ内に、機能の概要から適切な名前を考えてディレクトリを作成する。
- 以降、ファイルを作成するときはこのディレクトリの中に作成する。


# 2. 要件フェーズ

- ユーザから伝えられた機能の概要に基づいて、要件定義書（requirements.md）を作成するための質問票（questionnaire.md）を作成する。
  - 質問票は基本的にチェックボックスで問う形にする。
- 質問票への回答を基に、要件定義書を作成する。
- ユーザに対して要件定義書を提示し、問題がないかを尋ねる。
- ユーザが要件定義書を確認し、問題がないと答えるまで要件定義書を修正する。


# 3. 設計フェーズ

- 要件定義書に記載されている要件を満たすような設計を記述した設計書（design.md）を作成する。
  - 図はmermaid記法を使う。
- ユーザが設計書を確認し、問題がないと答えるまで設計書を修正する。


# 4. 実装計画フェーズ

- 設計書に基づいて実装計画書（plan.md）を作成する。
- 実装計画書には作業の区切りごとに見出しを分けて、各見出しごとに作業項目を書き出す。
  - 各作業項目はチェックボックスをつける。
  - 作業項目はTDDを実施するのに十分な粒度で設定する。
- ユーザーが実装計画書を確認し、問題がないと答えるまで実装計画書を修正する。
