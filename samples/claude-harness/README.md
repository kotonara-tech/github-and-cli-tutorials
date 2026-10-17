# claude-harness: Claude Code のハーネスの完成例

[発展編](../../docs/claude-code/README.md) で、練習用リポジトリ（`todo-cli-practice`）に作る **ハーネス**（Claude Code を安全に、確実に動かすための設定ファイル一式）の完成例です。
各章の演習では、まず自分で作ってから、このディレクトリのファイルと見比べてください。

## ファイルの構成

```text
claude-harness/
├── README.md                          # このファイル
├── template/                          # 練習用リポジトリのルートに置くファイル
│   ├── AGENTS.md                      # AI エージェント向けの、プロジェクトの決まり（第 2 章）
│   ├── CLAUDE.md                      # AGENTS.md を取り込み、Claude Code だけの補足を書く（第 2 章）
│   └── .claude/
│       ├── settings.json              # 権限の設定とフック（第 5 章）
│       ├── hooks/
│       │   ├── shellcheck-on-edit.sh  # .sh を編集したら shellcheck を実行するフック（第 5 章）
│       │   ├── readonly-bash.sh       # test-reviewer に読み取りだけのコマンドを実行させるフック（第 4 章）
│       │   └── lib/json.sh            # フックが受け取る JSON から値を取り出す関数
│       ├── skills/
│       │   ├── tdd-todo/SKILL.md      # /tdd-todo: テストリスト（TODO.md）を作る（第 4 章）
│       │   └── tdd-go/SKILL.md        # /tdd-go: TDD の 1 サイクルを回す（第 4 章）
│       └── agents/
│           └── test-reviewer.md       # テストをレビューする subagent（第 4 章）
└── tests/
    └── test_hooks.sh                  # フックのスクリプトのテスト（この教材の CI 用）
```

`tests/` は、この教材のリポジトリでフックのスクリプトを確かめるためのものです。練習用リポジトリにはコピーしません。

## 使い方

**練習用リポジトリに、同じ名前のファイルがないかを先に確認してください。** 自分で作ったファイルがある場合は、上書きせずに、見比べて必要な部分だけを書き写します。

```bash
cd ~/git-practice/todo-cli-practice

# 見比べる（左が完成例、右が自分のファイル）
code --diff ~/github-and-cli-tutorials/samples/claude-harness/template/AGENTS.md AGENTS.md
```

まだ作っていないファイルは、コピーして使えます。`cp -i` は、同じ名前のファイルがあるときに、上書きしてよいかを聞いてくれます（`n` で上書きしません）。

```bash
cd ~/git-practice/todo-cli-practice
cp -i ~/github-and-cli-tutorials/samples/claude-harness/template/AGENTS.md .
cp -i ~/github-and-cli-tutorials/samples/claude-harness/template/CLAUDE.md .
mkdir -p .claude
cp -R -i ~/github-and-cli-tutorials/samples/claude-harness/template/.claude/. .claude/
```

コピーしたら、`git status` で追加されたファイルを確認し、作業用のブランチでコミットして、Pull Request でマージします。

> [!NOTE]
> `.claude/settings.json` の「許可」（`allow`）の設定は、Claude Code でそのフォルダーを信頼したあとに有効になります（[発展編 第 1 章](../../docs/claude-code/01-setup.md#a14-初めて起動する)）。
> フックを使うには、`shellcheck` コマンドが必要です（[発展編 第 1 章](../../docs/claude-code/01-setup.md#a13-インストールする)）。

## このディレクトリで Claude Code を使うときの注意

この教材のリポジトリで Claude Code を使い、このディレクトリのファイルを読ませると、Claude Code は `template/` の中の `CLAUDE.md` や skill も読み込むことがあります。
教材そのものを編集するときは、そのことを意識してください。

## テスト

フックのスクリプトのテストは、この教材のリポジトリのルートで、次のように実行します（`shellcheck` が必要です）。

```bash
bash samples/claude-harness/tests/test_hooks.sh
```
