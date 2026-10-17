#!/usr/bin/env bash
#
# template/.claude/hooks/ のフックのスクリプトのテスト
#
# 実行方法（リポジトリのルートで）:
#   bash samples/claude-harness/tests/test_hooks.sh
#
# Claude Code がフックに渡すのと同じ形の JSON を標準入力に渡し、
# 終了コードと標準エラー出力を確かめます。shellcheck が必要です。
#
# assert_equal などの関数は samples/todo-cli/tests/test_todo.sh と同じものです。
# それぞれのテストを 1 つのファイルだけで読めるように、あえて共通化していません。

set -uo pipefail

SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
HOOKS_DIR="${SCRIPT_DIR}/../template/.claude/hooks"
EDIT_HOOK="${HOOKS_DIR}/shellcheck-on-edit.sh"
READONLY_HOOK="${HOOKS_DIR}/readonly-bash.sh"

PASSED=0
FAILED=0

# テスト用の一時ディレクトリを作り、終了時に削除する
WORK_DIR=$(mktemp -d)
trap 'rm -rf "$WORK_DIR"' EXIT

# フックを実行し、標準エラー出力を ERR、終了コードを STATUS に保存する
#   run_hook <フックのスクリプト> <標準入力に渡す JSON>
# 環境変数を変えたいときは、SHELLCHECK=... run_hook ... のように前に書く
run_hook() {
  ERR=$(printf '%s' "$2" | bash "$1" 2>&1 >/dev/null)
  STATUS=$?
}

# Edit ツールの入力を表す JSON を作る（パスの \ と " は JSON のエスケープにする）
#   edit_json <ファイルのパス>
edit_json() {
  local path="$1"
  path=${path//\\/\\\\}
  path=${path//\"/\\\"}
  printf '{"tool_name":"Edit","tool_input":{"file_path":"%s","old_string":"a","new_string":"b"},"tool_response":{"filePath":"%s"}}' "$path" "$path"
}

# Bash ツールの入力を表す JSON を作る（\ と " と改行は JSON のエスケープにする）
#   bash_json <コマンド>
bash_json() {
  local command="$1"
  command=${command//\\/\\\\}
  command=${command//\"/\\\"}
  command=${command//$'\n'/\\n}
  printf '{"tool_name":"Bash","tool_input":{"command":"%s","description":"テスト用"}}' "$command"
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

assert_equal() {
  if [ "$2" = "$3" ]; then
    pass "$1"
  else
    fail "$1" "期待値: $2" "実際  : $3"
  fi
}

assert_contains() {
  case "$3" in
    *"$2"*) pass "$1" ;;
    *) fail "$1" "「$2」が含まれていません" "実際: $3" ;;
  esac
}

# 準備: 警告のないスクリプト、警告のあるスクリプト、シェルスクリプト以外のファイル
cat >"${WORK_DIR}/good.sh" <<'SCRIPT'
#!/usr/bin/env bash
name="world"
echo "hello, ${name}"
SCRIPT
cat >"${WORK_DIR}/bad.sh" <<'SCRIPT'
#!/usr/bin/env bash
cd /tmp
echo "hello"
SCRIPT
cp "${WORK_DIR}/bad.sh" "${WORK_DIR}/a b\\c.sh"
echo "# メモ" >"${WORK_DIR}/notes.md"

# ---------------------------------------------------------------------------
# 編集のフック（shellcheck-on-edit.sh）: 対象外のファイル
# ---------------------------------------------------------------------------

run_hook "$EDIT_HOOK" "$(edit_json "${WORK_DIR}/notes.md")"
assert_equal ".sh 以外のファイルは終了コード 0 で終わる" 0 "$STATUS"
assert_equal ".sh 以外のファイルは何も表示しない" "" "$ERR"

run_hook "$EDIT_HOOK" '{"tool_name":"Bash","tool_input":{"command":"ls"}}'
assert_equal "file_path がない入力は終了コード 0 で終わる" 0 "$STATUS"

run_hook "$EDIT_HOOK" "$(edit_json "${WORK_DIR}/missing.sh")"
assert_equal "見つからない .sh は終了コード 1 で終わる（あなたに通知する）" 1 "$STATUS"
assert_contains "見つからない .sh はその旨を表示する" "見つからない" "$ERR"

# ---------------------------------------------------------------------------
# 編集のフック（shellcheck-on-edit.sh）: シェルスクリプト
# ---------------------------------------------------------------------------

run_hook "$EDIT_HOOK" "$(edit_json "${WORK_DIR}/good.sh")"
assert_equal "警告のないスクリプトは終了コード 0 で終わる" 0 "$STATUS"
assert_equal "警告のないスクリプトは何も表示しない" "" "$ERR"

run_hook "$EDIT_HOOK" "$(edit_json "${WORK_DIR}/bad.sh")"
assert_equal "警告のあるスクリプトは終了コード 2 で終わる（Claude に伝える）" 2 "$STATUS"
assert_contains "警告のあるスクリプトはファイル名を表示する" "bad.sh に警告" "$ERR"
assert_contains "警告のあるスクリプトは shellcheck の警告番号を表示する" "SC2164" "$ERR"

run_hook "$EDIT_HOOK" "$(edit_json "${WORK_DIR}/a b\\c.sh")"
assert_equal "空白や \\ を含むパス（JSON のエスケープ）も正しく読み取る" 2 "$STATUS"

# 項目が 2 つあるときは、最初の file_path（tool_input の中のもの）を使う
run_hook "$EDIT_HOOK" "$(printf '{"tool_input":{"file_path":"%s"},"other":{"file_path":"%s"}}' "${WORK_DIR}/bad.sh" "${WORK_DIR}/good.sh")"
assert_equal "file_path が 2 つあるときは最初のものをチェックする" 2 "$STATUS"

# 書き込む内容（content）の中のエスケープされた "file_path" は、項目として扱わない
run_hook "$EDIT_HOOK" "$(printf '{"tool_name":"Write","tool_input":{"content":"echo \\"file_path\\": \\"%s\\"","file_path":"%s"}}' "${WORK_DIR}/good.sh" "${WORK_DIR}/bad.sh")"
assert_equal "content の中の \"file_path\" という文字列は項目として扱わない" 2 "$STATUS"

# \uXXXX のエスケープ（ここでは \u002e = .）も元の文字に戻す
run_hook "$EDIT_HOOK" "$(printf '{"tool_input":{"file_path":"%s/bad\\u002esh"}}' "$WORK_DIR")"
assert_equal "\\uXXXX のエスケープを戻してからチェックする" 2 "$STATUS"

SHELLCHECK="${WORK_DIR}/no-such-shellcheck" run_hook "$EDIT_HOOK" "$(edit_json "${WORK_DIR}/good.sh")"
assert_equal "shellcheck がないときは終了コード 1 で終わる（あなたに通知する）" 1 "$STATUS"
assert_contains "shellcheck がないときはその旨を表示する" "shellcheck が見つからない" "$ERR"

# lib/json.sh をコピーし忘れた場合
mkdir -p "${WORK_DIR}/hooks-without-lib"
cp "$EDIT_HOOK" "$READONLY_HOOK" "${WORK_DIR}/hooks-without-lib/"
run_hook "${WORK_DIR}/hooks-without-lib/shellcheck-on-edit.sh" "$(edit_json "${WORK_DIR}/bad.sh")"
assert_equal "lib/json.sh がないときは終了コード 1 で終わる（あなたに通知する）" 1 "$STATUS"
assert_contains "lib/json.sh がないときはその旨を表示する" "lib/json.sh が見つからない" "$ERR"

# ---------------------------------------------------------------------------
# readonly-bash.sh: 読み取りだけのコマンドは実行してよい
# ---------------------------------------------------------------------------

for command in "git diff main...HEAD -- tests/" "git log --oneline -5" 'git log --format="%h %s"' "git show HEAD" "git status" "bash tests/test_todo.sh"; do
  run_hook "$READONLY_HOOK" "$(bash_json "$command")"
  assert_equal "読み取りだけのコマンドは実行してよい: ${command}" 0 "$STATUS"
done

# ---------------------------------------------------------------------------
# readonly-bash.sh: それ以外のコマンドは止める
# ---------------------------------------------------------------------------

for command in "git commit -m x" "git checkout -- tests/" "sed -i s/a/b/ todo.sh" "rm -rf tests" \
  "git diff > out.txt" "git diff; rm -rf tests" "git diff && rm -rf tests" "git log | tee out.txt" \
  "git log \$(touch x)" "git log \`touch x\`" "git log -1"$'\n'"rm -rf tests" \
  "git diff --output=out.txt" "git diff --ext-diff" "git log -p --textconv" "git diff --no-index /dev/null .env"; do
  run_hook "$READONLY_HOOK" "$(bash_json "$command")"
  assert_equal "読み取り以外のコマンドは止める（終了コード 2）: ${command//$'\n'/\\n}" 2 "$STATUS"
done

run_hook "$READONLY_HOOK" '{"tool_name":"Bash","tool_input":{"description":"command がない"}}'
assert_equal "command が取り出せないときは止める（終了コード 2）" 2 "$STATUS"

run_hook "${WORK_DIR}/hooks-without-lib/readonly-bash.sh" "$(bash_json "git status")"
assert_equal "lib/json.sh がないときは、安全のために止める（終了コード 2）" 2 "$STATUS"

run_hook "$READONLY_HOOK" "$(bash_json "git commit -m x")"
assert_contains "止めたときは理由を Claude に伝える" "test-reviewer が実行できるのは" "$ERR"

# ---------------------------------------------------------------------------
# 結果
# ---------------------------------------------------------------------------

echo
echo "結果: ${PASSED} 件成功, ${FAILED} 件失敗"
[ "$FAILED" -eq 0 ]
