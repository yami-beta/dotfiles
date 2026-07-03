---
name: pr-merge
description: Pull Requestをマージする。マージ前にCIチェックとレビュー状態を確認し、リポジトリのマージ設定に応じた方法でマージする。「PRをマージ」「プルリクエストをマージ」などの要求時に使用。
allowed-tools: Bash(gh pr merge *), Bash(gh pr view *), Bash(gh pr checks *), Bash(gh pr status *), Bash(gh repo view *), Bash(git fetch *), Skill(pr-monitor), AskUserQuestion
argument-hint: [pr-number]
---

# Pull Request マージワークフロー

## Context

- pr-number: $ARGUMENTS（未指定の場合は現在のブランチに紐づく Pull Request が対象）
- 許可されているマージ方法: !`gh repo view --json mergeCommitAllowed,squashMergeAllowed,rebaseMergeAllowed`

## Workflow

### Step 1: マージ前の状態確認

対象 PR の状態を確認する:

```bash
gh pr view <pr-number> --json title,url,state,mergeable,reviewDecision
gh pr checks <pr-number>
```

- `state` が `OPEN` 以外（`MERGED` / `CLOSED`）の場合: マージ対象外としてその旨を報告して終了する
- `mergeable` が `CONFLICTING` の場合: コンフリクトの解消が必要な旨を報告して終了する
- チェックに pending がある場合: `AskUserQuestion` で「CI の完了を待ってからマージするか」を問い、「待つ」が選ばれたら `Skill(pr-monitor)` で完了を待ち、全チェック pass を確認してから Step 2 へ進む。「待たない」が選ばれたら現状を報告して終了する（pending のままのマージ続行はユーザーの明示的な指示があった場合のみ）
- チェックに失敗がある、または `reviewDecision` が `CHANGES_REQUESTED` の場合: マージせずその内容を報告して終了する。続行はユーザーの明示的な指示があった場合のみ
- すべて問題なければ Step 2 へ進む

### Step 2: マージ方法の決定

上記Contextの「許可されているマージ方法」を確認し、以下の優先順位で採用する:
1. Merge commit (`--merge`)
2. Squash merge (`--squash`)
3. Rebase merge (`--rebase`)

### Step 3: Pull Requestをマージ

マージは取り消せない操作のため、実行前に `AskUserQuestion` で対象 PR（タイトル・URL）とマージ方法を提示し、ユーザーの確認を得る。

確認が取れたらマージを実行する:

```bash
gh pr merge <pr-number> <merge-method> --delete-branch
```

- `<merge-method>` には Step 2 で決定した方法（`--merge` / `--squash` / `--rebase`）を指定する
- pr-number が指定されていない場合は省略する（現在のブランチの PR が対象になる）
- `--delete-branch` によりローカル・リモートのトピックブランチが削除される（対象ブランチをチェックアウトしている場合はデフォルトブランチへの切り替えも行われる）

### Step 4: クリーンアップ

リモート追跡ブランチをクリーンアップする:

```bash
git fetch --prune
```
