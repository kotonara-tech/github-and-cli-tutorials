# 第 5 章: Issue

**Issue** は、プロジェクトで「やるべきこと」を管理するための GitHub の機能です。
バグの報告、新しい機能の提案、作業のタスク、質問など、あらゆる「話題」を 1 つずつ Issue として記録し、議論や進み具合を残していきます。

## この章のゴール

- [ ] 練習用リポジトリ `todo-cli-practice` を GitHub に作れる
- [ ] 他の人が読んで分かる Issue を書ける
- [ ] ブラウザと `gh` コマンドの両方で Issue を作成・確認・更新できる
- [ ] ラベルや担当者を設定できる
- [ ] Issue テンプレートの仕組みを説明できる

**所要時間の目安:** 45〜60 分

## 5.1 Issue とは

Issue は「課題」「問題」という意味です。GitHub の Issue には、次のような情報を記録できます。

| 項目 | 内容 |
| --- | --- |
| **番号** | `#1`、`#2` のように自動で振られる番号。他の Issue や Pull Request から `#1` と書いて参照できる |
| **タイトル・本文** | 何をするのか、なぜ必要なのか |
| **コメント** | 議論の記録 |
| **ラベル（Labels）** | `bug`（バグ）、`enhancement`（機能追加）などの分類 |
| **担当者（Assignees）** | 誰が対応するか |
| **状態** | Open（未対応）/ Closed（完了・対応しない） |

「口頭やチャットで伝えたけれど、誰が対応するのか曖昧になった」「なぜこの仕様にしたのか誰も覚えていない」といった問題を、Issue で防げます。

## 5.2 練習用リポジトリを準備する

第 5 章〜第 7 章では、サンプルの TODO アプリ [samples/todo-cli](../samples/todo-cli/) をコピーして、**あなた専用の練習用リポジトリ** を作り、その中で Issue や Pull Request を練習します。

```bash
# 1. サンプルをコピーする（隠しファイルの .github/ や .gitignore もコピーされる）
mkdir -p ~/git-practice
cp -r ~/github-and-cli-tutorials/samples/todo-cli ~/git-practice/todo-cli-practice
cd ~/git-practice/todo-cli-practice
ls -a

# 2. Git のリポジトリにして、最初のコミットをする
git init
git add .
git status
git commit -m "todo-cli の最初のバージョンを追加"

# 3. GitHub にリポジトリを作って push する
gh repo create todo-cli-practice --private --source=. --remote=origin --push

# 4. ブラウザで開く
gh browse
```

ブラウザで次の点を確認しましょう。

- **Code** タブ: ファイルと `README.md` が表示されている
- **Actions** タブ: `test` というワークフローが実行され、緑色のチェックマーク（成功）が付いている
  - `.github/workflows/test.yml` の設定により、push するたびにテストが自動で実行されます（[第 6 章](06-pull-request.md) で詳しく説明します）
- **Issues** タブ: 「**New issue**」をクリックすると、「バグ報告」「機能リクエスト」のテンプレートが選べる

> [!NOTE]
> リポジトリを `--public`（公開）で作ることもできます。公開リポジトリは誰でも見られますが、無料プランでも「ブランチの保護」機能（[第 7 章](07-github-flow.md)）が使えます。

## 5.3 良い Issue の書き方

Issue は、**未来の自分や、事情を知らない他の人が読んでも分かる** ように書きます。

| | 悪い例 | 良い例 |
| --- | --- | --- |
| タイトル | 「バグ」「動かない」 | 「空の内容でタスクを追加できてしまう」 |
| 本文 | 「add がおかしいです」 | 再現手順・期待する動作・実際の動作が書かれている |
| 粒度 | 「いろいろ直したい」 | 1 つの Issue に 1 つの話題 |

### バグ報告に書くこと

1. **発生している問題**: 何が起きているか
2. **再現手順**: 誰がやっても同じ問題が起きる手順
3. **期待する動作**: 本来どうなってほしいか
4. **実際の動作**: 実際にどうなったか（エラーメッセージはそのまま貼る）
5. **環境**: OS やツールのバージョン

### 機能の提案に書くこと

1. **やりたいこと**: どんな機能か
2. **背景・理由**: なぜ必要か
3. **完了の条件**: 何ができたら完了とするか

## 5.4 ブラウザで Issue を作る

`todo-cli` には、`./todo.sh add ""` のように空の内容を渡すと、空のタスクが追加されてしまう不具合があります。

```text
$ ./todo.sh add ""
追加しました:
$ ./todo.sh list
  1 [ ]
```

この不具合を Issue として報告してみましょう。

1. リポジトリの **Issues** タブ →「**New issue**」をクリックします。
2. 「**バグ報告**」テンプレートを選びます。
3. タイトルと本文を入力します。テンプレートの見出しに沿って書きます。`<!-- -->` で囲まれた部分は説明用のコメントで、投稿すると表示されません。

   **タイトル:** `[Bug] 空の内容でタスクを追加できてしまう`

   **本文の例:**

   ````markdown
   ## 発生している問題

   `./todo.sh add ""` のように空の内容を渡すと、内容が空のタスクが追加されてしまう。

   ## 再現手順

   1. `./todo.sh add ""` を実行する
   2. `./todo.sh list` を実行する

   ## 期待する動作

   「タスクの内容を指定してください」というエラーが表示され、タスクは追加されない。

   ## 実際の動作

   ```text
   $ ./todo.sh add ""
   追加しました:
   $ ./todo.sh list
     1 [ ]
   ```

   ## 環境

   - OS: Ubuntu 24.04
   - bash のバージョン: 5.2.21
   ````

4. 「**Preview**」タブで表示を確認します。
5. 画面右側（スマートフォンでは下部）で次の項目を設定します。
   - **Assignees**: 「assign yourself」をクリックして自分を担当者にする
   - **Labels**: テンプレートにより `bug` が設定済み
6. 「**Create**」（または「**Submit new issue**」）をクリックします。

作成された Issue には `#1` のような番号が付きます。

## 5.5 gh コマンドで Issue を作る

ターミナルから Issue を作ることもできます。`todo-cli` に「タスクを削除する機能」を追加する提案を作ってみましょう。

```bash
cd ~/git-practice/todo-cli-practice
gh issue create \
  --title "[Feature] タスクを削除する delete コマンドを追加したい" \
  --label enhancement \
  --assignee @me \
  --body-file - <<'EOF'
## やりたいこと

`./todo.sh delete 2` のように番号を指定して、タスクを削除したい。

## 背景・理由

間違えて追加したタスクや、不要になったタスクを消す方法がない。

## 完了の条件

- [ ] `./todo.sh delete <番号>` で指定したタスクが削除される
- [ ] 存在しない番号を指定するとエラーになる
- [ ] テストを追加する
- [ ] ヘルプと README.md の使い方を更新する
EOF
```

| オプション | 意味 |
| --- | --- |
| `--title` | タイトル |
| `--label` | ラベル |
| `--assignee @me` | 自分を担当者にする |
| `--body-file -` | 本文を標準入力から読み込む（ここでは `<<'EOF'` 〜 `EOF` の部分） |

行末の `\` は「コマンドが次の行に続く」という意味です。

オプションを付けずに `gh issue create` と実行すると、対話形式でタイトルやテンプレートを選びながら作成できます。
`gh issue create --web` なら、入力済みの状態でブラウザの作成画面が開きます。

## 5.6 Issue を確認・更新する

```bash
gh issue list                        # Open の Issue を一覧表示する
gh issue list --label bug            # ラベルで絞り込む
gh issue list --assignee @me         # 自分が担当の Issue だけ表示する
gh issue list --state closed         # Closed の Issue を表示する

gh issue view 1                      # #1 の内容を表示する
gh issue view 1 --web                # #1 をブラウザで開く

gh issue comment 1 --body "再現しました。修正に取りかかります。"   # コメントする
gh issue edit 2 --add-label "good first issue"                   # ラベルを追加する
gh issue edit 2 --add-assignee @me                               # 担当者を追加する
```

出力例:

```text
$ gh issue list

Showing 2 of 2 open issues in hanako/todo-cli-practice

ID  TITLE                                           LABELS       UPDATED
#2  [Feature] タスクを削除する delete コマンドを追…  enhancement  less than a minute ago
#1  [Bug] 空の内容でタスクを追加できてしまう         bug          about 5 minutes ago
```

## 5.7 Issue で使える Markdown

Issue やコメントの本文は **Markdown** という記法で書けます。

| 書き方 | 表示 |
| --- | --- |
| `## 見出し` | 見出し |
| `- 項目` | 箇条書き |
| `1. 項目` | 番号付きリスト |
| `- [ ] やること` / `- [x] 済んだこと` | チェックボックス（タスクリスト） |
| `` `コード` `` | インラインのコード |
| ` ``` ` で囲む | 複数行のコードブロック |
| `#1` | Issue / Pull Request の #1 へのリンク |
| `@ユーザー名` | ユーザーへの通知（メンション） |
| コミットハッシュ（例: `bbf2d2e`） | そのコミットへのリンク |
| `**太字**` | **太字** |
| `> 引用` | 引用 |

画像は、本文の入力欄にドラッグ & ドロップすると貼り付けられます。

## 5.8 ラベル・担当者・マイルストーン

### ラベル

新しく作ったリポジトリには、最初から次のようなラベルが用意されています。

| ラベル | 用途 |
| --- | --- |
| `bug` | 不具合 |
| `enhancement` | 新機能・改善 |
| `documentation` | ドキュメント |
| `question` | 質問 |
| `good first issue` | 初めての人に向いている |
| `help wanted` | 手伝ってほしい |
| `duplicate` / `invalid` / `wontfix` | 重複 / 無効 / 対応しない |

ラベルは自分で追加することもできます。

```bash
gh label list
gh label create "priority: high" --color D93F0B --description "優先度が高い"
```

### 担当者とマイルストーン

- **Assignees（担当者）**: 誰が対応するかを明確にします。チームでは「担当者が決まっていない Issue は誰も対応しない」ことがよくあるので、着手するときは自分を担当者にしましょう。
- **Milestones（マイルストーン）**: 「v1.1 リリース」のように、期限や目標ごとに Issue をまとめる機能です。
- **Projects**: Issue をカンバンボード（「未着手」「作業中」「完了」の列）で管理できる機能です。

## 5.9 Issue を閉じる

Issue を閉じる方法は 2 つあります。

1. **手動で閉じる**: Issue の画面下部の「**Close issue**」ボタン（`▼` から理由を選べる）、または `gh issue close` を使います。

   ```bash
   gh issue close 5 --comment "修正が完了したため閉じます"
   gh issue close 6 --reason "not planned"   # 対応しないことにした場合
   gh issue reopen 6                         # 開き直す
   ```

2. **Pull Request から自動で閉じる**: Pull Request の本文に `Closes #1` のように書いておくと、その Pull Request がマージされたときに Issue #1 が自動で閉じます（[第 6 章](06-pull-request.md)）。

## 5.10 Issue テンプレート

練習用リポジトリの「**New issue**」でテンプレートを選べたのは、`.github/ISSUE_TEMPLATE/` にテンプレートのファイルがあるからです。

```bash
cat .github/ISSUE_TEMPLATE/bug_report.md
```

```markdown
---
name: バグ報告
about: 期待どおりに動かない点を報告する
title: "[Bug] "
labels: bug
assignees: ""
---

## 発生している問題
...
```

先頭の `---` で囲まれた部分（**Front Matter**）に、テンプレートの名前・説明・タイトルの初期値・自動で付けるラベルを書きます。その下が本文の初期値になります。

> [!TIP]
> テンプレートには、Markdown 形式（`.md`）のほかに、入力欄や選択肢を持つフォーム形式（`.yml`、**Issue Forms**）もあります。
> この教材のリポジトリの [.github/ISSUE_TEMPLATE/](../.github/ISSUE_TEMPLATE/) では、フォーム形式を使っています。見比べてみましょう。

## 演習

### 演習 5-1: バグを報告する

本文の [5.4](#54-ブラウザで-issue-を作る) の手順で、空のタスクが追加されてしまう不具合をブラウザから Issue に報告してください。
実際に `./todo.sh add ""` を実行して、出力を確かめてから書きましょう（確認後、`rm todo.txt` で片付けます）。

### 演習 5-2: 機能を提案する

本文の [5.5](#55-gh-コマンドで-issue-を作る) の手順で、`delete` コマンドの追加を提案する Issue を `gh` コマンドで作成してください。

### 演習 5-3: Issue を整理する

[samples/todo-cli/README.md の「練習用の課題」](../samples/todo-cli/README.md#練習用の課題) から機能を 2 つ選び、それぞれ Issue を作成してください。その後、次の操作をしてください。

1. `gh issue list` で一覧を表示する
2. `priority: high` ラベルを作り、どれか 1 つの Issue に付ける
3. `gh issue list --label "priority: high"` で絞り込む
4. どれか 1 つの Issue に、どのように実装するかの方針をコメントする

<details>
<summary>解答例</summary>

```bash
cd ~/git-practice/todo-cli-practice

gh issue create --title "[Feature] 完了を取り消す undone コマンドを追加したい" \
  --label enhancement --assignee @me \
  --body "\`./todo.sh undone 1\` で、完了にしたタスクを未完了に戻したい。"

gh issue create --title "[Feature] タスクの件数を表示する count コマンドを追加したい" \
  --label enhancement --assignee @me \
  --body "\`./todo.sh count\` で、未完了と完了の件数を表示したい。"

gh issue list
gh label create "priority: high" --color D93F0B --description "優先度が高い"
gh issue edit 3 --add-label "priority: high"
gh issue list --label "priority: high"
gh issue comment 3 --body "done コマンドと同じように awk で [x] を [ ] に置き換える方針で実装します。"
```

`--body` の中の `` \` `` は、ダブルクォートの中でバッククォートをそのまま使うための書き方です（`\` を付けないと、シェルがコマンドとして実行しようとします）。

</details>

## まとめ

- Issue は「やるべきこと」を 1 件ずつ記録し、議論と経緯を残すための機能
- 他の人が読んで分かるように、再現手順・期待する動作・完了の条件などを書く
- ラベルで分類し、担当者を明確にする
- `gh issue create / list / view / comment / edit / close` でターミナルから操作できる
- テンプレートは `.github/ISSUE_TEMPLATE/` に置く

---

[← 前の章: ブランチ](04-branch.md) ｜ [目次](../README.md) ｜ [次の章: Pull Request →](06-pull-request.md)
