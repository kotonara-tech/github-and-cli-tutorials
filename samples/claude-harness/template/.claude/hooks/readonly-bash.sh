#!/usr/bin/env bash
#
# test-reviewer サブエージェントのフック（PreToolUse）から呼ばれるスクリプト（readonly-bash.sh）
#
# サブエージェントが Bash でコマンドを実行する直前に呼ばれ、決まった形の読み取りだけのコマンド
# （git diff / git log / git show / git status と、bash tests/test_todo.sh）以外を止めます。
# subagent の説明に「ファイルを変更しない」と書くだけでは「お願い」なので、フックで確実に止めます。
#
# 「危ないものを止める」のではなく「安全だと分かっているものだけを通す」考え方（許可リスト）で確かめます。
#   1. 使える文字を、英数字と . _ / : @ ~ ^ = , + - と空白だけに限る
#      （引用符、\、$、`、{ }、; & | < > などを含むコマンドは、シェルが別の意味に変えてしまうので通さない）
#   2. 空白で区切った最初の 2 語が、git diff / git log / git show / git status であること
#   3. - で始まる語（オプション）は、下の一覧にあるものだけ
#   4. それ以外の語（ブランチ名やファイル名）は、リポジトリの外を指していないこと（/ や ~ や .. で始まらない）
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
  {
    echo "test-reviewer が実行できるのは、git diff / git log / git show / git status（--stat などの決まったオプションだけ）と bash tests/test_todo.sh だけです。"
    echo "止めたコマンド: ${command}"
    echo "理由: $1"
  } >&2
  exit 2
}

if [ "$command" = "bash tests/test_todo.sh" ]; then
  exit 0
fi

# 1. 使える文字だけでできているか
case "$command" in
  '' | *[!A-Za-z0-9._/:@~^=,+\ -]*) block "使えない文字（引用符、\\、\$ など）が含まれています" ;;
esac

# 2. 最初の 2 語
set -f # * などをファイル名に展開しないようにしてから、空白で区切る
# shellcheck disable=SC2086 # 空白で区切るために、わざと引用符を付けない
set -- $command
case "${1:-} ${2:-}" in
  'git diff' | 'git log' | 'git show' | 'git status') ;;
  *) block "git diff / git log / git show / git status 以外のコマンドです" ;;
esac
shift 2

# 3. と 4. 残りの語
for word in "$@"; do
  case "$word" in
    --) ;;
    --stat | --shortstat | --numstat | --name-only | --name-status | --oneline | --graph | --decorate | \
      --patch | -p | --cached | --staged | --no-color | --reverse | --follow | --short | -s | \
      -[0-9] | -[0-9][0-9] | -n[0-9] | -n[0-9][0-9] | --max-count=[0-9] | --max-count=[0-9][0-9] | \
      -U[0-9] | -U[0-9][0-9] | --unified=[0-9] | --unified=[0-9][0-9]) ;;
    -*) block "使えないオプションです: ${word}" ;;
    /* | ~* | .. | ../* | */../* | */..) block "リポジトリの外を指している可能性があります: ${word}" ;;
  esac
done

exit 0
