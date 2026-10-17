#!/usr/bin/env bash
#
# template/.claude/hooks/ のフックのスクリプトのテスト
#
# 実行方法（リポジトリのルートで）:
#   bash samples/claude-harness/tests/test_hooks.sh
#
# Claude Code がフックに渡すのと同じ形の JSON を標準入力に渡し、
# 終了コードと標準エラー出力を確かめます。shellcheck と jq が必要です。
#
# assert_equal などの関数は samples/todo-cli/tests/test_todo.sh と同じものです。
# それぞれのテストを 1 つのファイルだけで読めるように、あえて共通化していません。

set -uo pipefail

SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
HOOKS_DIR="${SCRIPT_DIR}/../template/.claude/hooks"
EDIT_HOOK="${HOOKS_DIR}/shellcheck-on-edit.sh"
READONLY_HOOK="${HOOKS_DIR}/readonly-bash.sh"

for tool in shellcheck jq; do
  if ! command -v "$tool" >/dev/null 2>&1; then
    echo "このテストには ${tool} が必要です。インストールしてから実行してください。" >&2
    exit 1
  fi
done

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

# Edit ツールの入力を表す JSON を作る（jq の --arg で渡すので、\ や " や改行も正しくエスケープされる）
#   edit_json <ファイルのパス>
edit_json() {
  jq -nc --arg path "$1" \
    '{tool_name: "Edit", tool_input: {file_path: $path, old_string: "a", new_string: "b"}, tool_response: {filePath: $path}}'
}

# Bash ツールの入力を表す JSON を作る
#   bash_json <コマンド>
bash_json() {
  jq -nc --arg command "$1" '{tool_name: "Bash", tool_input: {command: $command, description: "テスト用"}}'
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

run_hook "$EDIT_HOOK" '{"tool_input":{"file_path":'
assert_equal "JSON を読み取れないときは終了コード 1 で終わる（あなたに通知する）" 1 "$STATUS"
assert_contains "JSON を読み取れないときはその旨を表示する" "JSON を読み取れない" "$ERR"

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

# tool_input の外や、tool_input の中のさらに内側にも file_path があるときは、tool_input.file_path を使う
run_hook "$EDIT_HOOK" "$(printf '{"file_path":"%s","tool_input":{"file_path":"%s"},"other":{"file_path":"%s"}}' "${WORK_DIR}/good.sh" "${WORK_DIR}/bad.sh" "${WORK_DIR}/good.sh")"
assert_equal "tool_input の外の file_path は使わず、tool_input の中のものをチェックする" 2 "$STATUS"
run_hook "$EDIT_HOOK" "$(printf '{"tool_input":{"options":{"file_path":"%s"},"file_path":"%s"}}' "${WORK_DIR}/good.sh" "${WORK_DIR}/bad.sh")"
assert_equal "tool_input の中の、さらに内側の file_path は使わない" 2 "$STATUS"

# 複数行に整形された JSON でも読み取れる
run_hook "$EDIT_HOOK" "$(printf '{\n  "tool_name": "Edit",\n  "tool_input": {\n    "file_path": "%s"\n  }\n}' "${WORK_DIR}/bad.sh")"
assert_equal "複数行に整形された JSON でも file_path を読み取る" 2 "$STATUS"

# 書き込む内容（content）の中のエスケープされた "file_path" は、項目として扱わない
run_hook "$EDIT_HOOK" "$(printf '{"tool_name":"Write","tool_input":{"content":"echo \\"file_path\\": \\"%s\\"","file_path":"%s"}}' "${WORK_DIR}/good.sh" "${WORK_DIR}/bad.sh")"
assert_equal "content の中の \"file_path\" という文字列は項目として扱わない" 2 "$STATUS"

# \uXXXX のエスケープ（ここでは \u002e = .）も元の文字に戻す
run_hook "$EDIT_HOOK" "$(printf '{"tool_input":{"file_path":"%s/bad\\u002esh"}}' "$WORK_DIR")"
assert_equal "\\uXXXX のエスケープを戻してからチェックする" 2 "$STATUS"

SHELLCHECK="${WORK_DIR}/no-such-shellcheck" run_hook "$EDIT_HOOK" "$(edit_json "${WORK_DIR}/good.sh")"
assert_equal "shellcheck がないときは終了コード 1 で終わる（あなたに通知する）" 1 "$STATUS"
assert_contains "shellcheck がないときはその旨を表示する" "shellcheck が見つからない" "$ERR"

JQ="${WORK_DIR}/no-such-jq" run_hook "$EDIT_HOOK" "$(edit_json "${WORK_DIR}/bad.sh")"
assert_equal "jq がないときは終了コード 1 で終わる（あなたに通知する）" 1 "$STATUS"
assert_contains "jq がないときはその旨を表示する" "jq が見つからない" "$ERR"

# ---------------------------------------------------------------------------
# readonly-bash.sh: 決まった形の読み取りだけのコマンドは実行してよい
# ---------------------------------------------------------------------------

for command in "git diff main...HEAD -- tests/" "git diff --stat main...HEAD" "git log --oneline -5" \
  "git log -n3 --oneline -- tests/test_todo.sh" "git show HEAD" "git show HEAD~1 --stat" "git status" "git status --short" \
  "git log --oneline origin/main..HEAD" "git diff main...HEAD -- docs/.environment.md" "git log -- app.env.example"; do
  run_hook "$READONLY_HOOK" "$(bash_json "$command")"
  assert_equal "読み取りだけのコマンドは実行してよい: ${command}" 0 "$STATUS"
done

# ---------------------------------------------------------------------------
# readonly-bash.sh: それ以外のコマンドは止める
# ---------------------------------------------------------------------------

# 読み取り以外のコマンドと、複数のコマンドをつなぐ書き方
for command in "git commit -m x" "git checkout -- tests/" "sed -i s/a/b/ todo.sh" "rm -rf tests" "git" "gitdiff" \
  "bash tests/test_todo.sh" \
  "git diff > out.txt" "git diff; rm -rf tests" "git diff && rm -rf tests" "git log | tee out.txt" \
  "git log \$(touch x)" "git log \`touch x\`" "git log -1"$'\n'"rm -rf tests"; do
  run_hook "$READONLY_HOOK" "$(bash_json "$command")"
  assert_equal "読み取り以外のコマンドは止める（終了コード 2）: ${command//$'\n'/\\n}" 2 "$STATUS"
done

# 引用符や \ で書き方を変えたオプション、一覧にないオプション、ファイル名の展開
for command in "git diff --out''put=todo.sh HEAD~1" "git diff --ext''-diff" "git diff --no-ind\\ex /dev/null .env" \
  "git diff --output=out.txt" "git diff --ext-diff" "git log -p --textconv" "git diff --no-index a b" \
  'git log --format="%h %s"' "git diff {a,b}" "git diff HEAD -- *.sh" "git -c core.pager=less diff"; do
  run_hook "$READONLY_HOOK" "$(bash_json "$command")"
  assert_equal "一覧にない書き方やオプションは止める（終了コード 2）: ${command}" 2 "$STATUS"
done

# リポジトリの外を指すパス（git diff は、外のパスを渡すと自動で --no-index と同じ動きになる）
for command in "git diff /dev/null /etc/hostname" "git diff -- ../outside.txt" "git show HEAD -- ~/.ssh/id_rsa" "git diff -- tests/../../x" \
  "git diff ./.. ." "git diff .//.. ." "git diff -- tests/.." "git show HEAD:.." "git diff =ls =cat"; do
  run_hook "$READONLY_HOOK" "$(bash_json "$command")"
  assert_equal "リポジトリの外を指すパスは止める（終了コード 2）: ${command}" 2 "$STATUS"
done

# 秘密の情報を書くファイル（.env など）
for command in "git show HEAD:.env" "git log -p -- .env" "git show HEAD:.env.local" "git show HEAD:config/.env" \
  "git diff HEAD~1 -- config/.env.production"; do
  run_hook "$READONLY_HOOK" "$(bash_json "$command")"
  assert_equal ".env を指すパスは止める（終了コード 2）: ${command}" 2 "$STATUS"
done

# tool_input.command だけを見る（ほかの場所にある同じ名前の項目は使わない）
run_hook "$READONLY_HOOK" '{"command":"git status","tool_name":"Bash","tool_input":{"command":"rm -rf tests"}}'
assert_equal "tool_input の外の command は使わない" 2 "$STATUS"
run_hook "$READONLY_HOOK" '{"tool_name":"Bash","tool_input":{"options":{"command":"git status"},"command":"rm -rf tests"}}'
assert_equal "tool_input の中の、さらに内側の command は使わない" 2 "$STATUS"

run_hook "$READONLY_HOOK" "$(bash_json "git commit -m x")"
assert_contains "止めたときは理由を Claude に伝える" "test-reviewer が実行できるのは" "$ERR"

run_hook "$READONLY_HOOK" '{"tool_name":"Bash","tool_input":{"description":"command がない"}}'
assert_equal "command が取り出せないときは止める（終了コード 2）" 2 "$STATUS"

run_hook "$READONLY_HOOK" '{"tool_input":{"command":"git status"'
assert_equal "JSON を読み取れないときは止める（終了コード 2）" 2 "$STATUS"
assert_contains "JSON を読み取れないときはその旨を表示する" "JSON を読み取れない" "$ERR"

JQ="${WORK_DIR}/no-such-jq" run_hook "$READONLY_HOOK" "$(bash_json "git status")"
assert_equal "jq がないときは、安全のために止める（終了コード 2）" 2 "$STATUS"
assert_contains "jq がないときはその旨を表示する" "jq が見つからない" "$ERR"

# test-reviewer.md に書いたフックのコマンドそのものを、Claude Code と同じようにシェルで実行する
REVIEWER_MD="${SCRIPT_DIR}/../template/.claude/agents/test-reviewer.md"
REVIEWER_HOOK_COMMAND=$(sed -n "s/^ *command: '\(.*\)'\$/\1/p" "$REVIEWER_MD")
run_reviewer_hook() {
  ERR=$(printf '%s' "$2" | CLAUDE_PROJECT_DIR="$1" sh -c "$REVIEWER_HOOK_COMMAND" 2>&1 >/dev/null)
  STATUS=$?
}
run_reviewer_hook "${SCRIPT_DIR}/../template" "$(bash_json "git status")"
assert_equal "test-reviewer.md のフック: 読み取りだけのコマンドは実行してよい" 0 "$STATUS"
run_reviewer_hook "${SCRIPT_DIR}/../template" "$(bash_json "rm -rf tests")"
assert_equal "test-reviewer.md のフック: それ以外のコマンドは止める" 2 "$STATUS"
mkdir -p "${WORK_DIR}/project-without-hooks"
run_reviewer_hook "${WORK_DIR}/project-without-hooks" "$(bash_json "git status")"
assert_equal "test-reviewer.md のフック: スクリプトが見つからないときも、安全のために止める（終了コード 2）" 2 "$STATUS"

# ---------------------------------------------------------------------------
# 結果
# ---------------------------------------------------------------------------

echo
echo "結果: ${PASSED} 件成功, ${FAILED} 件失敗"
[ "$FAILED" -eq 0 ]
