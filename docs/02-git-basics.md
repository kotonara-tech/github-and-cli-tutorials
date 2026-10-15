# 第 2 章: Git の基本

この章では、自分の PC の中だけで Git を使い、ファイルの変更履歴を記録する方法を学びます。
GitHub は使いません（次の章で使います）。

## この章のゴール

- [ ] Git の初期設定ができる
- [ ] ワーキングツリー・ステージングエリア・リポジトリの違いを説明できる
- [ ] `git add` と `git commit` で変更を記録できる
- [ ] `git status`・`git diff`・`git log` で状態や履歴を確認できる
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

Git を使い始める前に、一度だけ次の設定をします。`--global` は「この PC のすべてのリポジトリで使う設定」という意味です。

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

# コミットメッセージなどを書くときに開くエディタを nano にする
git config --global core.editor nano
```

VS Code を使いたい場合は、最後の設定の代わりに次のように設定します。

```bash
git config --global core.editor "code --wait"
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
core.editor=nano
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

## 2.4 リポジトリを作る

練習用のディレクトリを作って、Git のリポジトリにしてみましょう。

```bash
mkdir -p ~/git-practice/my-first-repo
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

> [!WARNING]
> `.git` ディレクトリを削除すると、そのリポジトリの履歴はすべて失われます。中身を直接編集することもしないでください。

## 2.5 最初のコミット

### ファイルを作る

```bash
echo "# はじめてのリポジトリ" > README.md
```

### 状態を確認する（git status）

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

`Untracked files` は「Git がまだ管理していないファイル」という意味です。
**`git status` は Git で最もよく使うコマンドです。** 迷ったらまず `git status` を実行しましょう。次に何をすればよいかのヒント（`use "git add <file>..."` など）も表示してくれます。

### ステージングエリアに追加する（git add）

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

`Changes to be committed`（コミットされる変更）に `README.md` が入りました。

### コミットする（git commit）

```bash
git commit -m "README を追加"
```

```text
[main (root-commit) bbf2d2e] README を追加
 1 file changed, 1 insertion(+)
 create mode 100644 README.md
```

`-m` の後ろに書いた文字列が **コミットメッセージ** です。`bbf2d2e` はコミットを識別する ID（**コミットハッシュ** の先頭 7 文字）で、コミットごとに異なります。

> [!TIP]
> `-m` を付けずに `git commit` を実行すると、エディタが開いてコミットメッセージを入力できます。
> 保存してエディタを閉じるとコミットされます。メッセージを空のまま閉じると、コミットは中止されます。

## 2.6 変更を記録する流れ

README.md に 1 行追記してみましょう。

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

`modified`（変更あり）と表示されています。

### 変更内容を確認する（git diff）

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

| コマンド | 比べるもの |
| --- | --- |
| `git diff` | ワーキングツリー と ステージングエリア（まだ `git add` していない変更） |
| `git diff --staged` | ステージングエリア と 最新のコミット（`git add` 済みで、次にコミットされる変更） |

### add して commit する

```bash
git add README.md
git diff --staged     # これからコミットする内容を確認
git commit -m "README に説明を追加"
```

> [!TIP]
> `git add .` と書くと、今いるディレクトリ以下の **すべての** 変更をまとめてステージングできます。
> 便利ですが、意図しないファイル（パスワードを書いたファイルなど）まで含めてしまうことがあります。
> `git add .` の後は、必ず `git status` で中身を確認してからコミットしましょう。

## 2.7 履歴を見る

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
**`.gitignore`** というファイルにパターンを書くと、そのファイルを Git が無視するようになります。

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

`.gitignore` 自体はコミットして、チームで共有します。

```bash
git add .gitignore
git commit -m ".gitignore を追加"
```

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

```bash
echo "間違えて書いた行" >> README.md
git restore README.md
cat README.md        # 追記した行が消えている
```

> [!WARNING]
> `git restore <ファイル>` で取り消した変更は、元に戻せません。

### ステージングを取り消す（git restore --staged）

`git add` したけれど、やっぱり次のコミットに含めたくないときに使います。ファイルの中身（ワーキングツリー）はそのまま残ります。

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
練習用のファイルで試してみましょう。

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

`rm` や `mv` で操作した後に `git add` しても、同じ結果になります。
削除したファイルも履歴には残っているので、`git log` や `git show` で過去の内容を確認できます。

## 2.11 良いコミットとは

- **1 つのコミットには 1 つの目的** の変更だけを含めます。「バグ修正」と「関係ない文言の修正」は別のコミットにします。
- **コミットメッセージには「何をしたか」を簡潔に** 書きます。必要なら「なぜそうしたか」も書きます。
- 動かない状態のコードは、なるべくコミットしないようにします。

書き方の詳しいルールと例は [付録: コミットメッセージの書き方](appendix/commit-message.md) にまとめています。

## 演習

### 演習 2-1: 自己紹介リポジトリを作る

1. `~/git-practice/my-first-repo` に `profile.md` を作り、名前と好きなものを書いてコミットしてください。
2. `profile.md` に趣味を追記し、`git diff` で差分を確認してからコミットしてください。
3. `git log --oneline` で、コミットが記録されていることを確認してください。

<details>
<summary>解答例</summary>

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

`cat > ファイル名 <<'EOF'` から `EOF` までの行は「ヒアドキュメント」という書き方で、複数行の文字列をファイルに書き込めます。もちろん、エディタで編集しても構いません。

</details>

### 演習 2-2: 2 つのファイルを別々のコミットにする

1. `profile.md` と `README.md` の両方を編集してください。
2. `profile.md` の変更だけをコミットし、その後で `README.md` の変更をコミットしてください。
3. `git log --oneline` と `git show` で、それぞれのコミットに 1 つのファイルの変更だけが含まれていることを確認してください。

<details>
<summary>解答例</summary>

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

1. `memo.tmp` と `notes.tmp` というファイルを作ってください。
2. 拡張子が `.tmp` のファイルを Git が無視するように `.gitignore` を設定し、コミットしてください。
3. `git status` に `.tmp` のファイルが表示されないことを確認してください。

<details>
<summary>解答例</summary>

```bash
touch memo.tmp notes.tmp
echo "*.tmp" >> .gitignore
git status              # .gitignore だけが表示される
git add .gitignore
git commit -m ".tmp ファイルを Git の管理から外す"
```

</details>

## まとめ

- 初めに `user.name` と `user.email` を設定する
- 「編集 → `git add` → `git commit`」が基本の流れ
- 迷ったら `git status`。差分は `git diff`、履歴は `git log` で確認する
- 管理したくないファイルは `.gitignore` に書く
- コミット前の変更は `git restore` で取り消せる

---

[← 前の章: CLI の基本](01-cli-basics.md) ｜ [目次](../README.md) ｜ [次の章: GitHub とリモートリポジトリ →](03-github-remote.md)
