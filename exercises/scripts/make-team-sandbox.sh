#!/usr/bin/env bash
#
# make-team-sandbox.sh - 複数人での開発（push / pull）を 1 台の PC で練習する環境を作る
#
# 使い方:
#   bash make-team-sandbox.sh [作成先ディレクトリ]
#
# 作成先を省略すると、カレントディレクトリに team-sandbox を作ります。
# 次の 3 つのディレクトリが作られます。
#
#   remote.git/ : GitHub の代わりになる「リモートリポジトリ」（中身は直接触りません）
#   alice/      : Alice さんの作業用リポジトリ（remote.git を clone したもの）
#   bob/        : Bob さんの作業用リポジトリ（remote.git を clone したもの）
#
# alice/ と bob/ を行き来しながら push / pull すると、
# 「他の人が先に push していたので push が拒否される」状況などを安全に体験できます。

set -euo pipefail

TARGET="${1:-team-sandbox}"

# 作成先がすでにないか、Git リポジトリの中ではないかを確認する（中身は lib/common.sh）
# shellcheck source=lib/common.sh
source "$(dirname "$0")/lib/common.sh"
check_sandbox_target "$TARGET"

mkdir -p "$TARGET"
cd "$TARGET"

# 1. リモートリポジトリ（作業ディレクトリを持たない「bare リポジトリ」）を作る
git init -q --bare -b main remote.git

# 2. Alice さんが clone して、最初のコミットを push する
git clone -q remote.git alice 2>/dev/null
git -C alice symbolic-ref HEAD refs/heads/main
git -C alice config user.name "Alice"
git -C alice config user.email "alice@example.com"
cat >alice/README.md <<'EOF'
# チーム開発の練習

## メンバー

- Alice

## 今週の目標

- （未定）
EOF
git -C alice add README.md
git -C alice commit -q -m "README を追加"
git -C alice push -q -u origin main

# 3. Bob さんも clone する
git clone -q remote.git bob
git -C bob config user.name "Bob"
git -C bob config user.email "bob@example.com"

cat <<EOF
チーム開発の練習環境を作成しました: $(pwd)

  remote.git/ : GitHub の代わりになるリモートリポジトリ
  alice/      : Alice さんの作業用リポジトリ
  bob/        : Bob さんの作業用リポジトリ

Alice さんと Bob さんの作業用リポジトリを、それぞれ別の VS Code のウィンドウで開きます。

  code "$(pwd)/alice"
  code "$(pwd)/bob"

練習の例:
  1. alice のウィンドウで README.md の「今週の目標」を編集して commit し、push する
  2. bob のウィンドウで README.md の同じ行を別の内容に編集して commit し、push する
     → 先に Alice さんが push しているため拒否されます
  3. bob のウィンドウで pull してコンフリクトを解消し、もう一度 push する
  4. alice のウィンドウで pull して、Bob さんの変更を取り込む

（ターミナルだけで進める場合は、cd "$(pwd)/alice" と cd "$(pwd)/bob" で行き来します）
詳しい手順は exercises/README.md を参照してください。
EOF
