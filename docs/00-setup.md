# 第 0 章: 環境構築

この教材で使うツールをインストールし、教材のリポジトリを手元に用意します。
ここで実行するコマンドの意味は、後の章で少しずつ説明します。今は「手順どおりに打ち込めば OK」と考えてください。

## この章のゴール

- [ ] ターミナルを開ける
- [ ] `git --version` でバージョンが表示される
- [ ] GitHub アカウントを持っている
- [ ] `gh --version` でバージョンが表示される
- [ ] `gh auth status` で「Logged in」と表示される
- [ ] 教材リポジトリが `~/github-and-cli-tutorials` にある

**所要時間の目安:** 30〜60 分

## 0.1 ターミナルを開く

**ターミナル** は、文字でコンピュータに命令（コマンド）を送るためのアプリです。
OS ごとに開き方が違います。

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

## 0.7 エディタを用意する

ファイルを編集するために、テキストエディタを用意します。迷ったら **Visual Studio Code（VS Code）** がおすすめです。

1. <https://code.visualstudio.com/> からダウンロードしてインストールします。
2. ターミナルから `code` コマンドで開けるようにします。
   - **macOS**: VS Code でコマンドパレット（<kbd>Command</kbd> + <kbd>Shift</kbd> + <kbd>P</kbd>）を開き、「Shell Command: Install 'code' command in PATH」を実行します。
   - **Windows（WSL2）**: VS Code に拡張機能「WSL」をインストールします。Ubuntu のターミナルで `code .` と打つと、WSL2 の中のファイルを開けます。
   - **Linux**: 通常はインストールするだけで `code` コマンドが使えます。
3. 確認します。

   ```bash
   code --version
   ```

ターミナルの中で動くエディタ（`nano` や `vim`）の使い方は [第 1 章](01-cli-basics.md) で紹介します。

## 確認チェックリスト

次のコマンドをすべて実行して、エラーが出なければ準備完了です。

```bash
git --version
gh --version
gh auth status
ls ~/github-and-cli-tutorials
```

うまくいかないときは [第 8 章: 困ったときは](08-troubleshooting.md) を見るか、講師に質問してください。

---

[目次](../README.md) ｜ [次の章: CLI の基本 →](01-cli-basics.md)
