# 付録: Git / GitHub CLI チートシート

## 初期設定

| コマンド | 意味 |
| --- | --- |
| `git config --global user.name "名前"` | コミットに記録する名前を設定する |
| `git config --global user.email "メール"` | コミットに記録するメールアドレスを設定する |
| `git config --global init.defaultBranch main` | 最初のブランチ名を `main` にする |
| `git config --global pull.rebase false` | `git pull` でマージを使う |
| `git config --global core.quotepath false` | 日本語のファイル名をそのまま表示する |
| `git config --global core.editor nano` | 使うエディタを設定する |
| `git config --global --list` | 設定を確認する |

## リポジトリを作る・取得する

| コマンド | 意味 |
| --- | --- |
| `git init` | 今いるディレクトリをリポジトリにする |
| `git clone <URL> [ディレクトリ]` | リモートリポジトリを複製する |

## 変更を記録する

| コマンド | 意味 |
| --- | --- |
| `git status` | 状態を確認する（**迷ったらこれ**） |
| `git add <file>` | 変更をステージングする |
| `git add .` | 今いるディレクトリ以下のすべての変更をステージングする |
| `git commit -m "メッセージ"` | コミットする |
| `git commit -am "メッセージ"` | 変更済みのファイル（新規ファイルを除く）を add してコミットする |
| `git rm <file>` / `git mv <old> <new>` | 削除する / 名前を変える |

## 確認する

| コマンド | 意味 |
| --- | --- |
| `git diff` | まだステージングしていない変更を表示する |
| `git diff --staged` | ステージング済みの変更を表示する |
| `git log --oneline` | 履歴を 1 行ずつ表示する |
| `git log --oneline --graph --all` | すべてのブランチの履歴を図で表示する |
| `git log -p <file>` | ファイルの変更履歴を差分付きで表示する |
| `git show <コミット>` | コミットの内容を表示する |
| `git blame <file>` | 各行を最後に変更したコミットを表示する |

## 取り消す

| コマンド | 意味 |
| --- | --- |
| `git restore <file>` | ワーキングツリーの変更を捨てる ⚠️ |
| `git restore --staged <file>` | ステージングを取り消す |
| `git commit --amend` | 直前のコミットを修正する（push 前のみ） |
| `git reset --soft HEAD~1` | 直前のコミットを取り消す（変更は残る。push 前のみ） |
| `git revert <コミット>` | コミットを打ち消すコミットを作る（push 後でも安全） |
| `git stash push -m "メモ"` / `git stash pop` | 変更を一時的に退避する / 戻す |
| `git reflog` | HEAD の移動履歴を表示する（消したコミットの復活に使う） |

## ブランチ

| コマンド | 意味 |
| --- | --- |
| `git branch` | ブランチの一覧を表示する |
| `git branch -a` | リモートのブランチも含めて表示する |
| `git switch -c <branch>` | ブランチを作って切り替える |
| `git switch <branch>` | ブランチを切り替える |
| `git switch -` | 直前のブランチに切り替える |
| `git merge <branch>` | 今のブランチに `<branch>` をマージする |
| `git merge --abort` | マージを中止する |
| `git branch -d <branch>` | マージ済みのブランチを削除する |
| `git branch -D <branch>` | ブランチを強制的に削除する ⚠️ |

## リモート

| コマンド | 意味 |
| --- | --- |
| `git remote -v` | 登録されているリモートを表示する |
| `git remote add origin <URL>` | リモートを登録する |
| `git remote set-url origin <URL>` | リモートの URL を変更する |
| `git push -u origin <branch>` | ブランチを初めて push する |
| `git push` | push する |
| `git pull` | リモートの変更を取り込む |
| `git fetch` | リモートの変更を受け取る（取り込まない） |
| `git fetch --prune` | 削除されたリモートブランチの情報を消す |
| `git push origin --delete <branch>` | リモートのブランチを削除する |

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

| コマンド | 意味 |
| --- | --- |
| `gh issue create` | Issue を作る（対話形式） |
| `gh issue create --title "..." --body "..." --label bug --assignee @me` | Issue を作る（一度に指定） |
| `gh issue list` | Issue の一覧を表示する |
| `gh issue list --assignee @me --label bug` | 絞り込んで表示する |
| `gh issue view <番号>` | Issue を表示する（`--web` でブラウザで開く） |
| `gh issue comment <番号> --body "..."` | コメントする |
| `gh issue edit <番号> --add-label <label>` | ラベルを追加する |
| `gh issue close <番号>` / `gh issue reopen <番号>` | 閉じる / 開き直す |
| `gh issue develop <番号> --checkout` | Issue に関連付けたブランチを作って切り替える |

### Pull Request

| コマンド | 意味 |
| --- | --- |
| `gh pr create` | Pull Request を作る（対話形式） |
| `gh pr create --fill` | コミットメッセージからタイトルと本文を作る |
| `gh pr create --draft` | ドラフトとして作る |
| `gh pr list` | Pull Request の一覧を表示する |
| `gh pr view [番号]` | Pull Request を表示する（`--web` でブラウザで開く） |
| `gh pr checks [番号]` | CI の結果を表示する |
| `gh pr diff [番号]` | 差分を表示する |
| `gh pr checkout <番号>` | Pull Request のブランチを手元に取得する |
| `gh pr review <番号> --approve` | 承認する |
| `gh pr review <番号> --comment --body "..."` | コメントのみのレビューをする |
| `gh pr review <番号> --request-changes --body "..."` | 修正を求める |
| `gh pr merge <番号> --squash --delete-branch` | Squash and merge して、ブランチを削除する |

### そのほか

| コマンド | 意味 |
| --- | --- |
| `gh label list` / `gh label create <name>` | ラベルの一覧 / 作成 |
| `gh run list` / `gh run view <id> --log-failed` | GitHub Actions の実行一覧 / 失敗したログの表示 |
| `gh help` / `gh <コマンド> --help` | ヘルプを表示する |

---

[← CLI チートシート](cli-cheatsheet.md) ｜ [目次](../../README.md) ｜ [用語集 →](glossary.md)
