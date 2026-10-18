# 演習一覧

各章の演習と、演習で使うスクリプトの一覧です。演習の本文と解答例は、それぞれの章にあります。

## VS Code で取り組む

演習は、VS Code で行います（準備は [第 0 章](../docs/00-setup.md#07-vs-code-をインストールする) を参照してください）。

1. 演習で使うフォルダを、`code <パス>` で VS Code で開きます。

   ```bash
   code ~/git-practice/todo-cli-practice
   ```

2. 初めて開いたフォルダは制限モードで開くので、信頼します（[0.8](../docs/00-setup.md#フォルダを信頼する制限モードを解除する)）。
3. コマンドは、VS Code の統合ターミナル（メニューの **ターミナル**（Terminal）> **新しいターミナル**（New Terminal））で実行します。開いたフォルダが、最初のカレントディレクトリになります。

Git の操作は、VS Code の画面でもコマンドでもできます。各章の「VS Code で操作する」と「コマンドで操作する」を見比べながら、両方試してみましょう。

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
| [発展編 第 1 章](../docs/claude-code/01-setup.md#演習) | A1-1〜A1-3 Claude Code に質問し、変更を確認して取り消す | `~/git-practice/todo-cli-practice` |
| [発展編 第 2 章](../docs/claude-code/02-claude-md.md#演習) | A2-1〜A2-3 AGENTS.md と CLAUDE.md を作る | 同上、[samples/claude-harness](../samples/claude-harness/) |
| [発展編 第 3 章](../docs/claude-code/03-models-and-effort.md#演習) | A3-1〜A3-3 モデルと effort を切り替えて比べる | 同上 |
| [発展編 第 4 章](../docs/claude-code/04-skills-and-agents.md#演習) | A4-1〜A4-2 TDD 用の skill とテストレビュー用の subagent を作る | 同上 |
| [発展編 第 5 章](../docs/claude-code/05-harness.md#演習) | A5-1〜A5-3 権限の設定とフックを取り込み、plan モードで作業する | 同上 |
| [発展編 第 6 章](../docs/claude-code/06-tdd.md) | 追加課題: t-wada 流 TDD で stats コマンドを作る | 同上 |

## 練習用環境を作るスクリプト

GitHub を使わずに、PC の中だけで「失敗」を安全に体験するためのスクリプトです。
**Git リポジトリの中では実行できない** ようにしてあるので、`cd ~` などでホームディレクトリに移動してから実行してください。

### make-conflict-sandbox.sh

コンフリクト（競合）を練習するためのリポジトリを作ります。

```bash
cd ~
bash ~/github-and-cli-tutorials/exercises/scripts/make-conflict-sandbox.sh
code ~/conflict-sandbox            # 作ったリポジトリを VS Code で開く
```

開いた VS Code の統合ターミナルで、マージしてコンフリクトを起こします。

```bash
git merge feature/update-hobby     # コンフリクトが発生する
```

コンフリクトは、VS Code の CodeLens やマージ エディターでも、コマンドでも解消できます（[第 4 章](../docs/04-branch.md#45-コンフリクト競合を解消する)）。

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

作ったら、Alice さんと Bob さんの作業用リポジトリを、それぞれ別の VS Code のウィンドウで開きます。

```bash
code ~/team-sandbox/alice
code ~/team-sandbox/bob
```

| ディレクトリ | 内容 |
| --- | --- |
| `~/team-sandbox/remote.git/` | GitHub の代わりになるリモートリポジトリ（中身は直接触らない） |
| `~/team-sandbox/alice/` | Alice さんの作業用リポジトリ |
| `~/team-sandbox/bob/` | Bob さんの作業用リポジトリ |

Alice さんのウィンドウと Bob さんのウィンドウを行き来しながら、2 人分の作業をします（ターミナルだけで進める場合は、`alice/` と `bob/` を `cd` で行き来します）。それぞれのリポジトリには、コミットの作者として `Alice` / `Bob` が設定されています。
ウィンドウのタイトルや **エクスプローラー** の一番上に表示されるフォルダ名（`alice` / `bob`）で、今どちらの作業をしているかを確かめましょう。

### 作り直すとき

どちらのスクリプトも、作成先がすでにあるとエラーになります。最初からやり直したいときは、削除してから実行し直してください。

```bash
rm -rf ~/conflict-sandbox ~/team-sandbox
```

引数でディレクトリ名を指定すると、別の場所に作ることもできます。

```bash
bash ~/github-and-cli-tutorials/exercises/scripts/make-conflict-sandbox.sh ~/conflict-sandbox-2
```
