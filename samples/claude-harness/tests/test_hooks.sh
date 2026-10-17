#!/usr/bin/env bash
#
# template/.claude/hooks/shellcheck-on-edit.sh のテスト
#
# 実行方法（リポジトリのルートで）:
#   bash samples/claude-harness/tests/test_hooks.sh
#
# Claude Code が PostToolUse フックに渡すのと同じ形の JSON を標準入力に渡し、
# 終了コードと標準エラー出力を確かめます。shellcheck が必要です。

set -uo pipefail

SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
HOOK="${SCRIPT_DIR}/../template/.claude/hooks/shellcheck-on-edit.sh"

PASSED=0
FAILED=0

# テスト用の一時ディレクトリを作り、終了時に削除する
WORK_DIR=$(mktemp -d)
trap 'rm -rf "$WORK_DIR"' EXIT

# フックを実行し、標準エラー出力を ERR、終了コードを STATUS に保存する
#   run_hook <標準入力に渡す JSON>
run_hook() {
  ERR=$(printf '%s' "$1" | bash "$HOOK" 2>&1 >/dev/null)
  STATUS=$?
}

# Edit ツールの入力を表す JSON を作る
#   edit_json <ファイルのパス>
edit_json() {
  printf '{"tool_name":"Edit","tool_input":{"file_path":"%s","old_string":"a","new_string":"b"},"tool_response":{"filePath":"%s"}}' "$1" "$1"
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
echo "# メモ" >"${WORK_DIR}/notes.md"

# ---------------------------------------------------------------------------
# 対象外のファイル
# ---------------------------------------------------------------------------

run_hook "$(edit_json "${WORK_DIR}/notes.md")"
assert_equal ".sh 以外のファイルは終了コード 0 で終わる" 0 "$STATUS"
assert_equal ".sh 以外のファイルは何も表示しない" "" "$ERR"

run_hook "$(edit_json "${WORK_DIR}/missing.sh")"
assert_equal "存在しないファイルは終了コード 0 で終わる" 0 "$STATUS"

run_hook '{"tool_name":"Bash","tool_input":{"command":"ls"}}'
assert_equal "file_path がない入力は終了コード 0 で終わる" 0 "$STATUS"

# ---------------------------------------------------------------------------
# シェルスクリプト
# ---------------------------------------------------------------------------

run_hook "$(edit_json "${WORK_DIR}/good.sh")"
assert_equal "警告のないスクリプトは終了コード 0 で終わる" 0 "$STATUS"
assert_equal "警告のないスクリプトは何も表示しない" "" "$ERR"

run_hook "$(edit_json "${WORK_DIR}/bad.sh")"
assert_equal "警告のあるスクリプトは終了コード 2 で終わる（Claude に伝える）" 2 "$STATUS"
assert_contains "警告のあるスクリプトはファイル名を表示する" "bad.sh に警告" "$ERR"
assert_contains "警告のあるスクリプトは shellcheck の警告番号を表示する" "SC2164" "$ERR"

# Write ツールで、内容に "file_path" という文字列を含むファイルを作った場合も、
# 最初の file_path（作ったファイル）をチェックする
run_hook "$(printf '{"tool_name":"Write","tool_input":{"file_path":"%s","content":"echo \\"file_path\\": \\"x.md\\""}}' "${WORK_DIR}/bad.sh")"
assert_equal "Write の入力でも最初の file_path をチェックする" 2 "$STATUS"

# ---------------------------------------------------------------------------
# 「shellcheck」コマンドが見つからない場合
# ---------------------------------------------------------------------------

ERR=$(edit_json "${WORK_DIR}/good.sh" | SHELLCHECK="${WORK_DIR}/no-such-shellcheck" bash "$HOOK" 2>&1 >/dev/null)
STATUS=$?
assert_equal "shellcheck がないときは終了コード 1 で終わる（あなたに通知する）" 1 "$STATUS"
assert_contains "shellcheck がないときはその旨を表示する" "shellcheck が見つからない" "$ERR"

# ---------------------------------------------------------------------------
# 結果
# ---------------------------------------------------------------------------

echo
echo "結果: ${PASSED} 件成功, ${FAILED} 件失敗"
[ "$FAILED" -eq 0 ]
