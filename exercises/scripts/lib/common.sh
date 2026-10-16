#!/usr/bin/env bash
#
# make-*-sandbox.sh で共通して使う関数
# このファイルは直接実行せず、各スクリプトから source で読み込みます。

# 練習用環境の作成先として使えるかを確認し、使えない場合はエラーで終了する
#   check_sandbox_target <作成先ディレクトリ>
check_sandbox_target() {
  local target="$1"

  if [ -e "$target" ]; then
    echo "エラー: ${target} はすでに存在します。" >&2
    echo "       もう一度作り直すときは rm -rf ${target} で削除してから実行してください。" >&2
    exit 1
  fi

  # リポジトリの中にリポジトリを作ると混乱のもとになるので、作成を止める。
  # 作成先の親ディレクトリがまだない場合（例: newdir/sandbox）は、
  # 実際に存在する一番近い親ディレクトリで確認する
  local parent
  parent=$(dirname "$target")
  while [ ! -d "$parent" ]; do
    parent=$(dirname "$parent")
  done
  if git -C "$parent" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    echo "エラー: $(cd "$parent" && pwd) は Git リポジトリの中です。" >&2
    echo "       cd ~ などでリポジトリの外に移動してから実行してください。" >&2
    exit 1
  fi
}
