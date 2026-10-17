# 発展編 第 4 章: skill と subagent

同じ手順を何度も頼むときは、毎回長い指示を書く代わりに、手順を **skill** として保存しておけます。
また、レビューのように「作業した本人とは別の目」で見てほしいことは、**subagent**（サブエージェント）に任せられます。
この章では、[第 6 章](06-tdd.md) の追加課題で使う、TDD 用の skill とテストレビュー用の subagent を作ります。

> [!NOTE]
> この章の内容は 2026 年 10 月時点のものです。最新の情報は [公式ドキュメント: skill](https://code.claude.com/docs/ja/skills) と [サブエージェント](https://code.claude.com/docs/ja/sub-agents) を確認してください。

## この章のゴール

- [ ] skill と subagent の違いと、使い分けを説明できる
- [ ] `SKILL.md` を書いて、`/名前` で呼び出せる skill を作れる
- [ ] 使えるツールを絞った subagent を作り、作業を任せられる

**所要時間の目安:** 60〜90 分

## A4.1 skill とは

**skill** は、Claude に教える「手順書」です。`.claude/skills/<skill の名前>/SKILL.md` というファイルに書きます。

- skill の **説明文**（`description`）は、いつも Claude に見えています。Claude は、頼まれた作業に合う skill があると、自分で本文を読み込んで使います。
- skill の **本文** は、使うときにだけ読み込まれます。そのため、たくさんの skill を用意しても、`CLAUDE.md` のように会話を圧迫しません。
- `/skill の名前` と入力すると、あなたが直接呼び出せます。名前の後ろに書いた文字は **引数** として skill に渡されます。

| 置く場所 | 使える範囲 |
| --- | --- |
| `<リポジトリ>/.claude/skills/<名前>/SKILL.md` | そのリポジトリ。Git で管理してチームで共有する |
| `~/.claude/skills/<名前>/SKILL.md` | 自分の、すべてのプロジェクト |

Claude Code には、最初から使える skill もあります（`/code-review` でコードのレビュー、`/simplify` でコードの整理、`/loop` で繰り返しの実行など）。使える skill の一覧は `/skills` で確認できます（[公式ドキュメント: コマンド](https://code.claude.com/docs/ja/commands)）。

### SKILL.md の書き方

`SKILL.md` は、先頭の `---` で囲まれた部分（**フロントマター**）に設定を書き、その下に手順を書きます。

```markdown
---
name: tdd-go
description: TODO.md のテストリストから次の 1 項目を選び、Red → Green → Refactor の 1 サイクルを回してコミットする。
disable-model-invocation: true
---

# TDD を 1 サイクル進める

`TODO.md` の **最初の未チェックの項目を 1 つだけ** 選び、次の順に進める。
...
```

よく使うフロントマターの項目です。

| 項目 | 意味 |
| --- | --- |
| `name` | `/` の後に入力する名前。省略するとディレクトリの名前になる |
| `description` | 何をする skill で、いつ使うか。Claude はこれを読んで、使うかどうかを判断する。**用途を最初に書く** |
| `argument-hint` | 引数の書き方のヒント（`/` のメニューに表示される）。例: `"[Issue 番号]"` |
| `disable-model-invocation` | `true` にすると、Claude が自分の判断では使わず、あなたが `/名前` で呼んだときだけ使う。コミットなど、勝手に実行されると困る手順に付ける |
| `allowed-tools` | この skill を使っている間、確認なしに使ってよいツール |
| `model` / `effort` | この skill を使っている間のモデルと effort（[第 3 章](03-models-and-effort.md)） |

本文では、`$ARGUMENTS` と書いた部分が、呼び出したときの引数に置き換わります。例えば `/tdd-todo 3` と呼び出すと、`$ARGUMENTS` が `3` になります。

本文は **短く、何をするかをはっきり書きます**。読み込まれた skill の本文は会話の中に残り続けるので、長い説明はそれだけ負担になります。目安は 500 行以内で、詳しい資料は別のファイルに分けて、本文から参照します。

## A4.2 TDD 用の skill を作る

[第 6 章](06-tdd.md) では、TDD を次の 2 つの skill で進めます。

| skill | 何をするか |
| --- | --- |
| `/tdd-todo <Issue 番号>` | Issue の仕様を読み、テストにできる振る舞いを **テストリスト**（`TODO.md`）に書き出す。コードはまだ書かない |
| `/tdd-go` | テストリストの次の 1 項目について、Red → Green → Refactor の **1 サイクルだけ** を回し、チェックを付けてコミットし、報告して止まる |

1 サイクルごとに止まるようにしているのは、あなたが Claude の作業を 1 つずつ確認し、TDD のリズムを体験するためです。
これは、Kent Beck が AI と TDD を行ったときに使った方法（テストリストを書いたファイルを用意し、「go」と言うたびに次の 1 つのテストを進めてもらう）を参考にしています（[第 6 章](06-tdd.md) で詳しく説明します）。

## A4.3 subagent とは

**subagent** は、特定の役割を持つ、別の Claude です。`.claude/agents/<名前>.md` というファイルに書きます。

- subagent は、**自分専用の会話（コンテキスト）** で作業し、結果だけを返します。たくさんのファイルを読む調査を任せても、あなたとの会話が散らかりません。
- **使えるツールを絞れます。** 例えば、ファイルを読むだけで書き換えられないレビュー役を作れます。
- 作業した本人とは別の会話で見るので、**作業の思い込みに引きずられずに** 結果を確かめられます。公式のベストプラクティスでも、作業が終わったら、新しい会話の subagent に差分をレビューさせることを勧めています（[公式ドキュメント: ベストプラクティス](https://code.claude.com/docs/ja/best-practices)）。

Claude Code には、最初から使える subagent もあります。ファイルを探して読む **Explore**、計画のための調査をする **Plan** などです。Claude は必要に応じて、これらを自分で使います。

### subagent のファイルの書き方

```markdown
---
name: test-reviewer
description: TDD で追加・変更したテストをレビューする。テストが振る舞いを確かめているか、実装に過剰適合していないか、テストが消されたり弱められたりしていないかを確認する。ファイルは変更しない。
tools: Read, Grep, Glob, Bash
model: sonnet
---

あなたは、テスト駆動開発（TDD）に詳しいレビュアーです。...
```

| 項目 | 意味 |
| --- | --- |
| `name` | subagent の名前（必須） |
| `description` | いつ、この subagent に任せるか（必須）。Claude はこれを読んで、任せるかどうかを判断する |
| `tools` | 使えるツール。省略すると、すべてのツールを使える。例: `Read, Grep, Glob`（読むだけ） |
| `model` | 使うモデル（`sonnet`、`opus`、`haiku`、または `inherit` で呼び出し元と同じ） |
| `effort` | effort のレベル |

フロントマターの下に書いた文章が、その subagent の役割の説明（システムプロンプト）になります。
subagent は、あなたとの会話の内容を知りません。必要な情報（何をレビューするのか、何を基準にするのか）は、本文に書いておきます。

### 「ファイルを変更しない」を仕組みで守る

`tools` に `Bash` を入れると、subagent は `git diff` のような読み取りのコマンドだけでなく、`git commit` や `rm` も実行できてしまいます。
本文に「ファイルは変更しない」と書くだけでは「お願い」なので、完成例では、subagent のフロントマターに **フック**（[第 5 章](05-harness.md#a55-フックで必ず実行する)）を書いて、Bash のコマンドを実行する直前（`PreToolUse`）にチェックしています。

```yaml
hooks:
  PreToolUse:
    - matcher: "Bash"
      hooks:
        - type: command
          command: 'bash "$CLAUDE_PROJECT_DIR/.claude/hooks/readonly-bash.sh" || exit 2'
```

[readonly-bash.sh](../../samples/claude-harness/template/.claude/hooks/readonly-bash.sh) は、`git diff` / `git log` / `git show` / `git status` 以外のコマンドを、終了コード 2 で止めます。レビューするテストのファイルの中身がそのまま実行されてしまうので、テストの実行（`bash tests/test_todo.sh`）も止めます。止められたコマンドは実行されず、理由が subagent に伝わります。
最後の `|| exit 2` は、「スクリプトが見つからないなどで、フックそのものが失敗したときも止める」という意味です。フックが 0 と 2 以外の終了コード（スクリプトが見つからないときは 127）で終わると、Claude Code はエラーを表示するだけで、コマンドを実行してしまうためです。
「危ないコマンドを探して止める」のではなく、「安全だと分かっている書き方だけを通す」（**許可リスト**）考え方で作っています。引用符や `$` などの記号を使うと、同じコマンドをいくらでも違う書き方にできるので、使える文字、オプション、パスを決めて、それ以外はすべて止めます。

> [!NOTE]
> subagent のフロントマターに書いたフックは、Claude Code でそのフォルダーを信頼したあとに使われます（[第 1 章](01-setup.md#a14-初めて起動する)）。

### subagent に任せる

subagent は、名前を出して頼みます。

```text
test-reviewer サブエージェントで、このブランチで追加したテストをレビューしてください。
```

`@` を入力して、一覧から subagent を選ぶこともできます。

## A4.4 使い分け

ここまでに出てきた部品の使い分けです（[公式ドキュメント: Claude Code を拡張する](https://code.claude.com/docs/ja/features-overview)）。

| 部品 | いつ効くか | 向いている内容 |
| --- | --- | --- |
| `CLAUDE.md` / `AGENTS.md` | 毎回の会話で、いつも | すべての作業に共通する決まり |
| skill | 呼び出したとき、または Claude が必要と判断したとき | 決まった手順、特定の作業にだけ必要な知識 |
| subagent | 任せたとき | 別の会話で行いたい作業（調査、レビュー） |
| フック（[第 5 章](05-harness.md)） | 決めたタイミングで、必ず | 例外なく毎回実行したいこと（チェックの実行など） |

skill、subagent、フックなどをまとめて配布できる **プラグイン** という仕組みもあります。`/plugin` で、公開されているプラグインを探してインストールできます（[公式ドキュメント: プラグイン](https://code.claude.com/docs/ja/plugins/overview)）。

## 演習

### 演習 A4-1: TDD 用の skill を作る

1. 練習用リポジトリで、作業用のブランチを作ります。

   ```bash
   cd ~/git-practice/todo-cli-practice
   git switch main
   git pull
   git switch -c chore/tdd-skills
   ```

2. VS Code のエクスプローラーで `.claude/skills/tdd-todo/SKILL.md` と `.claude/skills/tdd-go/SKILL.md` を作り、A4.2 の表の内容を、自分の言葉で手順として書きます。
   次のことを、必ず手順に入れてください。
   - `/tdd-todo`: 仕様を読む → テストにできる振る舞いを `TODO.md` にチェックボックスの形で書く → **コードは書かない** → 一覧を見せて止まる
   - `/tdd-go`: 最初の未チェックの項目を **1 つだけ** 選ぶ → Red（テストを書いて実行し、失敗を確かめる）→ Green（最小限のコード）→ Refactor → チェックを付けてコミット → 報告して止まる
   - テストを消したり弱めたりしない。頼まれていない機能を追加しない
3. Claude Code を起動し、`/skills` で 2 つの skill が一覧に表示されることを確認します。
4. 完成例と見比べます。

   ```bash
   code --diff ~/github-and-cli-tutorials/samples/claude-harness/template/.claude/skills/tdd-go/SKILL.md .claude/skills/tdd-go/SKILL.md
   ```

<details>
<summary>解答例</summary>

[samples/claude-harness/template/.claude/skills/](../../samples/claude-harness/template/.claude/skills/) を参照してください。
自分で書いた手順のほうが分かりやすい部分は、そのまま残して構いません。完成例をそのまま使う場合は、次のようにコピーします（`-i` を付けると、同じ名前のファイルがあるときに上書きしてよいか聞かれます）。

```bash
mkdir -p .claude/skills
cp -R -i ~/github-and-cli-tutorials/samples/claude-harness/template/.claude/skills/. .claude/skills/
```

</details>

### 演習 A4-2: テストレビュー用の subagent を作る

1. `.claude/agents/test-reviewer.md` を作ります。次のことを入れてください。
   - `tools` は `Read, Grep, Glob, Bash` にし、本文で「ファイルは変更しない」「Bash は `git diff` などの読み取りにだけ使う」と書く
   - A4.3 の `hooks` を書き、読み取りだけのコマンドしか実行できないようにする。フックのスクリプトは、完成例からコピーします（`cp -R -i ~/github-and-cli-tutorials/samples/claude-harness/template/.claude/hooks/. .claude/hooks/`）
   - レビューの観点: テストが振る舞いを確かめているか、決まった値を返すだけの実装でも通ってしまわないか、テストが消されたり弱められたりしていないか
   - 問題があるものだけを、重要な順に報告する
2. Claude Code を再起動し（`/exit` してから `claude`）、次のように頼みます。今はテストを追加していないので、「問題は見つかりませんでした」のような答えになれば、正しく動いています。

   ```text
   test-reviewer サブエージェントで、tests/test_todo.sh をレビューしてください。
   ```

3. 完成例（[test-reviewer.md](../../samples/claude-harness/template/.claude/agents/test-reviewer.md)）と見比べたら、skill とあわせてコミットし、Pull Request を作ってマージします。

<details>
<summary>解答例</summary>

```bash
git add .claude/skills .claude/agents .claude/hooks
git commit -m "chore: TDD 用の skill とテストレビュー用の subagent を追加"
git push -u origin chore/tdd-skills
gh pr create --title "TDD 用の skill とテストレビュー用の subagent を追加" --body "第 6 章の TDD で使う /tdd-todo、/tdd-go と、test-reviewer を追加します。"
```

</details>

## まとめ

- skill は、名前を付けて呼び出せる手順書。説明文はいつも見えていて、本文は使うときに読み込まれる
- 勝手に実行されると困る手順の skill には `disable-model-invocation: true` を付ける
- subagent は、自分専用の会話で作業する別の Claude。使えるツールを絞って、レビューなどを任せる
- いつも必要な決まりは CLAUDE.md、手順は skill、別の目で見る作業は subagent、必ず実行することはフック

---

[← 前の章: モデルと effort の選び方](03-models-and-effort.md) ｜ [目次](../../README.md) ｜ [次の章: ハーネスを整える →](05-harness.md)
