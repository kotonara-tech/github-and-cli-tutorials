# 第 7 章: 開発フローの総合演習

ここまでに学んだ Issue・ブランチ・Pull Request を組み合わせて、実際の開発と同じ流れで機能を追加します。
この流れは **GitHub Flow** と呼ばれ、多くのチームで使われているシンプルな開発の進め方です。

## この章のゴール

- [ ] GitHub Flow の流れを説明できる
- [ ] Issue の作成からマージ・後片付けまでを、資料を見ずに一通り実行できる
- [ ] 複数の機能を、それぞれ別の Issue・ブランチ・Pull Request で進められる
- [ ] （チームで学ぶ場合）他の人の Pull Request をレビューし、コンフリクトを解消できる

**所要時間の目安:** 90〜180 分

## 7.1 GitHub Flow

```mermaid
flowchart TD
  A["① Issue を作る・担当する"] --> B["② main から作業ブランチを作る"]
  B --> C["③ 実装・テスト・コミット"]
  C --> D["④ push して Pull Request を作る"]
  D --> E{"⑤ レビュー・CI"}
  E -- "修正が必要" --> C
  E -- "承認・成功" --> F["⑥ main にマージする"]
  F --> G["⑦ ブランチを削除し、手元の main を更新する"]
  G --> A
```

GitHub Flow のルールは、次の 4 つだけです。

1. **`main` ブランチは常に正しく動く状態に保つ**
2. 作業は **`main` から作ったブランチ** で行う
3. ブランチは **こまめに push** し、作業内容を共有する
4. **Pull Request でレビューと CI を通してから** `main` にマージする

## 7.2 総合演習: delete コマンドを追加する

[第 5 章](05-issue.md) で作った Issue #2「タスクを削除する delete コマンドを追加したい」に取り組みます。
各ステップのコマンドは、これまでの章を見返しながら、なるべく自分で考えて実行してみましょう。

### 仕様

```text
$ ./todo.sh list
  1 [ ] 牛乳を買う
  2 [x] 部屋を掃除する
  3 [ ] 本を読む
$ ./todo.sh delete 2
削除しました: 部屋を掃除する
$ ./todo.sh list
  1 [ ] 牛乳を買う
  2 [ ] 本を読む
$ ./todo.sh delete 5
エラー: 5 番のタスクはありません（todo.sh list で番号を確認してください）
```

- `delete <番号>` で、指定した番号のタスクを削除する（完了・未完了どちらでも）
- 番号が数字でない、または存在しない番号の場合はエラーにして、終了コード 1 で終わる
- `help` の表示と `README.md` の「使い方」に `delete` を追加する

### ステップ 1: Issue を確認して担当する

```bash
cd ~/git-practice/todo-cli-practice
gh issue view 2
gh issue edit 2 --add-assignee @me
```

### ステップ 2: 最新の main からブランチを作る

```bash
git switch main
git pull
git switch -c feature/2-delete-command
```

> [!TIP]
> `gh issue develop 2 --name feature/2-delete-command --checkout` を使うと、Issue と関連付けられたブランチを GitHub 上に作り、手元に切り替えるところまで一度に行えます。

### ステップ 3: テストを書き、実装する

1. `tests/test_todo.sh` に `delete` のテストを追加します（`# 結果` の区切り線の直前）。
2. テストが失敗することを確認します。
3. `todo.sh` に `cmd_delete` 関数を追加し、`main` 関数の `case` 文と `usage` 関数を更新します。
4. テストがすべて成功することを確認します。
5. `README.md` の「使い方」を更新します。

**コミットは、意味のあるまとまりごとに分けましょう。** 例えば次のように分けられます。

```bash
git add tests/test_todo.sh todo.sh
git commit -m "タスクを削除する delete コマンドを追加"
git add README.md
git commit -m "README に delete コマンドの使い方を追加"
```

<details>
<summary>テストの例</summary>

```bash
# ---------------------------------------------------------------------------
# delete
# ---------------------------------------------------------------------------

reset_todo
run_todo add "牛乳を買う"
run_todo add "部屋を掃除する"
run_todo add "本を読む"
run_todo "done" 2
run_todo delete 2
assert_equal "delete は終了コード 0 で終わる" 0 "$STATUS"
assert_equal "delete は削除したタスクを表示する" "削除しました: 部屋を掃除する" "$OUTPUT"
expected=$(printf '[ ] 牛乳を買う\n[ ] 本を読む')
assert_equal "delete は指定したタスクだけを削除する" "$expected" "$(cat "$TODO_FILE")"

for bad in 0 3 abc; do
  run_todo delete "$bad"
  assert_equal "delete に不正な番号（${bad}）を渡すと終了コード 1 で終わる" 1 "$STATUS"
done
```

</details>

<details>
<summary>実装の例</summary>

`todo.sh` の `main()` 関数の直前に、次の関数を追加します。番号のチェックは `cmd_done` と同じです。

```bash
# 指定した番号のタスクを削除する
cmd_delete() {
  if [ $# -ne 1 ]; then
    die "削除するタスクの番号を 1 つ指定してください（例: todo.sh delete 1）"
  fi
  case "$1" in
    '' | *[!0-9]*) die "番号は数字で指定してください: $1" ;;
  esac
  local num=$((10#$1))

  local total=0
  if [ -f "$TODO_FILE" ]; then
    total=$(wc -l <"$TODO_FILE" | tr -d ' ')
  fi
  if [ "$num" -lt 1 ] || [ "$num" -gt "$total" ]; then
    die "${num} 番のタスクはありません（todo.sh list で番号を確認してください）"
  fi

  local line
  line=$(sed -n "${num}p" "$TODO_FILE")

  local tmp
  tmp=$(mktemp "${TODO_FILE}.XXXXXX")
  awk -v n="$num" 'NR != n' "$TODO_FILE" >"$tmp"
  mv "$tmp" "$TODO_FILE"
  echo "削除しました: ${line#\[?\] }"
}
```

- `awk -v n="$num" 'NR != n'` は「行番号（`NR`）が `n` ではない行だけを出力する」、つまり `n` 行目を取り除く処理です。
- `${line#\[?\] }` は、行の先頭の `[ ]` または `[x]` と、その後ろの空白を取り除いた文字列です（`?` は任意の 1 文字）。

`main()` の `case` 文と、`usage()` のヘルプにも追加します。

```bash
    done) cmd_done "$@" ;;
    delete | rm) cmd_delete "$@" ;;
```

```text
  done <番号>   指定した番号のタスクを完了にする
  delete <番号> 指定した番号のタスクを削除する（rm でも可）
```

</details>

### ステップ 4: push して Pull Request を作る

```bash
git push -u origin feature/2-delete-command
gh pr create
```

- タイトル: `タスクを削除する delete コマンドを追加`
- 本文: テンプレートに沿って記入し、**`Closes #2`** を忘れずに書く

### ステップ 5: セルフレビューと CI の確認

```bash
gh pr checks
gh pr view --web
```

Files changed タブで、次の点を自分で確認しましょう。

- [ ] 関係のない変更（空白だけの変更、デバッグ用の `echo` など）が入っていない
- [ ] `help` と `README.md` の説明が実装と一致している
- [ ] CI が成功している

### ステップ 6: マージする

```bash
gh pr merge --squash --delete-branch
```

### ステップ 7: 後片付け

```bash
git switch main       # gh pr merge --delete-branch を使った場合は切り替え済み
git pull
git log --oneline -5
gh issue view 2       # Closed になっていることを確認
```

## 7.3 チャレンジ課題

同じ流れで、次の機能を 1 つずつ追加してみましょう。**1 つの機能につき、1 つの Issue・1 つのブランチ・1 つの Pull Request** です。
慣れてきたら、資料を見ずに「Issue → マージ → 後片付け」まで進められるか試してみてください。

| 課題 | 仕様 | ヒント |
| --- | --- | --- |
| `undone <番号>` | 完了したタスクを未完了に戻す | `cmd_done` の `[ ]` と `[x]` を逆にする |
| `count` | `未完了: 2 件 / 完了: 1 件` のように件数を表示する | `grep -c '^\[ \]'` で数えられる。0 件のとき `grep -c` は終了コード 1 になることに注意 |
| `clear` | 完了したタスクをすべて削除する | `grep -v '^\[x\]'` で完了以外の行だけを残す |
| `search <キーワード>` | キーワードを含むタスクだけを、元の番号付きで表示する | `grep -n -F` で行番号付きで探せる |
| リファクタリング | `cmd_done` と `cmd_delete` で重複している番号のチェックを、1 つの関数にまとめる | ブランチ名は `refactor/...`。動作は変えずに、テストがすべて成功することを確認する |

> [!TIP]
> 複数の機能を同時に進めると、`usage()` や `main()` の `case` 文で **コンフリクト** が起きることがあります。
> そのときは、作業ブランチに最新の `main` を取り込んで解消します。
>
> ```bash
> git switch feature/xxx
> git fetch
> git merge origin/main      # コンフリクトしたら第 4 章の手順で解消する
> bash tests/test_todo.sh
> git push
> ```
>
> 簡単なコンフリクトなら、Pull Request の画面の「**Resolve conflicts**」ボタンから、ブラウザ上で解消することもできます。

## 7.4 チームで練習する

2〜4 人で学んでいる場合は、1 つのリポジトリを共有して開発してみましょう。レビューやコンフリクトなど、1 人では体験しにくいことを練習できます。

### 準備

1. 代表者 1 人が、[第 5 章](05-issue.md#52-練習用リポジトリを準備する) の手順で練習用リポジトリ（例: `todo-cli-team`）を作ります。
2. 代表者が **Settings → Collaborators → Add people** から、メンバーを招待します。
3. 招待されたメンバーは、届いたメール（または <https://github.com/notifications>）から招待を承認し、リポジトリを clone します。

   ```bash
   cd ~/git-practice
   gh repo clone <代表者のユーザー名>/todo-cli-team
   ```

### ブランチを保護する（任意）

`main` に直接 push できないようにし、「Pull Request の承認と CI の成功」をマージの条件にできます。

1. **Settings → Rules → Rulesets** を開き、「**New ruleset**」→「**New branch ruleset**」を選びます。
2. **Ruleset Name** に `main を保護` などの名前を付け、**Enforcement status** を `Active` にします。
3. **Target branches** の「**Add target**」から「**Include default branch**」を選び、`main` を対象にします。
4. 次の項目を有効にします。
   - **Require a pull request before merging**（Pull Request を必須にする）
     - **Required approvals**: `1`（1 人以上の承認を必須にする）
   - **Require status checks to pass**（CI の成功を必須にする）→「**Add checks**」から `test` を追加
5. 「**Create**」で保存します。

> [!NOTE]
> ブランチの保護は、**公開リポジトリ** であれば無料プランで使えます。非公開リポジトリで使うには、有料プラン（GitHub Pro / Team など）が必要です。

### 進め方

1. [samples/todo-cli/README.md の「練習用の課題」](../samples/todo-cli/README.md#練習用の課題) や [7.3](#73-チャレンジ課題) の課題を、全員で Issue にします。
2. 各自が Issue を選び、自分を **Assignee** にしてから作業を始めます。
3. Pull Request を作ったら、他のメンバーを **Reviewers** に指定します。
4. レビューを依頼された人は、`gh pr checkout <番号>` で手元でも動作を確認し、コメントや Approve をします。
5. 承認されたら、**作成者が** マージします。
6. 他の人の Pull Request がマージされたら、自分の作業ブランチに `main` を取り込み、コンフリクトがあれば解消します。

### わざとコンフリクトを起こしてみる

2 人が同時に、`usage()` のヘルプの同じ場所（`done` の行の下）に別々のコマンドを追加すると、後からマージする方の Pull Request で必ずコンフリクトが起きます。
先にマージされた方の変更を取り込んで、両方のコマンドが使えるように解消してみましょう。

## 7.5 振り返り

次の質問に、自分の言葉で答えられるか確認しましょう。

- [ ] なぜ `main` に直接コミットせず、ブランチと Pull Request を使うのか
- [ ] 良い Issue・良い Pull Request には何が書かれているか
- [ ] CI が失敗したとき、どこを見て何をすればよいか
- [ ] push が拒否されたとき、コンフリクトが起きたとき、それぞれどうするか
- [ ] マージした後に手元で何をするか

## まとめ

- GitHub Flow は「`main` から作ったブランチで作業し、Pull Request でレビューと CI を通してからマージする」シンプルな開発フロー
- 1 つの目的に、1 つの Issue・1 つのブランチ・1 つの Pull Request
- テストを書き、CI で自動確認することで、`main` を常に正しく動く状態に保つ
- チームでは、担当者を明確にし、お互いにレビューし合う

お疲れさまでした。これで、GitHub を使った基本的な開発の流れを一通り体験できました。
困ったときは [第 8 章: 困ったときは](08-troubleshooting.md) と [付録](../README.md#付録) を参照してください。

---

[← 前の章: Pull Request](06-pull-request.md) ｜ [目次](../README.md) ｜ [次の章: 困ったときは →](08-troubleshooting.md)
