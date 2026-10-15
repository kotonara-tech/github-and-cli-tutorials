# CLI 練習用ファイル

[第 1 章「CLI の基本」](../../docs/01-cli-basics.md) の演習で使うファイルです。
ファイルの中身を書き換えても問題ありません。元に戻したくなったら、リポジトリのルートで次のコマンドを実行します（意味は第 2 章で学びます）。

```bash
git restore samples/cli-practice
```

## ファイル一覧

```text
cli-practice/
├── access.log             # Web サーバーのアクセスログ（架空のデータ）
├── fruits.txt             # 果物の名前のリスト（重複あり）
├── scores.csv             # テストの点数（CSV 形式）
└── notes/                 # メモのディレクトリ
    ├── 2026/
    │   ├── 04-meeting.md
    │   ├── 05-meeting.md
    │   └── ideas.txt
    └── archive/
        └── 2025-memo.txt
```

## 演習

まず、このディレクトリに移動しておきます。

```bash
cd ~/github-and-cli-tutorials/samples/cli-practice
```

### 演習 1: ファイルを眺める

1. `ls -l` でファイルの一覧を表示し、それぞれのファイルサイズを確認してください。
2. `notes` ディレクトリの中にあるファイルを、サブディレクトリも含めてすべて表示してください。
3. `access.log` の最初の 3 行と最後の 3 行を表示してください。

<details>
<summary>解答例</summary>

```bash
ls -l
ls -R notes          # または find notes
head -n 3 access.log
tail -n 3 access.log
```

</details>

### 演習 2: 数える・並べ替える

1. `fruits.txt` は何行ありますか？
2. `fruits.txt` に出てくる果物を、重複を除いて並べてください。
3. それぞれの果物が何回出てくるかを数え、多い順に並べてください。

<details>
<summary>解答例</summary>

```bash
wc -l fruits.txt                         # 10 行
sort fruits.txt | uniq                   # 6 種類
sort fruits.txt | uniq -c | sort -rn     # りんご が 3 回で最多
```

`uniq` は「**隣り合った** 同じ行」をまとめるコマンドなので、先に `sort` で並べ替えておくのがポイントです。

</details>

### 演習 3: 探す

1. `access.log` から、ステータスコードが `404` の行だけを表示してください。
2. `notes` ディレクトリの中から、`TODO` と書かれた行をすべて探してください（ファイル名と行番号も表示）。
3. `notes` ディレクトリの中から、拡張子が `.md` のファイルを探してください。

<details>
<summary>解答例</summary>

```bash
grep ' 404$' access.log      # $ は「行の末尾」を表します
grep -rn TODO notes          # -r: ディレクトリの中も探す、-n: 行番号を表示
find notes -name '*.md'
```

</details>

### 演習 4: 組み合わせる（パイプ）

1. `scores.csv` から数学（`math`）の点数が最も高い人の行を表示してください。
2. `access.log` で、アクセス数の多い IP アドレス順に回数を表示してください（IP アドレスは 3 列目です）。
3. 演習 4-2 の結果を `ip-ranking.txt` というファイルに保存し、`cat` で中身を確認してください。

<details>
<summary>解答例</summary>

```bash
grep math scores.csv | sort -t, -k3 -n -r | head -n 1
# → takahashi,math,95

cut -d' ' -f3 access.log | sort | uniq -c | sort -rn
# → 192.0.2.10 が 5 回で最多

cut -d' ' -f3 access.log | sort | uniq -c | sort -rn > ip-ranking.txt
cat ip-ranking.txt
```

- `sort -t, -k3 -n -r`: 区切り文字を `,` にして（`-t,`）、3 列目で（`-k3`）、数値として（`-n`）、逆順に（`-r`）並べ替えます。
- `cut -d' ' -f3`: 区切り文字をスペースにして、3 列目だけを取り出します。

</details>

### 演習 5: 作る・コピーする・消す

1. `practice` というディレクトリを作り、その中に `memo.txt` を作って「CLI の練習中」と書き込んでください。
2. `memo.txt` を `memo-backup.txt` という名前でコピーしてください。
3. `memo-backup.txt` を `notes/archive/` に移動してください。
4. 最後に、`practice` ディレクトリと、移動した `memo-backup.txt` を削除してください。

<details>
<summary>解答例</summary>

```bash
mkdir practice
echo "CLI の練習中" > practice/memo.txt
cat practice/memo.txt

cp practice/memo.txt practice/memo-backup.txt
mv practice/memo-backup.txt notes/archive/

rm -r practice
rm notes/archive/memo-backup.txt
```

`rm` で消したファイルはゴミ箱に入らず、**元に戻せません**。実行前に、消す対象を `ls` で確認する習慣を付けましょう。

</details>
