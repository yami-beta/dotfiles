---
name: project-setup
description: プロジェクトに Claude Code のハーネス（permissions・hooks・CLAUDE.md）を導入する。「プロジェクトをセットアップ」「ハーネスを敷く」「.claude を整備」などの要求時、または新しいプロジェクトで検証コマンドの許可プロンプトが頻発しているときに使用。
---

# プロジェクトハーネスのセットアップ

対象プロジェクトのスタックを検出し、エージェントが「止まらず・自己検証しながら」動けるようにプロジェクトローカルの `.claude/settings.json` と CLAUDE.md を整備する。

## Context

$ARGUMENTS

## Workflow

### Step 1: スタックの検出

プロジェクトルートの以下のファイルを確認し、言語・パッケージマネージャ・検証コマンドを特定する:

- `package.json`: `scripts` から test / lint / typecheck / build / format コマンドを読み取る。`packageManager` フィールドや lockfile（`pnpm-lock.yaml` / `package-lock.json` / `yarn.lock` / `bun.lockb`）からパッケージマネージャを判定
- `Cargo.toml`（Rust）: `cargo test` / `cargo clippy` / `cargo fmt`
- `go.mod`（Go）: `go test ./...` / `go vet ./...` / `gofmt`
- `Package.swift` / `*.xcodeproj`（Swift）: `swift test` / `swiftformat` / `swiftlint`
- フォーマッタ・リンタ設定: `.prettierrc*` / `biome.json` / `eslint.config.*` / `.swiftformat` など
- CI 設定（`.github/workflows/*.yml`）: CI が実際に実行している検証コマンドを正とする

検出結果（スタック・検証コマンドの一覧）をユーザーに提示してから次へ進む。

### Step 2: permissions の提案

検出した**読み取り・検証系コマンドのみ**を `.claude/settings.json` の `permissions.allow` として提案する。

```json
{
  "permissions": {
    "allow": [
      "Bash(pnpm test*)",
      "Bash(pnpm run lint*)",
      "Bash(pnpm run typecheck*)",
      "Bash(pnpm run build*)"
    ]
  }
}
```

- 書き込み・公開・削除を伴うコマンド（deploy、publish、db migrate 等）は allow に含めない
- 過去のセッションが十分あるプロジェクトでは、組み込みスキル `/fewer-permission-prompts` によるトランスクリプト分析も選択肢として案内する

### Step 3: hooks の提案（必要な場合のみ）

ユーザーに hooks の要否を確認し、希望があれば提案する。hooks は毎回決定的に実行したい処理にのみ使い、判断が必要な処理はスキルや CLAUDE.md の指針に任せる。

代表パターン（正確な構文で生成すること）:

**編集後の自動フォーマット**（フォーマッタ設定が存在する場合。コマンドは Step 1 で検出したパッケージマネージャに合わせる。例は pnpm）:

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Edit|Write",
        "hooks": [
          {
            "type": "command",
            "command": "jq -r '.tool_input.file_path' | { read f; case \"$f\" in *.ts|*.tsx) pnpm exec prettier --write \"$f\" >/dev/null 2>&1 || true;; esac; }",
            "timeout": 30
          }
        ]
      }
    ]
  }
}
```

構文の要点:

- イベント（`PreToolUse` / `PostToolUse` / `Stop` 等）→ `matcher`（ツール名の正規表現）→ `hooks` 配列の構造
- フックコマンドは stdin で JSON（`tool_name`, `tool_input.file_path` 等）を受け取る
- exit code 2 + stderr でエージェントにフィードバックを返す（ブロック）。それ以外の非ゼロは警告扱い
- フォーマット等の best-effort 処理は失敗しても exit 0 で抜け、エージェントをブロックしない
- 参考: https://code.claude.com/docs/en/hooks

### Step 4: プロジェクト CLAUDE.md の提案（存在しない場合のみ）

最小構成に留める（長い CLAUDE.md は毎セッションのコンテキストを消費するため）:

- ビルド・テスト・lint の実行コマンド
- ディレクトリ構成の要点（非自明なもののみ）
- プロジェクト固有の規約・制約（コードを読めば分かることは書かない）

検証ステップを追加する scaffolding（「非自明な変更では最終検証ステップを入れる」「サブエージェントで検証する」等）は書かない。モデルは指示なしで自己検証するため、過剰検証になる。

### Step 5: 確認と書き込み

1. 生成する全ファイルの内容と配置先を提示し、AskUserQuestion で承認を得る
2. 既存の `.claude/settings.json` や CLAUDE.md がある場合は上書きせず、差分をマージ提案する
3. `settings.json` は書き込み後に JSON として妥当か確認する（`jq . .claude/settings.json`）
4. permissions / hooks はセッション起動時に読み込まれるため、反映には新しいセッション（または再起動）が必要である旨を案内する

## 注意事項

- `.claude/settings.json` はリポジトリ共有（コミット対象）、`.claude/settings.local.json` は個人用（gitignore 推奨）。チームリポジトリでは共有してよい設定か確認する
- allow ルールは「エージェントの検証ループを止めないため」のもの。迷ったら allow に入れず、通常の許可プロンプトに任せる
