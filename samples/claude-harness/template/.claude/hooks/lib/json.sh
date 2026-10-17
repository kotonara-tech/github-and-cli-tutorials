#!/usr/bin/env bash
#
# Claude Code のフックのスクリプトから source で読み込む関数
# このファイルは直接実行しません。

# 標準入力の JSON から、文字列の項目を 1 つ取り出して表示する
#   json_string_field <項目名>    例: json_string_field file_path
#
# 最初に見つかった "<項目名>": "..." の値を、JSON のエスケープを戻して表示します。
# jq は macOS に入っていないことがあるので、grep と awk で取り出します。
# 戻せるエスケープは \" \\ \/ \n \t \r \b \f と、ASCII の範囲の \uXXXX です
# （Claude Code は日本語などの文字をエスケープせずに渡すので、これで足ります）。
json_string_field() {
  grep -o -E "\"$1\"[[:space:]]*:[[:space:]]*\"([^\"\\\\]|\\\\.)*\"" |
    head -n 1 |
    sed -E "s/^\"$1\"[[:space:]]*:[[:space:]]*\"//; s/\"\$//" |
    awk '
      # 16 進数の文字列を数に変える（例: "0041" → 65）
      function hex(s,    i, v) {
        v = 0
        for (i = 1; i <= length(s); i++) {
          v = v * 16 + index("0123456789abcdef", tolower(substr(s, i, 1))) - 1
        }
        return v
      }
      {
        out = ""
        n = length($0)
        for (i = 1; i <= n; i++) {
          c = substr($0, i, 1)
          if (c == "\\" && i < n) {
            # \ の次の 1 文字を見て、元の文字に戻す
            i++
            c = substr($0, i, 1)
            if (c == "n") c = "\n"
            else if (c == "t") c = "\t"
            else if (c == "r") c = "\r"
            else if (c == "b") c = "\b"
            else if (c == "f") c = "\f"
            else if (c == "u" && i + 4 <= n && hex(substr($0, i + 1, 4)) < 128) {
              c = sprintf("%c", hex(substr($0, i + 1, 4)))
              i += 4
            } else if (c == "u") c = "\\u"
          }
          out = out c
        }
        print out
      }'
}
