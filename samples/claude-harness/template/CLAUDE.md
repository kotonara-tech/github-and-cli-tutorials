@AGENTS.md

## Claude Code 向けの補足

- TDD は skill で進める: `/tdd-todo <Issue 番号>` でテストリストを作り、`/tdd-go` で 1 サイクルずつ進める
- テストのレビューは `test-reviewer` サブエージェントに任せる
- `.sh` ファイルを編集すると、フックで shellcheck が自動で実行される。警告が返ってきたら、次に進む前に直す
