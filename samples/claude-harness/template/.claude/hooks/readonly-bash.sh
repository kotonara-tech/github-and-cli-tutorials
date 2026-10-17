#!/usr/bin/env bash
#
# test-reviewer サブエージェントのフック（PreToolUse）から呼ばれるスクリプト（readonly-bash.sh）
#
# サブエージェントが Bash でコマンドを実行する直前に呼ばれ、読み取りだけのコマンド
# （git diff / git log / git show / git status）と、テストの実行（bash tests/test_todo.sh）
# 以外を止めます。subagent の説明に「ファイルを変更しない」と書くだけでは「お願い」なので、
# フックで確実に止めます。
#
# 終了コードの意味（Claude Code のフックの決まり）:
#   0 : 実行してよい
#   2 : 実行させない。標準エラー出力の内容が Claude に渡される

# JSON から値を取り出す関数を読み込む。見つからないときは、安全のためにコマンドを止める
json_lib="$(dirname "$0")/lib/json.sh"
if [ ! -f "$json_lib" ]; then
  echo "${json_lib} が見つからないため、コマンドを確認できません。実行を止めました（.claude/hooks/ をまとめてコピーしてください）" >&2
  exit 2
fi
# shellcheck source-path=SCRIPTDIR
# shellcheck source=lib/json.sh
source "$json_lib"

set -uo pipefail

# 標準入力で渡される JSON から、実行しようとしているコマンド（tool_input.command）を取り出す
command=$(json_string_field command)

block() {
  echo "test-reviewer が実行できるのは、git diff / git log / git show / git status と bash tests/test_todo.sh だけです: ${command}" >&2
  exit 2
}

# 複数のコマンドをつなぐ記号、リダイレクト、コマンドの置き換え、改行を含むものは止める
case "$command" in
  *[\;\&\|\<\>\`]* | *"\$("* | *$'\n'*) block ;;
esac

# 結果をファイルに書き出す、外部のプログラムを動かす、リポジトリの外のファイルを読む git のオプションは止める
case "$command" in
  *--output* | *--ext-diff* | *--textconv* | *--no-index*) block ;;
esac

case "$command" in
  'git diff' | 'git diff '* | 'git log' | 'git log '* | 'git show' | 'git show '* | 'git status' | 'git status '*) exit 0 ;;
  'bash tests/test_todo.sh') exit 0 ;;
  *) block ;;
esac
