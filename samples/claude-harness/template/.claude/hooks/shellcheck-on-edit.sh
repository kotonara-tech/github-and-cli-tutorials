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
# JSON を読むために jq を使います（shellcheck とあわせて、発展編 第 1 章でインストールします）。
# 環境変数 JQ と SHELLCHECK で、使うコマンドのパスを変えられます（テスト用）。

set -uo pipefail

JQ="${JQ:-jq}"
SHELLCHECK="${SHELLCHECK:-shellcheck}"

if ! command -v "$JQ" >/dev/null 2>&1; then
  echo "jq が見つからないため、shellcheck のフックを実行できませんでした（発展編 第 1 章の手順でインストールしてください）" >&2
  exit 1
fi

# 標準入力で渡される JSON から、編集したファイルのパス（tool_input.file_path）を取り出す
#   例: {"tool_name":"Edit","tool_input":{"file_path":"/home/hanako/todo-cli-practice/todo.sh",...},...}
#   // empty: 項目がないときに、null ではなく空の文字列にする
if ! file=$("$JQ" -r '.tool_input.file_path // empty'); then
  echo "フックが受け取った JSON を読み取れないため、shellcheck を実行できませんでした" >&2
  exit 1
fi

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
# --source-path=SCRIPTDIR: 読み込むファイルを、チェックするスクリプトと同じディレクトリから探す
output=$("$SHELLCHECK" --color=never -x --source-path=SCRIPTDIR "$file" 2>&1)
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
