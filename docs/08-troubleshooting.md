# 第 8 章: 困ったときは

Git や GitHub を使っていてよくあるトラブルと、その対処方法をまとめています。
**まずは落ち着いて `git status` を実行し、表示されたメッセージ（特に `hint:` の行）を読む** のが解決への近道です。

> [!IMPORTANT]
> この章のコマンドの中には、変更を **取り消せない形で消してしまう** ものがあります（⚠️ を付けています）。
> 実行する前に、何が消えるのかを理解してから実行してください。不安なときは、ディレクトリごとコピーしてバックアップを取っておくと安心です（`cp -r my-repo my-repo-backup`）。

## 目次

- [コミット・変更の取り消し](#コミット変更の取り消し)
  - [コミットメッセージを間違えた（push 前）](#コミットメッセージを間違えたpush-前)
  - [ファイルを入れ忘れてコミットした（push 前）](#ファイルを入れ忘れてコミットしたpush-前)
  - [直前のコミットを取り消したい（push 前）](#直前のコミットを取り消したいpush-前)
  - [push したコミットを取り消したい](#push-したコミットを取り消したい)
  - [main で作業してしまった（push 前）](#main-で作業してしまったpush-前)
  - [作業中の変更を一時的に退避したい](#作業中の変更を一時的に退避したい)
  - [消してしまったコミットやブランチを復活させたい](#消してしまったコミットやブランチを復活させたい)
- [push / pull のエラー](#push--pull-のエラー)
  - [push が rejected になる](#push-が-rejected-になる)
  - [pull で「divergent branches」と表示される](#pull-でdivergent-branchesと表示される)
  - [認証に失敗する（HTTPS）](#認証に失敗するhttps)
  - [Permission denied (publickey) と表示される（SSH）](#permission-denied-publickey-と表示されるssh)
- [ブランチ・マージ](#ブランチマージ)
  - [ブランチを切り替えられない](#ブランチを切り替えられない)
  - [コンフリクトが起きた](#コンフリクトが起きた)
  - [ブランチを削除できない（not fully merged）](#ブランチを削除できないnot-fully-merged)
  - [detached HEAD と表示される](#detached-head-と表示される)
- [そのほか](#そのほか)
  - [エディタ（vim）が開いて抜けられない](#エディタvimが開いて抜けられない)
  - [not a git repository と表示される](#not-a-git-repository-と表示される)
  - [日本語のファイル名が数字の羅列で表示される](#日本語のファイル名が数字の羅列で表示される)
  - [LF will be replaced by CRLF と表示される](#lf-will-be-replaced-by-crlf-と表示される)
  - [パスワードや API キーをコミットしてしまった](#パスワードや-api-キーをコミットしてしまった)
- [それでも解決しないときは](#それでも解決しないときは)

## コミット・変更の取り消し

まだ push していない変更と、すでに push した変更とで、対処方法が異なります。

| 状況 | 使うコマンド |
| --- | --- |
| まだ `git add` していない変更を捨てたい | `git restore <ファイル>` ⚠️ |
| `git add` を取り消したい | `git restore --staged <ファイル>` |
| 直前のコミットを修正したい（**push 前**） | `git commit --amend` |
| 直前のコミットを取り消したい（**push 前**） | `git reset --soft HEAD~1` |
| push したコミットを取り消したい | `git revert <コミット>` |

### コミットメッセージを間違えた（push 前）

```bash
git commit --amend -m "正しいメッセージ"
```

直前のコミットが、新しいメッセージのコミットに置き換わります。

### ファイルを入れ忘れてコミットした（push 前）

```bash
git add 忘れたファイル
git commit --amend --no-edit     # --no-edit: メッセージはそのまま
```

> [!WARNING]
> `--amend` はコミットを **作り直す** 操作です。すでに push したコミットに使うと、リモートと履歴が食い違い、push できなくなります。push 済みの場合は、新しいコミットを追加して修正しましょう。

### 直前のコミットを取り消したい（push 前）

```bash
git reset --soft HEAD~1
```

コミットだけが取り消され、変更内容はステージングされた状態で残ります。修正してコミットし直せます。

| コマンド | コミット | ステージング | ファイルの変更 |
| --- | --- | --- | --- |
| `git reset --soft HEAD~1` | 取り消す | 残る | 残る |
| `git reset HEAD~1` | 取り消す | 取り消す | 残る |
| `git reset --hard HEAD~1` ⚠️ | 取り消す | 取り消す | **消える** |

### push したコミットを取り消したい

push 済みのコミットは、履歴を書き換えずに **「打ち消すコミット」を新しく追加** して取り消します。

```bash
git log --oneline                # 取り消したいコミットのハッシュを確認する
git revert 1d5c482               # そのコミットの変更を打ち消すコミットを作る
git push
```

エディタが開いたら、メッセージ（`Revert "..."`）を確認して保存し、閉じます。

> [!CAUTION]
> `git reset` で履歴を巻き戻してから `git push --force` する方法もありますが、**他の人がすでに取り込んだコミットを消してしまう** 危険があります。共有しているブランチでは使わないでください。

### main で作業してしまった（push 前）

作業ブランチを作るのを忘れて、`main` でコミットしてしまった場合です。

```bash
git switch -c feature/xxx        # 今の状態（コミット済み）のまま、新しいブランチを作って移動する
git switch main
git reset --hard origin/main     # ⚠️ main をリモートと同じ状態に戻す
git switch feature/xxx           # 作業ブランチに戻って続きをする
```

> [!WARNING]
> `git reset --hard` は、コミットしていない変更をすべて消します。実行前に `git status` で、コミットしていない変更がないことを確認してください。

まだコミットしていない（編集しただけの）場合は、`git switch -c feature/xxx` を実行するだけで、変更を持ったまま新しいブランチに移動できます。

### 作業中の変更を一時的に退避したい

「作業の途中だけど、急いで別のブランチで作業しなければならない」ときは、**stash（スタッシュ）** で変更を一時的に退避できます。

```bash
git stash push -m "delete コマンドの作業途中"   # 変更を退避する（ワーキングツリーがきれいになる）
git switch main                               # 別の作業をする
# ...
git switch feature/2-delete-command
git stash list                                # 退避した変更の一覧
git stash pop                                 # 最新の退避を取り出して元に戻す
```

新しく作ったファイル（Untracked files）も退避したいときは `git stash push -u` を使います。

### 消してしまったコミットやブランチを復活させたい

`git reset --hard` や `git branch -D` で消してしまったコミットも、しばらくの間は **reflog** に記録が残っています。

```bash
git reflog
```

```text
8e4f2a1 (HEAD -> main) HEAD@{0}: reset: moving to HEAD~1
1d5c482 HEAD@{1}: commit: 消してしまったコミット
...
```

戻したい時点のハッシュを見つけたら、そこからブランチを作って復活させます。

```bash
git switch -c restored 1d5c482
```

## push / pull のエラー

### push が rejected になる

```text
 ! [rejected]        main -> main (fetch first)
error: failed to push some refs to 'https://github.com/hanako/my-first-repo.git'
```

リモートに、手元にないコミットがあります。先に取り込んでから push します。

```bash
git pull
git push
```

コンフリクトした場合は、[コンフリクトが起きた](#コンフリクトが起きた) を参照してください。**`git push --force` は使わないでください。**

### pull で「divergent branches」と表示される

```text
hint: You have divergent branches and need to specify how to reconcile them.
...
fatal: Need to specify how to reconcile divergent branches.
```

手元とリモートの両方に新しいコミットがあり、「どうやって 1 つにまとめるか」が設定されていないために止まっています。
[第 2 章](02-git-basics.md#そのほかのおすすめ設定) のおすすめ設定（マージでまとめる）をしてから、もう一度 pull します。

```bash
git config --global pull.rebase false
git pull
```

### 認証に失敗する（HTTPS）

```text
remote: Support for password authentication was removed on August 13, 2021.
fatal: Authentication failed for 'https://github.com/hanako/my-first-repo.git/'
```

GitHub のパスワードでは認証できません。`gh` でログインし直し、Git から `gh` の認証情報を使うように設定します。

```bash
gh auth login
gh auth setup-git
gh auth status
```

`Repository not found` と表示される場合は、URL の打ち間違いか、そのリポジトリへのアクセス権がない（非公開のリポジトリに招待されていない）可能性があります。`git remote -v` で URL を確認してください。

### Permission denied (publickey) と表示される（SSH）

```text
git@github.com: Permission denied (publickey).
fatal: Could not read from remote repository.
```

SSH の鍵が GitHub に登録されていません。[第 3 章の SSH の手順](03-github-remote.md#ssh参考) で鍵を作って登録するか、HTTPS の URL に切り替えます。

```bash
git remote set-url origin https://github.com/<ユーザー名>/<リポジトリ名>.git
```

## ブランチ・マージ

### ブランチを切り替えられない

```text
error: Your local changes to the following files would be overwritten by checkout:
	README.md
Please commit your changes or stash them before you switch branches.
Aborting
```

コミットしていない変更が、切り替え先のブランチの内容と衝突しています。次のどれかを選びます。

- 変更をコミットしてから切り替える
- 変更を `git stash` で退避してから切り替える（[作業中の変更を一時的に退避したい](#作業中の変更を一時的に退避したい)）
- 変更が不要なら `git restore README.md` で捨ててから切り替える ⚠️

### コンフリクトが起きた

```text
CONFLICT (content): Merge conflict in profile.txt
Automatic merge failed; fix conflicts and then commit the result.
```

1. `git status` で `both modified` のファイルを確認する
2. ファイルを開き、`<<<<<<<`・`=======`・`>>>>>>>` の部分を正しい内容に書き換える（マーカーの行は消す）
3. `git add <ファイル>`
4. `git commit`

詳しくは [第 4 章](04-branch.md#45-コンフリクト競合を解消する) を参照してください。マージをやめたいときは `git merge --abort` で元に戻せます。

### ブランチを削除できない（not fully merged）

```text
error: the branch 'fix/1-empty-task' is not fully merged.
If you are sure you want to delete it, run 'git branch -D fix/1-empty-task'
```

そのブランチのコミットが、今いるブランチに取り込まれていません。

- GitHub の Pull Request を **Squash and merge** や **Rebase and merge** でマージした場合は、内容は取り込まれていても別のコミットになっているため、このエラーになります。Pull Request がマージ済みであることを確認してから `git branch -D` で削除してください。
- 本当にマージしていない場合は、削除すると作業が失われます。必要な作業でないかよく確認してください。

### detached HEAD と表示される

```text
You are in 'detached HEAD' state. ...
```

ブランチではなく、特定のコミットに直接移動している状態です。過去の状態を眺めるだけなら問題ありませんが、この状態でコミットすると、後で見つけにくくなります。
ブランチに戻るには、ブランチ名を指定して切り替えます。

```bash
git switch main          # または git switch -（直前のブランチに戻る）
```

detached HEAD の状態でコミットしてしまい、それを残したい場合は、戻る前にブランチを作ります。

```bash
git switch -c save-my-work
```

## そのほか

### エディタ（vim）が開いて抜けられない

`git commit` や `git merge` のときに、見慣れない画面が開いて操作できなくなった場合は、vim が開いています。

- 保存して閉じる（メッセージを確定する）: <kbd>Esc</kbd> → `:wq` → <kbd>Enter</kbd>
- 保存せずに閉じる: <kbd>Esc</kbd> → `:q!` → <kbd>Enter</kbd>

今後は使い慣れたエディタが開くように設定しておきましょう。

```bash
git config --global core.editor nano
# または
git config --global core.editor "code --wait"
```

### not a git repository と表示される

```text
fatal: not a git repository (or any of the parent directories): .git
```

Git のリポジトリではないディレクトリでコマンドを実行しています。`pwd` で今いる場所を確認し、リポジトリのディレクトリに `cd` してください。

### 日本語のファイル名が数字の羅列で表示される

`git status` で `"\346\227\245\350\250\230.md"` のように表示される場合は、次の設定をします。

```bash
git config --global core.quotepath false
```

### LF will be replaced by CRLF と表示される

```text
warning: in the working copy of 'todo.sh', LF will be replaced by CRLF the next time Git touches it
```

改行コードの違い（Linux / macOS は `LF`、Windows は `CRLF`）に関する警告です。WSL2 の中で作業していれば通常は表示されません。
Windows 側のフォルダで作業している場合は、WSL2 のホームディレクトリ（`~`）で作業し直すのがおすすめです。
シェルスクリプトの改行コードが `CRLF` になると、`$'\r': command not found` というエラーで動かなくなります。

### パスワードや API キーをコミットしてしまった

> [!CAUTION]
> 秘密情報を一度でも push してしまったら、**履歴から消すだけでは不十分** です。push した時点で、他の人や自動で収集するプログラムに読み取られている可能性があります。

1. **すぐに、そのパスワードや API キーを無効化（変更・再発行）** します。これが最優先です。
2. 秘密情報を書いたファイルを `.gitignore` に追加し、リポジトリから削除するコミットをします（`git rm --cached <ファイル>` で、手元のファイルは残したまま Git の管理から外せます）。
3. 履歴からも完全に消す必要がある場合は、チームの管理者に相談してください。

push する前に気づいた場合は、[直前のコミットを取り消したい（push 前）](#直前のコミットを取り消したいpush-前) の方法でコミットを取り消し、ファイルを `.gitignore` に追加してからコミットし直します。

## それでも解決しないときは

1. エラーメッセージをそのまま検索する（英語のメッセージで検索すると情報が多く見つかります）
2. `git help <コマンド>` でマニュアルを読む
3. 講師やチームのメンバーに質問する。このとき、次の情報を伝えると解決が早くなります
   - 何をしようとしていたか
   - 実行したコマンド
   - 表示されたメッセージ（**スクリーンショットではなく、テキストをコピーして** 貼る）
   - `git status` の結果
4. この教材の誤りだと思われる場合は、[Issue](https://github.com/kotonara-tech/github-and-cli-tutorials/issues/new/choose) で報告してください

---

[← 前の章: 開発フローの総合演習](07-github-flow.md) ｜ [目次](../README.md)
