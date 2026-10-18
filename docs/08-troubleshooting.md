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
- [VS Code](#vs-code)
  - [`code` コマンドが見つからない](#code-コマンドが見つからない)
  - [`git commit` で VS Code が開いたのに、すぐにコミットが中止される](#git-commit-で-vs-code-が開いたのにすぐにコミットが中止される)
  - [ターミナルが PowerShell や cmd になる（WSL2 に接続されていない）](#ターミナルが-powershell-や-cmd-になるwsl2-に接続されていない)
  - [ソース管理ビューに何も表示されない](#ソース管理ビューに何も表示されない)
  - [改行コードが CRLF になる](#改行コードが-crlf-になる)
  - [スマート コミットで「常時」を選んでしまった](#スマート-コミットで常時を選んでしまった)
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

VS Code にメッセージ（`Revert "..."`）のタブが開くので、内容を確認して保存し、タブを閉じます（<kbd>Ctrl</kbd> + <kbd>W</kbd>、macOS は <kbd>Command</kbd> + <kbd>W</kbd>）。タブを閉じると、打ち消すコミットが作られます。

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

2 つのブランチで同じ場所が変更されていて、Git が自動でまとめられなかった状態です。どちらの内容を残すかを決めて解消します。詳しくは [第 4 章](04-branch.md#45-コンフリクト競合を解消する) を参照してください。

#### VS Code で操作する

1. **ソース管理** ビューの **変更のマージ**（Merge Changes）に表示されたファイルをクリックして開きます。
2. コンフリクトしている部分の上に表示される **現在の変更を取り込む**（Accept Current Change）・**入力側の変更を取り込む**（Accept Incoming Change）・**両方の変更を取り込む**（Accept Both Changes）のどれかをクリックするか、直接書き換えます。
   **マージ エディターで解決**（Resolve in Merge Editor）をクリックすると、3 つの画面に分かれたマージ エディターで解消することもできます（最後に **マージの完了**（Complete Merge）をクリックします）。
3. 保存したら、ファイルの **変更をステージ**（**+**）をクリックします。
4. メッセージ欄を確認して **コミット** をクリックします。

#### コマンドで操作する

1. `git status` で `both modified` のファイルを確認する
2. ファイルを開き、`<<<<<<<`・`=======`・`>>>>>>>` の部分を正しい内容に書き換える（マーカーの行は消す）
3. `git add <ファイル>`
4. `git commit`（VS Code にメッセージのタブが開くので、確認して保存し、タブを閉じる）

マージをやめたいときは `git merge --abort`（VS Code ではコマンド パレットの「**Git: マージの中止**」（Git: Abort Merge））で元に戻せます。

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

## VS Code

VS Code を使っていて困ったときの対処方法です。VS Code の画面の名前は、[第 0 章の 0.8](00-setup.md#08-vs-code-の画面と用語) を参照してください。

### `code` コマンドが見つからない

```text
bash: code: command not found
```

macOS の zsh でも、表示は少し違いますが `command not found` と表示されます。

ターミナルが `code` コマンドの場所を知らない状態です。OS ごとに、次の点を確認します（[第 0 章の手順](00-setup.md#ターミナルから-code-コマンドで開けるようにする)・[公式ドキュメント: Command Line Interface](https://code.visualstudio.com/docs/configure/command-line)）。

- **macOS**: VS Code を起動し、コマンド パレット（<kbd>Command</kbd> + <kbd>Shift</kbd> + <kbd>P</kbd>）で `shell command` と入力して、「**シェル コマンド: PATH 内に 'code' コマンドをインストールします**」（Shell Command: Install 'code' command in PATH）を実行します。
- **Windows（WSL2）**: VS Code を Windows 側にインストールし、インストールの途中で **PATH への追加**（Add to PATH）にチェックを入れたか確認します。入れていなかった場合は、インストールし直します。あわせて、VS Code に **WSL** 拡張機能（`ms-vscode-remote.remote-wsl`）が入っていることを確認します。
- **Linux**: VS Code のインストールが終わっているか確認します。

どの OS でも、設定した後は **ターミナルを一度閉じて開き直す** 必要があります（ターミナルは、開いたときに `PATH` を読み込むためです）。開き直したら、確認します。

```bash
which code
code --version
```

`code` コマンドが使えるようになるまでは、VS Code のメニューの **ファイル**（File）> **フォルダーを開く...**（Open Folder...）でフォルダを開けます。

### `git commit` で VS Code が開いたのに、すぐにコミットが中止される

VS Code にコミットメッセージのタブ（`COMMIT_EDITMSG`）が開くのに、ターミナルにはすぐに次のように表示されて、コミットが作られない場合です。

```text
Aborting commit due to empty commit message.
```

Git のエディタの設定に `--wait` が付いていないことが原因です。`--wait` がないと、`code` コマンドは VS Code にファイルを渡してすぐに終わってしまうため、Git は「メッセージが空のまま、エディタが閉じられた」と判断して、コミットを中止します。
設定を確認します。

```bash
git config --global core.editor
```

次のように `--wait` がなければ、これが原因です。

```text
code
```

`--wait` を付けて設定し直します。

```bash
git config --global core.editor "code --wait"
```

設定し直したら、開いたままの `COMMIT_EDITMSG` のタブは閉じ、もう一度 `git commit` を実行します。
今度は、ターミナルに `hint: Waiting for your editor to close the file...` と表示されて待つようになります。メッセージを書いて保存し、タブを閉じる（<kbd>Ctrl</kbd> + <kbd>W</kbd>、macOS は <kbd>Command</kbd> + <kbd>W</kbd>）と、コミットが作られます。`#` で始まる行は、メッセージに含まれません。

`gh` コマンドのエディタも同じです。`gh config get editor` で確認し、`code --wait` になっていなければ設定し直します。

```bash
gh config set editor "code --wait"
```

VS Code の **ソース管理** ビューのメッセージ欄からコミットする場合は、この設定に関係なくコミットできます。

### ターミナルが PowerShell や cmd になる（WSL2 に接続されていない）

Windows で、統合ターミナルの名前が `powershell` や `cmd` になり、`git` や `bash` のコマンドが思ったとおりに動かない場合です。
VS Code が WSL2 に接続されず、Windows 側のフォルダとして開いています。

1. VS Code の左下を見て、「**WSL: Ubuntu**」と表示されていなければ、WSL2 に接続されていません。
2. コマンド パレット（<kbd>Ctrl</kbd> + <kbd>Shift</kbd> + <kbd>P</kbd>）で「**WSL: Connect to WSL**」を実行します。
3. 新しいウィンドウが開いたら、**ファイル**（File）> **フォルダーを開く...**（Open Folder...）で、WSL2 の中のフォルダ（`/home/<あなたのユーザー名>/...`）を開きます。

Ubuntu のターミナルで、開きたいフォルダを `code` で開いても構いません。この方法なら、最初から WSL2 に接続された状態で開きます。

```bash
code ~/git-practice/todo-cli-practice
```

左下に「**WSL: Ubuntu**」と表示され、ターミナルの名前が `bash` になれば解決です（[第 0 章: 統合ターミナルを開く](00-setup.md#統合ターミナルを開く)・[公式ドキュメント: WSL](https://code.visualstudio.com/docs/remote/wsl)）。

### ソース管理ビューに何も表示されない

**ソース管理**（Source Control）ビューに、変更したファイルやコミットのメッセージ欄が表示されない場合は、次の 3 つのどれかが原因です。ビューに表示されているメッセージで見分けられます（[公式ドキュメント: Source Control](https://code.visualstudio.com/docs/sourcecontrol/overview)）。

#### フォルダを信頼していない（制限モード）

ソース管理ビューに「制限モードで動作する登録済みのソース管理プロバイダーはありません。」と表示される場合は、フォルダが **制限モード**（Restricted Mode）で開いています。
画面上部の表示の **管理**（Manage）> **信頼する**（Trust）で信頼すると、表示されるようになります（[第 0 章: フォルダを信頼する](00-setup.md#フォルダを信頼する制限モードを解除する)）。

#### リポジトリとは違うフォルダを開いている

VS Code では、**リポジトリのいちばん上のフォルダ**（`.git` があるフォルダ）を開きます。

- **リポジトリの中のフォルダを開いた場合**（例: `todo-cli-practice/tests`）: 「Git リポジトリがワークスペースの親フォルダーまたは開いているファイルで見つかりました。」と表示されます。**リポジトリを開く**（Open Repository）をクリックしても使えますが、`code ~/git-practice/todo-cli-practice` のように、リポジトリのいちばん上のフォルダを開き直すのが確実です。親フォルダーのリポジトリを開くかどうかは、設定の `git.openRepositoryInParentFolders` で変えられます。
- **リポジトリより上のフォルダを開いた場合**（例: `~/git-practice` やホームディレクトリ）: VS Code は、開いたフォルダのすぐ下のフォルダまでしかリポジトリを探しません。そのため、目的のリポジトリが表示されなかったり、関係のない別のリポジトリが一緒に表示されたりします。リポジトリのいちばん上のフォルダを開き直します。

#### フォルダが Git のリポジトリになっていない

「現在開いているフォルダーには Git リポジトリがありません。」と表示され、**リポジトリを初期化する**（Initialize Repository）のボタンがある場合は、開いているフォルダが Git のリポジトリではありません（`git init` をしていないか、上のように違うフォルダを開いています）。

> [!WARNING]
> ホームディレクトリなど、リポジトリにするつもりのないフォルダで **リポジトリを初期化する** をクリックしないでください。そのフォルダの中のすべてのファイルが、Git の変更として表示されるようになってしまいます。

どのフォルダがリポジトリなのかは、統合ターミナルで次のコマンドを実行すると確認できます。

```bash
git rev-parse --show-toplevel
```

リポジトリの中にいれば、そのリポジトリのいちばん上のフォルダが表示されます。開くのは、このフォルダです。

```text
/home/hanako/git-practice/todo-cli-practice
```

リポジトリの外にいる場合は、次のように表示されます。

```text
fatal: not a git repository (or any of the parent directories): .git
```

### 改行コードが CRLF になる

ステータス バーの右側に `CRLF` と表示されている場合、そのファイルの改行コードは Windows 形式の `CRLF` です。
シェルスクリプトが `CRLF` になると、次のようなエラーで動かなくなります（Linux / WSL2 の場合）。

```text
$ ./todo.sh list
/usr/bin/env: 'bash\r': No such file or directory
/usr/bin/env: use -[v]S to pass options in shebang lines
```

`bash todo.sh` で実行したときは、`$'\r': command not found` のようなエラーになります。
改行コードは、`file` コマンドでも確認できます。`with CRLF line terminators` と表示されたら `CRLF` です（出力は Ubuntu の場合）。

```text
$ file todo.sh
todo.sh: Bourne-Again shell script, Unicode text, UTF-8 text executable, with CRLF line terminators
```

#### VS Code で操作する

1. ステータス バーの `CRLF` をクリックします。
2. 「**改行コードの選択**」（Select End of Line Sequence）が表示されるので、`LF` を選びます。
3. ファイルを保存します（<kbd>Ctrl</kbd> + <kbd>S</kbd>、macOS は <kbd>Command</kbd> + <kbd>S</kbd>）。

ステータス バーの表示が `LF` に変われば解決です。変更をコミットしておきましょう。

#### 設定ファイルで防ぐ

練習用リポジトリには、改行コードを `LF` にそろえるための次のファイルが入っています（[第 5 章](05-issue.md#おすすめの拡張機能をインストールする)）。自分で作るリポジトリにも、同じファイルを置いておくと安心です。

- `.gitattributes` の `* text=auto eol=lf`: Git がファイルを書き出すときに、改行コードを `LF` にします。
- `.editorconfig` の `end_of_line = lf`: EditorConfig 拡張機能が、保存するときに改行コードを `LF` にします。

Windows では、VS Code が WSL2 に接続されていることも確認してください（[ターミナルが PowerShell や cmd になる](#ターミナルが-powershell-や-cmd-になるwsl2-に接続されていない)）。

### スマート コミットで「常時」を選んでしまった

何もステージしていないときに **コミット** をクリックすると、「ステージされている変更がなく、コミットできません。… すべての変更をステージして、直接コミットしますか?」と確認されます。
ここで **常時** を選ぶと、それ以降は確認されなくなり、ステージしていない変更もすべて自動でコミットされるようになります（**スマート コミット**、[公式ドキュメント: Staging and committing](https://code.visualstudio.com/docs/sourcecontrol/staging-commits)）。どの変更をコミットに含めるかを自分で選べなくなるので、元に戻しておきましょう。

#### VS Code で操作する

1. 設定（<kbd>Ctrl</kbd> + <kbd>,</kbd>、macOS は <kbd>Command</kbd> + <kbd>,</kbd>）を開きます。
2. 検索欄に `git.enableSmartCommit` と入力します。
3. 「ステージされた変更がない場合はすべての変更をコミットします。」のチェックを外します。

#### 設定ファイルで操作する

コマンド パレットで「**基本設定: ユーザー設定を開く (JSON)**」（Preferences: Open User Settings (JSON)）を実行し、`"git.enableSmartCommit": true` の行を削除するか、`false` に書き換えて保存します。

```json
{
  "git.enableSmartCommit": false
}
```

確認のダイアログで **行わない** を選んだ場合は、`git.suggestSmartCommit` が `false` になり、何もステージしていないときに **コミット** をクリックしても何も起きなくなります。確認を表示したいときは、同じ方法で `git.suggestSmartCommit` にチェックを入れ直します。
意図しないファイルまでコミットしてしまった場合は、push する前なら、コマンド パレットの「**Git: 前回のコミットを元に戻す**」（Git: Undo Last Commit）で取り消せます（`git reset --soft HEAD~1` と同じです。[直前のコミットを取り消したい（push 前）](#直前のコミットを取り消したいpush-前)）。

## そのほか

### エディタ（vim）が開いて抜けられない

`git commit` や `git merge` のときに、ターミナルの中に見慣れない画面が開いて操作できなくなった場合は、vim が開いています。Git のエディタを設定していないと、vim が使われることがあります。

- 保存して閉じる（メッセージを確定する）: <kbd>Esc</kbd> → `:wq` → <kbd>Enter</kbd>
- 保存せずに閉じる: <kbd>Esc</kbd> → `:q!` → <kbd>Enter</kbd>

今後は VS Code が開くように設定しておきましょう。

```bash
git config --global core.editor "code --wait"
```

VS Code を使えない環境（サーバーに接続したときなど）では、操作が簡単な nano にしておく方法もあります。

```bash
git config --global core.editor nano
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
シェルスクリプトの改行コードが `CRLF` になると、`$'\r': command not found` というエラーで動かなくなります（[改行コードが CRLF になる](#改行コードが-crlf-になる)）。

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

[← 前の章: 開発フローの総合演習](07-github-flow.md) ｜ [目次](../README.md) ｜ [発展編: Claude Code と TDD →](claude-code/README.md)
