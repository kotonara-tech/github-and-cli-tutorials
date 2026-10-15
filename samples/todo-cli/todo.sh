#!/usr/bin/env bash
#
# todo.sh - シンプルな TODO 管理 CLI
#
# GitHub / CLI チュートリアルの演習用サンプルです。
# 機能追加やバグ修正を Issue → ブランチ → Pull Request の流れで練習するために使います。
#
# 使い方:
#   ./todo.sh add "牛乳を買う"   タスクを追加する
#   ./todo.sh list              タスクを一覧表示する
#   ./todo.sh done 1            1 番のタスクを完了にする
#   ./todo.sh help              ヘルプを表示する
#
# タスクは環境変数 TODO_FILE で指定したファイル（既定: ./todo.txt）に
# 1 行 1 タスクで保存されます。
#   [ ] 未完了のタスク
#   [x] 完了したタスク

# エラーが起きたらすぐに終了する（-e）、未定義の変数を使ったらエラーにする（-u）、
# パイプの途中で失敗したらエラーにする（-o pipefail）
set -euo pipefail

readonly VERSION="1.0.0"
TODO_FILE="${TODO_FILE:-./todo.txt}"

# ヘルプメッセージを表示する
usage() {
  cat <<'EOF'
使い方: todo.sh <コマンド> [引数]

コマンド:
  add <内容>    タスクを追加する
  list          タスクを一覧表示する（ls でも可）
  done <番号>   指定した番号のタスクを完了にする
  help          このヘルプを表示する
  version       バージョンを表示する

環境変数:
  TODO_FILE     タスクを保存するファイル（既定: ./todo.txt）
EOF
}

# エラーメッセージを標準エラー出力に表示して終了する
die() {
  echo "エラー: $*" >&2
  exit 1
}

# タスクの件数を数える
# （wc -l は改行の数を数えるため、最後の行に改行がないと 1 件少なくなる。awk なら正しく数えられる）
count_tasks() {
  if [ -f "$TODO_FILE" ]; then
    awk 'END { print NR }' "$TODO_FILE"
  else
    echo 0
  fi
}

# awk でタスクのファイルを書き換える
#   rewrite_tasks <awk に渡す引数...>
# 一時ファイルに書き出してから中身を書き戻すので、awk が途中で失敗しても元のファイルは壊れず、
# ファイルの権限もそのまま保たれる
rewrite_tasks() {
  local tmp
  tmp=$(mktemp "${TODO_FILE}.XXXXXX")
  if ! awk "$@" "$TODO_FILE" >"$tmp"; then
    rm -f "$tmp"
    die "タスクのファイルを書き換えられませんでした: ${TODO_FILE}"
  fi
  cat "$tmp" >"$TODO_FILE"
  rm -f "$tmp"
}

# タスクを追加する
cmd_add() {
  if [ $# -eq 0 ]; then
    die "追加するタスクの内容を指定してください（例: todo.sh add \"牛乳を買う\"）"
  fi
  local text="$*"
  # 改行を含む内容は「1 行 1 タスク」の形式が崩れるので受け付けない
  case "$text" in
    *$'\n'*) die "タスクの内容に改行は含められません" ;;
  esac
  # エディタで編集したなどで、ファイルの最後が改行で終わっていない場合は、
  # 新しいタスクが前の行につながらないように改行を補う
  if [ -s "$TODO_FILE" ] && [ -n "$(tail -c 1 "$TODO_FILE")" ]; then
    echo >>"$TODO_FILE"
  fi
  printf '[ ] %s\n' "$text" >>"$TODO_FILE"
  echo "追加しました: $text"
}

# タスクを番号付きで一覧表示する
cmd_list() {
  if [ ! -s "$TODO_FILE" ]; then
    echo "タスクはありません。"
    return 0
  fi
  local n=0 line
  while IFS= read -r line || [ -n "$line" ]; do
    n=$((n + 1))
    printf '%3d %s\n' "$n" "$line"
  done <"$TODO_FILE"
}

# 指定した番号のタスクを完了にする
cmd_done() {
  if [ $# -ne 1 ]; then
    die "完了にするタスクの番号を 1 つ指定してください（例: todo.sh done 1）"
  fi
  case "$1" in
    '' | *[!0-9]*) die "番号は数字で指定してください: $1" ;;
  esac
  # 先頭の 0 を取り除いて 10 進数として扱う（例: 01 → 1）
  local num=$((10#$1))

  local total
  total=$(count_tasks)
  if [ "$num" -lt 1 ] || [ "$num" -gt "$total" ]; then
    die "${num} 番のタスクはありません（todo.sh list で番号を確認してください）"
  fi

  local line
  line=$(sed -n "${num}p" "$TODO_FILE")
  case "$line" in
    '[ ] '*) ;;
    '[x] '*)
      echo "すでに完了しています: ${line#\[x\] }"
      return 0
      ;;
    *) die "${num} 番の行がタスクの形式（[ ] または [x] で始まる）になっていません: ${line}" ;;
  esac

  # n 行目の先頭の [ ] を [x] に置き換える
  rewrite_tasks -v n="$num" 'NR == n { sub(/^\[ \]/, "[x]") } { print }'
  echo "完了にしました: ${line#\[ \] }"
}

main() {
  if [ $# -eq 0 ]; then
    usage >&2
    exit 1
  fi

  local cmd="$1"
  shift
  case "$cmd" in
    add) cmd_add "$@" ;;
    list | ls) cmd_list ;;
    done) cmd_done "$@" ;;
    help | -h | --help) usage ;;
    version | -v | --version) echo "todo.sh ${VERSION}" ;;
    *)
      echo "エラー: 不明なコマンドです: ${cmd}" >&2
      echo >&2
      usage >&2
      exit 1
      ;;
  esac
}

main "$@"
