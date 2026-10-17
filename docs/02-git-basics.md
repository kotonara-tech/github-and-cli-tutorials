# 第 2 章: Git の基本

この章では、自分の PC の中だけで Git を使い、ファイルの変更履歴を記録する方法を学びます。
GitHub は使いません（次の章で使います）。

Git の操作は、VS Code の **ソース管理**（Source Control）ビューでの操作と、統合ターミナルで実行するコマンドの両方で説明します。
ソース管理ビューは、Git の操作を画面のボタンで行える VS Code の機能です（[公式ドキュメント: Source Control](https://code.visualstudio.com/docs/sourcecontrol/overview)）。画面の各部分の名前は、[0.8](00-setup.md#画面の各部分の名前) で確認できます。

> [!NOTE]
> 各操作の「VS Code で操作する」と「コマンドで操作する」は、どちらか一方を行えば十分です（両方を行うと、同じ変更を 2 回することになります）。
> どちらで操作しても結果は同じです。画面で操作した結果をコマンド（`git status` や `git log`）で確かめたり、その逆を試したりすると、理解が深まります。

## この章のゴール

- [ ] Git の初期設定ができる
- [ ] ワーキングツリー・ステージングエリア・リポジトリの違いを説明できる
- [ ] VS Code のソース管理ビューと、`git add`・`git commit` の両方で変更を記録できる
- [ ] ソース管理ビューと、`git status`・`git diff`・`git log` で状態や履歴を確認できる
- [ ] `.gitignore` で Git の管理から外すファイルを指定できる
- [ ] コミット前の変更を取り消せる

**所要時間の目安:** 60〜90 分

## 2.1 Git とは

**Git** は **バージョン管理システム** の 1 つです。ファイルの変更履歴を記録しておくことで、次のようなことができるようになります。

- いつ・誰が・何を・なぜ変更したのかを後から確認できる
- 以前の状態に戻せる
- 複数人で同じファイルを同時に編集し、変更をまとめられる

「レポート_最終.docx」「レポート_最終_修正版.docx」「レポート_最終_本当に最終.docx」のようにファイルを増やしていく代わりに、Git では変更の区切りごとに **コミット** という記録を残していきます。コミットは「その時点のファイルの状態のスナップショット（写真）」のようなものです。

Git で管理しているディレクトリを **リポジトリ** と呼びます。

## 2.2 Git の初期設定

Git を使い始める前に、一度だけ次の設定をします。設定は、統合ターミナルでコマンドを実行して行います。`--global` は「この PC のすべてのリポジトリで使う設定」という意味です。

### 名前とメールアドレス

コミットには「誰が変更したか」として、名前とメールアドレスが記録されます。

```bash
git config --global user.name "Hanako Yamada"
git config --global user.email "<メールアドレス>"
```

`"Hanako Yamada"` の部分はあなたの名前に置き換えてください（ローマ字がおすすめです）。

> [!IMPORTANT]
> GitHub に公開したコミットのメールアドレスは、誰でも見られます。
> 個人のメールアドレスを公開したくない場合は、GitHub が用意している **noreply アドレス** を使いましょう。
> noreply アドレスは、GitHub の [Settings → Emails](https://github.com/settings/emails) で「Keep my email addresses private」にチェックを入れると表示されます。
> `gh` コマンドでも確認できます。
>
> ```bash
> gh api user --jq '"\(.id)+\(.login)@users.noreply.github.com"'
> ```
>
> 表示された `12345678+hanako@users.noreply.github.com` のようなアドレスを `user.email` に設定します。

### そのほかのおすすめ設定

```bash
# 新しく作るリポジトリの最初のブランチ名を main にする
git config --global init.defaultBranch main

# git pull で取り込むときの方法を「マージ」にする（第 3 章で説明します）
git config --global pull.rebase false

# 日本語のファイル名を \346\227... のように表示せず、そのまま表示する
git config --global core.quotepath false

# コミットメッセージなどを書くときに開くエディタを VS Code にする
git config --global core.editor "code --wait"
```

最後の設定で、`git commit` などでメッセージを書くときに、VS Code のタブが開くようになります（使い方は [2.5](#コミットするgit-commit) で説明します）。
`--wait` は「開いたタブを閉じるまで、Git がコマンドの続きを待つ」という意味です。`--wait` を付けないと、Git はメッセージを書き終わるのを待たずに続きを実行し、メッセージが空のためコミットを中止してしまいます。

`gh` コマンドのエディタは、[0.7](00-setup.md#github-cli-のエディタを-vs-code-にする) で同じ `code --wait` に設定しました。`gh` は Git の `core.editor` を使わないため、それぞれに設定が必要です。

ターミナルの中で動くエディタのほうが好みの場合は、代わりに `nano` を設定しても構いません（`nano` の使い方は [1.10](01-cli-basics.md#nano初心者向け) を参照してください）。

```bash
git config --global core.editor nano
```

### 設定の確認

```bash
git config --global --list
```

出力例:

```text
user.name=Hanako Yamada
user.email=12345678+hanako@users.noreply.github.com
init.defaultbranch=main
pull.rebase=false
core.quotepath=false
core.editor=code --wait
```

設定は `~/.gitconfig` というファイルに保存されています（`cat ~/.gitconfig` で確認できます）。

## 2.3 Git の 3 つの場所

Git を理解するうえで最も大切なのが、次の 3 つの場所です。

```mermaid
flowchart LR
  W["ワーキングツリー<br>（今編集しているファイル）"] -- "git add" --> S["ステージングエリア<br>（次のコミットに含める変更）"]
  S -- "git commit" --> R["リポジトリ<br>（コミットの履歴）"]
```

| 場所 | 説明 | たとえると |
| --- | --- | --- |
| **ワーキングツリー** | 実際にファイルを編集する場所。普段目にしているファイルそのもの | 机の上の書類 |
| **ステージングエリア** | 次のコミットに含める変更を置いておく場所（**インデックス** とも呼ぶ） | 提出用の封筒 |
| **リポジトリ** | コミットの履歴が保存される場所（`.git` ディレクトリの中） | 提出済みの書類の保管庫 |

「編集する → `git add` で封筒に入れる → `git commit` で保管庫に記録する」という流れを繰り返すのが、Git の基本です。
ステージングエリアがあるおかげで、「複数のファイルを編集したけれど、このコミットにはこのファイルの変更だけを含めたい」という調整ができます。

VS Code のソース管理ビューは、この 3 つの場所をそのまま表示しています。

| Git の場所 | ソース管理ビューでの表示 |
| --- | --- |
| ワーキングツリー（まだ `git add` していない変更） | **変更**（Changes）に並ぶファイル |
| ステージングエリア | **ステージされている変更**（Staged Changes）に並ぶファイル（ステージしたファイルがあるときだけ表示されます） |
| リポジトリ | **グラフ**（Graph）に並ぶコミット |

**変更** にあるファイルの **+** をクリックするのが `git add`、メッセージを書いて **コミット** をクリックするのが `git commit` にあたります。

## 2.4 リポジトリを作る

練習用のディレクトリを作って、VS Code で開きましょう。統合ターミナルで次のコマンドを実行します。

```bash
mkdir -p ~/git-practice/my-first-repo
code ~/git-practice/my-first-repo
```

`my-first-repo` が新しいウィンドウで開きます（メニューの **ファイル**（File）> **フォルダーを開く...**（Open Folder...）で `my-first-repo` を選んでも構いません）。この章の残りの操作は、このウィンドウで行います。

初めて開いたフォルダは **制限モード**（Restricted Mode）で開くため、このままではソース管理ビューが使えません（「制限モードで動作する登録済みのソース管理プロバイダーはありません。」と表示されます）。
[0.8](00-setup.md#フォルダを信頼する制限モードを解除する) と同じように、画面上部の **管理**（Manage）をクリックし、**信頼する**（Trust）でフォルダを信頼してください。

> [!TIP]
> 同じ「ワークスペースの信頼」の画面の **信頼済みフォルダーとワークスペース** で **フォルダーの追加** をクリックし、`~/git-practice` を追加しておくのがおすすめです。
> この後の章で `~/git-practice` の中に作る練習用のリポジトリも、最初から信頼された状態で開くようになります。

次に、このフォルダを Git のリポジトリにします。この章では `git init` のコマンドで作る方法を使いますが、VS Code のボタンでも同じリポジトリができます。どちらか一方を行えば十分です。

### VS Code で操作する

1. アクティビティ バーの **ソース管理**（Source Control）を選びます（<kbd>Ctrl</kbd> + <kbd>Shift</kbd> + <kbd>G</kbd>、macOS は <kbd>Control</kbd> + <kbd>Shift</kbd> + <kbd>G</kbd>）。
2. 「現在開いているフォルダーには Git リポジトリがありません。」と表示されるので、**リポジトリを初期化する**（Initialize Repository）をクリックします。

### コマンドで操作する

メニューの **ターミナル**（Terminal）> **新しいターミナル**（New Terminal）で、このウィンドウの統合ターミナルを開きます（最初から `my-first-repo` にいます）。

```bash
cd ~/git-practice/my-first-repo
git init
```

出力例:

```text
Initialized empty Git repository in /home/hanako/git-practice/my-first-repo/.git/
```

`git init` を実行すると、`.git` という隠しディレクトリが作られます。この中に、コミットの履歴などすべての情報が保存されます。

```bash
ls -a
```

```text
.  ..  .git
```

エクスプローラーには `.git` は表示されません。誤って編集しないように、VS Code は初期設定で `.git` を表示しないようにしています。

> [!WARNING]
> `.git` ディレクトリを削除すると、そのリポジトリの履歴はすべて失われます。中身を直接編集することもしないでください。

## 2.5 最初のコミット

### ファイルを作る

#### VS Code で操作する

1. エクスプローラーの空いているところを右クリックして **新しいファイル...**（New File...）を選び、`README.md` と入力して <kbd>Enter</kbd> を押します。
2. 開いたエディターに `# はじめてのリポジトリ` と入力し、<kbd>Enter</kbd> で改行してから保存します（<kbd>Ctrl</kbd> + <kbd>S</kbd>、macOS は <kbd>Command</kbd> + <kbd>S</kbd>）。

> [!TIP]
> VS Code でファイルを書くときは、最後の行の後にも <kbd>Enter</kbd> で改行を入れておきましょう。`echo` で書いたファイルと同じ形になり、この後で `>>` を使って追記しても、前の行とつながりません。

#### コマンドで操作する

```bash
echo "# はじめてのリポジトリ" > README.md
```

### 状態を確認する（git status）

#### VS Code で操作する

1. アクティビティ バーの **ソース管理** を選びます。
2. **変更**（Changes）に `README.md` が表示され、右に `U` が付いています。アクティビティ バーのソース管理のアイコンには、変更のあるファイルの数（`1`）が表示されます。

エクスプローラーでも、`README.md` が緑色になり、右に `U` が表示されます。ファイル名の右の文字（Git の印）は、次の意味です。

| 印 | 意味 | `git status` での表示 |
| --- | --- | --- |
| `U`（緑） | Git がまだ管理していない新しいファイル（Untracked） | `Untracked files` |
| `M`（黄色系） | 変更されたファイル（Modified） | `modified` |
| `D`（赤） | 削除されたファイル（Deleted） | `deleted` |
| `A` | ステージした新しいファイル（Added） | `new file` |
| `R` | ステージした、名前を変えたファイル（Renamed） | `renamed` |

#### コマンドで操作する

```bash
git status
```

```text
On branch main

No commits yet

Untracked files:
  (use "git add <file>..." to include in what will be committed)
	README.md

nothing added to commit but untracked files present (use "git add" to track)
```

`Untracked files` は「Git がまだ管理していないファイル」という意味で、VS Code の `U` と同じです。
**`git status` は Git で最もよく使うコマンドです。** 迷ったらまず `git status` を実行しましょう。次に何をすればよいかのヒント（`use "git add <file>..."` など）も表示してくれます。
VS Code のソース管理ビューも、`git status` と同じ情報をいつも表示しています。

### ステージングエリアに追加する（git add）

#### VS Code で操作する

1. ソース管理ビューの **変更** にある `README.md` にマウスを合わせ、**+**（**変更をステージ**（Stage Changes））をクリックします。
2. `README.md` が **ステージされている変更**（Staged Changes）に移り、印が `A` に変わります。

統合ターミナルで `git status` を実行すると、下の「コマンドで操作する」と同じ表示になることを確かめられます。

#### コマンドで操作する

```bash
git add README.md
git status
```

```text
On branch main

No commits yet

Changes to be committed:
  (use "git rm --cached <file>..." to unstage)
	new file:   README.md
```

`Changes to be committed`（コミットされる変更）に `README.md` が入りました。VS Code の **ステージされている変更** と同じ意味です。

### コミットする（git commit）

#### VS Code で操作する

1. ソース管理ビューの上にあるメッセージ欄（「メッセージ (Ctrl+Enter で "main" にコミット)」と表示されている入力欄）に、`README を追加` と入力します。
2. **コミット**（Commit）をクリックします（<kbd>Ctrl</kbd> + <kbd>Enter</kbd>、macOS は <kbd>Command</kbd> + <kbd>Enter</kbd> でも同じです）。
3. **ステージされている変更** が空になれば、コミットできています。統合ターミナルで `git log --oneline` を実行すると、コミットが記録されたことを確かめられます。

> [!WARNING]
> ステージしたファイルがない状態で **コミット** をクリックすると、「ステージされている変更がなく、コミットできません。すべての変更をステージして、直接コミットしますか?」と聞かれます（スマート コミット）。
> **はい** を選ぶと、**変更** にあるすべてのファイルをステージしてコミットします。コミットに含めるファイルを選びたいときは、**キャンセル** で閉じて、ステージしてからやり直します。
> **常時** は選ばないでください。次から確認なしで、いつもすべての変更をステージしてコミットするようになり（設定の `git.enableSmartCommit` がオンになります）、ステージングエリアでコミットの中身を選ぶ練習ができなくなります。

#### コマンドで操作する

```bash
git commit -m "README を追加"
```

```text
[main (root-commit) bbf2d2e] README を追加
 1 file changed, 1 insertion(+)
 create mode 100644 README.md
```

`-m` の後ろに書いた文字列が **コミットメッセージ** です（VS Code では、メッセージ欄に書いた文字列です）。`bbf2d2e` はコミットを識別する ID（**コミットハッシュ** の先頭 7 文字）で、コミットごとに異なります。

> [!TIP]
> `-m` を付けずに `git commit` を実行すると、VS Code に `COMMIT_EDITMSG` というタブが開きます（2.2 で `core.editor` を `code --wait` にしたためです）。
> 1 行目にコミットメッセージを書いて保存し、タブを閉じる（<kbd>Ctrl</kbd> + <kbd>W</kbd>、macOS は <kbd>Command</kbd> + <kbd>W</kbd>）と、ターミナルの `git commit` が続きを実行してコミットされます。タブを閉じるまで、ターミナルには `hint: Waiting for your editor to close the file...` と表示されています。
> `#` で始まる行は無視されます。メッセージを空のまま閉じると、コミットは中止されます。
> ソース管理ビューでも、メッセージ欄を空のまま **コミット** をクリックすると、同じように `COMMIT_EDITMSG` のタブが開きます。

## 2.6 変更を記録する流れ

README.md に 1 行追記して、変更を確認してからコミットする流れを試してみましょう。

### ファイルを編集する

#### VS Code で操作する

1. エクスプローラーで `README.md` を開き、2 行目に `Git の練習用リポジトリです。` と入力して <kbd>Enter</kbd> で改行し、保存します。
2. ソース管理ビューの **変更** に `README.md` が表示され、印が `M` になります。

エディターの行番号の右（ガター）にも色が付きます。追加した行は緑、変更した行は青、削除した行は赤い三角で表示されます。

#### コマンドで操作する

```bash
echo "Git の練習用リポジトリです。" >> README.md
git status
```

```text
On branch main
Changes not staged for commit:
  (use "git add <file>..." to update what will be committed)
  (use "git restore <file>..." to discard changes in working directory)
	modified:   README.md

no changes added to commit (use "git add" and/or "git commit -a")
```

`modified`（変更あり）と表示されています。VS Code の `M` と同じ意味です。

### 変更内容を確認する（git diff）

#### VS Code で操作する

1. ソース管理ビューの **変更** にある `README.md` をクリックします。
2. **差分エディター**（Diff Editor）が開き、左に変更前（ステージングエリアの内容）、右に変更後（今のファイル）が並びます。追加した行は緑色で表示されます。

左右に並べずに 1 列で見たいときは、コマンド パレットで「**インライン ビューの切り替え**」（Toggle Inline View）を実行します。`git diff` の表示に近くなります（[公式ドキュメント: Staging and committing](https://code.visualstudio.com/docs/sourcecontrol/staging-commits)）。

#### コマンドで操作する

```bash
git diff
```

```diff
diff --git a/README.md b/README.md
index 8222397..c3b4902 100644
--- a/README.md
+++ b/README.md
@@ -1 +1,2 @@
 # はじめてのリポジトリ
+Git の練習用リポジトリです。
```

`+` で始まる行が追加された行、`-` で始まる行が削除された行です。

| コマンド | 比べるもの | VS Code での確認方法 |
| --- | --- | --- |
| `git diff` | ワーキングツリー と ステージングエリア（まだ `git add` していない変更） | **変更** にあるファイルをクリックする |
| `git diff --staged` | ステージングエリア と 最新のコミット（`git add` 済みで、次にコミットされる変更） | **ステージされている変更** にあるファイルをクリックする |

### add して commit する

#### VS Code で操作する

1. **変更** にある `README.md` の **+**（変更をステージ）をクリックします。
2. **ステージされている変更** に移った `README.md` をクリックし、これからコミットする内容を差分エディターで確認します（`git diff --staged` と同じです）。
3. メッセージ欄に `README に説明を追加` と入力し、**コミット** をクリックします。

#### コマンドで操作する

```bash
git add README.md
git diff --staged     # これからコミットする内容を確認
git commit -m "README に説明を追加"
```

> [!TIP]
> `git add .` と書くと、今いるディレクトリ以下の **すべての** 変更をまとめてステージングできます。ソース管理ビューの **変更** の見出しにマウスを合わせて **+**（**すべての変更をステージ**（Stage All Changes））をクリックしても、同じようにすべての変更をまとめてステージします。
> 便利ですが、意図しないファイル（パスワードを書いたファイルなど）まで含めてしまうことがあります。
> まとめてステージした後は、必ず `git status` やソース管理ビューで中身を確認してからコミットしましょう。

## 2.7 履歴を見る

### VS Code で操作する

1. ソース管理ビューの下のほうにある **グラフ**（Graph）を開きます。コミットが新しい順に並び、最新のコミットには今のブランチの名前 `main` が表示されます。
2. コミットをクリックすると、そのコミットで変更されたファイルの一覧が開きます。ファイルをクリックすると、そのコミットでの差分を確認できます（`git show` と同じです）。

グラフでコミットを選んでも、ファイルが過去の状態に戻ることはありません。

1 つのファイルの履歴を見たいときは、そのファイルをエディターで開き、エクスプローラーの下のほうにある **タイムライン**（Timeline）を開きます。そのファイルを変更したコミットが並び、クリックするとその時点の差分を確認できます。タイムラインには、ファイルを保存した記録（ローカル履歴）も一緒に並びます（[公式ドキュメント: Source Control History](https://code.visualstudio.com/docs/sourcecontrol/history)）。

### コマンドで操作する

```bash
git log
```

```text
commit 1d5c4826ef9135f96c519a95d6792a523e3420c7 (HEAD -> main)
Author: Hanako Yamada <12345678+hanako@users.noreply.github.com>
Date:   Wed Apr 1 10:05:00 2026 +0900

    README に説明を追加

commit bbf2d2e11be7efa10ee4acb8d68815f59730d847
Author: Hanako Yamada <12345678+hanako@users.noreply.github.com>
Date:   Wed Apr 1 10:00:00 2026 +0900

    README を追加
```

新しいコミットが上に表示されます。`HEAD -> main` は「今 main ブランチにいて、その最新のコミットがこれ」という意味です（ブランチは [第 4 章](04-branch.md) で学びます）。

よく使うオプション:

```bash
git log --oneline           # 1 コミット 1 行で表示する
git log -p                  # 各コミットの差分も表示する
git log --oneline --graph   # 枝分かれの様子を図で表示する
git show bbf2d2e            # 特定のコミットの内容を表示する（ハッシュは先頭の数文字でよい）
```

```text
$ git log --oneline
1d5c482 (HEAD -> main) README に説明を追加
bbf2d2e README を追加
```

## 2.8 Git の管理から外す（.gitignore）

ログファイル、ビルドで生成されるファイル、パスワードなどの秘密情報を書いたファイルは、リポジトリに含めるべきではありません。
**`.gitignore`** というファイルにパターンを書くと、そのファイルを Git が無視するようになります。`.gitignore` 自体はコミットして、チームで共有します。

### VS Code で操作する

1. エクスプローラーの **新しいファイル...** で `password.txt` を作り、`secret` と書いて保存します。同じように、`debug.log` を作って `debug` と書いて保存します。
2. ソース管理ビューの **変更** に、2 つのファイルが `U` の印付きで表示されます。
3. **新しいファイル...** で `.gitignore` を作り、次の内容を書いて保存します（最後の行の後にも改行を入れます）。

   ```text
   # 秘密情報
   password.txt

   # ログファイル（* は「任意の文字列」）
   *.log
   ```

4. `password.txt` と `debug.log` が **変更** から消え、`.gitignore` だけが表示されます。エクスプローラーでは、2 つのファイルが灰色で表示されます。灰色は、Git が無視しているファイルの印です。
5. `.gitignore` の **+** でステージし、メッセージ欄に `.gitignore を追加` と入力して **コミット** をクリックします。

### コマンドで操作する

```bash
echo "secret" > password.txt
echo "debug" > debug.log
git status          # password.txt と debug.log が Untracked files に表示される
```

```bash
cat > .gitignore <<'EOF'
# 秘密情報
password.txt

# ログファイル（* は「任意の文字列」）
*.log
EOF
git status          # .gitignore だけが表示され、2 つのファイルは表示されなくなる
```

```bash
git add .gitignore
git commit -m ".gitignore を追加"
```

### .gitignore の書き方

| 書き方 | 意味 |
| --- | --- |
| `password.txt` | `password.txt` という名前のファイル（どの階層でも） |
| `*.log` | 拡張子が `.log` のファイル |
| `build/` | `build` ディレクトリとその中身 |
| `/todo.txt` | リポジトリのルート直下の `todo.txt` だけ |
| `# ...` | コメント |

> [!WARNING]
> `.gitignore` が無視するのは「まだ Git が管理していない」ファイルだけです。一度コミットしてしまったファイルは、後から `.gitignore` に書いても無視されません。
> 秘密情報は **最初にコミットする前に** `.gitignore` に書きましょう。

## 2.9 変更を取り消す

### ワーキングツリーの変更を取り消す（git restore）

ファイルを編集したけれど、最後にコミットした状態に戻したいときに使います。

#### VS Code で操作する

1. `README.md` の最後に `間違えて書いた行` を追記して保存します。
2. ソース管理ビューの **変更** にある `README.md` にマウスを合わせ、**変更を破棄**（Discard Changes）のアイコン（↶）をクリックします。
3. 確認のメッセージで **ファイルの破棄**（Discard File）をクリックすると、追記した行が消えます。

> [!WARNING]
> **変更を破棄** で取り消した変更は、元に戻せません（ゴミ箱にも入りません）。
> また、新しく作ったファイル（`U` の印のファイル）で **変更を破棄** を選ぶと、「追跡されていない次のファイルを削除しますか」と聞かれ、**ファイルを削除** を選ぶとファイルそのものが削除されます。

#### コマンドで操作する

```bash
echo "間違えて書いた行" >> README.md
git restore README.md
cat README.md        # 追記した行が消えている
```

> [!WARNING]
> `git restore <ファイル>` で取り消した変更は、元に戻せません。

### ステージングを取り消す（git restore --staged）

`git add` したけれど、やっぱり次のコミットに含めたくないときに使います。ファイルの中身（ワーキングツリー）はそのまま残ります。

#### VS Code で操作する

1. `README.md` の最後に `まだコミットしたくない変更` を追記して保存し、**+** でステージします。
2. **ステージされている変更** にある `README.md` にマウスを合わせ、**−**（**変更のステージング解除**（Unstage Changes））をクリックします。
3. `README.md` が **変更** に戻ります。ファイルの中身は変わりません。
4. 練習が終わったので、**変更を破棄** で追記した行も取り消しておきます。

#### コマンドで操作する

```bash
echo "まだコミットしたくない変更" >> README.md
git add README.md
git restore --staged README.md
git status           # modified（まだ add されていない状態）に戻っている
git restore README.md  # 練習が終わったので、追記した行も取り消しておく
```

コミットした後の取り消し方は [第 8 章: 困ったときは](08-troubleshooting.md) で紹介します。

## 2.10 ファイルの削除と名前の変更

Git で管理しているファイルを削除・名前変更するときは、`git rm` / `git mv` を使うと、変更が自動でステージングされます。
VS Code のエクスプローラーで削除・名前変更したときは、`rm` / `mv` と同じようにファイルが変わるだけなので、その後で自分でステージします。
練習用のファイルで試してみましょう。

### VS Code で操作する

1. エクスプローラーの **新しいファイル...** で `temp.md` を作り、`一時的なメモ` と書いて保存します。ステージして、`一時的なメモを追加` というメッセージでコミットします。
2. エクスプローラーで `temp.md` を右クリックし、**名前の変更...**（Rename...）で `temp-old.md` に変えます。
3. ソース管理ビューの **変更** に、`temp.md`（`D`）と `temp-old.md`（`U`）の 2 つが表示されます。この時点の Git には、「`temp.md` が消えて、`temp-old.md` という新しいファイルができた」ように見えています。
4. **変更** の見出しの **+**（**すべての変更をステージ**）で、2 つともステージします。**ステージされている変更** には `temp-old.md` だけが、`R`（名前の変更）の印付きで表示されます。
5. `メモのファイル名を変更` というメッセージでコミットします。
6. エクスプローラーで `temp-old.md` を右クリックし、**削除**（Delete）を選びます。**変更** に `temp-old.md` が `D` の印付きで表示されるので、ステージして `不要になったメモを削除` というメッセージでコミットします。

Git は、「削除されたファイル」と「新しいファイル」の **両方がステージされたとき** に、中身が同じ（または似ている）ことから、名前の変更だと判断します。片方だけをステージした状態では、`new file` と `deleted` の 2 つの別々の変更として扱います。
手順 3 と手順 4 の状態を `git status` で確かめると、それぞれ次のように表示されます。

```text
$ git status
On branch main
Changes not staged for commit:
  (use "git add/rm <file>..." to update what will be committed)
  (use "git restore <file>..." to discard changes in working directory)
	deleted:    temp.md

Untracked files:
  (use "git add <file>..." to include in what will be committed)
	temp-old.md

no changes added to commit (use "git add" and/or "git commit -a")
```

```text
$ git status
On branch main
Changes to be committed:
  (use "git restore --staged <file>..." to unstage)
	renamed:    temp.md -> temp-old.md
```

### コマンドで操作する

```bash
echo "一時的なメモ" > temp.md
git add temp.md
git commit -m "一時的なメモを追加"

git mv temp.md temp-old.md     # 名前を変える
git status                     # renamed: temp.md -> temp-old.md と表示される
git commit -m "メモのファイル名を変更"

git rm temp-old.md             # 削除する
git status                     # deleted: temp-old.md と表示される
git commit -m "不要になったメモを削除"
```

`rm` や `mv` で操作した後に `git add` しても、同じ結果になります（VS Code のエクスプローラーでの操作は、この方法と同じです）。
削除したファイルも履歴には残っているので、`git log` や `git show` で過去の内容を確認できます。

## 2.11 良いコミットとは

- **1 つのコミットには 1 つの目的** の変更だけを含めます。「バグ修正」と「関係ない文言の修正」は別のコミットにします。
- **コミットメッセージには「何をしたか」を簡潔に** 書きます。必要なら「なぜそうしたか」も書きます。
- 動かない状態のコードは、なるべくコミットしないようにします。

書き方の詳しいルールと例は [付録: コミットメッセージの書き方](appendix/commit-message.md) にまとめています。

## 演習

### 演習 2-1: 自己紹介リポジトリを作る

1. `~/git-practice/my-first-repo` に `profile.md` を作り、名前と好きなものを書いてコミットしてください。
2. `profile.md` に趣味を追記し、差分を確認してからコミットしてください。
3. コミットが記録されていることを、ソース管理ビューの **グラフ** か `git log --oneline` で確認してください。

<details>
<summary>解答例</summary>

VS Code で操作する場合は、次のとおりです。

1. エクスプローラーの **新しいファイル...** で `profile.md` を作り、次の内容を書いて保存します。

   ```markdown
   # 自己紹介

   - 名前: 山田 花子
   - 好きなもの: カレー
   ```

2. ソース管理ビューで `profile.md` の **+** をクリックしてステージし、メッセージ欄に `自己紹介を追加` と入力して **コミット** をクリックします。
3. `profile.md` の最後に `- 趣味: 読書` の行を書き足して保存します。**変更** にある `profile.md` をクリックして差分エディターで確認してから、ステージし、`自己紹介に趣味を追加` というメッセージでコミットします。
4. **グラフ** に、2 つのコミットが増えていることを確認します。

コマンドで操作する場合は、次のとおりです。

```bash
cd ~/git-practice/my-first-repo
cat > profile.md <<'EOF'
# 自己紹介

- 名前: 山田 花子
- 好きなもの: カレー
EOF
git add profile.md
git commit -m "自己紹介を追加"

echo "- 趣味: 読書" >> profile.md
git diff
git add profile.md
git commit -m "自己紹介に趣味を追加"

git log --oneline
```

`cat > ファイル名 <<'EOF'` から `EOF` までの行は「ヒアドキュメント」という書き方で、複数行の文字列をファイルに書き込めます。エディタを使わずに、コマンドだけでファイルを作りたいときに便利です。

</details>

### 演習 2-2: 2 つのファイルを別々のコミットにする

1. `profile.md` と `README.md` の両方を編集し、保存してください。
2. `profile.md` の変更だけをコミットし、その後で `README.md` の変更をコミットしてください。
3. それぞれのコミットに 1 つのファイルの変更だけが含まれていることを、**グラフ** でコミットをクリックするか、`git log --oneline` と `git show` で確認してください。

<details>
<summary>解答例</summary>

VS Code で操作する場合は、次のとおりです。

1. `profile.md` の最後に `- 出身: 東京都`、`README.md` の最後に `自己紹介を管理しています。` を書き足して、両方を保存します。**変更** に 2 つのファイルが `M` の印付きで表示されます。
2. `profile.md` の **+** だけをクリックしてステージします。**ステージされている変更** に `profile.md`、**変更** に `README.md` が並んでいることを確認し、`自己紹介に出身地を追加` というメッセージでコミットします。
3. `README.md` をステージし、`README にリポジトリの説明を追記` というメッセージでコミットします。
4. **グラフ** で 2 つのコミットをそれぞれクリックし、変更されたファイルが 1 つずつであることを確認します。

手順 2 で、ステージせずに **コミット** をクリックしないように注意しましょう。スマート コミットの確認で **はい** を選ぶと、2 つのファイルがまとめて 1 つのコミットになってしまいます。

コマンドで操作する場合は、次のとおりです。

```bash
echo "- 出身: 東京都" >> profile.md
echo "自己紹介を管理しています。" >> README.md
git status                 # 2 つのファイルが modified

git add profile.md
git status                 # profile.md だけが Changes to be committed
git commit -m "自己紹介に出身地を追加"

git add README.md
git commit -m "README にリポジトリの説明を追記"

git log --oneline
git show HEAD              # 最新のコミット（README.md の変更だけ）
git show HEAD~1            # 1 つ前のコミット（profile.md の変更だけ）
```

`HEAD` は「今いる場所の最新のコミット」、`HEAD~1` は「その 1 つ前のコミット」を表します。

</details>

### 演習 2-3: .gitignore を使う

1. `memo.tmp` と `notes.tmp` というファイルを作ってください（中身は空で構いません）。
2. 拡張子が `.tmp` のファイルを Git が無視するように `.gitignore` を設定し、コミットしてください。
3. ソース管理ビューや `git status` に `.tmp` のファイルが表示されないことを確認してください。

<details>
<summary>解答例</summary>

VS Code で操作する場合は、次のとおりです。

1. エクスプローラーの **新しいファイル...** で `memo.tmp` と `notes.tmp` を作ります。**変更** に 2 つのファイルが `U` の印付きで表示されます。
2. 2.8 で作った `.gitignore` を開き、最後に `*.tmp` の行を書き足して保存します。
3. `memo.tmp` と `notes.tmp` が **変更** から消え、エクスプローラーでは灰色で表示されます。**変更** には `.gitignore`（`M`）だけが残ります。
4. `.gitignore` をステージし、`.tmp ファイルを Git の管理から外す` というメッセージでコミットします。

コマンドで操作する場合は、次のとおりです。

```bash
touch memo.tmp notes.tmp
echo "*.tmp" >> .gitignore
git status              # .gitignore だけが表示される
git add .gitignore
git commit -m ".tmp ファイルを Git の管理から外す"
```

</details>

## まとめ

- 初めに `user.name` と `user.email` を設定し、Git のエディタを VS Code（`code --wait`）にする
- 「編集 → ステージ（**+** / `git add`）→ コミット（**コミット** / `git commit`）」が基本の流れ。ソース管理ビューの **変更** と **ステージされている変更** は、ワーキングツリーとステージングエリアにあたる
- 迷ったらソース管理ビューか `git status` で状態を確認する。差分は差分エディターか `git diff`、履歴は **グラフ** か `git log` で確認する
- 管理したくないファイルは `.gitignore` に書く（エクスプローラーでは灰色で表示される）
- コミット前の変更は、**変更を破棄** や `git restore` で取り消せる（取り消した変更は元に戻せない）

---

[← 前の章: CLI の基本](01-cli-basics.md) ｜ [目次](../README.md) ｜ [次の章: GitHub とリモートリポジトリ →](03-github-remote.md)
