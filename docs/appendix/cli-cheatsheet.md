# 付録: CLI チートシート

よく使うコマンドの一覧です。詳しい使い方は `コマンド --help` や `man コマンド` で確認できます。

## 場所の確認と移動

| コマンド | 意味 |
| --- | --- |
| `pwd` | 今いるディレクトリを表示する |
| `ls` | ファイルの一覧を表示する |
| `ls -la` | 隠しファイルも含めて詳しく表示する |
| `ls -R <dir>` | サブディレクトリの中も表示する |
| `cd <dir>` | ディレクトリに移動する |
| `cd ..` | 1 つ上のディレクトリに移動する |
| `cd -` | 直前のディレクトリに戻る |
| `cd` / `cd ~` | ホームディレクトリに移動する |

## ファイルとディレクトリの操作

| コマンド | 意味 |
| --- | --- |
| `mkdir <dir>` | ディレクトリを作る |
| `mkdir -p a/b/c` | 途中のディレクトリもまとめて作る |
| `touch <file>` | 空のファイルを作る |
| `cp <src> <dst>` | ファイルをコピーする |
| `cp -r <src> <dst>` | ディレクトリを中身ごとコピーする |
| `mv <src> <dst>` | 移動する・名前を変える |
| `rm <file>` | ファイルを削除する（元に戻せない） |
| `rm -r <dir>` | ディレクトリを中身ごと削除する（元に戻せない） |
| `rmdir <dir>` | 空のディレクトリを削除する |

## ファイルの中身を見る

| コマンド | 意味 |
| --- | --- |
| `cat <file>` | 中身をすべて表示する |
| `less <file>` | 1 画面ずつ表示する（<kbd>q</kbd> で終了、<kbd>/</kbd> で検索） |
| `head -n 10 <file>` | 先頭の 10 行を表示する |
| `tail -n 10 <file>` | 末尾の 10 行を表示する |
| `tail -f <file>` | 末尾に追記される内容を表示し続ける（<kbd>Ctrl</kbd> + <kbd>C</kbd> で終了） |
| `wc -l <file>` | 行数を数える |

## 探す・加工する

| コマンド | 意味 |
| --- | --- |
| `grep <文字列> <file>` | 文字列を含む行を表示する |
| `grep -rn <文字列> <dir>` | ディレクトリの中を、行番号付きで探す |
| `grep -i` / `grep -v` | 大文字小文字を区別しない / 含まない行を表示する |
| `find <dir> -name "*.md"` | 名前でファイルを探す |
| `sort` / `sort -n` / `sort -r` | 並べ替える / 数値として / 逆順に |
| `uniq` / `uniq -c` | 隣り合った同じ行をまとめる / 回数も表示する |
| `cut -d, -f1` | `,` 区切りの 1 列目を取り出す |
| `diff <file1> <file2>` | 2 つのファイルの違いを表示する |

## リダイレクトとパイプ

| 書き方 | 意味 |
| --- | --- |
| `cmd > file` | 出力をファイルに書き込む（上書き） |
| `cmd >> file` | 出力をファイルの末尾に追記する |
| `cmd 2> file` | エラー出力をファイルに書き込む |
| `cmd > file 2>&1` | 通常の出力とエラー出力の両方をファイルに書き込む |
| `cmd1 \| cmd2` | `cmd1` の出力を `cmd2` の入力に渡す（パイプ） |
| `cmd1 && cmd2` | `cmd1` が成功したら `cmd2` を実行する |
| `cmd1 ; cmd2` | `cmd1` の結果に関係なく `cmd2` を実行する |

## 権限・実行

| コマンド | 意味 |
| --- | --- |
| `chmod +x <file>` | 実行権限を付ける |
| `./<file>` | 今いるディレクトリのファイルを実行する |
| `bash <file>` | bash でスクリプトを実行する（実行権限がなくてもよい） |
| `sudo <cmd>` | 管理者の権限でコマンドを実行する |
| `echo $?` | 直前のコマンドの終了コードを表示する（0 なら成功） |

## 環境・情報

| コマンド | 意味 |
| --- | --- |
| `echo $HOME` / `echo $PATH` | 環境変数の値を表示する |
| `export NAME=value` | 環境変数を設定する（そのシェルの中で有効） |
| `which <cmd>` | コマンドの実体の場所を表示する |
| `history` | 入力したコマンドの履歴を表示する |
| `man <cmd>` / `<cmd> --help` | 使い方を表示する |
| `clear` | 画面をきれいにする |

## キー操作

| キー | 動作 |
| --- | --- |
| <kbd>Tab</kbd> | 補完する |
| <kbd>↑</kbd> / <kbd>↓</kbd> | 履歴をたどる |
| <kbd>Ctrl</kbd> + <kbd>C</kbd> | 実行中のコマンドを中断する |
| <kbd>Ctrl</kbd> + <kbd>L</kbd> | 画面をきれいにする |
| <kbd>Ctrl</kbd> + <kbd>A</kbd> / <kbd>Ctrl</kbd> + <kbd>E</kbd> | 行の先頭 / 末尾に移動する |
| <kbd>Ctrl</kbd> + <kbd>U</kbd> | カーソルより前を削除する |
| <kbd>Ctrl</kbd> + <kbd>R</kbd> | 履歴を検索する |

## エディタ

この教材では、ファイルの編集に **VS Code** を使います（[第 0 章](../00-setup.md#07-vs-code-をインストールする)）。
nano と vim は、ターミナルしか使えない場面（サーバーに接続したときなど）のために、保存と終了の方法だけ覚えておくと安心です。

| エディタ | 保存 | 終了 |
| --- | --- | --- |
| VS Code | <kbd>Ctrl</kbd> + <kbd>S</kbd>（macOS は <kbd>Command</kbd> + <kbd>S</kbd>） | タブを閉じる: <kbd>Ctrl</kbd> + <kbd>W</kbd>（macOS は <kbd>Command</kbd> + <kbd>W</kbd>） |
| nano | <kbd>Ctrl</kbd> + <kbd>O</kbd> → <kbd>Enter</kbd> | <kbd>Ctrl</kbd> + <kbd>X</kbd> |
| vim | <kbd>Esc</kbd> → `:w` | <kbd>Esc</kbd> → `:q`（保存せずに終了は `:q!`、保存して終了は `:wq`） |

### code コマンド

ターミナルから VS Code を操作するコマンドです（[公式ドキュメント: Command Line Interface](https://code.visualstudio.com/docs/configure/command-line)）。

| コマンド | 意味 |
| --- | --- |
| `code .` | 今いるディレクトリを VS Code で開く |
| `code <dir>` | ディレクトリを VS Code で開く（新しいウィンドウで開く） |
| `code <file>` | ファイルを VS Code で開く（ファイルがなければ、保存したときに作られる） |
| `code --diff <file1> <file2>` | 2 つのファイルの違いを、VS Code の差分エディターで表示する |
| `code --wait <file>` | ファイルを開き、タブを閉じるまで待つ（Git や `gh` のエディタの設定に使う） |
| `code --install-extension <ID>` | 拡張機能をインストールする |
| `code --list-extensions` | インストールされている拡張機能の一覧を表示する |
| `code --version` | VS Code のバージョンを表示する |

---

[目次](../../README.md) ｜ [Git チートシート →](git-cheatsheet.md)
