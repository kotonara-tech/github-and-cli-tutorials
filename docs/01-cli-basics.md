# 第 1 章: CLI の基本

**CLI（Command Line Interface）** は、マウスでクリックする代わりに、文字でコマンドを打ち込んでコンピュータを操作する方法です。
Git や GitHub CLI もコマンドで操作するので、まずはターミナルでの基本操作に慣れましょう。

この章のコマンドは、すべて VS Code の **統合ターミナル**（Integrated Terminal）で実行します。統合ターミナルの開き方は、[0.8](00-setup.md#08-vs-code-の画面と用語) の「統合ターミナルを開く」で確認してください。
VS Code で開くフォルダは、演習で使う `samples/cli-practice` だけでも、教材のフォルダ（`~/github-and-cli-tutorials`）全体でも構いません。迷ったら `samples/cli-practice` を開くと、この章の例をそのまま試せます。

```bash
code ~/github-and-cli-tutorials/samples/cli-practice
```

新しいウィンドウでフォルダが開きます。メニューの **ファイル**（File）> **フォルダーを開く...**（Open Folder...）で選んでも同じです。
ファイルやフォルダを作ったり消したりすると、その結果は左側の **エクスプローラー**（Explorer）にもすぐに表示されます。コマンドの結果を目で確かめながら進めましょう。

## この章のゴール

- [ ] 今いるディレクトリを確認し、別のディレクトリに移動できる
- [ ] ファイルやディレクトリを、VS Code のエクスプローラーとコマンドの両方で作成・コピー・移動・削除できる
- [ ] ファイルの中身を表示できる
- [ ] パイプ（`|`）とリダイレクト（`>`）を使ってコマンドを組み合わせられる
- [ ] コマンドの使い方を自分で調べられる
- [ ] VS Code でファイルを開いて編集・保存でき、Git がターミナルの中のエディタ（vim など）を開いたときも終了できる

**所要時間の目安:** 60〜90 分

## 1.1 コマンドの基本

統合ターミナルを開くと、次のような表示があり、文字を入力できる状態になっています。

```text
hanako@my-pc:~$
```

この部分を **プロンプト** と呼びます。「ユーザー名@コンピュータ名:今いる場所」を表し、最後の `$` が「コマンドを入力できます」という合図です（macOS では `%` のこともあります）。

コマンドは、基本的に次の形で入力します。各部分は **スペース** で区切ります。

```text
コマンド名 オプション 引数
```

```bash
ls -l docs
```

| 部分 | 例 | 意味 |
| --- | --- | --- |
| コマンド名 | `ls` | 何をするか（ここでは「一覧を表示する」） |
| オプション | `-l` | どのようにするか（ここでは「詳しく表示する」）。`-` や `--` で始まる |
| 引数 | `docs` | 何に対してするか（ここでは「docs ディレクトリ」） |

> [!NOTE]
> この教材では、コマンドを次の 2 種類の書き方で紹介します。
>
> - **入力するコマンド**: 先頭に `$` を付けずに書きます。そのままコピーして貼り付けられます。
> - **出力例**: コマンドと結果をあわせて見せるときは、先頭に `$` を付けて「ここが入力した部分」と分かるようにします。

## 1.2 場所を確認して移動する

### ファイルシステムの構造

ファイルやディレクトリ（Windows や macOS の「フォルダ」と同じもの）は、**ルート**（`/`）を頂点とした木のような構造になっています。

```text
/                         ← ルート
├── home/
│   └── hanako/           ← ホームディレクトリ（~ と書ける）
│       ├── github-and-cli-tutorials/
│       │   ├── docs/
│       │   └── samples/
│       └── git-practice/
└── usr/
    └── bin/              ← コマンドの実体が置かれている場所の 1 つ
```

### pwd: 今いる場所を表示する

```bash
pwd
```

```text
/home/hanako
```

### ls: ファイルの一覧を表示する

```bash
ls              # 今いるディレクトリの一覧
ls docs         # docs ディレクトリの一覧
ls -l           # 詳しい情報（権限・サイズ・更新日時）も表示
ls -a           # 隠しファイル（. で始まるファイル）も表示
ls -la          # オプションはまとめて書ける
```

`#` から後ろは **コメント** で、シェルは無視します。コピーして貼り付けても問題ありません。

### cd: 別のディレクトリに移動する

```bash
cd ~/github-and-cli-tutorials   # 教材のディレクトリに移動
cd docs                         # 今いる場所の中の docs に移動
cd ..                           # 1 つ上のディレクトリに戻る
cd -                            # 直前にいたディレクトリに戻る
cd                              # 引数なしならホームディレクトリに戻る
```

### パスの書き方

ファイルやディレクトリの場所を表す文字列を **パス** と呼びます。

| 書き方 | 意味 | 例 |
| --- | --- | --- |
| `/` で始まる | **絶対パス**（ルートからの道のり） | `/home/hanako/github-and-cli-tutorials` |
| `/` 以外で始まる | **相対パス**（今いる場所からの道のり） | `docs/00-setup.md` |
| `~` | ホームディレクトリ | `~/github-and-cli-tutorials` |
| `.` | 今いるディレクトリ | `./todo.sh` |
| `..` | 1 つ上のディレクトリ | `../README.md` |

### エクスプローラーと見比べる

VS Code のエクスプローラーは、開いたフォルダの中身を、ここまでのコマンドと同じ木の形で表示しています。

| やりたいこと | VS Code | コマンド |
| --- | --- | --- |
| 今いる場所を知る | 統合ターミナルを開いた直後は、VS Code で開いたフォルダにいます | `pwd` |
| フォルダの中身を見る | エクスプローラーで、フォルダ名をクリックして開く | `ls <ディレクトリ>` |
| 隠しファイルを見る | `.` で始まるファイルも、そのまま表示されます（`.git` など一部は表示されません） | `ls -a` |
| ファイルの絶対パスを知る | ファイルを右クリックして **パスのコピー**（Copy Path）を選び、貼り付ける | `pwd` の結果の後ろに `/ファイル名` を付ける |
| ファイルの相対パスを知る | ファイルを右クリックして **相対パスをコピー**（Copy Relative Path）を選ぶ（VS Code で開いたフォルダからの道のりになります） | 今いる場所からの道のりを、`..` などを使って書く |
| そのフォルダでターミナルを使う | フォルダを右クリックして **統合ターミナルで開く**（Open in Integrated Terminal）を選ぶ（新しいターミナルが開きます） | `cd <ディレクトリ>` |

> [!NOTE]
> エクスプローラーでフォルダを開いたり閉じたりしても、ターミナルの今いる場所は変わりません。ターミナルで場所を移動するときは `cd` を使います。

## 1.3 ファイルとディレクトリを操作する

ファイルやディレクトリの作成・コピー・名前の変更・移動・削除は、VS Code のエクスプローラーでも、コマンドでもできます。**どちらで操作しても、結果は同じです。**
ここでは `samples/cli-practice` の中に練習用の `practice` ディレクトリを作り、両方の方法で同じ操作をしてみます。まず統合ターミナルで `cli-practice` に移動しておきます。

```bash
cd ~/github-and-cli-tutorials/samples/cli-practice
```

### VS Code で操作する

エクスプローラーでファイルやフォルダを右クリックすると、操作のメニューが表示されます（[公式ドキュメント: Explorer view](https://code.visualstudio.com/docs/editing/getting-started/userinterface#_explorer-view)）。
各手順の最後の（）の中は、同じ意味のコマンドです。教材のフォルダ全体を開いている場合は、「エクスプローラーの空いているところ」を「`cli-practice` フォルダ」に読み替えてください。

1. エクスプローラーの空いているところを右クリックして **新しいフォルダー...**（New Folder...）を選び、`practice` と入力して <kbd>Enter</kbd> を押します（`mkdir practice`）。
2. `practice` を右クリックして **新しいフォルダー...** を選び、`a/b/c` と入力します。`/` で区切ると、途中のフォルダもまとめて作れます（`mkdir -p practice/a/b/c`）。
3. `practice` を右クリックして **新しいファイル...**（New File...）を選び、`memo.txt` と入力します。空のファイルができて、エディターで開きます（`touch practice/memo.txt`）。
4. `memo.txt` を右クリックして **コピー**（Copy）を選び、続けて `practice` を右クリックして **貼り付け**（Paste）を選びます。同じフォルダに貼り付けたので、名前の後ろに `copy` などが付いたコピーができます（`cp`）。
5. 同じように、`practice` を右クリックして **コピー** を選び、エクスプローラーの空いているところを右クリックして **貼り付け** を選ぶと、フォルダが中身ごとコピーされます（`cp -r`）。
6. 手順 4 でできたコピーを右クリックして **名前の変更...**（Rename...）を選び、`renamed.txt` に変えます（`mv`）。<kbd>F2</kbd> キー（macOS は <kbd>Enter</kbd> キー）でも名前を変えられます。
7. `renamed.txt` を `a` の上にドラッグ＆ドロップします。「'renamed.txt' を 'a' に移動しますか?」と表示されたら、**移動** をクリックします（`mv`）。
8. `memo.txt` を右クリックして **削除**（Delete）を選び、確認のメッセージで **ゴミ箱に移動** をクリックします（`rm`）。
9. 手順 5 でできたフォルダのコピーも、同じように削除します（`rm -r`）。

エクスプローラーで削除したファイルは、OS のゴミ箱に移動します。
ただし、ゴミ箱を使えない環境（Windows で WSL2 に接続しているときなど）では「'memo.txt' を完全に削除してもよろしいですか?」と表示されることがあり、その場合、削除したファイルは元に戻せません。

操作が終わったら、統合ターミナルで結果を確かめます。

```bash
ls -R practice    # -R: 中のディレクトリも順にすべて表示する
```

出力例（Linux の場合。macOS では表示の形が少し異なります）:

```text
practice:
a

practice/a:
b  renamed.txt

practice/a/b:
c

practice/a/b/c:
```

確かめたら `practice` を削除して（エクスプローラーの **削除**、または `rm -r practice`）、同じことをコマンドでやってみましょう。

### コマンドで操作する

```bash
mkdir practice                 # ディレクトリを作る
mkdir -p practice/a/b/c        # 途中のディレクトリもまとめて作る
touch practice/memo.txt        # 空のファイルを作る（既存ファイルなら更新日時を変える）

cp practice/memo.txt practice/copy.txt   # ファイルをコピーする
cp -r practice practice-backup           # ディレクトリを中身ごとコピーする（-r: 再帰的に）

mv practice/copy.txt practice/renamed.txt  # 名前を変える
mv practice/renamed.txt practice/a/        # 別のディレクトリに移動する

rm practice/memo.txt           # ファイルを削除する
rm -r practice-backup          # ディレクトリを中身ごと削除する
```

コマンドで作ったファイルやディレクトリも、エクスプローラーにすぐに表示されます。`ls -R practice` で確かめると、VS Code で操作したときと同じ結果になります。

```bash
ls -R practice
```

```text
practice:
a

practice/a:
b  renamed.txt

practice/a/b:
c

practice/a/b/c:
```

練習が終わったら、`rm -r practice` で `practice` を削除しておきましょう。

> [!WARNING]
> `rm` で削除したファイルは **ゴミ箱に入らず、元に戻せません**。
> 特に `rm -r` は中身ごと消えるので、実行する前に `ls` で対象をよく確認しましょう。
> ファイル名に `*`（ワイルドカード）を使うときは、先に `ls *.txt` のように確認してから `rm *.txt` を実行すると安全です。

## 1.4 ファイルの中身を見る

```bash
cat README.md            # 中身をすべて表示する
less README.md           # 1 画面ずつ表示する（長いファイル向け）
head -n 5 README.md      # 先頭の 5 行だけ表示する
tail -n 5 README.md      # 末尾の 5 行だけ表示する
```

`less` は次のキーで操作します。**`q` で終了** することだけは必ず覚えておきましょう。

| キー | 動作 |
| --- | --- |
| <kbd>Space</kbd> / <kbd>b</kbd> | 1 画面進む / 戻る |
| <kbd>↓</kbd> / <kbd>↑</kbd>（または <kbd>j</kbd> / <kbd>k</kbd>） | 1 行進む / 戻る |
| <kbd>/</kbd> + 文字列 + <kbd>Enter</kbd> | 文字列を検索する（<kbd>n</kbd> で次を検索） |
| <kbd>q</kbd> | 終了する |

VS Code では、エクスプローラーでファイルをクリックすると、中身がエディターに表示されます（[1.10](#110-ファイルを編集するvs-code-とターミナルのエディタ) で説明する `code` コマンドでも開けます）。
長いファイルは、スクロールしたり、<kbd>Ctrl</kbd> + <kbd>F</kbd>（macOS は <kbd>Command</kbd> + <kbd>F</kbd>）で文字列を検索したりして読めます。

> [!TIP]
> `git log` や `git diff` の結果が長いときも、この `less` と同じ画面で表示されます。抜けられなくなったら <kbd>q</kbd> を押しましょう。

## 1.5 コマンドを組み合わせる

### echo とリダイレクト（`>`、`>>`）

`echo` は、引数の文字列をそのまま表示するコマンドです。
**リダイレクト** を使うと、画面に表示される結果をファイルに書き込めます。

```bash
echo "こんにちは"                  # 画面に表示する
echo "1 行目" > hello.txt          # ファイルに書き込む（上書き）
echo "2 行目" >> hello.txt         # ファイルの末尾に追記する
cat hello.txt
```

```text
1 行目
2 行目
```

作った `hello.txt` は、エクスプローラーにも表示されます。`code hello.txt` を実行すると VS Code で開けるので、書き込まれた中身を確かめられます。

> [!WARNING]
> `>` は、ファイルがすでにあると **中身を消して上書き** します。追記したいときは `>>` を使います。

### パイプ（`|`）

**パイプ** は、あるコマンドの出力を、次のコマンドの入力として渡す仕組みです。小さなコマンドをつなげて、複雑な処理ができます。

```bash
ls -l | less                     # 長い一覧を 1 画面ずつ見る
cat fruits.txt | sort            # 並べ替える
sort fruits.txt | uniq -c        # 並べ替えてから、同じ行を数える
grep "404" access.log | wc -l    # 404 を含む行を探して、行数を数える
```

### よく組み合わせるコマンド

| コマンド | 意味 | 例 |
| --- | --- | --- |
| `grep` | 文字列を含む行を探す | `grep -n "TODO" notes.txt`（`-n`: 行番号を表示、`-r`: ディレクトリの中も探す、`-i`: 大文字小文字を区別しない） |
| `wc` | 行数・単語数・バイト数を数える | `wc -l fruits.txt`（`-l`: 行数だけ） |
| `sort` | 並べ替える | `sort -n`（数値として）、`sort -r`（逆順） |
| `uniq` | 隣り合った同じ行をまとめる | `uniq -c`（回数も表示） |
| `cut` | 列を取り出す | `cut -d, -f1 scores.csv`（`,` 区切りの 1 列目） |
| `find` | ファイルを探す | `find . -name "*.md"` |

## 1.6 使い方を調べる

コマンドの使い方が分からないときは、次の方法で調べられます。

```bash
ls --help          # 簡単な使い方を表示する（macOS の一部のコマンドは非対応）
man ls             # 詳しいマニュアルを表示する（less と同じく q で終了）
git help commit    # Git のサブコマンドのマニュアル
gh pr --help       # GitHub CLI のヘルプ
```

## 1.7 覚えておくと便利なキー操作

| キー | 動作 |
| --- | --- |
| <kbd>Tab</kbd> | コマンド名やファイル名を **補完** する。候補が複数あるときは 2 回押すと一覧が出る |
| <kbd>↑</kbd> / <kbd>↓</kbd> | 以前に入力したコマンドを呼び出す |
| <kbd>Ctrl</kbd> + <kbd>C</kbd> | 実行中のコマンドを **中断** する。入力途中の行を取り消す |
| <kbd>Ctrl</kbd> + <kbd>L</kbd> | 画面をきれいにする（`clear` コマンドと同じ） |
| <kbd>Ctrl</kbd> + <kbd>A</kbd> / <kbd>Ctrl</kbd> + <kbd>E</kbd> | 行の先頭 / 末尾にカーソルを移動する |
| <kbd>Ctrl</kbd> + <kbd>R</kbd> | 過去のコマンドを検索する |

> [!TIP]
> <kbd>Tab</kbd> 補完は、入力の手間を省くだけでなく **打ち間違いを防ぐ** 効果があります。ファイル名は積極的に補完しましょう。

## 1.8 権限とスクリプトの実行

`ls -l` で表示される左端の文字列は、ファイルの **権限（パーミッション）** を表しています。

```text
$ ls -l samples/todo-cli
-rw-r--r-- 1 hanako hanako 3392 Apr  1 10:00 README.md
drwxr-xr-x 2 hanako hanako 4096 Apr  1 10:00 tests
-rwxr-xr-x 1 hanako hanako 5028 Apr  1 10:00 todo.sh
```

```text
-  rwx  r-x  r-x
│   │    │    └── その他のユーザーの権限
│   │    └─────── グループの権限
│   └──────────── 所有者の権限（r: 読み取り、w: 書き込み、x: 実行）
└──────────────── 種類（-: ファイル、d: ディレクトリ）
```

`x`（実行権限）があるファイルは、パスを指定して実行できます。今いるディレクトリのファイルを実行するときは、先頭に `./` を付けます。

```bash
cd ~/github-and-cli-tutorials/samples/todo-cli
./todo.sh help
```

実行権限がない場合は `Permission denied` と表示されます。`chmod +x` で実行権限を付けられます。

```bash
chmod +x todo.sh
```

## 1.9 環境変数と PATH

**環境変数** は、シェルやコマンドが参照する設定値です。`$` を付けると値を取り出せます。

```bash
echo $HOME      # ホームディレクトリ
echo $USER      # ユーザー名
echo $SHELL     # 使っているシェル
```

特に重要なのが `PATH` です。コマンド名を入力したとき、シェルは `PATH` に書かれたディレクトリを順番に探して、コマンドの実体を見つけます。

```bash
echo $PATH      # : 区切りのディレクトリの一覧
which git       # git コマンドの実体がどこにあるか
```

`command not found` と表示されたときは、コマンド名の打ち間違いか、インストールされていない（または `PATH` に含まれていない）ことが原因です。

コマンドの前に `変数名=値` と書くと、そのコマンドの実行中だけ環境変数を設定できます。

```bash
TODO_FILE=/tmp/my-todo.txt ./todo.sh list
```

## 1.10 ファイルを編集する（VS Code とターミナルのエディタ）

この教材では、ファイルの編集は VS Code で行います（[公式ドキュメント: Basic editing](https://code.visualstudio.com/docs/editing/codebasics)）。
ただし、ターミナルしか使えない場面もあります。その場面で使うエディタ（nano と vim）の最低限の操作も、この節の後半で覚えておきましょう。

### VS Code でファイルを開く

#### VS Code で操作する

- エクスプローラーでファイルをクリックすると、エディターで開きます。1 回のクリックでは **プレビュー モード**（タブの名前が斜体）で開き、別のファイルを開くとそのタブが置き換わります。ダブルクリックするか編集すると、タブが固定されます（[0.8](00-setup.md#画面の各部分の名前)）。
- <kbd>Ctrl</kbd> + <kbd>P</kbd>（macOS は <kbd>Command</kbd> + <kbd>P</kbd>）で **クイック オープン**（Quick Open）を開き、ファイル名の一部を入力して <kbd>Enter</kbd> を押しても開けます。

#### コマンドで操作する

統合ターミナルで `code` コマンドを使うと、ファイルやフォルダを VS Code で開けます。

```bash
code memo.txt     # memo.txt をエディターで開く（ファイルがなければ新しく作られる）
code .            # 今いるディレクトリ（.）をフォルダとして VS Code で開く
```

`code .` を、ほかのフォルダを開いているウィンドウのターミナルで実行すると、新しいウィンドウでフォルダが開きます。
`code` コマンドのほかの使い方は、[公式ドキュメント: Command Line Interface](https://code.visualstudio.com/docs/configure/command-line) にまとまっています。

### 編集して保存する

1. エディターで文字を入力します。
2. <kbd>Ctrl</kbd> + <kbd>S</kbd>（macOS は <kbd>Command</kbd> + <kbd>S</kbd>）で保存します。

保存していないファイルは、タブの名前の右に **●** が表示されます。保存すると ● が消えます。
[0.10](00-setup.md#自動保存を有効にする) で **自動保存**（Auto Save）を有効にしていれば、入力をやめて少しすると自動で保存されます。それでも、テストや Git の操作の前には、● が残っていないことを確かめる習慣を付けましょう（[公式ドキュメント: Save / Auto Save](https://code.visualstudio.com/docs/editing/codebasics#_save-auto-save)）。

保存した内容は、ターミナルからもすぐに見えます。

```bash
code memo.txt      # VS Code で開いて「こんにちは」と書き、保存する
cat memo.txt       # ターミナルで中身を確かめる
```

```text
こんにちは
```

タブは、タブの × か <kbd>Ctrl</kbd> + <kbd>W</kbd>（macOS は <kbd>Command</kbd> + <kbd>W</kbd>）で閉じます。
保存していないタブを閉じようとすると「memo.txt に加えた変更を保存しますか?」と聞かれるので、**保存** を選びます。

### Markdown をプレビューする

`.md` のファイル（Markdown）は、GitHub で表示したときに近い見た目で確かめられます（[公式ドキュメント: Markdown preview](https://code.visualstudio.com/docs/languages/markdown#_markdown-preview)）。

- `.md` のファイルを開いた状態で <kbd>Ctrl</kbd> + <kbd>Shift</kbd> + <kbd>V</kbd>（macOS は <kbd>Command</kbd> + <kbd>Shift</kbd> + <kbd>V</kbd>）を押すと、プレビューのタブが開きます。
- エディターの右上にある **プレビューを横に表示**（Open Preview to the Side）のアイコンをクリックすると、編集しながら、横に並べたプレビューで見た目を確かめられます。

`samples/cli-practice/README.md` などを開いて試してみましょう。

### nano（初心者向け）

ターミナルしか使えない場面（サーバーに接続したときや、Git が開いたとき）では、ターミナルの中で動くエディタを使います。
`nano` は、画面の下部に操作方法が表示されるので迷いにくいエディタです（`^` は <kbd>Ctrl</kbd> キーの意味です）。

```bash
nano memo.txt
```

| キー | 動作 |
| --- | --- |
| そのまま入力 | 文字を書き込む |
| <kbd>Ctrl</kbd> + <kbd>O</kbd> → <kbd>Enter</kbd> | 保存する |
| <kbd>Ctrl</kbd> + <kbd>X</kbd> | 終了する（未保存なら保存するか聞かれる） |

### vim（抜け方だけは必ず覚える）

`vim` は高機能ですが、初めて使うと終了方法が分からず困りがちです。Git のエディタを設定する前や、接続したサーバーの上では、`git commit` などで `vim` が開くことがあるので、次の操作だけは覚えておきましょう。

| やりたいこと | キー操作 |
| --- | --- |
| 文字を入力する | <kbd>i</kbd> を押してから入力する（画面下に `-- INSERT --` と表示される） |
| 入力を終える | <kbd>Esc</kbd> |
| 保存して終了する | <kbd>Esc</kbd> → `:wq` → <kbd>Enter</kbd> |
| 保存せずに終了する | <kbd>Esc</kbd> → `:q!` → <kbd>Enter</kbd> |

Git が開くエディタを VS Code（または `nano`）に変える方法は [第 2 章](02-git-basics.md#そのほかのおすすめ設定) で説明します。

## 演習

### 演習 1-1: CLI 練習用ファイルを使った演習

[samples/cli-practice/README.md](../samples/cli-practice/README.md) にある演習 1〜5 に取り組んでください。

### 演習 1-2: サンプルの TODO アプリを動かす

次の章以降で使うサンプルアプリ `todo.sh` を動かしてみましょう。

1. `~/github-and-cli-tutorials/samples/todo-cli` に移動してください。
2. `./todo.sh help` で使い方を表示してください。
3. タスクを 3 つ追加し、一覧を表示してください。
4. 2 番目のタスクを完了にしてください。
5. タスクが保存されているファイル `todo.txt` の中身を `cat` で表示してください。VS Code でも開いて、同じ内容であることを確かめてください。
6. `todo.txt` を削除してください（エクスプローラーでも、コマンドでも構いません）。

<details>
<summary>解答例</summary>

```bash
cd ~/github-and-cli-tutorials/samples/todo-cli
./todo.sh help
./todo.sh add "Git をインストールする"
./todo.sh add "GitHub アカウントを作る"
./todo.sh add "第 1 章を読む"
./todo.sh list
./todo.sh done 2
cat todo.txt
code todo.txt     # VS Code で開いて確かめる
rm todo.txt
```

`todo.txt` の中身は次のようになっています。

```text
[ ] Git をインストールする
[x] GitHub アカウントを作る
[ ] 第 1 章を読む
```

教材のフォルダ全体を VS Code で開いている場合は、`rm todo.txt` の代わりに、エクスプローラーで `samples/todo-cli` の中の `todo.txt` を右クリックして **削除** を選んでも削除できます。
`todo.txt` がエクスプローラーで灰色に表示されるのは、Git が無視する設定になっているためです（[第 2 章](02-git-basics.md) で学びます）。

</details>

## まとめ

- コマンドは VS Code の統合ターミナルに、「コマンド名 オプション 引数」の形で、スペースで区切って入力する
- `pwd`・`ls`・`cd` で場所を確認・移動する。ファイルの作成・コピー・移動・削除は、エクスプローラーでもコマンド（`mkdir`・`cp`・`mv`・`rm`）でも同じ結果になる。`rm` で消したファイルは元に戻せない
- `>` / `>>` で結果をファイルに保存し、`|` でコマンドをつなげられる
- ファイルは VS Code で編集する。`code <ファイル>` で開き、<kbd>Ctrl</kbd> + <kbd>S</kbd>（macOS は <kbd>Command</kbd> + <kbd>S</kbd>）で保存する。タブの ● は未保存の印
- 困ったら `--help` や `man` で調べる。抜けられなくなったら <kbd>q</kbd>、<kbd>Ctrl</kbd> + <kbd>C</kbd>、vim なら <kbd>Esc</kbd> → `:q!`

もっと多くのコマンドは [付録: CLI チートシート](appendix/cli-cheatsheet.md) にまとめています。

---

[← 前の章: 環境構築](00-setup.md) ｜ [目次](../README.md) ｜ [次の章: Git の基本 →](02-git-basics.md)
