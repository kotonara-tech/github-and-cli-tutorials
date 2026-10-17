#!/usr/bin/env bash
#
# Claude Code のフックのスクリプトから source で読み込む関数
# このファイルは直接実行しません。

# 標準入力の JSON から、文字列の項目を 1 つ取り出して表示する
#   json_string_field <項目名>    例: json_string_field file_path
#
# 最初に見つかった "<項目名>": "..." の値を、JSON のエスケープ（\\ や \" など）を戻して表示します。
# jq は macOS に入っていないことがあるので、grep と awk で取り出します。
json_string_field() {
  grep -o -E "\"$1\"[[:space:]]*:[[:space:]]*\"([^\"\\\\]|\\\\.)*\"" |
    head -n 1 |
    sed -E "s/^\"$1\"[[:space:]]*:[[:space:]]*\"//; s/\"\$//" |
    awk '{
      out = ""
      n = length($0)
      for (i = 1; i <= n; i++) {
        c = substr($0, i, 1)
        if (c == "\\" && i < n) {
          # \ の次の 1 文字を取り出す（\n と \t は改行とタブに戻す）
          i++
          c = substr($0, i, 1)
          if (c == "n") c = "\n"
          else if (c == "t") c = "\t"
        }
        out = out c
      }
      print out
    }'
}
