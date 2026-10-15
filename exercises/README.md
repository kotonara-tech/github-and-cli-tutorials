# 演習一覧

各章の演習と、演習で使うスクリプトの一覧です。演習の本文と解答例は、それぞれの章にあります。

## 演習の一覧

| 章 | 演習 | 使うもの |
| --- | --- | --- |
| [第 1 章](../docs/01-cli-basics.md#演習) | 1-1 CLI 練習用ファイルを使った演習 | [samples/cli-practice](../samples/cli-practice/) |
| | 1-2 サンプルの TODO アプリを動かす | [samples/todo-cli](../samples/todo-cli/) |
| [第 2 章](../docs/02-git-basics.md#演習) | 2-1 自己紹介リポジトリを作る | `~/git-practice/my-first-repo` |
| | 2-2 2 つのファイルを別々のコミットにする | 同上 |
| | 2-3 .gitignore を使う | 同上 |
| [第 3 章](../docs/03-github-remote.md#演習) | 3-1 GitHub に push する | 同上 |
| | 3-2 2 つの clone を行き来する | 同上 |
| | 3-3 push が拒否される状況を体験する | [make-team-sandbox.sh](scripts/make-team-sandbox.sh) |
| [第 4 章](../docs/04-branch.md#演習) | 4-1 fast-forward マージ | `~/git-practice/my-first-repo` |
| | 4-2 コンフリクトを解消する | [make-conflict-sandbox.sh](scripts/make-conflict-sandbox.sh) |
| | 4-3 チーム開発でのコンフリクト | [make-team-sandbox.sh](scripts/make-team-sandbox.sh) |
| [第 5 章](../docs/05-issue.md#演習) | 5-1 バグを報告する | `~/git-practice/todo-cli-practice` |
| | 5-2 機能を提案する | 同上 |
| | 5-3 Issue を整理する | 同上 |
| [第 6 章](../docs/06-pull-request.md#演習) | 6-1 バグを修正する Pull Request を作る | 同上 |
| | 6-2 セルフレビューと指摘への対応 | 同上 |
| | 6-3 CI の失敗を体験する | 同上 |
| [第 7 章](../docs/07-github-flow.md) | 7.2 総合演習: delete コマンドを追加する | 同上 |
| | 7.3 チャレンジ課題 | 同上 |
| | 7.4 チームで練習する | 2〜4 人で共有するリポジトリ |

## 練習用環境を作るスクリプト

GitHub を使わずに、PC の中だけで「失敗」を安全に体験するためのスクリプトです。
**Git リポジトリの中では実行できない** ようにしてあるので、`cd ~` などでホームディレクトリに移動してから実行してください。

### make-conflict-sandbox.sh

コンフリクト（競合）を練習するためのリポジトリを作ります。

```bash
cd ~
bash ~/github-and-cli-tutorials/exercises/scripts/make-conflict-sandbox.sh
cd ~/conflict-sandbox
git merge feature/update-hobby     # コンフリクトが発生する
```

| ブランチ | 内容 |
| --- | --- |
| `main` | `profile.txt` の「趣味」を「読書」に変更 |
| `feature/update-hobby` | `profile.txt` の「趣味」を「料理」に変更 |

### make-team-sandbox.sh

複数人での開発（push / pull）を、1 台の PC で再現する環境を作ります。

```bash
cd ~
bash ~/github-and-cli-tutorials/exercises/scripts/make-team-sandbox.sh
```

| ディレクトリ | 内容 |
| --- | --- |
| `~/team-sandbox/remote.git/` | GitHub の代わりになるリモートリポジトリ（中身は直接触らない） |
| `~/team-sandbox/alice/` | Alice さんの作業用リポジトリ |
| `~/team-sandbox/bob/` | Bob さんの作業用リポジトリ |

`alice/` と `bob/` を `cd` で行き来しながら、2 人分の作業をします。それぞれのリポジトリには、コミットの作者として `Alice` / `Bob` が設定されています。

### 作り直すとき

どちらのスクリプトも、作成先がすでにあるとエラーになります。最初からやり直したいときは、削除してから実行し直してください。

```bash
rm -rf ~/conflict-sandbox ~/team-sandbox
```

引数でディレクトリ名を指定すると、別の場所に作ることもできます。

```bash
bash ~/github-and-cli-tutorials/exercises/scripts/make-conflict-sandbox.sh ~/conflict-sandbox-2
```
