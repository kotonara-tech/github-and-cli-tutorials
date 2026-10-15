# todo-cli

ターミナルで使うシンプルな TODO 管理ツールです。
[GitHub と CLI のチュートリアル](https://github.com/kotonara-tech/github-and-cli-tutorials) で、Issue・ブランチ・Pull Request を使った開発の流れを練習するためのサンプルです。

## 使い方

```bash
./todo.sh add "牛乳を買う"     # タスクを追加する
./todo.sh add "部屋を掃除する"
./todo.sh list                # タスクを一覧表示する
./todo.sh done 1              # 1 番のタスクを完了にする
./todo.sh help                # ヘルプを表示する
```

出力例:

```text
$ ./todo.sh list
  1 [x] 牛乳を買う
  2 [ ] 部屋を掃除する
```

タスクはカレントディレクトリの `todo.txt` に保存されます。
保存先を変えたいときは、環境変数 `TODO_FILE` を指定します。

```bash
TODO_FILE=~/my-todo.txt ./todo.sh list
```

## テストの実行

```bash
bash tests/test_todo.sh
```

すべて成功すると、最後に `結果: 26 件成功, 0 件失敗` のように表示されます。
機能を追加・修正したら、`tests/test_todo.sh` にテストも追加しましょう。

## ファイル構成

```text
todo-cli/
├── .github/
│   ├── ISSUE_TEMPLATE/          # Issue のテンプレート（バグ報告・機能リクエスト）
│   ├── pull_request_template.md # Pull Request のテンプレート
│   └── workflows/test.yml       # Pull Request ごとにテストを自動実行する設定
├── .gitignore
├── README.md
├── tests/
│   └── test_todo.sh             # テスト
└── todo.sh                      # 本体
```

> [!NOTE]
> `.github/` の中のファイルは、このディレクトリを **リポジトリのルート** に置いたときに GitHub が読み込みます。
> チュートリアルでは、このディレクトリを丸ごとコピーして自分の練習用リポジトリを作ります（[第 5 章](https://github.com/kotonara-tech/github-and-cli-tutorials/blob/main/docs/05-issue.md) 参照）。

## 練習用の課題

このサンプルには、Issue → ブランチ → Pull Request の流れで取り組める課題を用意しています。

| 種類 | 課題 | 難易度 |
| --- | --- | --- |
| バグ | `./todo.sh add ""` のように空の内容を渡すと、空のタスクが追加されてしまう | ★☆☆ |
| 機能 | タスクを削除する `delete <番号>` コマンドを追加する | ★★☆ |
| 機能 | 完了を取り消す `undone <番号>` コマンドを追加する | ★★☆ |
| 機能 | 未完了と完了の件数を表示する `count` コマンドを追加する | ★★☆ |
| 機能 | 完了したタスクをまとめて削除する `clear` コマンドを追加する | ★★☆ |
| 機能 | キーワードでタスクを絞り込む `search <キーワード>` コマンドを追加する | ★★★ |

> [!TIP]
> 空のタスクが追加されてしまう不具合は、Issue を書く練習のために **あえて残してあります**。
> [第 5 章](https://github.com/kotonara-tech/github-and-cli-tutorials/blob/main/docs/05-issue.md) と [第 6 章](https://github.com/kotonara-tech/github-and-cli-tutorials/blob/main/docs/06-pull-request.md) で、この不具合を Issue に報告して修正します。
