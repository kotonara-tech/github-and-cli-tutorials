# 第 0 章: 環境構築

この教材で使うツールをインストールし、教材のリポジトリを手元に用意します。
後半では、この教材で作業に使う **VS Code** をインストールし、画面の見方と用語、追加する拡張機能を確認します。
ここで実行するコマンドの意味は、後の章で少しずつ説明します。今は「手順どおりに打ち込めば OK」と考えてください。

## この章のゴール

- [ ] ターミナルを開ける
- [ ] `git --version` でバージョンが表示される
- [ ] GitHub アカウントを持っている
- [ ] `gh --version` でバージョンが表示される
- [ ] `gh auth status` で「Logged in」と表示される
- [ ] 教材リポジトリが `~/github-and-cli-tutorials` にある
- [ ] VS Code で教材のフォルダを開き、統合ターミナルでコマンドを実行できる
- [ ] この教材で使う VS Code の拡張機能をインストールした

**所要時間の目安:** 60〜90 分

## 0.1 ターミナルを開く

**ターミナル** は、文字でコンピュータに命令（コマンド）を送るためのアプリです。
OS ごとに開き方が違います。0.7 で VS Code を用意した後は、VS Code の中のターミナル（統合ターミナル）を使いますが、それまではここで開くターミナルを使います。

### macOS

1. <kbd>Command</kbd> + <kbd>Space</kbd> で Spotlight を開きます。
2. 「ターミナル」または「Terminal」と入力して <kbd>Enter</kbd> を押します。

### Linux（Ubuntu など）

<kbd>Ctrl</kbd> + <kbd>Alt</kbd> + <kbd>T</kbd> で開けることが多いです。
開けない場合は、アプリケーション一覧から「端末」または「Terminal」を探してください。

### Windows

Windows では **WSL2（Windows Subsystem for Linux）** を使い、Windows の中で Linux（Ubuntu）を動かします。
この教材のコマンドは、すべて WSL2 の Ubuntu で実行してください。

1. スタートメニューで「PowerShell」を検索し、右クリックして「**管理者として実行**」を選びます。
2. 次のコマンドを実行します。

   ```powershell
   wsl --install
   ```

3. PC を再起動します。
4. 再起動後に Ubuntu のウィンドウが開くので、Linux 用の **ユーザー名** と **パスワード** を決めて入力します。
   パスワードは入力しても画面に何も表示されませんが、正しく入力されています。
5. 次回からは、スタートメニューで「Ubuntu」を検索して開きます。

> [!TIP]
> WSL2 では、Windows 側のフォルダ（`/mnt/c/...`）ではなく、Linux 側のホームディレクトリ（`~`）で作業しましょう。
> Windows 側のフォルダで作業すると、動作が遅くなったり改行コードの問題が起きたりします。

## 0.2 Git をインストールする

**Git** は、ファイルの変更履歴を記録・管理するためのツールです。

### macOS

ターミナルで次のコマンドを実行します。

```bash
xcode-select --install
```

ダイアログが表示されたら「インストール」を選びます。すでにインストール済みの場合はエラーが表示されますが、問題ありません。

[Homebrew](https://brew.sh/ja/) を使っている場合は、次のコマンドでも最新版をインストールできます。

```bash
brew install git
```

### Linux（Ubuntu）/ Windows（WSL2 の Ubuntu）

```bash
sudo apt update
sudo apt install -y git
```

`sudo` は「管理者の権限で実行する」という意味です。パスワードを聞かれたら、ログインパスワード（WSL2 の場合は Ubuntu の初回起動時に決めたパスワード）を入力します。

### 確認

```bash
git --version
```

出力例:

```text
git version 2.43.0
```

この教材では **Git 2.28 以上** を前提にしています。

## 0.3 GitHub アカウントを作る

**GitHub** は、Git で管理しているリポジトリをインターネット上で共有し、チームで開発するためのサービスです。

1. <https://github.com/signup> にアクセスし、画面の案内に従ってアカウントを作成します。
2. **ユーザー名** は、あなたの公開プロフィール URL（`https://github.com/<ユーザー名>`）になります。仕事でも使える名前にしておくと安心です。
3. 案内に従って **2 要素認証（2FA）** を設定します。スマートフォンの認証アプリなどを使います。

> [!NOTE]
> 教材リポジトリが非公開（Private）の場合、閲覧するには Organization（組織）のメンバーとして招待されている必要があります。
> アクセスできない場合は、講師や管理者に GitHub のユーザー名を伝えて招待を依頼してください。

## 0.4 GitHub CLI（gh）をインストールする

**GitHub CLI**（コマンド名は `gh`）は、Issue や Pull Request などの GitHub の操作をターミナルから行うためのツールです。
この教材では、ブラウザでの操作と `gh` での操作の両方を紹介します。

### macOS

```bash
brew install gh
```

### Linux（Ubuntu）/ Windows（WSL2 の Ubuntu）

公式の手順に従ってインストールします。コマンドが長いので、ページからコピーして貼り付けてください。

- 公式手順: <https://github.com/cli/cli/blob/trunk/docs/install_linux.md>（「Debian, Ubuntu Linux ...」の項目）

> [!TIP]
> ターミナルへの貼り付けは、macOS では <kbd>Command</kbd> + <kbd>V</kbd>、
> Linux や WSL2 では <kbd>Ctrl</kbd> + <kbd>Shift</kbd> + <kbd>V</kbd>（または右クリック）です。

### 確認

```bash
gh --version
```

出力例:

```text
gh version 2.89.0 (2026-03-26)
https://github.com/cli/cli/releases/tag/v2.89.0
```

## 0.5 GitHub CLI でログインする

```bash
gh auth login
```

いくつか質問されるので、矢印キーで選んで <kbd>Enter</kbd> を押します（表示は `gh` のバージョンによって少し異なります）。

| 質問 | 選ぶもの |
| --- | --- |
| Where do you use GitHub? | `GitHub.com` |
| What is your preferred protocol for Git operations on this host? | `HTTPS` |
| Authenticate Git with your GitHub credentials? | `Yes` |
| How would you like to authenticate GitHub CLI? | `Login with a web browser` |

`First copy your one-time code: XXXX-XXXX` と表示されたら、そのコードをメモして <kbd>Enter</kbd> を押します。
ブラウザが開くので、コードを入力して認証を許可します。

> [!TIP]
> WSL2 などでブラウザが自動で開かない場合は、表示された URL（`https://github.com/login/device`）を自分でブラウザに貼り付けて開いてください。

最後に、ログインできたことを確認します。

```bash
gh auth status
```

出力例:

```text
github.com
  ✓ Logged in to github.com account <あなたのユーザー名> (keyring)
  - Active account: true
  - Git operations protocol: https
```

これで、`git` コマンドも GitHub に接続できるようになりました。仕組みは [第 3 章](03-github-remote.md) で説明します。

## 0.6 教材リポジトリを手元に用意する

ホームディレクトリに移動して、教材のリポジトリをダウンロード（**clone**）します。

```bash
cd ~
gh repo clone kotonara-tech/github-and-cli-tutorials
```

`~/github-and-cli-tutorials` というディレクトリができていれば成功です。

```bash
ls ~/github-and-cli-tutorials
```

出力例:

```text
CONTRIBUTING.md  README.md  docs  exercises  samples
```

> [!NOTE]
> 教材の内容が更新されたときは、次のコマンドで最新の状態にできます（[第 3 章](03-github-remote.md) で学ぶ `git pull` です）。
>
> ```bash
> cd ~/github-and-cli-tutorials
> git pull
> ```

## 0.7 VS Code をインストールする

**Visual Studio Code（VS Code）** は、Microsoft が無料で提供しているエディタ（ファイルを編集するアプリ）です。
ファイルの編集だけでなく、ターミナルや Git の操作も 1 つの画面でできるため、この教材では **すべての演習を VS Code の中で行います**。

### インストールする

<https://code.visualstudio.com/> を開き、自分の OS 用のファイルをダウンロードしてインストールします。

- **macOS**: ダウンロードした `.zip` を開き、中の「Visual Studio Code」を「アプリケーション」フォルダに移動します。
- **Windows**: Windows 側にインストールします（WSL2 の Ubuntu の中ではありません）。インストールの途中の「追加タスクの選択」で、**PATH への追加**（Add to PATH）にチェックが入っていることを確認します。
- **Linux（Ubuntu）**: `.deb` ファイルをダウンロードし、ファイルをダブルクリックするか、`sudo apt install ./<ダウンロードしたファイル名>.deb` でインストールします。

詳しい手順は、公式ドキュメントの [macOS](https://code.visualstudio.com/docs/setup/mac)、[Windows](https://code.visualstudio.com/docs/setup/windows)、[Linux](https://code.visualstudio.com/docs/setup/linux) のページにあります。

### ターミナルから `code` コマンドで開けるようにする

ターミナルで `code <フォルダ>` と入力すると、そのフォルダを VS Code で開けるようにします。

- **macOS**: VS Code を起動し、<kbd>Command</kbd> + <kbd>Shift</kbd> + <kbd>P</kbd> で入力欄（コマンド パレット）を開きます。`shell command` と入力し、「**Shell Command: Install 'code' command in PATH**」を選んで <kbd>Enter</kbd> を押します。その後、ターミナルを一度閉じて開き直します。
- **Windows（WSL2）**: 次の手順で、WSL2 の中のファイルを VS Code で開けるようにします。
  1. VS Code を起動し、左端のアイコンの列から **Extensions**（四角が 4 つ並んだアイコン）を選びます。
  2. 検索欄に `ms-vscode-remote.remote-wsl` と入力し、「**WSL**」（発行元: Microsoft）の **Install** をクリックします。
  3. Ubuntu のターミナルを開き直し、`code .` と入力します。初回は「Installing VS Code Server」と表示され、準備が終わると VS Code が開きます。
  4. VS Code の左下に「**WSL: Ubuntu**」と表示されていれば、WSL2 の中のフォルダを開けています。
- **Linux**: インストールするだけで `code` コマンドが使えます。

確認します。

```bash
code --version
```

バージョン番号などが 3 行表示されれば成功です。

### 表示を日本語にする

この教材は、VS Code の表示を日本語にしていることを前提に説明します。

1. 左端のアイコンの列から **Extensions** を選び、検索欄に `MS-CEINTL.vscode-language-pack-ja` と入力します。
2. 「**Japanese Language Pack for Visual Studio Code**」（発行元: Microsoft）の **Install** をクリックします。
3. 右下に表示される「**Change Language and Restart**」をクリックすると、VS Code が再起動して日本語の表示になります。

右下の通知を閉じてしまった場合は、コマンド パレットで `display language` と入力して「**Configure Display Language**」を選び、「日本語」を選んで再起動します（[公式ドキュメント](https://code.visualstudio.com/docs/configure/locales)）。

> [!NOTE]
> 日本語化の拡張機能は VS Code 本体より少し遅れて更新されるため、新しい機能のボタンなどは英語のまま表示されることがあります。
> この教材では「**ソース管理**（Source Control）」のように英語の表示も添えているので、見つからないときは英語の名前でも探してください。

### GitHub CLI のエディタを VS Code にする

`gh` コマンドで Issue や Pull Request の本文を書くときに開くエディタを、VS Code にしておきます（設定しないと、ターミナルの中で動くエディタ `nano` が開きます）。

```bash
gh config set editor "code --wait"
```

`--wait` は「VS Code でファイルを閉じるまで、コマンドの続きを待つ」という意味です。Git のエディタも [第 2 章](02-git-basics.md) で同じように設定します。

## 0.8 VS Code の画面と用語

### 教材のフォルダを開く

VS Code では、**作業するフォルダを丸ごと開いて** 使います。0.6 で用意した教材のフォルダを開いてみましょう。

#### VS Code で操作する

1. メニューの **ファイル**（File）> **フォルダーを開く...**（Open Folder...）を選びます。
2. ホームディレクトリの中の `github-and-cli-tutorials` を選び、**開く** をクリックします。
   Windows の場合は、先にコマンド パレットで「**WSL: Connect to WSL**」を実行して WSL2 に接続してから、フォルダを選びます。

#### コマンドで操作する

```bash
code ~/github-and-cli-tutorials
```

### フォルダを信頼する（制限モードを解除する）

初めて開いたフォルダは **制限モード**（Restricted Mode）で開き、画面の上に「制限モードは、安全なコード参照のためのものです。…」と表示されます。
制限モードは、インターネットから入手した知らないフォルダの中のプログラムが勝手に動かないようにする仕組みです。この状態では、Git の操作（ソース管理）やタスクの実行など、一部の機能が動きません。

自分で用意したフォルダや、教材のフォルダは信頼して構いません。

1. 画面上部の表示の **管理**（Manage）をクリックします（表示が見つからないときは、コマンド パレットで「**ワークスペースの信頼を管理**」を実行します）。
2. 「ワークスペースの信頼」の画面で、**信頼する**（Trust）をクリックします。

同じ画面の「**信頼済みフォルダーとワークスペース**」で **フォルダーの追加** をクリックしてフォルダを選ぶと、そのフォルダの中（サブフォルダを含む）がすべて信頼されます。
[第 2 章](02-git-basics.md) で練習用のフォルダ `~/git-practice` を作ったら、ここに追加しておくと、練習用のリポジトリを開くたびに信頼する手間が省けます。

> [!WARNING]
> インターネットから入手した、中身を確認していないフォルダは信頼しないでください。詳しくは [公式ドキュメント: Workspace Trust](https://code.visualstudio.com/docs/editing/workspaces/workspace-trust) を参照してください。

### 画面の各部分の名前

この教材でよく出てくる、VS Code の画面の部分と機能の名前です。今すぐすべてを覚える必要はありません。分からなくなったときに、この表に戻ってきてください。

| 用語 | 場所と役割 | 公式ドキュメント |
| --- | --- | --- |
| **アクティビティ バー**（Activity Bar） | 画面の左端に縦に並ぶアイコンの列。エクスプローラー、検索、ソース管理、拡張機能などを切り替えます | [User Interface](https://code.visualstudio.com/docs/editing/getting-started/userinterface) |
| **サイド バー**（Primary Side Bar） | アクティビティ バーで選んだビューを表示する、左側の領域です | [User Interface](https://code.visualstudio.com/docs/editing/getting-started/userinterface) |
| **エクスプローラー**（Explorer） | 開いたフォルダの中のファイルとフォルダを、木の形で表示するビューです。ファイルの作成・名前の変更・削除もできます | [Explorer view](https://code.visualstudio.com/docs/editing/getting-started/userinterface#_explorer-view) |
| **エディター**（Editor） | ファイルの中身を表示・編集する、中央の領域です。開いたファイルは **タブ** で並びます | [User Interface](https://code.visualstudio.com/docs/editing/getting-started/userinterface) |
| **プレビュー モード**（Preview mode） | エクスプローラーでファイルを 1 回クリックすると、タブの名前が斜体で表示され、別のファイルを開くとそのタブが置き換わります。ダブルクリックするか編集すると、タブが固定されます | [Preview mode](https://code.visualstudio.com/docs/editing/getting-started/userinterface#_preview-mode) |
| **パネル**（Panel） | エディターの下の領域です。**ターミナル**、**問題**（Problems）、**出力**（Output）などのタブがあります | [User Interface](https://code.visualstudio.com/docs/editing/getting-started/userinterface) |
| **統合ターミナル**（Integrated Terminal） | VS Code の中で使えるターミナルです。この教材のコマンドは、すべてここで実行します | [Terminal Basics](https://code.visualstudio.com/docs/terminal/basics) |
| **ステータス バー**（Status Bar） | 画面の下端の帯です。左側に今のブランチ名や WSL の接続先、右側に改行コード（`LF` / `CRLF`）や文字コードが表示されます | [User Interface](https://code.visualstudio.com/docs/editing/getting-started/userinterface) |
| **コマンド パレット**（Command Palette） | VS Code のすべての機能を、名前で検索して実行できる入力欄です | [Command Palette](https://code.visualstudio.com/docs/editing/getting-started/userinterface#_command-palette) |
| **クイック オープン**（Quick Open） | ファイル名の一部を入力して、ファイルをすばやく開く入力欄です | [User Interface](https://code.visualstudio.com/docs/editing/getting-started/userinterface) |
| **ソース管理**（Source Control） | Git の操作（変更の確認、ステージ、コミット、push など）を画面で行うビューです。[第 2 章](02-git-basics.md) から使います | [Source Control](https://code.visualstudio.com/docs/sourcecontrol/overview) |
| **Git の印**（Git decorations） | エクスプローラーのファイル名の右に表示される文字と色です。`U` は Git がまだ管理していない新しいファイル、`M` は変更されたファイル、`D` は削除されたファイルを表します | [Source Control](https://code.visualstudio.com/docs/sourcecontrol/overview) |
| **拡張機能**（Extensions） | VS Code に機能を追加するプログラムです。拡張機能ビューで検索してインストールします | [Extension Marketplace](https://code.visualstudio.com/docs/configure/extensions/extension-marketplace) |
| **設定**（Settings） | VS Code の動作を変える項目です。VS Code 全体に効く **ユーザー** の設定と、開いているフォルダだけに効く **ワークスペース** の設定があります | [Settings](https://code.visualstudio.com/docs/configure/settings) |
| **ワークスペース**（Workspace） | VS Code で開いているフォルダのことです。設定や推奨する拡張機能を、フォルダの中の `.vscode/` に保存できます | [Workspaces](https://code.visualstudio.com/docs/editing/workspaces/workspaces) |
| **ワークスペースの信頼**（Workspace Trust） | 信頼したフォルダだけで、すべての機能を有効にする仕組みです。信頼していないフォルダは **制限モード** で開きます | [Workspace Trust](https://code.visualstudio.com/docs/editing/workspaces/workspace-trust) |
| **自動保存**（Auto Save） | 編集したファイルを、自動で保存する機能です（0.10 で設定します） | [Save / Auto Save](https://code.visualstudio.com/docs/editing/codebasics#_save-auto-save) |
| **Markdown プレビュー** | `.md` ファイルを、GitHub で見るのに近い見た目で表示する機能です。この教材も、プレビューで読むと読みやすくなります | [Markdown preview](https://code.visualstudio.com/docs/languages/markdown#_markdown-preview) |

画面の右側に **チャット**（Chat）が表示されることがありますが、本編では使いません。右上の × で閉じて構いません（[発展編](claude-code/README.md) では、AI のコーディングエージェントの Claude Code を使います）。

### よく使うキー操作

| 操作 | Windows / Linux | macOS |
| --- | --- | --- |
| コマンド パレットを開く | <kbd>Ctrl</kbd> + <kbd>Shift</kbd> + <kbd>P</kbd>（または <kbd>F1</kbd>） | <kbd>Command</kbd> + <kbd>Shift</kbd> + <kbd>P</kbd> |
| ファイルを名前で開く（クイック オープン） | <kbd>Ctrl</kbd> + <kbd>P</kbd> | <kbd>Command</kbd> + <kbd>P</kbd> |
| ファイルを保存する | <kbd>Ctrl</kbd> + <kbd>S</kbd> | <kbd>Command</kbd> + <kbd>S</kbd> |
| ターミナルを表示する / 隠す | <kbd>Ctrl</kbd> + <kbd>&#96;</kbd> | <kbd>Control</kbd> + <kbd>&#96;</kbd> |
| エクスプローラーを開く | <kbd>Ctrl</kbd> + <kbd>Shift</kbd> + <kbd>E</kbd> | <kbd>Command</kbd> + <kbd>Shift</kbd> + <kbd>E</kbd> |
| ソース管理を開く | <kbd>Ctrl</kbd> + <kbd>Shift</kbd> + <kbd>G</kbd> | <kbd>Control</kbd> + <kbd>Shift</kbd> + <kbd>G</kbd> |
| 拡張機能を開く | <kbd>Ctrl</kbd> + <kbd>Shift</kbd> + <kbd>X</kbd> | <kbd>Command</kbd> + <kbd>Shift</kbd> + <kbd>X</kbd> |
| 設定を開く | <kbd>Ctrl</kbd> + <kbd>,</kbd> | <kbd>Command</kbd> + <kbd>,</kbd> |
| Markdown のプレビューを開く | <kbd>Ctrl</kbd> + <kbd>Shift</kbd> + <kbd>V</kbd> | <kbd>Command</kbd> + <kbd>Shift</kbd> + <kbd>V</kbd> |
| サイド バーを表示する / 隠す | <kbd>Ctrl</kbd> + <kbd>B</kbd> | <kbd>Command</kbd> + <kbd>B</kbd> |

ターミナルのキー（<kbd>&#96;</kbd> はバッククォート）は、日本語配列のキーボードでは <kbd>Ctrl</kbd> + <kbd>@</kbd> になることがあります。うまくいかないときは、メニューの **表示**（View）> **ターミナル**（Terminal）を使ってください。

すべてのキー操作は、公式の一覧表（[Windows](https://code.visualstudio.com/shortcuts/keyboard-shortcuts-windows.pdf)・[macOS](https://code.visualstudio.com/shortcuts/keyboard-shortcuts-macos.pdf)・[Linux](https://code.visualstudio.com/shortcuts/keyboard-shortcuts-linux.pdf)、PDF）や、[公式ドキュメント: Keyboard shortcuts](https://code.visualstudio.com/docs/configure/keybindings) で確認できます。

### 統合ターミナルを開く

メニューの **ターミナル**（Terminal）> **新しいターミナル**（New Terminal）を選ぶと、パネルにターミナルが開きます。開いているフォルダが、最初のカレントディレクトリになります。

```bash
pwd
```

出力例（Linux / WSL2 の場合。macOS では `/Users/<あなたのユーザー名>/github-and-cli-tutorials` になります）:

```text
/home/<あなたのユーザー名>/github-and-cli-tutorials
```

パネルの右上のターミナルの名前が `bash` または `zsh` になっていれば準備完了です。

> [!WARNING]
> Windows で `powershell` や `cmd` と表示される場合は、VS Code が WSL2 に接続されていません。
> 左下に「**WSL: Ubuntu**」と表示されていることを確認し、表示されていなければ、Ubuntu のターミナルで `code ~/github-and-cli-tutorials` を実行して開き直してください。

ターミナルの種類（シェル）を変えたいときは、ターミナルの **+** の横の **∨** から「**既定のプロファイルの選択**」（Select Default Profile）で選べます（[公式ドキュメント: Terminal Profiles](https://code.visualstudio.com/docs/terminal/profiles)）。

## 0.9 拡張機能を追加する

この教材で使う拡張機能をインストールします。

| 拡張機能 | 何に使うか | 使う章 | ID |
| --- | --- | --- | --- |
| [Japanese Language Pack for Visual Studio Code](https://marketplace.visualstudio.com/items?itemName=MS-CEINTL.vscode-language-pack-ja) | 表示を日本語にします（0.7 でインストール済み） | すべて | `MS-CEINTL.vscode-language-pack-ja` |
| [WSL](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-wsl) | WSL2 の中のフォルダを開きます（**Windows のみ**。0.7 でインストール済み） | すべて | `ms-vscode-remote.remote-wsl` |
| [GitHub Pull Requests](https://marketplace.visualstudio.com/items?itemName=GitHub.vscode-pull-request-github) | Issue や Pull Request の作成・レビュー・マージを、VS Code の中で行います | 第 5〜7 章 | `GitHub.vscode-pull-request-github` |
| [ShellCheck](https://marketplace.visualstudio.com/items?itemName=timonwong.shellcheck) | シェルスクリプトの間違いやすい書き方を、編集中に波線で教えてくれます | 第 6〜7 章 | `timonwong.shellcheck` |
| [EditorConfig for VS Code](https://marketplace.visualstudio.com/items?itemName=EditorConfig.EditorConfig) | リポジトリの `.editorconfig` に書かれた決まり（改行コードやインデント）に合わせて保存します | すべて | `EditorConfig.EditorConfig` |
| [markdownlint](https://marketplace.visualstudio.com/items?itemName=DavidAnson.vscode-markdownlint) | Markdown の書き方の誤りを教えてくれます（**任意**） | README などを書くとき | `DavidAnson.vscode-markdownlint` |

[発展編](claude-code/README.md) では、さらに [Claude Code for VS Code](https://marketplace.visualstudio.com/items?itemName=anthropic.claude-code)（`anthropic.claude-code`）を使います。今はインストールしなくて構いません。

### VS Code で操作する

1. アクティビティ バーの **拡張機能**（Extensions）を選びます（<kbd>Ctrl</kbd> + <kbd>Shift</kbd> + <kbd>X</kbd>、macOS は <kbd>Command</kbd> + <kbd>Shift</kbd> + <kbd>X</kbd>）。
2. 検索欄に、表の **ID** を入力します（名前が似た拡張機能がたくさんあるので、ID で探すと確実です）。
3. 発行元が表と同じであることを確認し、**インストール**（Install）をクリックします。

Windows で WSL2 に接続しているときは、ボタンが「**WSL: Ubuntu にインストールする**」のように表示されることがあります。そのままクリックしてください（WSL2 の中で動く拡張機能は、WSL2 の側にインストールする必要があります）。

### コマンドで操作する

統合ターミナルで、次のコマンドを実行してもインストールできます。

```bash
code --install-extension GitHub.vscode-pull-request-github
code --install-extension timonwong.shellcheck
code --install-extension EditorConfig.EditorConfig
code --install-extension DavidAnson.vscode-markdownlint
```

インストールされている拡張機能の一覧は、次のコマンドで確認できます。

```bash
code --list-extensions
```

出力例（順番や、ほかの拡張機能の有無は環境によって異なります）:

```text
davidanson.vscode-markdownlint
editorconfig.editorconfig
github.vscode-pull-request-github
timonwong.shellcheck
```

### おすすめの拡張機能の通知

リポジトリに `.vscode/extensions.json` があると、フォルダを開いたときに「このリポジトリ 用のおすすめ拡張機能 … をインストールしますか?」という通知が表示されます。
この教材のリポジトリや、[第 5 章](05-issue.md) で作る練習用リポジトリにも用意してあるので、通知が出たら **インストール** をクリックしてください（[公式ドキュメント: Workspace recommended extensions](https://code.visualstudio.com/docs/configure/extensions/extension-marketplace#_workspace-recommended-extensions)）。

### 入れなくてよい拡張機能

Git の履歴をグラフで表示する「Git Graph」や、多機能な「GitLens」は人気がありますが、この教材では使いません。
VS Code には、コミットの履歴をグラフで表示する **ソース管理グラフ** や、ファイルごとの履歴を表示する **タイムライン** が最初から入っているためです。
初めのうちは、画面に表示されるものが少ないほうが、Git の仕組みを理解しやすくなります。

## 0.10 VS Code の初期設定

### 自動保存を有効にする

ファイルを編集したあと、保存し忘れたまま Git の操作やテストを実行すると、「変更したのに反映されない」という混乱のもとになります。編集した内容が自動で保存されるようにしておきましょう。

#### VS Code で操作する

メニューの **ファイル**（File）> **自動保存**（Auto Save）を選び、チェックを入れます。

#### 設定ファイルで操作する

コマンド パレットで「**基本設定: ユーザー設定を開く (JSON)**」（Preferences: Open User Settings (JSON)）を実行すると、ユーザーの設定ファイル `settings.json` が開きます。次のように `"files.autoSave": "afterDelay"` を追加して保存します。

```json
{
  "files.autoSave": "afterDelay"
}
```

すでにほかの設定が書かれている場合は、前の行の末尾に `,`（カンマ）を付けてから、`{ }` の中に 1 行追加します。

設定画面（<kbd>Ctrl</kbd> + <kbd>,</kbd>、macOS は <kbd>Command</kbd> + <kbd>,</kbd>）で `auto save` と検索して変えることもできます。画面での設定と `settings.json` は同じものを表しています（[公式ドキュメント: Settings](https://code.visualstudio.com/docs/configure/settings)）。

### Git の自動フェッチはオフのままにする

VS Code には、GitHub の最新の状態を定期的に取得する「自動フェッチ」（`git.autofetch`）という設定があります。
この教材では、[第 3 章](03-github-remote.md) で「`git fetch` で取得してから、内容を確認して取り込む」流れを学ぶため、**オフのまま**（初期値のまま）にしておきます。

## 確認チェックリスト

次のコマンドを VS Code の統合ターミナルで実行して、エラーが出なければ準備完了です。

```bash
git --version
gh --version
gh auth status
code --version
code --list-extensions
ls ~/github-and-cli-tutorials
```

あわせて、次のことも確認してください。

- [ ] VS Code の表示が日本語になっている
- [ ] 教材のフォルダを VS Code で開き、制限モードを解除した
- [ ] 統合ターミナルのシェルが `bash` または `zsh` になっている

うまくいかないときは [第 8 章: 困ったときは](08-troubleshooting.md) を見るか、講師に質問してください。

---

[目次](../README.md) ｜ [次の章: CLI の基本 →](01-cli-basics.md)
