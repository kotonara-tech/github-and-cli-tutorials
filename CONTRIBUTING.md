# コントリビューションガイド

この教材の改善に協力していただき、ありがとうございます。
誤字の修正から新しい演習の追加まで、どんな貢献も歓迎します。

このリポジトリ自体も、教材で紹介している **GitHub Flow**（Issue → ブランチ → Pull Request → レビュー → マージ）で運用しています。
教材で学んだことを実践する場として活用してください。

## Issue で報告・提案する

まずは Issue で気軽に報告・提案してください。[New issue](https://github.com/kotonara-tech/github-and-cli-tutorials/issues/new/choose) から、目的に合ったテンプレートを選べます。

| テンプレート | 用途 |
| --- | --- |
| 教材の誤り・分かりにくい箇所 | 説明の誤り、動かないコマンド、出力例の違い、リンク切れ、誤字など |
| 質問 | 教材の内容や演習について分からないこと |
| 改善の提案 | 新しい章・演習の追加、構成の改善など |

## Pull Request で修正する

修正には、このリポジトリへの書き込み権限が必要です（このリポジトリはフォークを受け付けていません）。
権限がない場合は、Issue で修正内容を提案してください。

### 1. ブランチを作る

```bash
git switch main
git pull
git switch -c docs/fix-typo-in-chapter-3
```

ブランチ名は `種類/内容` の形にします。Issue がある場合は番号を入れます（例: `docs/12-add-ssh-section`）。

| 種類 | 用途 |
| --- | --- |
| `docs/` | 教材（`docs/`、各 `README.md`）の追加・修正 |
| `feat/` | サンプルコードや練習用スクリプトの機能追加 |
| `fix/` | サンプルコードや練習用スクリプトの不具合修正 |
| `chore/` | テンプレート、CI、設定ファイルなどの変更 |

### 2. 変更してコミットする

コミットメッセージは、[Conventional Commits](https://www.conventionalcommits.org/ja/v1.0.0/) 形式の接頭辞を付け、日本語で要約を書きます。
詳しくは [付録: コミットメッセージの書き方](docs/appendix/commit-message.md) を参照してください。

```text
docs: 第 3 章に SSH 鍵の登録手順を追加
fix: make-team-sandbox.sh が既存ディレクトリを上書きする問題を修正
chore: markdownlint の設定を更新
```

### 3. ローカルでチェックする

Pull Request では、GitHub Actions で次のチェックが自動で実行されます（[.github/workflows/ci.yml](.github/workflows/ci.yml)）。push する前に、手元でも実行しておくと安心です。

```bash
# Markdown の書式チェック（Node.js が必要）
npx --yes markdownlint-cli2@0.18.1

# シェルスクリプトのチェック（shellcheck が必要）
git ls-files -z '*.sh' | xargs -0 shellcheck

# サンプルと練習用スクリプトのテスト（test_hooks.sh には shellcheck と jq が必要）
bash samples/todo-cli/tests/test_todo.sh
bash exercises/scripts/tests/test_sandboxes.sh
bash samples/claude-harness/tests/test_hooks.sh

# JSON ファイル（Claude Code の設定など）の書式チェック
# （.vscode/ の JSON はコメントを書ける形式（JSONC）なので対象外）
git ls-files -z '*.json' ':!:.vscode/**' ':!:**/.vscode/**' |
  xargs -0 -n 1 sh -c 'python3 -m json.tool "$1" >/dev/null || { echo "JSON の書式が正しくありません: $1"; exit 1; }' sh
```

`shellcheck` と `jq` は、macOS なら `brew install shellcheck jq`、Ubuntu なら `sudo apt install shellcheck jq` でインストールできます。

### 4. Pull Request を作る

```bash
git push -u origin docs/fix-typo-in-chapter-3
gh pr create
```

本文は [Pull Request テンプレート](.github/pull_request_template.md) に沿って記入します。関連する Issue がある場合は `Closes #番号` を書いてください。
1 人以上の承認と、CI の成功を確認してからマージします。マージ方法は **Squash and merge** を使います。

## 執筆ガイドライン

### 文体・表記

- 「です・ます」調で書きます。
- **全角文字と半角英数字の間には半角スペースを入れます**（例: 「Git の基本」「第 3 章」「2 つのブランチ」）。
- 句読点は「、」「。」を使います。文中の括弧は全角（）を使います。
- 初心者が読むことを前提に、専門用語は初めて出てきたときに説明します。用語は [用語集](docs/appendix/glossary.md) にも追加してください。
- 1 つの文を短くし、1 つの段落で 1 つのことを説明します。

### コマンドと出力

- 入力するコマンドは ` ```bash ` のコードブロックに、`$` を付けずに書きます（コピーしてそのまま実行できるように）。
- 出力は ` ```text ` のコードブロックに書きます。コマンドと出力をあわせて示すときは、入力行の先頭に `$` と半角スペースを付けます。
- 置き換えが必要な部分は `<あなたのユーザー名>` のように `< >` で囲みます。
- **コマンドと出力例は、必ず実際に実行して確認します。** 出力のハッシュ値や日時は、例として自然な値で構いません。
- 削除・上書きなど、取り消せない操作には `> [!WARNING]` などの注意書きを付けます。
- macOS（zsh / BSD 系のコマンド）と Linux（bash / GNU 系のコマンド）で動作が異なるコマンドは、なるべく避けるか、違いを明記します。

### 章の構成

各章は、次の構成にそろえます。

```markdown
# 第 N 章: タイトル

（導入: この章で何を学ぶか、なぜ必要か）

## この章のゴール

- [ ] 〜できる

**所要時間の目安:** 〇〜〇 分

## N.1 見出し

（本文）

## 演習

### 演習 N-1: タイトル

（問題）

<details>
<summary>解答例</summary>

（解答）

</details>

## まとめ

- 箇条書きで要点を 3〜5 個

---

[← 前の章: タイトル](前の章.md) ｜ [目次](../README.md) ｜ [次の章: タイトル →](次の章.md)
```

### GitHub の画面の説明

- ボタンやメニューは、英語表示での名前を **太字** で書きます（例: 「**New repository**」）。
- GitHub の画面は頻繁に変わるため、スクリーンショットよりも「どのタブの、どのボタンか」を文章で説明することを優先します。

### VS Code の画面の説明

- この教材は、VS Code に日本語化の拡張機能（Japanese Language Pack）を入れていることを前提にします。
- ボタンやメニューは **日本語表示での名前を太字** で書き、初めて出てくるときは英語表示の名前を（）で添えます（例: 「**ソース管理**（Source Control）」「**変更の同期**（Sync Changes）」）。
  日本語化の拡張機能は VS Code 本体より更新が遅れることがあり、新しい機能は英語のまま表示されることがあるためです。
- GitHub Pull Requests 拡張機能のように日本語化されていない画面は、英語の名前だけを書きます。
- 日本語の名前は、VS Code の公式の翻訳（[microsoft/vscode-loc](https://github.com/microsoft/vscode-loc)）と照らし合わせて確認します。
- 用語は公式の翻訳に合わせます（例: 「コマンド パレット」「ステータス バー」）。
- VS Code の機能を説明するときは、[公式ドキュメント](https://code.visualstudio.com/docs) へのリンクを添えます。
- VS Code は毎週更新されるため、本文にバージョン番号は書きません。

### キー操作の書き方

- キーは `<kbd>` で囲み、同時に押すキーは ` + ` でつなぎます（例: <kbd>Ctrl</kbd> + <kbd>Shift</kbd> + <kbd>P</kbd>）。
- OS によって違う場合は、Windows / Linux を先に書き、macOS を（）で添えます（例: <kbd>Ctrl</kbd> + <kbd>S</kbd>（macOS は <kbd>Command</kbd> + <kbd>S</kbd>））。
- バッククォートのキーは `<kbd>&#96;</kbd>` と書きます（`` ` `` をそのまま書くと、コードの表記と解釈されて表示が崩れることがあります）。

### VS Code とコマンドの両方で説明する

Git の操作は、VS Code の画面での操作とコマンドでの操作を **同じ比重で** 説明します。
既存の節の中に、次の 2 つの小見出しを、その節の 1 つ下のレベルで並べます（見出しの番号は変えません）。

````markdown
## 2.5 コミットする（git commit）

（その操作が何をするのかの説明）

### VS Code で操作する

1. **ソース管理**（Source Control）ビューを開きます。
2. ...

### コマンドで操作する

```bash
git commit -m "..."
```
````

- 両方の手順で、同じ結果になることを確認します。画面での操作の結果は、コマンド（`git status` や `git log`）で確かめる方法も添えると理解が深まります。
- 演習の解答例も、両方の方法を示します。

### Claude Code の説明（発展編）

- Claude Code は頻繁に更新されるため、各章の冒頭に「何年何月時点の情報か」を書き、機能ごとに [公式ドキュメント](https://code.claude.com/docs/ja/overview) へのリンクを添えます。日本語版のページがあれば、日本語版にリンクします。
- コマンド名、設定の項目名、ファイルの置き場所は、公式ドキュメントで確認してから書きます。確認できないことは書きません。
- Claude の返答は実行するたびに変わるため、出力例には「例」であることを明記します。テストの結果などのコマンドの出力は、実際に実行して確認します。
- `samples/claude-harness/template/` の skill・subagent・設定を変更したら、スクラッチの練習用リポジトリにコピーして、実際の Claude Code で動くことを確認します。

### サンプルコード・スクリプト

- シェルスクリプトは、macOS 標準の bash 3.2 でも動くように書きます（連想配列、`mapfile`、`${var,,}` などは使いません）。
- `sed -i` のように macOS と Linux でオプションが異なるコマンドは避けます。
- `shellcheck` の警告が出ないようにします。
- 動作を変更したら、テストも追加・更新します。
- 学習者が読むことを前提に、処理の意図をコメントで説明します。
- `samples/todo-cli` の「練習用にあえて残してある不具合」（空の内容のタスクを追加できる）は、修正しないでください。
