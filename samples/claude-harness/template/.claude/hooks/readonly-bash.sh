#!/usr/bin/env bash
#
# test-reviewer サブエージェントのフック（PreToolUse）から呼ばれるスクリプト（readonly-bash.sh）
#
# サブエージェントが Bash でコマンドを実行する直前に呼ばれ、決まった形の読み取りだけのコマンド
# （git diff / git log / git show / git status）以外を止めます。
# テストの実行（bash tests/test_todo.sh）も止めます。レビューするテストのファイルに書かれた
# コマンドがそのまま実行されてしまうためです。
# subagent の説明に「ファイルを変更しない」と書くだけでは「お願い」なので、フックで確実に止めます。
#
# 「危ないものを止める」のではなく「安全だと分かっているものだけを通す」考え方（許可リスト）で確かめます。
#   1. 使える文字を、英数字と . _ / : @ ~ ^ = , + - と空白だけに限る
#      （引用符、\、$、`、{ }、; & | < > などを含むコマンドは、シェルが別の意味に変えてしまうので通さない）
#   2. 空白で区切った最初の 2 語が、git diff / git log / git show / git status であること
#   3. - で始まる語（オプション）は、下の一覧にあるものだけ
#   4. それ以外の語（ブランチ名やファイル名）は、リポジトリの外を指していないこと
#      （/ や ~ や = で始まらない。途中や最後も含めて、.. の部分がない）。
#      = で始まる語は、zsh（macOS の標準のシェル）が =ls → /bin/ls のようにコマンドのパスに置き換えるため止める
#      秘密の情報を書くファイル（.env、.env.local など）も、名前で指定できない
#      （.env をコミットしてしまうと、git log -p などの出力には含まれてしまいます。.env はコミットしないこと）
#
# このフックが防ぐのは、test-reviewer がコマンドでファイルを変更したり、リポジトリの外を読んだりすることです。
# git の設定（.git/config など）があらかじめ書き換えられている場合までは防げません。
# このフックが確かめるのは Bash のコマンドだけです。Read や Grep のツールで .env を読むことは、
# .claude/settings.json の deny（発展編 第 5 章）で防ぎます。
#
# 終了コードの意味（Claude Code のフックの決まり）:
#   0 : 実行してよい
#   2 : 実行させない。標準エラー出力の内容が Claude に渡される
#
# JSON を読むために jq を使います（発展編 第 1 章でインストールします）。
# 環境変数 JQ で、使う jq のパスを変えられます（テスト用）。

set -uo pipefail

JQ="${JQ:-jq}"

if ! command -v "$JQ" >/dev/null 2>&1; then
  echo "jq が見つからないため、コマンドを確認できません。安全のために実行を止めました（発展編 第 1 章の手順でインストールしてください）" >&2
  exit 2
fi

# 標準入力で渡される JSON から、実行しようとしているコマンド（tool_input.command）を取り出す
#   例: {"tool_name":"Bash","tool_input":{"command":"git diff main...HEAD -- tests/","description":"..."},...}
#   // empty: 項目がないときに、null ではなく空の文字列にする
if ! command=$("$JQ" -r '.tool_input.command // empty'); then
  echo "フックが受け取った JSON を読み取れないため、コマンドを確認できません。安全のために実行を止めました" >&2
  exit 2
fi

block() {
  {
    echo "test-reviewer が実行できるのは、git diff / git log / git show / git status（--stat などの決まったオプションだけ）だけです。"
    echo "止めたコマンド: ${command}"
    echo "理由: $1"
  } >&2
  exit 2
}

# 1. 使える文字だけでできているか
case "$command" in
  '' | *[!A-Za-z0-9._/:@~^=,+\ -]*) block "使えない文字（引用符、\\、\$ など）が含まれています" ;;
esac

# 2. 最初の 2 語
set -f # 念のため、* などをファイル名に展開しないようにしてから、空白で区切る（* などは 1. ですでに止めている）
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
    /* | ~* | =*) block "リポジトリの外を指している可能性があります: ${word}" ;;
  esac
  # .. の部分（../x、x/../y、./.. や HEAD:.. など）。前後に / を付け、: も / とみなして、/../ を探す
  case "/${word//://}/" in
    */../*) block "リポジトリの外を指している可能性があります: ${word}" ;;
  esac
  # 秘密の情報を書くファイル。HEAD:.env や config/.env.local のような書き方もあるので、
  # 最後の / または : より後ろ（ファイル名）で比べる
  case "${word##*[/:]}" in
    .env | .env.*) block "秘密の情報を書くファイル（.env など）は読めません: ${word}" ;;
  esac
done

exit 0
