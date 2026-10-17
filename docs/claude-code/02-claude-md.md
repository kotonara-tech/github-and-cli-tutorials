# 発展編 第 2 章: CLAUDE.md と AGENTS.md

Claude Code は、会話を始めるたびに、リポジトリについて何も知らない状態から始まります。
「テストはどう実行するのか」「どんな決まりでコードを書くのか」を毎回説明しなくて済むように、**プロジェクトの決まりをファイルに書いておきます**。そのためのファイルが `CLAUDE.md` と `AGENTS.md` です。

> [!NOTE]
> この章の内容は 2026 年 10 月時点のものです。最新の情報は [公式ドキュメント: メモリ（CLAUDE.md）](https://code.claude.com/docs/ja/memory) を確認してください。

## この章のゴール

- [ ] `CLAUDE.md` と `AGENTS.md` の役割と、読み込まれる場所を説明できる
- [ ] `/init` で `CLAUDE.md` のひな形を作り、必要な内容だけに整えられる
- [ ] `AGENTS.md` に共通の決まりを書き、`CLAUDE.md` から読み込める
- [ ] 作ったファイルを、ブランチと Pull Request でリポジトリに追加できる

**所要時間の目安:** 45〜60 分

## A2.1 CLAUDE.md とは

`CLAUDE.md` は、Claude Code が **会話を始めるときに必ず読み込む** Markdown のファイルです。
コードを読むだけでは分からないこと（テストの実行方法、チームの決まり、注意が必要な点）を書いておくと、Claude はそれに沿って作業します。

ただし、`CLAUDE.md` はあくまで「お願い」です。Claude が守らないこともあります。
**必ず実行させたいこと**（編集のたびにチェックを実行する、など）は、[第 5 章](05-harness.md) で学ぶ **フック** で自動化します。

## A2.2 読み込まれる場所

`CLAUDE.md` は、置く場所によって効く範囲が変わります。見つかったファイルはすべて読み込まれ、つなげて Claude に渡されます。

| 場所 | 効く範囲 | 用途 |
| --- | --- | --- |
| `~/.claude/CLAUDE.md` | 自分の、すべてのプロジェクト | 自分の好み（例: 「説明は日本語で」） |
| `<リポジトリ>/CLAUDE.md`（または `<リポジトリ>/.claude/CLAUDE.md`） | そのリポジトリ。**Git で管理してチームで共有する** | プロジェクトの決まり |
| `<リポジトリ>/CLAUDE.local.md` | 自分の、そのリポジトリだけ。`.gitignore` に追加してコミットしない | 自分だけのメモ |
| `<リポジトリ>/<サブディレクトリ>/CLAUDE.md` | そのディレクトリのファイルを Claude が読んだときに、追加で読み込まれる | 一部のディレクトリだけの決まり |

会社などの組織で使う場合は、組織が配布する `CLAUDE.md` が加わることもあります。
今どのファイルが読み込まれているかは、Claude Code の中で `/memory` または `/context` を実行すると確認できます。

## A2.3 AGENTS.md と組み合わせる

AI のコーディングエージェントは、Claude Code のほかにもたくさんあります。
[AGENTS.md](https://agents.md/) は、さまざまなエージェントが共通して読む「エージェント向けの README」として広く使われているファイルです。

Claude Code は、`CLAUDE.md` がないときだけ `AGENTS.md` を読み込みます（バージョン 2.1.277 以降。[公式ドキュメント: AGENTS.md](https://code.claude.com/docs/ja/memory#agents-md)）。`CLAUDE.md` があると、`AGENTS.md` は読み込まれません。両方を使うときは、次の形にするのがおすすめです。

- **`AGENTS.md`**: どのエージェントにも伝えたい、プロジェクトの決まりを書く
- **`CLAUDE.md`**: 1 行目に `@AGENTS.md` と書いて AGENTS.md を取り込み、その下に Claude Code だけの補足を書く

```markdown
@AGENTS.md

## Claude Code 向けの補足

- TDD は skill で進める: `/tdd-todo <Issue 番号>` でテストリストを作り、`/tdd-go` で 1 サイクルずつ進める
```

`@パス` と書くと、そのファイルの内容が取り込まれます。パスは、書いたファイルからの相対パスです。
こうしておくと、決まりを変えるときは `AGENTS.md` だけを直せばよく、ほかのエージェントを使う人とも同じ決まりを共有できます。

## A2.4 /init でひな形を作る

`CLAUDE.md` は自分で一から書くこともできますが、Claude Code の `/init` を使うと、Claude がリポジトリを調べてひな形を作ってくれます。

```text
/init
```

作られた `CLAUDE.md` は、**そのまま使わずに必ず読み直して** 、必要なものだけを残します。
`/init` は、コードを読めば分かること（ファイルの一覧や関数の説明）も書いてしまうことがあるためです。

## A2.5 何を書き、何を書かないか

`CLAUDE.md` は毎回の会話で読み込まれるので、長すぎると大事な指示が埋もれてしまいます。公式のベストプラクティスでは、次のように整理しています（[公式ドキュメント: ベストプラクティス](https://code.claude.com/docs/ja/best-practices)）。

| ✅ 書くもの | ❌ 書かないもの |
| --- | --- |
| Claude が推測できないコマンド（テストやチェックの実行方法） | コードを読めば分かること |
| 一般的なやり方と違う、プロジェクト独自のコードの書き方 | その言語の、一般的な書き方の決まり |
| テストの書き方と、使うテストの道具 | 詳しい API の説明（リンクを書く） |
| リポジトリの作法（ブランチの名前、Pull Request の決まり） | 頻繁に変わる情報 |
| プロジェクト固有の設計上の判断 | 長い説明やチュートリアル |
| 開発環境のくせ（必要な環境変数など） | ファイルごとの説明 |
| 気づきにくい落とし穴 | 「きれいなコードを書く」のような当たり前のこと |

書くときの目安です。

- **200 行より短く** します。1 行ごとに「**この行を消したら、Claude は間違えるか？**」と考え、間違えないなら消します。
- 「ちゃんとテストする」ではなく「コミットの前に `bash tests/test_todo.sh` を実行する」のように、**確かめられる具体的な指示** にします。
- 何度言っても守られない 1 行にだけ、`IMPORTANT` などで強調を付けます。あちこちに付けると、どれも目立たなくなります。

この教材の練習用リポジトリでは、例えば次のことが「Claude が推測できない、間違えやすいこと」です。

- テストは `bash tests/test_todo.sh` で実行し、最後の行の `結果: N 件成功, 0 件失敗` で判断する
- macOS 標準の bash 3.2 でも動くように書く（新しい bash の機能を使わない）
- `sed -i` は macOS と Linux で書き方が違うので使わない
- 件数を数えるときに `grep -c` を使うと、0 件のときに終了コード 1 になり、`set -e` で止まってしまう

完成例は [samples/claude-harness/template/AGENTS.md](../../samples/claude-harness/template/AGENTS.md) にあります。

## A2.6 決まりをファイルに分ける（.claude/rules/）

決まりが増えてきたら、`.claude/rules/` ディレクトリに、テーマごとの Markdown ファイルとして分けられます。
ファイルの先頭に `paths:` を書くと、そのパターンに合うファイルを Claude が読んだときだけ読み込まれます。

```markdown
---
paths:
  - "tests/**"
---

# テストの書き方

- テストは「準備 → 実行 → 結果の確認」の順に書く
- 既存の `run_todo` / `assert_equal` / `assert_contains` を使う
```

練習用リポジトリは小さいので、この章では使いません。プロジェクトが大きくなったときのために、覚えておいてください。

## A2.7 Claude が自分で書くメモ（自動メモリ）

Claude Code は、作業中に気づいたこと（あなたの好みや、プロジェクトのくせ）を、自分用のメモに書き残すことがあります。これを **自動メモリ** と呼びます。
自動メモリは、あなたのパソコンの中（`~/.claude/projects/` の下）に保存され、Git では共有されません。内容の確認や、機能のオン・オフは `/memory` で行えます。

| | CLAUDE.md / AGENTS.md | 自動メモリ |
| --- | --- | --- |
| 書く人 | あなた（チーム） | Claude |
| 保存場所 | リポジトリ（Git で共有する） | 自分のパソコン |
| 向いている内容 | チームで守る決まり | 自分との作業で分かった、ちょっとしたこと |

## 演習

### 演習 A2-1: /init でひな形を作る

1. 練習用リポジトリで、作業用のブランチを作ります。

   ```bash
   cd ~/git-practice/todo-cli-practice
   git switch main
   git pull
   git switch -c chore/claude-md
   ```

2. `claude` を起動して `/init` を実行し、ファイルの作成を許可します。
3. 作られた `CLAUDE.md` を VS Code で開き、A2.5 の表に照らして、書かなくてよい行に印を付けてみましょう。

### 演習 A2-2: AGENTS.md に分ける

演習 A2-1 の `CLAUDE.md` を、次の形に整えます。

- `AGENTS.md`: プロジェクトの概要、テストとチェックのコマンド、コードの決まり、Git の決まり
- `CLAUDE.md`: 1 行目に `@AGENTS.md`。Claude Code だけの補足があれば、その下に書く（今はなくても構いません）

自分で書いたら、完成例と見比べます。

```bash
code --diff ~/github-and-cli-tutorials/samples/claude-harness/template/AGENTS.md AGENTS.md
```

完成例には、[第 4 章](04-skills-and-agents.md) 以降で使う「TDD の進め方」と「テストリスト（TODO.md）」の節もあります。今のうちに取り込んでも、後の章で追加しても構いません。

あわせて、自分だけのファイルがコミットされないように、`.gitignore` に次の行があるか確認し、なければ最後に追加します。

```text
# Claude Code の、自分だけの設定とメモ
.claude/settings.local.json
CLAUDE.local.md
```

<details>
<summary>解答例</summary>

[samples/claude-harness/template/AGENTS.md](../../samples/claude-harness/template/AGENTS.md) と [CLAUDE.md](../../samples/claude-harness/template/CLAUDE.md) を参照してください。
大事なのは「Claude が推測できないことだけを、確かめられる形で書く」ことです。内容が完成例と同じである必要はありません。

</details>

### 演習 A2-3: 効いているか確かめてマージする

1. Claude Code で `/clear` を実行して会話をリセットし、次のように聞きます。

   ```text
   このリポジトリでテストを実行するには、どうすればよいですか？
   ```

   `AGENTS.md` に書いたコマンドで答えれば、正しく読み込まれています。`/context` を実行して、読み込まれているファイルを確認することもできます。

2. 本編の [第 6 章](../06-pull-request.md) と同じ流れで、コミット → push → Pull Request → マージまで進めます。

<details>
<summary>解答例</summary>

```bash
git add AGENTS.md CLAUDE.md .gitignore
git commit -m "docs: AI エージェント向けの AGENTS.md と CLAUDE.md を追加"
git push -u origin chore/claude-md
gh pr create --title "AI エージェント向けの AGENTS.md と CLAUDE.md を追加" --body "Claude Code などの AI エージェントに、テストの実行方法とコードの決まりを伝えるファイルを追加します。"
```

VS Code の **ソース管理** ビューでコミットし、GitHub Pull Requests 拡張機能で Pull Request を作っても構いません。
CI が成功したらマージし、`main` に戻って `git pull` しておきます。

</details>

## まとめ

- `CLAUDE.md` は、会話の始めに必ず読み込まれる「プロジェクトの決まり」のファイル
- `AGENTS.md` に共通の決まりを書き、`CLAUDE.md` の 1 行目の `@AGENTS.md` で取り込む
- `/init` で作ったひな形は、Claude が推測できないことだけに絞る（200 行より短く、具体的に）
- 必ず守らせたいことは、`CLAUDE.md` ではなくフックで自動化する

---

[← 前の章: Claude Code のセットアップ](01-setup.md) ｜ [目次](../../README.md) ｜ [次の章: モデルと effort の選び方 →](03-models-and-effort.md)
