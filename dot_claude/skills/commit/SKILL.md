---
name: commit
description: gitコミットを作成する。変更の確認、コミットメッセージの作成、コミット実行までを一貫して行う。「コミットを作成」「変更をコミット」「git commit」などの要求時に使用。
allowed-tools: Bash(git status *), Bash(git diff *), Bash(git log *), Bash(git add *), Bash(git commit *), Bash(git branch *), Bash(git switch *), Bash(git symbolic-ref *)
---

# Gitコミットを作成

## Context

$ARGUMENTS

## Workflow

### Step 1: 変更の確認

- 現在のブランチ: !`git branch --show-current`
- デフォルトブランチ: !`git symbolic-ref --short refs/remotes/origin/HEAD 2>/dev/null`
- コミット履歴: !`git log --oneline -20 2>/dev/null`
- 変更ファイルの一覧を確認: !`git status`
- ステージされていない変更を確認: !`git diff`
- ステージされた変更を確認: !`git diff --staged`

変更（staged / unstaged / untracked）が一切ない場合は、コミット対象がない旨を報告してワークフローを終了する。

### Step 2: ブランチを作成

- 現在のブランチがデフォルトブランチと異なる場合
    - トピックブランチ上なので **Step 3** へ進む
- 現在のブランチがデフォルトブランチの場合
   - コミット履歴を分析してリポジトリのワークフローを判定
       - トピックブランチ運用（`Merge`コミットが含まれている、または件名末尾に `(#123)` のような PR 番号がある = squash merge の痕跡）→ **Step 2.1** へ進む
       - 直接コミットスタイル（上記のいずれも見られない）→ **Step 3** へ進む
       - 判断材料が乏しい場合（コミット履歴が数件以下の新規リポジトリなど）は安全側に倒し **Step 2.1** へ進む

#### Step 2.1: トピックブランチの作成

デフォルトブランチへの直接コミットは避け、トピックブランチを作成する。

1. Step 1で確認した変更内容から適切なブランチ名を生成
   - 例: `feat/add-xxx`, `fix/resolve-yyy`, `docs/update-readme`
2. ブランチを作成してチェックアウト
   ```bash
   git switch -c <branch-name>
   ```
3. **Step 3** へ進む

### Step 3: コミットメッセージの作成

変更内容を分析し、適切なコミットメッセージを作成する。

基本フォーマット:
```
<type>[scope]: <description>

[optional body]
```

#### type の選び方

Conventional Commits に従い、変更の性質で type を選ぶ。リポジトリに確立した慣習があればそれを優先しつつ、以下を基準にする:

- `feat`: 新機能
- `fix`: バグ修正
- `build`: ビルドシステムや**外部依存**の変更（依存の追加/更新/削除、lockfile、パッケージマネージャ設定など）
- `ci`: CI 設定・ワークフローの変更
- `docs`: ドキュメントのみ
- `refactor`: 挙動を変えないコード整理
- `test`: テストの追加・修正
- `style`: フォーマット等（挙動・意味に影響しない）
- `perf`: パフォーマンス改善
- `chore`: 上記のいずれにも当てはまらない雑多な変更

#### 本文（body）に含める内容

会話履歴を振り返り、以下の情報を本文にまとめて記載する:

- **変更の動機・背景**: なぜこの変更が必要になったか
- **設計判断とその理由**: 技術的な選択とその根拠
- **却下した代替案**: 検討したが採用しなかったアプローチとその理由
- **ユーザーからのフィードバックによる方針変更**: 当初の方針から変更があった場合、その経緯

#### GitHubのリンクを掲載するとき

**同一リポジトリ**の issue/PR を参照する場合は、通常の `#123` 形式（または `https://github.com/{org}/{repo}/issues/123` のフルURL）を使う。`redirect.github.com` は使わない。
`Fixes #123` / `Closes #123` / `Resolves #123` などのクローズキーワードは、同一リポジトリ内の `#123` 形式かフルURLでのみ GitHub に認識され、マージ時に issue が自動クローズされる。`redirect.github.com` 経由にすると認識されず自動クローズされない。

**他のGitHubリポジトリ**（作業リポジトリが `github.com/yami-beta/{repo}` の場合の別 `{org}/{repo}`）の issue 等へのリンクは以下のように変更する。
例: `https://github.com/{org}/{repo}/issues/1` は `https://redirect.github.com/{org}/{repo}/issues/1` とする

`redirect.github.com` を使うことでリンク先に参照元として表示されることを防止できる（他リポジトリへのバックリンク通知を避ける目的であり、同一リポジトリの参照には不要かつ弊害がある）
https://docs.github.com/en/get-started/writing-on-github/working-with-advanced-formatting/autolinked-references-and-urls#avoiding-backlinks-to-linked-references

### Step 4: 変更のステージングとコミット

```bash
git add <files>
git commit -m "<message>"
```

### Step 5: 結果の確認

```bash
git status
git log --oneline -3
```

## 注意事項

- コミット前に必ず `git diff` で変更内容を確認する
- `.env` やシークレットを含むファイルはコミットしない
- 大きな変更は論理的な単位で分割してコミットする
- `--amend` や `--force` は明示的に指示された場合のみ使用する
