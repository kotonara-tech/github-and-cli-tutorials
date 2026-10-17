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
#   1 : フック自体の問題（shellcheck が見つからないなど）。Claude には伝わらず、
#       Claude Code の会話の表示に「hook error」として、標準エラー出力の 1 行目が表示される
#
# 環境変数 SHELLCHECK で、使う shellcheck のパスを変えられます（テスト用）。

# JSON から値を取り出す関数を読み込む（.claude/hooks/lib/ もあわせてコピーしておく）
json_lib="$(dirname "$0")/lib/json.sh"
if [ ! -f "$json_lib" ]; then
  echo "${json_lib} が見つからないため、shellcheck のフックを実行できませんでした（.claude/hooks/ をまとめてコピーしてください）" >&2
  exit 1
fi
# shellcheck source-path=SCRIPTDIR
# shellcheck source=lib/json.sh
source "$json_lib"

set -uo pipefail

SHELLCHECK="${SHELLCHECK:-shellcheck}"

# 標準入力で渡される JSON から、編集したファイルのパス（tool_input.file_path）を取り出す
#   例: {"tool_name":"Edit","tool_input":{"file_path":"/home/hanako/todo-cli-practice/todo.sh",...},...}
file=$(json_string_field file_path)

# シェルスクリプト以外は対象外
case "$file" in
  *.sh) ;;
  *) exit 0 ;;
esac

if [ ! -f "$file" ]; then
  echo "編集したファイルが見つからないため、shellcheck を実行できませんでした: ${file}" >&2
  exit 1
fi

if ! command -v "$SHELLCHECK" >/dev/null 2>&1; then
  echo "shellcheck が見つからないため、${file##*/} をチェックできませんでした（発展編 第 1 章の手順でインストールしてください）" >&2
  exit 1
fi

# 「shellcheck」の終了コード: 0 = 警告なし、1 = 警告あり、それ以外 = 実行できなかった
# -x: source で読み込んでいるファイルもたどってチェックする
output=$("$SHELLCHECK" --color=never -x "$file" 2>&1)
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
