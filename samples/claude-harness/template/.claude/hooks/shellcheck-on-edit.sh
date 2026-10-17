#!/usr/bin/env bash
#
# Claude Code のフック（PostToolUse）から呼ばれるスクリプト（shellcheck-on-edit.sh）
#
# Claude がファイルを編集・作成した直後に実行されます。
# 編集したファイルがシェルスクリプト（.sh）なら shellcheck でチェックし、
# 警告があれば、その内容を Claude に伝えて直してもらいます。
#
# 終了コードの意味（Claude Code のフックの決まり）:
#   0 : 問題なし。何も伝えない
#   2 : 警告あり。標準エラー出力の内容が Claude に渡される
#   1 : フック自体の問題（shellcheck が見つからないなど）。あなたの画面に通知される
#
# 環境変数 SHELLCHECK で、使う shellcheck のパスを変えられます（テスト用）。

set -uo pipefail

SHELLCHECK="${SHELLCHECK:-shellcheck}"

# 標準入力で渡される JSON から、編集したファイルのパス（tool_input.file_path）を取り出す。
#   例: {"tool_name":"Edit","tool_input":{"file_path":"/home/hanako/todo-cli-practice/todo.sh",...},...}
# jq は macOS に入っていないことがあるので、grep と sed で最初に見つかった file_path を使う
input=$(cat)
file=$(printf '%s\n' "$input" |
  grep -o '"file_path"[[:space:]]*:[[:space:]]*"[^"]*"' |
  head -n 1 |
  sed 's/^"file_path"[[:space:]]*:[[:space:]]*"\(.*\)"$/\1/')

# シェルスクリプト以外と、存在しないファイルは対象外
case "$file" in
  *.sh) ;;
  *) exit 0 ;;
esac
if [ ! -f "$file" ]; then
  exit 0
fi

if ! command -v "$SHELLCHECK" >/dev/null 2>&1; then
  echo "shellcheck が見つからないため、${file##*/} をチェックできませんでした（発展編 第 1 章の手順でインストールしてください）" >&2
  exit 1
fi

# 「shellcheck」の終了コード: 0 = 警告なし、1 = 警告あり、それ以外 = 実行できなかった
output=$("$SHELLCHECK" --color=never "$file" 2>&1)
status=$?
case "$status" in
  0)
    exit 0
    ;;
  1)
    {
      echo "shellcheck が ${file##*/} に警告を出しました。次に進む前に直してください。"
      echo "$output"
    } >&2
    exit 2
    ;;
  *)
    echo "shellcheck を実行できませんでした（終了コード ${status}）: ${output}" >&2
    exit 1
    ;;
esac
