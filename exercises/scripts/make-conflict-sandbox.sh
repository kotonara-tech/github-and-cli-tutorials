#!/usr/bin/env bash
#
# make-conflict-sandbox.sh - コンフリクト（競合）を練習するためのリポジトリを作る
#
# 使い方:
#   bash make-conflict-sandbox.sh [作成先ディレクトリ]
#
# 作成先を省略すると、カレントディレクトリに conflict-sandbox を作ります。
# 作成されるリポジトリには 2 つのブランチがあり、profile.txt の同じ行を
# それぞれ別の内容に変更しています。
#
#   main                 : 「趣味」を「読書」に変更
#   feature/update-hobby : 「趣味」を「料理」に変更
#
# main で feature/update-hobby をマージすると、コンフリクトが発生します。

set -euo pipefail

TARGET="${1:-conflict-sandbox}"

# 作成先がすでにないか、Git リポジトリの中ではないかを確認する（中身は lib/common.sh）
# shellcheck source=lib/common.sh
source "$(dirname "$0")/lib/common.sh"
check_sandbox_target "$TARGET"

# 練習用のコミットは「Tutorial Bot」という架空のユーザーとして作る
# （このスクリプトの中だけで有効です。あなたの Git の設定は変わりません）
export GIT_AUTHOR_NAME="Tutorial Bot"
export GIT_AUTHOR_EMAIL="tutorial-bot@example.com"
export GIT_COMMITTER_NAME="$GIT_AUTHOR_NAME"
export GIT_COMMITTER_EMAIL="$GIT_AUTHOR_EMAIL"

mkdir -p "$TARGET"
cd "$TARGET"
git init -q -b main

# 1. 最初のコミット
cat >profile.txt <<'EOF'
名前: 山田 花子
出身: 東京都
趣味: （未設定）
好きな食べ物: カレー
EOF
git add profile.txt
git commit -q -m "プロフィールを追加"

# 2. feature/update-hobby ブランチで「趣味」を変更する
git switch -q -c feature/update-hobby
cat >profile.txt <<'EOF'
名前: 山田 花子
出身: 東京都
趣味: 料理
好きな食べ物: カレー
EOF
git commit -q -am "趣味を料理に変更"

# 3. main ブランチでも同じ行を別の内容に変更する
git switch -q main
cat >profile.txt <<'EOF'
名前: 山田 花子
出身: 東京都
趣味: 読書
好きな食べ物: カレー
EOF
git commit -q -am "趣味を読書に変更"

cat <<EOF
コンフリクト練習用のリポジトリを作成しました: $(pwd)

次のコマンドで、ブランチの状態を確認してからマージしてみましょう。

  cd $(pwd)
  git log --oneline --graph --all
  git merge feature/update-hobby

コンフリクトの解消方法は docs/04-branch.md を参照してください。
EOF
