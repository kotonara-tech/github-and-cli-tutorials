# 発展編 第 5 章: ハーネスを整える

Claude Code にどこまで任せるか、何を必ず確かめさせるかは、**権限のモード**、**権限の設定**、**フック** で決めます。
さらに、テストのように「成功したか失敗したか」を判定できるチェックを Claude に渡すと、Claude は自分で結果を確かめながら作業を進められるようになります。
この章では、これらを組み合わせて、練習用リポジトリの **ハーネス**（Claude Code を安全に、確実に動かすための仕組み）を完成させます。

> [!NOTE]
> この章の内容は 2026 年 10 月時点のものです。最新の情報は [公式ドキュメント: 権限モード](https://code.claude.com/docs/ja/permission-modes)、[権限](https://code.claude.com/docs/ja/permissions)、[フック](https://code.claude.com/docs/ja/hooks-guide)、[/goal](https://code.claude.com/docs/ja/goal) を確認してください。

## この章のゴール

- [ ] 権限モード（Manual / acceptEdits / plan / auto）の違いを説明し、作業に合わせて切り替えられる
- [ ] plan モードで、調べる → 計画する → 実装する → コミットする の流れで作業を頼める
- [ ] `.claude/settings.json` に、許可・確認・拒否のルールとフックを書ける
- [ ] `/goal` で完了の条件を決めて、Claude に作業を続けさせられる

**所要時間の目安:** 60〜90 分

## A5.1 ハーネスの全体像

[第 2 章](02-claude-md.md) から [第 4 章](04-skills-and-agents.md) までに、決まり（`AGENTS.md` / `CLAUDE.md`）と手順（skill / subagent）を用意しました。この章で、残りの部品をそろえます。

| 部品 | 決めること | 強さ |
| --- | --- | --- |
| `AGENTS.md` / `CLAUDE.md` | プロジェクトの決まり | お願い（守られないこともある） |
| skill / subagent | 作業の手順、別の役割 | お願い |
| **権限モード** | どこまで確認なしで任せるか | 仕組みで強制される |
| **権限の設定**（`.claude/settings.json`） | どのコマンドを許可・確認・拒否するか | 仕組みで強制される |
| **フック** | 決めたタイミングで必ず実行すること | 仕組みで強制される |
| **検証ループ** | 何をもって「終わった」とするか | テストなどのチェックで判定する |

完成例は [samples/claude-harness/template/](../../samples/claude-harness/template/) にあります。

## A5.2 権限モード

権限モードは、Claude が **確認なしで** できることの範囲を決めます。<kbd>Shift</kbd> + <kbd>Tab</kbd> を押すたびに、auto → Manual → acceptEdits → plan → auto の順に切り替わります。

| モード | 入力欄の下の表示 | 確認なしでできること | 向いている場面 |
| --- | --- | --- | --- |
| Manual（設定名: `default`） | `⏸ manual mode on` | ファイルを読むことだけ | 学習中、大事な作業。1 つずつ確かめたいとき |
| acceptEdits | `⏵⏵ accept edits on` | 読むこと、ファイルの編集、`mkdir` などの簡単なファイル操作 | 編集は任せて、差分は後でまとめて確認したいとき |
| plan | `⏸ plan mode on` | 読んで調べることだけ。ファイルは変更しない | 変更する前に、計画を立ててもらうとき |
| auto | `⏵⏵ auto mode on` | ほぼすべて。別の AI（分類器）が、頼んだ範囲を超える操作や危険な操作を止める | 方向性が決まった長い作業 |

> [!WARNING]
> auto モードは確認の回数を減らしますが、**安全を保証するものではありません**（公式ドキュメントにも明記されています）。
> 方向性に納得している作業にだけ使い、大事な操作の確認の代わりにはしないでください。

このほかに、確認が必要な操作をすべて断る `dontAsk`（自動化のスクリプト用）と、確認をすべて飛ばす `bypassPermissions`（隔離された環境専用）があります。この教材では使いません。

## A5.3 plan モードで計画してから実装する

Claude にいきなりコードを書かせると、「間違った問題を解いてしまう」ことがあります。公式のベストプラクティスでは、次の 4 つの段階に分けることを勧めています（[公式ドキュメント: ベストプラクティス](https://code.claude.com/docs/ja/best-practices)）。

1. **調べる**: plan モード（`⏸ plan mode on`）にして、関係するファイルを読んでもらいます。
2. **計画する**: どのファイルをどう変えるか、計画を立ててもらいます。<kbd>Ctrl</kbd> + <kbd>G</kbd> を押すと、計画をエディタで開いて直接直せます。
3. **実装する**: 計画を承認すると plan モードが終わり、Claude が計画に沿って変更を始めます。
4. **コミットする**: テストが通ったら、分かりやすいメッセージでコミットしてもらいます。

計画ができると、Claude はどう進めるかを聞いてきます。

| 選択肢 | 意味 |
| --- | --- |
| **Yes, and use auto mode** | 計画を承認し、auto モードで実装を始める |
| **Yes, manually approve edits** | 計画を承認し、変更を 1 つずつ確認しながら実装を始める（Manual モード） |
| **No, keep planning** | plan モードのまま、計画の直してほしい点を伝える |

plan モードは、指示の最初に `/plan` を付けても始められます（例: `/plan README に stats コマンドの説明を足したい`）。
VS Code の拡張機能（[第 1 章](01-setup.md#a16-vs-code-の拡張機能で使う)）では、計画を画面で読み、編集してから承認できます。

> [!TIP]
> 計画には手間がかかります。「変更の内容を 1 文で説明できる」くらいの小さな作業（誤字の修正など）は、plan モードを使わずに直接頼んで構いません。

## A5.4 権限の設定（.claude/settings.json）

どのコマンドを確認なしで許可するかは、設定ファイルで決めます（[公式ドキュメント: 設定](https://code.claude.com/docs/ja/settings)）。

| ファイル | 範囲 | Git |
| --- | --- | --- |
| `~/.claude/settings.json` | 自分の、すべてのプロジェクト | 管理しない |
| `<リポジトリ>/.claude/settings.json` | そのリポジトリ。チームで共有する | **コミットする** |
| `<リポジトリ>/.claude/settings.local.json` | 自分の、そのリポジトリだけ。確認で「Yes, and don't ask again」を選ぶとここに保存される | コミットしない（`.gitignore` に追加する） |

同じ項目が複数のファイルにあるときは、範囲の狭いもの（local → リポジトリ → 自分のすべてのプロジェクト）が優先されます。

完成例の `.claude/settings.json` の権限の部分です。

```json
{
  "$schema": "https://json.schemastore.org/claude-code-settings.json",
  "permissions": {
    "allow": [
      "Bash(bash tests/test_todo.sh)",
      "Bash(shellcheck *)",
      "Bash(./todo.sh *)",
      "Bash(git add *)",
      "Bash(git commit *)"
    ],
    "ask": [
      "Bash(git push *)",
      "Bash(gh pr *)"
    ],
    "deny": [
      "Bash(git push *--force*)",
      "Bash(git push -f*)",
      "Bash(git push * -f*)",
      "Bash(git push * +*)",
      "Read(**/.env)",
      "Read(**/.env.*)"
    ]
  }
}
```

| 項目 | 意味 |
| --- | --- |
| `allow` | 確認なしで許可する。テストの実行、shellcheck、コミットまでは任せる |
| `ask` | どのモードでも、必ず確認する。GitHub に送る操作（push、Pull Request）は、自分で内容を見てから行う |
| `deny` | どのモードでも拒否する。強制 push の代表的な書き方（`--force`、`--force-with-lease`、`-f`、`+ブランチ名`）と、秘密の情報を書くファイル（`.env`、`.env.local` など）の読み取りを禁止する |

- `Bash(git add *)` の `*` は「何が続いてもよい」という意味です。`Bash(git add *)` は `git add todo.sh` にも `git add`（引数なし）にも当てはまります。
- `*` は途中にも書けます。`Bash(git push *--force*)` は、`git push --force` にも `git push origin main --force-with-lease` にも当てはまります。
- ただし、コマンドの引数の書き方はいくらでも変えられるので、このようなルールで **すべての書き方を確実に防ぐことはできません**（公式ドキュメントにも明記されています）。例えば `git push -uf`（`-u` と `-f` をまとめた書き方）は、この `deny` では防げません。この設定では、`git push` はすべて `ask` で確認されるので、確認のときに内容を必ず読みます。`main` ブランチへの強制 push を確実に防ぐには、GitHub の **ブランチの保護**（[本編の第 7 章](../07-github-flow.md#ブランチを保護する任意)）を組み合わせます。
- `Read(**/.env)` の `**/` は「どの階層のフォルダーでも」という意味です。リポジトリのルートの `.env` だけでなく、`config/.env` なども拒否します。
- `Read` の `deny` は、Claude Code のファイルを読むツールと、Bash の `cat` や `head` のようにファイル名を指定して読むコマンドに効きます。ただし、`grep -r` のようにファイル名を指定せずに読むコマンドや、スクリプトが自分でファイルを開く場合には効きません（[公式ドキュメント: 権限](https://code.claude.com/docs/ja/permissions)）。OS の機能で確実に防ぐには、**サンドボックス**（`/sandbox`、[公式ドキュメント](https://code.claude.com/docs/ja/sandboxing)）を使います。秘密の情報は、そもそも練習用リポジトリに置かないのがいちばん安全です。
- `git status`、`git diff`、`git log` などの読み取りだけのコマンドは、最初から確認なしで実行されます。
- `$schema` の行があると、VS Code がこのファイルの書き方をチェックし、入力の候補を表示してくれます。
- `/permissions` で、今効いているルールを確認・追加・削除できます。

> [!IMPORTANT]
> リポジトリの `.claude/settings.json` の `allow` は、[第 1 章](01-setup.md#a14-初めて起動する) で説明した **フォルダーの信頼** を受け入れるまで使われません。
> 知らないリポジトリが勝手に「何でも許可する」設定を持ち込めないようにするためです。`ask` と `deny` は、制限を強める設定なので、信頼する前から使われます。

## A5.5 フックで必ず実行する

`CLAUDE.md` に「シェルスクリプトを変更したら shellcheck を実行する」と書いても、Claude が忘れることがあります。
**例外なく毎回実行したいこと** は、**フック**（hook）で自動化します。フックは、Claude Code が決まったタイミングで実行するコマンドです（[公式ドキュメント: フック](https://code.claude.com/docs/ja/hooks-guide)）。

| タイミング（イベント） | いつ実行されるか | 使い道の例 |
| --- | --- | --- |
| `PreToolUse` | Claude がツールを使う直前 | 危険なコマンドを止める |
| `PostToolUse` | Claude がツールを使った直後 | 編集したファイルをチェックする、整形する |
| `Stop` | Claude が返答を終えようとしたとき | テストが通るまで終わらせない |
| `SessionStart` | 会話を始めたとき | 必要な情報を Claude に渡す |

完成例では、Claude がファイルを編集・作成した直後（`PostToolUse`）に、shellcheck を実行します。

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Edit|Write",
        "hooks": [
          {
            "type": "command",
            "command": "bash \"$CLAUDE_PROJECT_DIR/.claude/hooks/shellcheck-on-edit.sh\""
          }
        ]
      }
    ]
  }
}
```

- `matcher` の `Edit|Write` は「ファイルの編集（Edit）または作成（Write）のツールを使ったとき」という意味です。
- `command` は、シェルで実行するコマンドです。`$CLAUDE_PROJECT_DIR` は、リポジトリのルートのパスが入った環境変数です。パスに空白が含まれていても動くように、`\"`（JSON の中のダブルクォート）で囲んでいます。
- `bash` で実行するので、スクリプトに実行の権限（`chmod +x`）がなくても動きます。
- 実行するスクリプト [shellcheck-on-edit.sh](../../samples/claude-harness/template/.claude/hooks/shellcheck-on-edit.sh) は、Claude Code から受け取った情報（JSON）から編集したファイルのパスを取り出し、`.sh` のファイルなら shellcheck でチェックします。JSON から値を取り出すには、公式ドキュメントの例と同じく jq（[第 1 章](01-setup.md#shellcheck-と-jq)）を使います（`jq -r '.tool_input.file_path // empty'`）。

フックのスクリプトは、**終了コード** で結果を伝えます。

| 終了コード | 意味 | 誰に伝わるか |
| --- | --- | --- |
| `0` | 問題なし | 何も伝えない |
| `2` | 問題あり（`PostToolUse` では、編集は取り消されない） | 標準エラー出力の内容が **Claude に** 伝わり、Claude が直す |
| それ以外 | フック自体の問題（作業は続く） | Claude には伝わらない。会話の表示に「hook error」として、標準エラー出力の 1 行目が表示される |

警告が出たときの様子です。Claude が書いたスクリプトに `cd /tmp`（`cd` に失敗したときの処理がない）があると、フックが次の内容を Claude に返し、Claude は次に進む前に直します。

```text
shellcheck が scratch.sh に警告を出しました。次に進む前に直してください。

In .../scratch.sh line 2:
cd /tmp
^-----^ SC2164 (warning): Use 'cd ... || exit' or 'cd ... || return' in case cd fails.
```

設定されているフックは、Claude Code の中で `/hooks` を実行すると確認できます。

> [!WARNING]
> フックは、あなたのパソコンの上で **確認なしに** コマンドを実行します。他人のリポジトリのフックは、中身を読んでから信頼してください。

## A5.6 ループの設計（検証ループ）

### 「終わったように見える」ではなく「確かめて終わる」

公式のベストプラクティスでは、次のように説明しています。

> Claude は、作業が終わったように見えたところで止まります。実行できるチェックがなければ、「終わったように見える」ことしか判断の材料がなく、**あなたが確認の役（検証ループ）になってしまいます**。
> 成功か失敗かを返すチェック（テスト、ビルド、リンター、出力の比較など）を Claude に渡せば、Claude が作業し、チェックを実行し、結果を読み、通るまで繰り返す、というループが自分で閉じます。
>
> （[公式ドキュメント: ベストプラクティス](https://code.claude.com/docs/ja/best-practices) の「Claude が自分の作業を検証できるようにする」を要約）

この教材では、このように「Claude が結果を確かめながら進めるための仕組みを設計すること」を **ループの設計** と呼びます。
練習用リポジトリでは、`bash tests/test_todo.sh`（テスト）と `shellcheck`（書き方のチェック）が、そのチェックになります。

チェックをどのくらい強く「終わりの条件」にするかには、段階があります。

| 方法 | どう効くか | 使いどころ |
| --- | --- | --- |
| 指示の中で頼む | 「実装したらテストを実行し、失敗したら直して」と書く | すぐに使える。いつも最初はこれ |
| `/goal` で条件を決める | 返答のたびに別の AI が条件を確かめ、満たすまで Claude に続けさせる | 長い作業を、条件を満たすまで続けてほしいとき |
| `Stop` フック | 返答を終える前にスクリプトでチェックし、失敗したら終わらせない | 毎回、例外なく確かめたいとき |
| 確認用の subagent | 別の会話の Claude に結果を確かめさせる | 作業した本人とは別の目で見てほしいとき |

### /goal で完了の条件を決める

`/goal` に続けて **完了の条件** を書くと、Claude はその条件を満たすまで、あなたが指示しなくても作業を続けます（[公式ドキュメント: /goal](https://code.claude.com/docs/ja/goal)）。

```text
/goal TODO.md のすべての項目が [x] になっていて、bash tests/test_todo.sh の最後の行が「0 件失敗」になっている。20 ターンで終わらなければ止める
```

よい条件の書き方です。

- **確かめられる終わりの状態を 1 つ** 書く（テストの結果、ファイルの状態など）
- **どう確かめるか** を書く（「`bash tests/test_todo.sh` の最後の行が〜」）
- **変えてはいけないもの** があれば書く（「既存のテストは変更しない」）
- **止まる条件** を書く（「20 ターンで終わらなければ止める」）

条件を確かめる AI は、自分でコマンドを実行したりファイルを読んだりしません。**会話の中に表示された結果** を見て判断するので、Claude がテストを実行して結果を表示するような条件にします。

- `/goal` だけを実行すると、今の状態（条件、経過時間、ターン数など）が表示されます。
- `/goal clear` で取り消せます。<kbd>Esc</kbd> でも、その場で止められます。
- `/goal` は権限モードを変えません。Manual モードでは、許可していない操作のたびに確認が表示されます。確認なしで続けさせたいときは auto モードと組み合わせますが、その前に、A5.4 の `ask` と `deny` が設定されていることを確かめてください。

### /loop で繰り返す

`/loop` は、同じ指示を **時間の間隔を決めて** 繰り返します（[公式ドキュメント: スケジュールされたタスク](https://code.claude.com/docs/ja/scheduled-tasks)）。

```text
/loop 10m git fetch して、main に新しいコミットがあれば、内容を短く教えて
```

間隔を書かないと、Claude が自分で間隔を決めます。`/loop` は Claude Code を開いている間だけ動き、<kbd>Esc</kbd> で止められます。

| | 次の作業が始まるとき | 止まるとき |
| --- | --- | --- |
| `/goal` | 前の返答が終わったとき | 条件を満たしたとき（または、満たせないと判断されたとき） |
| `/loop` | 決めた時間がたったとき | あなたが止めたとき（または、Claude が終わったと判断したとき） |
| `Stop` フック | 前の返答が終わったとき | スクリプトが「終わってよい」と判断したとき |

### ループを設計するときの注意

- **必ず止まる条件を決めます。** ターン数や時間の上限を条件に入れ、利用上限を使い切らないようにします。
- **チェックが正しいことを先に確かめます。** チェックが甘いと、Claude は「チェックに通るだけ」の作業をしてしまいます。TDD でテストが失敗することを先に確かめるのは、このためです（[第 6 章](06-tdd.md)）。
- **テストを変えて通すことを禁止します。** 「既存のテストを変更・削除しない」を条件や `AGENTS.md` に書き、終わったら [第 4 章](04-skills-and-agents.md) の `test-reviewer` で確かめます。
- **終わったら差分を確認します。** 長い作業ほど、最後に `git log` と差分を自分で確かめます。

> [!TIP]
> ほかにも、Claude Code のコマンドを OS の機能で隔離して実行する **サンドボックス**（`/sandbox`、[公式ドキュメント](https://code.claude.com/docs/ja/sandboxing)）や、スクリプトから Claude Code を実行する `claude -p`（[公式ドキュメント](https://code.claude.com/docs/ja/headless)）があります。
> どちらも便利ですが、仕組みを理解してから使ってください。この教材では使いません。

## 演習

### 演習 A5-1: ハーネスを取り込む

1. 作業用のブランチを作ります。

   ```bash
   cd ~/git-practice/todo-cli-practice
   git switch main
   git pull
   git switch -c chore/claude-harness
   ```

2. 完成例の `.claude/settings.json` を、自分のリポジトリにまだないか確認してから取り込みます。すでにある場合は、`code --diff` で見比べて、必要な部分だけを自分のファイルに書き写します。

   ```bash
   ls .claude
   code --diff ~/github-and-cli-tutorials/samples/claude-harness/template/.claude/settings.json .claude/settings.json
   ```

   ないときは、コピーします（`-i` を付けると、上書きする前に確認されます）。

   ```bash
   cp -i ~/github-and-cli-tutorials/samples/claude-harness/template/.claude/settings.json .claude/
   ```

   フックのスクリプト（`.claude/hooks/` の中のファイル）は、[第 4 章](04-skills-and-agents.md#演習-a4-2-テストレビュー用の-subagent-を作る) の演習 A4-2 でコピーしてあります。`ls .claude/hooks` で `shellcheck-on-edit.sh` と `readonly-bash.sh` があることを確認してください。ない場合だけ、`cp -R -i ~/github-and-cli-tutorials/samples/claude-harness/template/.claude/hooks/. .claude/hooks/` でコピーします。

3. `.claude/settings.json` を VS Code で開き、A5.4 と A5.5 の説明と照らして、それぞれの行が何をするのかを確かめます。
4. Claude Code を起動し直し、`/permissions` と `/hooks` で、設定が読み込まれていることを確認します。

### 演習 A5-2: フックが動くことを確かめる

Claude Code で、次のように頼みます。確認が表示されたら、内容を読んで許可します。

```text
scratch.sh というファイルを作り、1 行目に #!/usr/bin/env bash、2 行目に cd /tmp だけを書いてください。そのあと、指摘を受けたらどう直したかを教えてください。
```

フックが shellcheck の警告を Claude に返し、Claude が `cd /tmp || exit` のように直すことを確かめます。確かめたら、`scratch.sh` は削除します。

```bash
rm scratch.sh
```

### 演習 A5-3: plan モードで計画してから実装する

1. <kbd>Shift</kbd> + <kbd>Tab</kbd> で `⏸ plan mode on` にして、次のように頼みます。

   ```text
   README.md に、AI エージェント（Claude Code）を使った開発の進め方を短く追加したい。AGENTS.md と CLAUDE.md の役割、.claude/ に何があるかを説明する節を作る計画を立ててください。
   ```

2. 計画を読み、直してほしい点があれば **No, keep planning** を選んで伝えます。納得したら **Yes, manually approve edits** を選び、変更を 1 つずつ確認します。
3. 変更を差分で確認したら、演習 A5-1 の設定とあわせてコミットし、Pull Request を作ってマージします。

<details>
<summary>解答例</summary>

```bash
git add .claude/settings.json .claude/hooks README.md
git commit -m "chore: Claude Code の権限の設定と shellcheck のフックを追加"
git push -u origin chore/claude-harness
gh pr create --title "Claude Code の権限の設定と shellcheck のフックを追加" --body "テストと shellcheck の実行を許可し、push と強制 push を制限します。シェルスクリプトを編集したら、フックで shellcheck を自動で実行します。"
```

</details>

## まとめ

- 権限モードで、どこまで確認なしで任せるかを決める。学習中は Manual、計画は plan、方向が決まった長い作業は auto
- `.claude/settings.json` の `allow` / `ask` / `deny` で、コマンドごとに許可・確認・拒否を決める。`allow` はフォルダーを信頼してから効く
- 例外なく毎回実行したいことは、フックで自動化する
- テストのような「成功か失敗か」を返すチェックを渡すと、Claude が自分で確かめながら進める。`/goal` では、確かめられる条件と止まる条件を書く

---

[← 前の章: skill と subagent](04-skills-and-agents.md) ｜ [目次](../../README.md) ｜ [次の章: 追加課題: t-wada 流 TDD で stats コマンドを作る →](06-tdd.md)
