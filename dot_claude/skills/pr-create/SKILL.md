---
name: pr-create
description: Pull Requestを作成する。未コミットの変更があればコミットし、リモートへプッシュしてPRを作成する。「PRを作成」「プルリクエストを作成」などの要求時に使用。
allowed-tools: Bash(git status *), Bash(git log *), Bash(git diff *), Bash(git push *), Bash(git switch *), Bash(git fetch *), Bash(gh pr create *), Bash(gh pr view *), Bash(gh repo view *), Read, Glob, Skill(commit), Skill(pr-monitor), AskUserQuestion
---

# Pull Request 作成ワークフロー

## Context

$ARGUMENTS

## Workflow

### Step 1: 未コミットの差分を確認

変更ファイルの一覧: !`git status --short`

- 未コミットの差分なし: Step 2へ進む
- 未コミットの差分あり: `Skill(commit)` でブランチ、コミット作成後、Step 2へ進む

### Step 2: ブランチと既存 PR の確認

- ベースブランチ（デフォルトブランチ）を取得する:
  ```bash
  gh repo view --json defaultBranchRef -q .defaultBranchRef.name
  git fetch origin <base>
  ```
- ベースブランチとの差分がない場合（`git log origin/<base>..HEAD` が空）: PR にする変更がない旨を報告して終了する
- 現在のブランチがデフォルトブランチの場合: デフォルトブランチからの PR は作成しない。変更内容から適切な名前（例: `feat/add-xxx`, `fix/resolve-yyy`, `docs/update-readme`）でトピックブランチを作成（`git switch -c <branch-name>`）してから Step 3 へ進む。この場合ローカルのデフォルトブランチにコミットが残り origin と分岐したままになるため、その旨をユーザーに報告する
- 現在のブランチに紐づく PR を確認する:
  ```bash
  gh pr view --json url,state
  ```
  - open な PR が既にある場合: 新規作成はせず、`git push` で既存 PR を更新し、その URL を報告して Step 6 へ進む（Step 3〜5 はスキップ）
  - PR がない（またはクローズ済みの）場合: Step 3 へ進む

### Step 3: リモートにプッシュしてブランチの変更内容を把握

リモートにプッシュする:

```bash
git push -u origin <branch-name>
```

ベースブランチからの全体像を把握する:

- コミット履歴: `git log --format='%h %s%n%b---' origin/<base>..HEAD`
- 差分の統計: `git diff --stat origin/<base>..HEAD`

`<base>` は Step 2 で取得したデフォルトブランチ（ローカルの base が古い可能性があるため `origin/<base>` を使う）。

### Step 4: PR タイトルとボディの作成

#### タイトル

- 70文字以内で変更の目的を簡潔に表す
- コミットが1つの場合はそのコミットメッセージの件名を流用してよい
- 複数コミットの場合は全体を包括する要約にする

#### ボディ

まず、リポジトリに PR テンプレートがあるか確認する:

- `.github/PULL_REQUEST_TEMPLATE.md`
- `.github/PULL_REQUEST_TEMPLATE/` ディレクトリ内のファイル

**テンプレートがある場合**: テンプレートの構造に従い、会話履歴とコミット履歴を振り返って各セクションを埋める。

**テンプレートがない場合**: 会話履歴とコミット履歴を振り返り、以下の構造で作成する:

- **概要**: この PR で何を実現するかを 1〜3 文で説明する
- **背景・動機**: なぜこの変更が必要になったか、解決する課題やユーザーの要求
- **アプローチ**: 採用した設計方針とその理由、却下した代替案、フィードバックによる方針変更の経緯
- **レビューポイント**: 特にレビュアーに確認してほしい箇所や判断（該当がなければ省略）

**注意事項**:
- 複数コミットの場合: コミットメッセージをそのまま貼り付けず、コミット群を俯瞰した要約とする
- 単一コミットの場合: コミットメッセージの本文を PR ボディとして流用してよい
- セクションの内容が薄い場合は無理に埋めず、該当セクションを省略する

### Step 5: Pull Request の作成

```bash
gh pr create --title "<title>" --body "<body>"
```

### Step 6: 結果の報告

作成（または更新）した Pull Request の URL を報告する。

### Step 7: CI チェックの監視

`AskUserQuestion` で「GitHub Actions のチェック完了を監視しますか？」のように問い、「監視する」「監視しない」の選択肢を提示する。「監視する」が選ばれた場合のみ `Skill(pr-monitor)` を呼び出し、対象 Pull Request のチェックが完了するまで監視し、結果を報告する。
