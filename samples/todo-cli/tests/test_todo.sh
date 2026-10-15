#!/usr/bin/env bash
#
# todo.sh のテスト
#
# 実行方法（todo-cli ディレクトリで）:
#   bash tests/test_todo.sh
#
# 新しい機能を追加したら、このファイルにテストも追加しましょう。
# テストは「準備 → 実行 → 結果の確認」の順に書きます。

set -uo pipefail

SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
TODO="${SCRIPT_DIR}/../todo.sh"

PASSED=0
FAILED=0

# テスト用の一時ディレクトリを作り、終了時に削除する
WORK_DIR=$(mktemp -d)
trap 'rm -rf "$WORK_DIR"' EXIT
export TODO_FILE="${WORK_DIR}/todo.txt"

# todo.sh を実行し、出力を OUTPUT、終了コードを STATUS に保存する
run_todo() {
  OUTPUT=$(bash "$TODO" "$@" 2>&1)
  STATUS=$?
}

# タスクファイルを空にする（各テストの最初に呼ぶ）
reset_todo() {
  rm -f "$TODO_FILE"
}

pass() {
  PASSED=$((PASSED + 1))
  echo "ok   - $1"
}

fail() {
  FAILED=$((FAILED + 1))
  echo "FAIL - $1"
  shift
  for msg in "$@"; do
    echo "       $msg"
  done
}

# 2 つの値が等しいことを確認する
#   assert_equal <テスト名> <期待値> <実際の値>
assert_equal() {
  if [ "$2" = "$3" ]; then
    pass "$1"
  else
    fail "$1" "期待値: $2" "実際  : $3"
  fi
}

# 文字列に指定した文字列が含まれることを確認する
#   assert_contains <テスト名> <探す文字列> <対象の文字列>
assert_contains() {
  case "$3" in
    *"$2"*) pass "$1" ;;
    *) fail "$1" "「$2」が含まれていません" "実際: $3" ;;
  esac
}

# ---------------------------------------------------------------------------
# help / version
# ---------------------------------------------------------------------------

run_todo help
assert_equal "help は終了コード 0 で終わる" 0 "$STATUS"
assert_contains "help は使い方を表示する" "使い方:" "$OUTPUT"

run_todo
assert_equal "引数なしは終了コード 1 で終わる" 1 "$STATUS"
assert_contains "引数なしは使い方を表示する" "使い方:" "$OUTPUT"

run_todo version
assert_equal "version はバージョンを表示する" "todo.sh 1.0.0" "$OUTPUT"

run_todo unknown
assert_equal "不明なコマンドは終了コード 1 で終わる" 1 "$STATUS"
assert_contains "不明なコマンドはエラーを表示する" "不明なコマンドです: unknown" "$OUTPUT"

# ---------------------------------------------------------------------------
# add
# ---------------------------------------------------------------------------

reset_todo
run_todo add "牛乳を買う"
assert_equal "add は終了コード 0 で終わる" 0 "$STATUS"
assert_equal "add は追加したタスクを表示する" "追加しました: 牛乳を買う" "$OUTPUT"
assert_equal "add はファイルに未完了のタスクを書き込む" "[ ] 牛乳を買う" "$(cat "$TODO_FILE")"

reset_todo
run_todo add レポートを 書く
assert_equal "add は複数の引数をスペースでつなげる" "[ ] レポートを 書く" "$(cat "$TODO_FILE")"

reset_todo
run_todo add
assert_equal "add に内容がないと終了コード 1 で終わる" 1 "$STATUS"
assert_contains "add に内容がないとエラーを表示する" "タスクの内容を指定してください" "$OUTPUT"

reset_todo
run_todo add "$(printf '1 行目\n2 行目')"
assert_equal "add に改行を含む内容を渡すと終了コード 1 で終わる" 1 "$STATUS"
assert_equal "add に改行を含む内容を渡してもタスクは追加されない" "" "$(cat "$TODO_FILE" 2>/dev/null)"

# エディタで編集して、最後の行に改行がない状態を再現する
reset_todo
printf '[ ] 牛乳を買う\n[ ] 部屋を掃除する' >"$TODO_FILE"
run_todo add "本を読む"
expected=$(printf '[ ] 牛乳を買う\n[ ] 部屋を掃除する\n[ ] 本を読む')
assert_equal "add は最後の行に改行がないファイルにも正しく追加する" "$expected" "$(cat "$TODO_FILE")"

# ---------------------------------------------------------------------------
# list
# ---------------------------------------------------------------------------

reset_todo
run_todo list
assert_equal "タスクがないときの list" "タスクはありません。" "$OUTPUT"

reset_todo
run_todo add "牛乳を買う"
run_todo add "部屋を掃除する"
run_todo list
expected=$(printf '  1 [ ] 牛乳を買う\n  2 [ ] 部屋を掃除する')
assert_equal "list はタスクを番号付きで表示する" "$expected" "$OUTPUT"

run_todo ls
assert_equal "ls は list と同じ結果になる" "$expected" "$OUTPUT"

# ---------------------------------------------------------------------------
# done
# ---------------------------------------------------------------------------

reset_todo
run_todo add "牛乳を買う"
run_todo add "部屋を掃除する"
run_todo "done" 2
assert_equal "done は終了コード 0 で終わる" 0 "$STATUS"
assert_equal "done は完了したタスクを表示する" "完了にしました: 部屋を掃除する" "$OUTPUT"
expected=$(printf '[ ] 牛乳を買う\n[x] 部屋を掃除する')
assert_equal "done は指定したタスクだけを完了にする" "$expected" "$(cat "$TODO_FILE")"

run_todo "done" 2
assert_equal "完了済みのタスクに done すると知らせる" "すでに完了しています: 部屋を掃除する" "$OUTPUT"

run_todo "done" 01
assert_equal "done は先頭に 0 が付いた番号も受け付ける" "完了にしました: 牛乳を買う" "$OUTPUT"

for bad in 0 3 abc; do
  run_todo "done" "$bad"
  assert_equal "done に不正な番号（${bad}）を渡すと終了コード 1 で終わる" 1 "$STATUS"
done

run_todo "done"
assert_equal "done に番号がないと終了コード 1 で終わる" 1 "$STATUS"

reset_todo
run_todo "done" 1
assert_equal "タスクがないときの done は終了コード 1 で終わる" 1 "$STATUS"

# エディタで編集して、最後の行に改行がない状態を再現する
reset_todo
printf '[ ] 牛乳を買う\n[ ] 部屋を掃除する' >"$TODO_FILE"
run_todo "done" 2
assert_equal "done は最後の行に改行がないファイルの最後のタスクも完了にできる" "完了にしました: 部屋を掃除する" "$OUTPUT"

reset_todo
printf 'メモ\n' >"$TODO_FILE"
run_todo "done" 1
assert_equal "done はタスクの形式でない行に対しては終了コード 1 で終わる" 1 "$STATUS"
assert_equal "done はタスクの形式でない行を変更しない" "メモ" "$(cat "$TODO_FILE")"

reset_todo
run_todo add "牛乳を買う"
chmod 644 "$TODO_FILE"
run_todo "done" 1
assert_equal "done はファイルの権限を変えない" "$TODO_FILE" "$(find "$TODO_FILE" -perm 644)"
assert_equal "done は一時ファイルを残さない" "todo.txt" "$(ls "$WORK_DIR")"

# ---------------------------------------------------------------------------
# 結果
# ---------------------------------------------------------------------------

echo
echo "結果: ${PASSED} 件成功, ${FAILED} 件失敗"
[ "$FAILED" -eq 0 ]
