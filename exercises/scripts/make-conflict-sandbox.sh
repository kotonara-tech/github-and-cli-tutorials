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

if [ -e "$TARGET" ]; then
  echo "エラー: ${TARGET} はすでに存在します。" >&2
  echo "       もう一度作り直すときは rm -rf ${TARGET} で削除してから実行してください。" >&2
  exit 1
fi

# リポジトリの中にリポジトリを作ると混乱のもとになるので、作成を止める
PARENT=$(dirname "$TARGET")
if git -C "$PARENT" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "エラー: ${PARENT} は Git リポジトリの中です。" >&2
  echo "       cd ~ などでリポジトリの外に移動してから実行してください。" >&2
  exit 1
fi

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
