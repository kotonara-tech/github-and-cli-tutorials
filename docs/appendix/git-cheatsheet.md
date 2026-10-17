# 付録: Git / GitHub CLI チートシート

表の「VS Code での操作」の列は、同じことを VS Code で行う方法です（ない場合は「—」）。

- 「Git: …」は、コマンド パレット（<kbd>Ctrl</kbd> + <kbd>Shift</kbd> + <kbd>P</kbd>、macOS は <kbd>Command</kbd> + <kbd>Shift</kbd> + <kbd>P</kbd>）で実行するコマンドです。
- 「…」は、**ソース管理**（Source Control）ビューの上部にある **その他の操作...**（More Actions...）のメニューです。
- 画面の名前は、[第 0 章の 0.8](../00-setup.md#08-vs-code-の画面と用語) を参照してください。

## 初期設定

| コマンド | 意味 |
| --- | --- |
| `git config --global user.name "名前"` | コミットに記録する名前を設定する |
| `git config --global user.email "メール"` | コミットに記録するメールアドレスを設定する |
| `git config --global init.defaultBranch main` | 最初のブランチ名を `main` にする |
| `git config --global pull.rebase false` | `git pull` でマージを使う |
| `git config --global core.quotepath false` | 日本語のファイル名をそのまま表示する |
| `git config --global core.editor "code --wait"` | コミットメッセージなどを書くエディタを VS Code にする |
| `gh config set editor "code --wait"` | `gh` が本文などを書くときに使うエディタを VS Code にする |
| `git config --global --list` | 設定を確認する |

## リポジトリを作る・取得する

| コマンド | 意味 | VS Code での操作 |
| --- | --- | --- |
| `git init` | 今いるディレクトリをリポジトリにする | ソース管理ビューの **リポジトリを初期化する**（Initialize Repository） |
| `git clone <URL> [ディレクトリ]` | リモートリポジトリを複製する | 「**Git: クローン**」（Git: Clone） |

## 変更を記録する

| コマンド | 意味 | VS Code での操作 |
| --- | --- | --- |
| `git status` | 状態を確認する（**迷ったらこれ**） | **ソース管理**（Source Control）ビューを開く（<kbd>Ctrl</kbd> + <kbd>Shift</kbd> + <kbd>G</kbd>、macOS は <kbd>Control</kbd> + <kbd>Shift</kbd> + <kbd>G</kbd>） |
| `git add <file>` | 変更をステージングする | ファイルの **変更をステージ**（Stage Changes、**+**） |
| `git add .` | 今いるディレクトリ以下のすべての変更をステージングする | **変更**（Changes）の **すべての変更をステージ**（Stage All Changes） |
| `git commit -m "メッセージ"` | コミットする | メッセージ欄に入力して **コミット**（Commit） |
| `git commit -am "メッセージ"` | 変更済みのファイル（新規ファイルを除く）を add してコミットする | — |
| `git rm <file>` / `git mv <old> <new>` | 削除する / 名前を変える | エクスプローラーの **削除**（Delete）/ **名前の変更...**（Rename...）のあと、ソース管理ビューで変更をステージする（エクスプローラーの操作だけではステージされない） |

## 確認する

| コマンド | 意味 | VS Code での操作 |
| --- | --- | --- |
| `git diff` | まだステージングしていない変更を表示する | **変更**（Changes）のファイルをクリック（差分エディターが開く） |
| `git diff --staged` | ステージング済みの変更を表示する | **ステージされている変更**（Staged Changes）のファイルをクリック |
| `git log --oneline` | 履歴を 1 行ずつ表示する | ソース管理ビューの **グラフ**（Graph） |
| `git log --oneline --graph --all` | すべてのブランチの履歴を図で表示する | **グラフ** で表示するブランチを **すべて**（All）にする |
| `git log -p <file>` | ファイルの変更履歴を差分付きで表示する | エクスプローラーの **タイムライン**（Timeline） |
| `git show <コミット>` | コミットの内容を表示する | **グラフ** でコミットをクリック |
| `git blame <file>` | 各行を最後に変更したコミットを表示する | — |

## 取り消す

| コマンド | 意味 | VS Code での操作 |
| --- | --- | --- |
| `git restore <file>` | ワーキングツリーの変更を捨てる ⚠️ | ファイルの **変更を破棄**（Discard Changes）⚠️ |
| `git restore --staged <file>` | ステージングを取り消す | ファイルの **変更のステージング解除**（Unstage Changes、**−**） |
| `git commit --amend` | 直前のコミットを修正する（push 前のみ） | **コミット** の横の `∨` > **コミット (修正)**（Commit (Amend)） |
| `git reset --soft HEAD~1` | 直前のコミットを取り消す（変更は残る。push 前のみ） | 「**Git: 前回のコミットを元に戻す**」（Git: Undo Last Commit） |
| `git revert <コミット>` | コミットを打ち消すコミットを作る（push 後でも安全） | — |
| `git stash push -m "メモ"` / `git stash pop` | 変更を一時的に退避する / 戻す | 「**Git: スタッシュ**」（Git: Stash）/「**Git: 最新のスタッシュをポップ**」（Git: Pop Latest Stash） |
| `git reflog` | HEAD の移動履歴を表示する（消したコミットの復活に使う） | — |

## ブランチ

| コマンド | 意味 | VS Code での操作 |
| --- | --- | --- |
| `git branch` | ブランチの一覧を表示する | ステータス バーのブランチ名をクリック |
| `git branch -a` | リモートのブランチも含めて表示する | 同上（リモートのブランチも表示される） |
| `git switch -c <branch>` | ブランチを作って切り替える | ブランチ名 >「**+ 新しいブランチの作成...**」（Create new branch...） |
| `git switch <branch>` | ブランチを切り替える | ブランチ名 > 切り替え先のブランチを選ぶ |
| `git switch -` | 直前のブランチに切り替える | — |
| `git merge <branch>` | 今のブランチに `<branch>` をマージする | 「**Git: マージ...**」（Git: Merge...） |
| `git merge --abort` | マージを中止する | 「**Git: マージの中止**」（Git: Abort Merge） |
| `git branch -d <branch>` | マージ済みのブランチを削除する | 「**Git: ブランチの削除...**」（Git: Delete Branch...） |
| `git branch -D <branch>` | ブランチを強制的に削除する ⚠️ | 「**Git: ブランチの削除...**」で、確認に **ブランチの削除**（Delete Branch）と答える ⚠️ |

## リモート

| コマンド | 意味 | VS Code での操作 |
| --- | --- | --- |
| `git remote -v` | 登録されているリモートを表示する | — |
| `git remote add origin <URL>` | リモートを登録する | 「**Git: リモートの追加...**」（Git: Add Remote...） |
| `git remote set-url origin <URL>` | リモートの URL を変更する | — |
| `git push -u origin <branch>` | ブランチを初めて push する | **Branch の発行**（Publish Branch） |
| `git push` | push する | **変更の同期**（Sync Changes）、または「…」> **プッシュ**（Push） |
| `git pull` | リモートの変更を取り込む | **変更の同期**、または「…」> **プル**（Pull） |
| `git fetch` | リモートの変更を受け取る（取り込まない） | 「…」> **フェッチ**（Fetch） |
| `git fetch --prune` | 削除されたリモートブランチの情報を消す | 「**Git: フェッチ (Prune)**」（Git: Fetch (Prune)） |
| `git push origin --delete <branch>` | リモートのブランチを削除する | 「**Git: リモート ブランチの削除...**」（Git: Delete Remote Branch...） |

**変更の同期** は、プルしてからプッシュします（`git pull` と `git push` を続けて実行するのと同じです）。

## GitHub CLI（gh）

### 認証・リポジトリ

| コマンド | 意味 |
| --- | --- |
| `gh auth login` / `gh auth status` | ログインする / 状態を確認する |
| `gh auth setup-git` | Git が gh の認証情報を使うように設定する |
| `gh repo create <name> --private --source=. --remote=origin --push` | 手元のリポジトリから GitHub にリポジトリを作って push する |
| `gh repo clone <owner>/<repo>` | リポジトリを clone する |
| `gh repo view --web` / `gh browse` | リポジトリをブラウザで開く |

### Issue

「VS Code での操作」の列は、GitHub Pull Requests 拡張機能の **GitHub** ビューでの操作です（[第 5 章の 5.6](../05-issue.md#56-issue-を確認更新する)）。

| コマンド | 意味 | VS Code での操作 |
| --- | --- | --- |
| `gh issue create` | Issue を作る（対話形式） | **Issues** の **+**（**Create an Issue**） |
| `gh issue create --title "..." --body "..." --label bug --assignee @me` | Issue を作る（一度に指定） | — |
| `gh issue list` | Issue の一覧を表示する | **Issues** のセクション |
| `gh issue list --assignee @me --label bug` | 絞り込んで表示する | **Issues** の **My Issues**（自分が担当の Issue だけを表示する） |
| `gh issue view <番号>` | Issue を表示する（`--web` でブラウザで開く） | **Issues** で Issue をクリック |
| `gh issue comment <番号> --body "..."` | コメントする | Issue のタブの下部で **Comment** |
| `gh issue edit <番号> --add-label <label>` | ラベルを追加する | Issue のタブの **Labels** |
| `gh issue close <番号>` / `gh issue reopen <番号>` | 閉じる / 開き直す | Issue のタブの **Close Issue** / — |
| `gh issue develop <番号> --checkout` | Issue に関連付けたブランチを作って切り替える | **Start Working on Issue**（ブランチ名の決まり方は [第 7 章](../07-github-flow.md#ステップ-2-最新の-main-からブランチを作る) を参照） |

### Pull Request

「VS Code での操作」の列は、GitHub Pull Requests 拡張機能での操作です（[第 6 章](../06-pull-request.md)）。

| コマンド | 意味 | VS Code での操作 |
| --- | --- | --- |
| `gh pr create` | Pull Request を作る（対話形式） | **Pull Requests** の **Create Pull Request** |
| `gh pr create --fill` | コミットメッセージからタイトルと本文を作る | — |
| `gh pr create --draft` | ドラフトとして作る | **Create** の `∨` > **Create Draft** |
| `gh pr list` | Pull Request の一覧を表示する | **Pull Requests** のセクション |
| `gh pr view [番号]` | Pull Request を表示する（`--web` でブラウザで開く） | **Pull Requests** で Pull Request をクリック（**Description** のページ） |
| `gh pr checks [番号]` | CI の結果を表示する | **Description** のページの下部 |
| `gh pr diff [番号]` | 差分を表示する | **Pull Requests** で Pull Request を開き、ファイルをクリック |
| `gh pr checkout <番号>` | Pull Request のブランチを手元に取得する | **Description** のページの **Checkout** |
| `gh pr review <番号> --approve` | 承認する | **Description** のページで **Approve** |
| `gh pr review <番号> --comment --body "..."` | コメントのみのレビューをする | **Description** のページで **Comment** |
| `gh pr review <番号> --request-changes --body "..."` | 修正を求める | **Description** のページで **Request Changes** |
| `gh pr merge <番号> --squash --delete-branch` | Squash and merge して、ブランチを削除する | **Merge Pull Request**（**Squash and Merge**）→ **Delete Branch...** |

### そのほか

| コマンド | 意味 |
| --- | --- |
| `gh label list` / `gh label create <name>` | ラベルの一覧 / 作成 |
| `gh run list` / `gh run view <id> --log-failed` | GitHub Actions の実行一覧 / 失敗したログの表示 |
| `gh help` / `gh <コマンド> --help` | ヘルプを表示する |

---

[← CLI チートシート](cli-cheatsheet.md) ｜ [目次](../../README.md) ｜ [用語集 →](glossary.md)
