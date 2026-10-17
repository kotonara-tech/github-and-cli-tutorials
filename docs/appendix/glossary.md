# 付録: 用語集

この教材に出てくる用語を、分野ごとにまとめています。

## CLI・シェル

| 用語 | 意味 |
| --- | --- |
| **引数（ひきすう）** | コマンドに渡す値。`ls docs` の `docs` |
| **オプション** | コマンドの動作を変える指定。`-l` や `--help` など |
| **カレントディレクトリ** | 今いるディレクトリ。`pwd` で確認できる |
| **環境変数** | シェルやコマンドが参照する設定値。`$HOME`、`$PATH` など |
| **絶対パス / 相対パス** | ルート（`/`）からの道のり / 今いる場所からの道のり |
| **終了コード** | コマンドの実行結果を表す数値。`0` が成功、それ以外は失敗 |
| **シェル** | 入力したコマンドを解釈して実行するプログラム。`bash` や `zsh` など |
| **ターミナル** | シェルを操作するためのアプリ |
| **ディレクトリ** | ファイルをまとめる入れ物。「フォルダ」と同じ |
| **パイプ** | `\|` でコマンドの出力を次のコマンドの入力に渡す仕組み |
| **パーミッション** | ファイルの読み取り（r）・書き込み（w）・実行（x）の権限 |
| **プロンプト** | コマンドの入力を待っていることを示す表示（`$` など） |
| **ホームディレクトリ** | ユーザーごとの作業場所。`~` で表す |
| **リダイレクト** | `>` や `>>` でコマンドの出力をファイルに書き込む仕組み |
| **CLI** | Command Line Interface。文字でコマンドを入力して操作する方法 |
| **PATH** | コマンドを探すディレクトリの一覧を持つ環境変数 |
| **WSL** | Windows Subsystem for Linux。Windows の中で Linux を動かす仕組み |

## Git

| 用語 | 意味 |
| --- | --- |
| **インデックス** | ステージングエリアの別名 |
| **コミット** | ある時点のファイルの状態を記録したもの。またはそれを記録する操作 |
| **コミットハッシュ** | コミットを識別する ID（`1d5c4826ef...` のような英数字。先頭 7 文字程度で指定できる） |
| **コンフリクト（競合）** | 2 つのブランチで同じ箇所が変更されていて、自動でマージできない状態 |
| **ステージング / ステージングエリア** | 次のコミットに含める変更を選ぶこと / その変更を置いておく場所 |
| **スタッシュ** | コミットしていない変更を一時的に退避する機能 |
| **ブランチ** | コミットの流れを枝分かれさせる仕組み。特定のコミットを指す名札 |
| **マージ** | ブランチの変更を別のブランチに取り込むこと |
| **マージコミット** | 2 つのブランチを合流させたときに作られるコミット |
| **リバート** | 指定したコミットの変更を打ち消すコミットを作ること |
| **リベース** | ブランチのコミットを、別のコミットの先に付け替えること |
| **リポジトリ** | Git で管理しているファイルと履歴のまとまり |
| **リモートリポジトリ / ローカルリポジトリ** | サーバー上のリポジトリ / 自分の PC の中のリポジトリ |
| **リモート追跡ブランチ** | `origin/main` のような、最後に fetch したときのリモートのブランチの状態 |
| **ワーキングツリー** | 実際にファイルを編集している場所 |
| **fast-forward** | 新しいコミットを作らず、ブランチの位置を前に進めるだけのマージ |
| **HEAD** | 今いるブランチ（またはコミット）を指す特別な名札 |
| **main** | 多くのリポジトリで使われる、本流のブランチの名前（以前は `master` が一般的だった） |
| **origin** | clone 元のリモートリポジトリに付く、慣習的な名前 |
| **.gitignore** | Git の管理から外すファイルを指定するファイル |

## GitHub

| 用語 | 意味 |
| --- | --- |
| **コラボレーター** | リポジトリへの書き込み権限を与えられたユーザー |
| **フォーク** | 他の人のリポジトリを、自分のアカウントにコピーしたもの |
| **マイルストーン** | 期限や目標ごとに Issue や Pull Request をまとめる機能 |
| **メンション** | `@ユーザー名` と書いて、その人に通知すること |
| **ラベル** | Issue や Pull Request を分類するためのタグ |
| **レビュー** | Pull Request の変更内容を確認し、コメントや承認をすること |
| **Actions（GitHub Actions）** | テストなどを自動で実行する GitHub の機能 |
| **Approve** | レビューで変更を承認すること |
| **Assignee** | Issue や Pull Request の担当者 |
| **CI** | Continuous Integration（継続的インテグレーション）。変更のたびにテストなどを自動で実行し、問題を早く見つける仕組み |
| **Draft Pull Request** | 作業中であることを示す、下書きの Pull Request |
| **gh（GitHub CLI）** | GitHub の操作をターミナルから行うためのツール |
| **GitHub Flow** | `main` からブランチを作り、Pull Request でマージするシンプルな開発の流れ |
| **Issue** | バグ・要望・タスクなど「やるべきこと」を管理する機能 |
| **Organization** | 複数のユーザーでリポジトリを共有・管理するための組織アカウント |
| **Pull Request（PR）** | ブランチの変更を取り込んでもらうための提案。レビューや CI を行う場 |
| **README** | リポジトリの説明を書くファイル。GitHub のトップページに表示される |
| **Squash and merge** | Pull Request のコミットを 1 つにまとめてマージする方法 |

## VS Code

画面の場所は、[第 0 章の「画面の各部分の名前」](../00-setup.md#画面の各部分の名前) も参照してください。

| 用語 | 意味 |
| --- | --- |
| **アクティビティ バー**（Activity Bar） | 画面の左端のアイコンの列。エクスプローラーやソース管理などを切り替える（[公式](https://code.visualstudio.com/docs/editing/getting-started/userinterface)） |
| **エクスプローラー**（Explorer） | 開いたフォルダの中のファイルを木の形で表示し、作成・名前の変更・削除ができるビュー（[公式](https://code.visualstudio.com/docs/editing/getting-started/userinterface#_explorer-view)） |
| **エディター**（Editor） | ファイルの中身を表示・編集する中央の領域。開いたファイルはタブで並ぶ（[公式](https://code.visualstudio.com/docs/editing/getting-started/userinterface)） |
| **拡張機能**（Extensions） | VS Code に機能を追加するプログラム（[0.9](../00-setup.md#09-拡張機能を追加する)・[公式](https://code.visualstudio.com/docs/configure/extensions/extension-marketplace)） |
| **コマンド パレット**（Command Palette） | VS Code のすべての機能を名前で検索して実行できる入力欄。<kbd>Ctrl</kbd> + <kbd>Shift</kbd> + <kbd>P</kbd>（macOS は <kbd>Command</kbd> + <kbd>Shift</kbd> + <kbd>P</kbd>）で開く（[公式](https://code.visualstudio.com/docs/editing/getting-started/userinterface#_command-palette)） |
| **差分エディター**（Diff Editor） | 変更前と変更後のファイルを左右に並べて、違いを色分けして表示するエディター（[第 2 章](../02-git-basics.md#変更内容を確認するgit-diff)・[公式](https://code.visualstudio.com/docs/sourcecontrol/overview)） |
| **ステータス バー**（Status Bar） | 画面の下端の帯。今のブランチ名や改行コード（`LF` / `CRLF`）などが表示される（[公式](https://code.visualstudio.com/docs/editing/getting-started/userinterface)） |
| **ソース管理**（Source Control） | 変更の確認・ステージ・コミット・push などの Git の操作を画面で行うビュー（[公式](https://code.visualstudio.com/docs/sourcecontrol/overview)） |
| **タスク**（Tasks） | テストの実行などのよく使うコマンドを、名前を付けて登録し、VS Code から実行する仕組み。`.vscode/tasks.json` に書く（[第 6 章](../06-pull-request.md#まずテストを書く)・[公式](https://code.visualstudio.com/docs/debugtest/tasks)） |
| **統合ターミナル**（Integrated Terminal） | VS Code の中で使えるターミナル。この教材のコマンドはここで実行する（[0.8](../00-setup.md#統合ターミナルを開く)・[公式](https://code.visualstudio.com/docs/terminal/basics)） |
| **マージ エディター**（Merge Editor） | コンフリクトを、2 つのブランチの内容と結果の 3 つの画面で見比べながら解消するエディター（[第 4 章](../04-branch.md#45-コンフリクト競合を解消する)・[公式](https://code.visualstudio.com/docs/sourcecontrol/merge-conflicts)） |
| **ワークスペース**（Workspace） | VS Code で開いているフォルダ。そのフォルダだけに効く設定や推奨する拡張機能を `.vscode/` に保存できる（[公式](https://code.visualstudio.com/docs/editing/workspaces/workspaces)） |
| **ワークスペースの信頼 / 制限モード**（Workspace Trust / Restricted Mode） | 信頼したフォルダだけで、すべての機能を有効にする仕組み / 信頼していないフォルダを開いたときの、一部の機能（Git の操作やタスクなど）が動かない状態（[0.8](../00-setup.md#フォルダを信頼する制限モードを解除する)・[公式](https://code.visualstudio.com/docs/editing/workspaces/workspace-trust)） |

## Claude Code（発展編）

| 用語 | 意味 |
| --- | --- |
| **AGENTS.md** | さまざまな AI のコーディングエージェントが読む、エージェント向けのプロジェクトの説明ファイル（[発展編 第 2 章](../claude-code/02-claude-md.md)・[agents.md](https://agents.md/)） |
| **auto モード** | 別の AI（分類器）が危険な操作だけを止め、それ以外は確認なしで進める権限モード。安全を保証するものではない（[発展編 第 5 章](../claude-code/05-harness.md#a52-権限モード)・[公式](https://code.claude.com/docs/ja/permission-modes)） |
| **CLAUDE.md** | Claude Code が会話の始めに必ず読み込む、プロジェクトの決まりを書くファイル（[発展編 第 2 章](../claude-code/02-claude-md.md)・[公式](https://code.claude.com/docs/ja/memory)） |
| **Claude Code** | Anthropic の AI のコーディングエージェント。ファイルの読み書きやコマンドの実行を自分で行う（[発展編 第 1 章](../claude-code/01-setup.md)・[公式](https://code.claude.com/docs/ja/overview)） |
| **effort** | Claude がどれだけ念入りに考えて取り組むかの度合い。`low` から `max` まである（[発展編 第 3 章](../claude-code/03-models-and-effort.md)・[公式](https://code.claude.com/docs/ja/model-config)） |
| **Manual モード** | ファイルの編集やコマンドの実行の前に、毎回確認する権限モード。設定上の名前は `default`（[発展編 第 1 章](../claude-code/01-setup.md#学習中は-manual-モードで始める)） |
| **plan モード** | ファイルを変更せずに、調べて計画を立てる権限モード（[発展編 第 5 章](../claude-code/05-harness.md#a53-plan-モードで計画してから実装する)） |
| **skill** | 名前を付けて呼び出せる、Claude への手順書。`.claude/skills/<名前>/SKILL.md` に書く（[発展編 第 4 章](../claude-code/04-skills-and-agents.md)・[公式](https://code.claude.com/docs/ja/skills)） |
| **subagent（サブエージェント）** | 自分専用の会話で作業する、役割を持った別の Claude。`.claude/agents/<名前>.md` に書く（[発展編 第 4 章](../claude-code/04-skills-and-agents.md)・[公式](https://code.claude.com/docs/ja/sub-agents)） |
| **エージェントループ**（agentic loop） | AI のエージェントが「情報を集める → 行動する → 結果を確かめる」を繰り返して作業を進めること（[公式](https://code.claude.com/docs/ja/how-claude-code-works)） |
| **検証ループ** | テストなど、成功か失敗かを返すチェックを使って、Claude が自分で結果を確かめながら作業を進める仕組み（[発展編 第 5 章](../claude-code/05-harness.md#a56-ループの設計検証ループ)） |
| **コンテキスト** | Claude が覚えておける会話の内容。量に限りがあり、いっぱいになるほど指示を忘れやすくなる（[公式](https://code.claude.com/docs/ja/best-practices)） |
| **ハーネス**（harness） | AI のモデルの周りで、使える道具や渡す情報を管理する仕組み。発展編では、Claude Code を安全に、確実に動かすための設定ファイル一式を指す（[発展編](../claude-code/README.md)） |
| **フック**（hook） | Claude Code が決まったタイミング（ファイルの編集の直後など）で必ず実行するコマンド（[発展編 第 5 章](../claude-code/05-harness.md#a55-フックで必ず実行する)・[公式](https://code.claude.com/docs/ja/hooks-guide)） |
| **モデル** | Claude の種類（Opus、Sonnet、Haiku など）。どれだけ賢いかを決める（[発展編 第 3 章](../claude-code/03-models-and-effort.md)） |

## テスト駆動開発（TDD）

| 用語 | 意味 |
| --- | --- |
| **Green** | TDD で、失敗していたテストを、最小限のコードで成功させる段階 |
| **Red** | TDD で、テストを 1 つ書き、それが期待どおりの理由で失敗することを確かめる段階 |
| **Refactor（リファクタリング）** | 動作を変えずに、コードの設計を整えること。TDD では、すべてのテストが成功している間だけ行う |
| **テスト駆動開発（TDD）** | テストリストから 1 つ選び、Red → Green → Refactor を繰り返して開発する進め方（[発展編 第 6 章](../claude-code/06-tdd.md)） |
| **テストリスト（TODO リスト）** | TDD で確かめたい振る舞いを、チェックボックス付きで書き出したリスト。進める途中で気づいたことも追加する |
| **仮実装**（Fake It） | テストが期待する値をそのまま返すコードで、まずテストを成功させること |
| **三角測量**（Triangulation） | 2 つ以上の具体例のテストから、一般化した実装を導くこと |
| **明白な実装**（Obvious Implementation） | 実装が明らかなときに、正しい実装をそのまま書くこと |

---

[← Git チートシート](git-cheatsheet.md) ｜ [目次](../../README.md) ｜ [コミットメッセージの書き方 →](commit-message.md)
