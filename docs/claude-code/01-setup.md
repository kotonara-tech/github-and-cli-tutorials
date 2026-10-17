# 発展編 第 1 章: Claude Code のセットアップ

**Claude Code** をインストールし、VS Code の統合ターミナルで使えるようにします。
あわせて、Claude Code に作業を任せるときの基本の操作と、安全に使うための心得を学びます。

> [!NOTE]
> この章の内容は 2026 年 10 月時点のものです。最新の手順は [公式ドキュメント: クイックスタート](https://code.claude.com/docs/ja/quickstart) と [セットアップ](https://code.claude.com/docs/ja/setup) を確認してください。

## この章のゴール

- [ ] Claude Code が何をするツールなのかを説明できる
- [ ] Claude Code をインストールし、自分のアカウントでログインできる
- [ ] 練習用リポジトリで Claude Code を起動し、質問や小さな作業を頼める
- [ ] Claude の変更を差分で確認し、必要なら取り消せる

**所要時間の目安:** 45〜60 分

## A1.1 Claude Code とは

Claude Code は、Anthropic が提供している AI の **コーディングエージェント** です。
チャットで質問に答えるだけの AI とは違い、Claude Code は次のことを自分で行えます。

- リポジトリのファイルを読んで、コードの構造を理解する
- ファイルを作成・編集する
- テストや Git などのコマンドを実行し、その結果を読む

あなたが「テストを実行して、失敗していたら直して」のように頼むと、Claude は **情報を集める → 行動する → 結果を確かめる** を繰り返して作業を進めます。
この繰り返しを **エージェントループ**（agentic loop）と呼びます（[公式ドキュメント: Claude Code の仕組み](https://code.claude.com/docs/ja/how-claude-code-works)）。

Claude Code は便利な一方で、あなたのパソコンの上でコマンドを実行します。そのため、何をしてよいかを **あなたが決めて、確認する** ことが大切です。この章の最後で、安全に使うための心得を確認します。

## A1.2 必要なプランと費用

Claude Code を使うには、次のどれかが必要です（[公式ドキュメント: 認証](https://code.claude.com/docs/ja/authentication)）。

| 方法 | 支払い | この教材での扱い |
| --- | --- | --- |
| Claude の有料プラン（**Pro** / **Max**） | 月額の定額。一定時間あたりの利用上限がある | **この教材の前提** |
| Claude の Team / Enterprise プラン | 組織が契約する | 研修などで組織から配られた場合 |
| Claude Console の API キー | 使った量に応じて支払う（従量課金） | 補足。使いすぎに注意が必要 |

> [!NOTE]
> 無料プランでは Claude Code を使えません。
> 今の利用状況（利用上限までの残り）は、Claude Code の中で `/usage` を実行すると確認できます（[公式ドキュメント: コスト](https://code.claude.com/docs/ja/costs)）。

## A1.3 インストールする

### Claude Code 本体

VS Code の統合ターミナルで、次のコマンドを実行します。macOS、Linux、Windows（WSL2 の Ubuntu）のどれでも同じコマンドです。

```bash
curl -fsSL https://claude.ai/install.sh | bash
```

このコマンドは、Anthropic が配布しているインストール用のスクリプトをダウンロードして実行します。この方法（ネイティブ版）でインストールすると、Claude Code は自動で最新の状態に更新されます。

> [!TIP]
> macOS で [Homebrew](https://brew.sh/ja/) を使っている場合は、`brew install --cask claude-code` でもインストールできます。ただし、この方法では自動で更新されないので、ときどき `brew upgrade claude-code` を実行してください。

インストールできたら、**ターミナルを一度閉じて開き直して** から確認します。

```bash
claude --version
```

出力例（バージョン番号は異なります）:

```text
2.1.302 (Claude Code)
```

インストールの状態は、次のコマンドでも確認できます。問題があれば、表示される `Fix:` の手順に従ってください。

```bash
claude doctor
```

### shellcheck と jq

発展編では、Claude Code がシェルスクリプトを編集するたびに、[ShellCheck](https://www.shellcheck.net/) で書き方の誤りをチェックする仕組みを作ります（[第 5 章](05-harness.md)）。
VS Code の ShellCheck 拡張機能とは別に、ターミナルから使える `shellcheck` コマンドをインストールしておきます。
あわせて、JSON を読み取る [jq](https://jqlang.org/) もインストールします。この仕組みのスクリプトは、Claude Code から受け取る情報（JSON）を jq で読み取ります（公式ドキュメントの例と同じやり方です）。

```bash
# macOS（Homebrew）
brew install shellcheck jq

# Linux（Ubuntu）/ Windows（WSL2 の Ubuntu）
sudo apt install -y shellcheck jq
```

```bash
shellcheck --version
jq --version
```

## A1.4 初めて起動する

練習用リポジトリを VS Code で開き、統合ターミナルで `claude` を起動します。

```bash
cd ~/git-practice/todo-cli-practice
code .
```

開いた VS Code の統合ターミナルで、次のコマンドを実行します。

```bash
claude
```

初めて起動したときは、次の順に設定します。表示は英語です。

1. **文字の色（テーマ）** を選びます。見やすいものを選んで <kbd>Enter</kbd> を押します。
2. **ログインの方法** を選びます。Pro / Max プランの場合は、Claude のアカウント（サブスクリプション）でログインする方法を選びます。ブラウザが開くので、ログインして許可します。
   ブラウザが開かないときは、表示された URL を自分でブラウザに貼り付けます。
3. 注意事項が表示されたら、読んで <kbd>Enter</kbd> を押します。
4. **このフォルダーを信頼するか** を聞かれます。自分で作ったリポジトリなので、信頼する（Yes）を選びます。

> [!IMPORTANT]
> フォルダーの信頼は、VS Code の「ワークスペースの信頼」と同じ考え方です。
> Claude Code は、信頼したフォルダーでだけ、リポジトリの `.claude/settings.json` に書かれた「許可」の設定を使います（[第 5 章](05-harness.md)）。
> インターネットから入手した、中身を確認していないリポジトリでは、信頼する前に中身を確認してください（[公式ドキュメント: セキュリティ](https://code.claude.com/docs/ja/security)）。

準備ができると、入力欄（`>`）が表示されます。ここに、日本語で頼みたいことを書きます。

> [!TIP]
> Claude Code が動いているターミナルに `git add` などのコマンドを入力すると、シェルではなく Claude への指示として扱われます。
> 自分でコマンドを実行するときは、メニューの **ターミナル** > **新しいターミナル** でもう 1 つ統合ターミナルを開いて、そちらで実行します。Claude Code の入力欄で、先頭に `!` を付けて実行することもできます（例: `! git status`、A1.5）。
> 発展編では、`bash` と書いたコードブロックのコマンドは、Claude Code とは別のターミナルで実行します。

### 改行の入力を有効にする

Claude への指示の途中で改行したいときに <kbd>Shift</kbd> + <kbd>Enter</kbd> を使えるように、Claude Code の中で次のコマンドを 1 回だけ実行します（[公式ドキュメント: ターミナルの設定](https://code.claude.com/docs/ja/terminal-config)）。

```text
/terminal-setup
```

### 学習中は Manual モードで始める

Claude Code には、Claude がどこまで確認なしに作業してよいかを決める **権限モード** があります。
入力欄の下に、今のモードが表示されています。

| 表示 | モード | 確認なしでできること |
| --- | --- | --- |
| `⏸ manual mode on` | Manual（手動） | ファイルを読むことだけ。編集やコマンドの実行の前に、毎回あなたに確認する |
| `⏵⏵ auto mode on` | auto（自動） | ほぼすべて。別の AI（分類器）が、危険な操作だけを止める |

新しいバージョンの Claude Code は、**auto モード** で起動します。
しかし、発展編の前半では、Claude が何をしようとしているのかを 1 つずつ見て理解するために、**Manual モード** で使います。
モードは <kbd>Shift</kbd> + <kbd>Tab</kbd> を押すたびに切り替わるので、`⏸ manual mode on` と表示されるまで押してください。

毎回切り替えるのが面倒な場合は、自分用の設定ファイル `~/.claude/settings.json` で、起動時のモードを Manual にできます。

```bash
code ~/.claude/settings.json
```

```json
{
  "permissions": {
    "defaultMode": "default"
  }
}
```

`default` は Manual モードの設定上の名前です。ファイルがすでにある場合は、`{ }` の中に `"permissions"` の部分を追加します。
Claude Code から「auto モードに切り替えるか」と 1 度だけ聞かれることがありますが、発展編の第 5 章まではそのまま（切り替えない）にしておきます。
モードの詳しい説明は [第 5 章](05-harness.md) にあります（[公式ドキュメント: 権限モード](https://code.claude.com/docs/ja/permission-modes)）。

## A1.5 基本の操作

| 操作 | 何をするか |
| --- | --- |
| 文章を入力して <kbd>Enter</kbd> | Claude に頼む。日本語で構いません |
| `@` に続けてファイル名 | ファイルを指定する（例: `@todo.sh の cmd_done は何をしていますか？`） |
| `/` に続けてコマンド名 | Claude Code のコマンドを実行する（例: `/help`、`/usage`） |
| `!` に続けてコマンド | シェルのコマンドを直接実行する（例: `! git status`） |
| <kbd>Esc</kbd> | Claude の作業をその場で止める。会話の内容は残るので、続けて別の指示を出せる |
| <kbd>Esc</kbd> を 2 回、または `/rewind` | 前の時点に戻す（会話とファイルの変更を巻き戻す） |
| <kbd>Shift</kbd> + <kbd>Tab</kbd> | 権限モードを切り替える |
| `/clear` | 会話を最初からやり直す（関係のない作業を始めるとき） |
| `/compact` | 長くなった会話を要約して、Claude が覚えておける量に余裕を作る |
| `/context` | 会話の量（コンテキスト）が、どのくらい使われているかを見る |
| `/exit` | Claude Code を終了する |

Claude が覚えておける会話の量（**コンテキスト**）には限りがあり、いっぱいになるほど指示を忘れやすくなります。
**1 つの作業が終わったら `/clear` で区切る** のが、Claude Code を上手に使うコツです（[公式ドキュメント: ベストプラクティス](https://code.claude.com/docs/ja/best-practices)）。

### 確認（権限のプロンプト）に答える

Manual モードでは、Claude がファイルを編集したりコマンドを実行したりする前に、確認が表示されます。
コマンドを実行するときの確認は、次のような形です（[公式ドキュメント: 権限](https://code.claude.com/docs/ja/permissions) の画面の例をもとにしています。表示はバージョンによって異なります）。

```text
Bash command

  bash tests/test_todo.sh
  Run the test suite

This command requires approval

Do you want to proceed?
❯ 1. Yes
  2. Yes, and don't ask again for: bash tests/test_todo.sh
  3. Yes, and switch to auto mode
  4. No

Esc to cancel · Tab to amend
```

| 選択肢 | 意味 |
| --- | --- |
| **Yes** | 今回だけ許可する |
| **Yes, and don't ask again for: ...** | 同じコマンドを、このリポジトリでは今後確認なしに許可する（`.claude/settings.local.json` に保存される） |
| **Yes, and switch to auto mode** | 許可して、auto モードに切り替える |
| **No** | 許可しない。<kbd>Esc</kbd> でも同じ。続けて、どうしてほしいかを伝えられる |

**何をしようとしているのかを読んでから** 選んでください。分からないコマンドは **No** を選んで、「このコマンドは何をしますか？」と聞けば説明してくれます。

## A1.6 VS Code の拡張機能で使う

Claude Code には、VS Code の画面で操作できる公式の拡張機能 **Claude Code for VS Code**（ID: `anthropic.claude-code`）もあります（[公式ドキュメント: VS Code](https://code.claude.com/docs/ja/vs-code)）。

| 使い方 | 特徴 |
| --- | --- |
| 統合ターミナルで `claude` を実行する（**この教材の方法**） | コマンドの操作がすべて使える。画面の表示はターミナルの文字だけ |
| 拡張機能のパネルで使う | チャットのような画面で使える。Claude の変更が VS Code の差分の画面に表示され、計画（[第 5 章](05-harness.md)）を画面で確認・編集できる |

どちらも同じアカウント、同じ設定ファイル（`~/.claude/settings.json`）、同じ `CLAUDE.md` を使います。
発展編ではターミナルで操作しますが、慣れてきたら拡張機能も試してみてください。

- 拡張機能は、[第 0 章](../00-setup.md#09-拡張機能を追加する) と同じ手順で、ID `anthropic.claude-code` を検索してインストールします。ファイルを開いているときにエディターの右上に表示される、Claude のアイコン（スパークのアイコン）から開きます。
- 拡張機能を入れても、ターミナル用の `claude` コマンドは入りません。A1.3 のインストールは別に必要です。
- 拡張機能で起動時のモードを Manual にするには、VS Code のユーザー設定で `claudeCode.initialPermissionMode` を `default` にします。
- VS Code の統合ターミナルで `claude` を起動すると、自動で VS Code とつながり、Claude の変更を VS Code の差分の画面で確認できます。VS Code の外のターミナルで起動した場合は、Claude Code の中で `/ide` を実行してつなぎます。

## A1.7 安全に使うための心得

Claude Code は、あなたの代わりにファイルを書き換え、コマンドを実行します。次のことを守りましょう。

1. **変更は必ず差分で確認する。** VS Code の **ソース管理** ビュー、`git diff`、または Claude Code の `/diff` で、何が変わったかを確認してから受け入れます。
2. **Git を安全網にする。** 作業の前に、作業用のブランチを作り、きりのよいところでコミットしておきます。`/rewind` で戻せるのは Claude がファイル編集の機能で行った変更だけで、コマンドによる変更は戻せません。
3. **確認をすべて飛ばすモードは使わない。** `--dangerously-skip-permissions` などで確認をすべて飛ばすモード（bypassPermissions）は、インターネットにつながらない隔離された環境のためのものです。この教材では使いません。
4. **秘密の情報を読ませない。** パスワードや API キーが書かれたファイルは、リポジトリに置かないのが基本です。読ませたくないファイルは、[第 5 章](05-harness.md) の設定で読めないようにできます。
5. **最後に判断するのはあなた。** Claude の説明やコードは、もっともらしく見えても間違っていることがあります。テストで確かめ、`git push` や Pull Request の作成は、自分で内容を確認してから行います。

## 演習

### 演習 A1-1: コードについて質問する

練習用リポジトリで Claude Code を起動し（Manual モード）、次のように聞いてみましょう。

```text
@todo.sh の cmd_done 関数は何をしていますか？初心者にも分かるように説明してください。
```

ファイルを読むだけなので、確認は表示されずに答えが返ってきます。気になったところを、さらに質問してみてください。

### 演習 A1-2: コマンドの実行を許可する

次のように頼み、確認が表示されたら、コマンドの内容を読んでから **Yes** を選びます。

```text
テストを実行して、結果を教えてください。
```

<details>
<summary>解答例</summary>

`bash tests/test_todo.sh` を実行してよいかの確認が表示されます。**Yes** を選ぶと、Claude がテストの結果（成功した件数と失敗した件数）をまとめて報告します。
**Yes, and don't ask again for: ...** を選ぶと、次から同じコマンドは確認なしで実行されるようになります。どちらを選んでも構いません。

</details>

### 演習 A1-3: 変更を確認して取り消す

1. 次のように頼み、確認が表示されたら **Yes** を選びます。

   ```text
   README.md の最初の見出しの下に、このツールを一言で説明する 1 行を追加してください。
   ```

2. VS Code の **ソース管理** ビューで `README.md` をクリックし、差分を確認します。
3. 変更を取り消します。次のどれかの方法で取り消してみましょう。
   - ソース管理ビューで `README.md` の **変更を破棄**（Discard Changes）をクリックする
   - 統合ターミナルで `git restore README.md` を実行する（Claude Code を `/exit` で終了するか、別のターミナルを開いて実行します）
   - Claude Code で <kbd>Esc</kbd> を 2 回押し、変更する前の時点を選んで戻す

<details>
<summary>解答例</summary>

どの方法でも、`README.md` は変更前の状態に戻ります。`git status` を実行して、`nothing to commit, working tree clean` と表示されれば元どおりです。

```bash
git status
```

</details>

## まとめ

- Claude Code は、ファイルの読み書きやコマンドの実行を自分で行う AI のコーディングエージェント
- Pro / Max プランでログインし、VS Code の統合ターミナルで `claude` を起動して使う
- 学習中は Manual モードで、Claude の操作を 1 つずつ確認する
- 変更は差分で確認し、Git を安全網にする。確認をすべて飛ばすモードは使わない

---

[← 前の章: 発展編の目次](README.md) ｜ [目次](../../README.md) ｜ [次の章: CLAUDE.md と AGENTS.md →](02-claude-md.md)
