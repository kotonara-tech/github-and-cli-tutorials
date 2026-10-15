#!/usr/bin/env bash
#
# 練習用環境を作るスクリプト（make-*-sandbox.sh）のテスト
#
# 実行方法（リポジトリのルートで）:
#   bash exercises/scripts/tests/test_sandboxes.sh

set -uo pipefail

SCRIPTS_DIR=$(cd "$(dirname "$0")/.." && pwd)

PASSED=0
FAILED=0

WORK_DIR=$(mktemp -d)
trap 'rm -rf "$WORK_DIR"' EXIT

# Git のユーザー設定がない環境（CI など）でもマージを試せるようにする
export GIT_AUTHOR_NAME="Test"
export GIT_AUTHOR_EMAIL="test@example.com"
export GIT_COMMITTER_NAME="$GIT_AUTHOR_NAME"
export GIT_COMMITTER_EMAIL="$GIT_AUTHOR_EMAIL"

pass() {
  PASSED=$((PASSED + 1))
  echo "ok   - $1"
}

fail() {
  FAILED=$((FAILED + 1))
  echo "FAIL - $1"
}

# 条件（コマンド）が成功すれば pass、失敗すれば fail にする
#   check <テスト名> <コマンド...>
check() {
  local name="$1"
  shift
  if "$@" >/dev/null 2>&1; then
    pass "$name"
  else
    fail "$name"
  fi
}

# ---------------------------------------------------------------------------
# make-conflict-sandbox.sh
# ---------------------------------------------------------------------------

cd "$WORK_DIR" || exit 1
check "conflict: 作成に成功する" bash "${SCRIPTS_DIR}/make-conflict-sandbox.sh"
check "conflict: main と feature/update-hobby ブランチがある" \
  git -C conflict-sandbox rev-parse --verify --quiet feature/update-hobby
check "conflict: main ブランチにいる" \
  test "$(git -C conflict-sandbox branch --show-current)" = "main"

if git -C conflict-sandbox merge feature/update-hobby >/dev/null 2>&1; then
  fail "conflict: マージするとコンフリクトが発生する"
else
  check "conflict: マージするとコンフリクトが発生する" \
    test "$(git -C conflict-sandbox diff --name-only --diff-filter=U)" = "profile.txt"
fi

check "conflict: 同じ場所にもう一度作ろうとするとエラーになる" \
  test "$(
    bash "${SCRIPTS_DIR}/make-conflict-sandbox.sh" >/dev/null 2>&1
    echo $?
  )" = "1"

check "conflict: Git リポジトリの中では作成しない" \
  test "$(
    bash "${SCRIPTS_DIR}/make-conflict-sandbox.sh" conflict-sandbox/nested >/dev/null 2>&1
    echo $?
  )" = "1"

# ---------------------------------------------------------------------------
# make-team-sandbox.sh
# ---------------------------------------------------------------------------

cd "$WORK_DIR" || exit 1
check "team: 作成に成功する" bash "${SCRIPTS_DIR}/make-team-sandbox.sh"
check "team: alice と bob が同じコミットを持っている" \
  test "$(git -C team-sandbox/alice rev-parse HEAD)" = "$(git -C team-sandbox/bob rev-parse HEAD)"

# Alice さんが先に push する
echo "Alice の変更" >>team-sandbox/alice/README.md
git -C team-sandbox/alice commit -q -am "Alice の変更"
check "team: alice は push できる" git -C team-sandbox/alice push -q

# Bob さんが後から push すると拒否される
echo "Bob の変更" >>team-sandbox/bob/README.md
git -C team-sandbox/bob commit -q -am "Bob の変更"
if git -C team-sandbox/bob push -q >/dev/null 2>&1; then
  fail "team: 後から push した bob は拒否される"
else
  pass "team: 後から push した bob は拒否される"
fi

# ---------------------------------------------------------------------------
# 結果
# ---------------------------------------------------------------------------

echo
echo "結果: ${PASSED} 件成功, ${FAILED} 件失敗"
[ "$FAILED" -eq 0 ]
