---
name: pr-monitor
description: PR の CI チェックの完了を Monitor ツールで監視し、各チェックが確定するたびに通知して最終結果を報告する。PR の CI 完了を待ちたいとき、マージ前に CI を確認したいとき、失敗チェックを早く知りたいときに使用する。トリガー例「PR の CI をモニター」「チェックを監視」「CI 完了を待つ」「CI 通ったら教えて」。
allowed-tools: Bash(gh pr checks *), Bash(gh pr view *), Bash(gh pr status *), ToolSearch, Monitor, TaskStop
---

# PR チェック監視

## 概要

Monitor ツールで PR の CI チェックを監視し、全チェック完了時に通知する。`gh pr checks --watch` が GitHub Actions と external checks（Codecov 等）の両方を一括で監視する。

## いつ使うか

- PR の CI 完了を待ちたいとき（マージ前の確認など）
- 失敗したチェックを早く知りたいとき
- 長時間かかるチェック（ローカル E2E ビルド等）の完了を待ち、その間ほかの作業を続けたいとき

## 前提

- `gh` が認証済みで、対象リポジトリの PR にアクセスできること

## 手順

1. **対象 PR を特定する**。ユーザーが PR 番号 / URL を指定していればそれを使う。指定がなければ現在のブランチに紐づく PR を対象にする（`gh pr checks` は引数なしで現在ブランチの PR を見る）。
2. **現在の状況を確認する**: `gh pr checks <PR>` を実行。すべて確定済み（pending なし）なら監視は不要で、手順 5 の要約だけ行って終了する。pending があれば手順 3 へ。
3. **Monitor を読み込む**: Monitor は deferred ツールのため、`ToolSearch` で `select:Monitor` を実行して読み込む。
4. **Monitor を起動する**。下記スクリプトを `command` に渡す。全チェック完了時に結果を出力して終了する。
   - `description`: 「PR #<n> の CI チェック結果」のように具体的に。
   - `timeout_ms`: CI の所要時間に合わせ十分に取る（既定 3600000 = 60 分。ローカル E2E ビルド等を含むなら長め）。
   - `persistent`: false。

   ```bash
   if gh pr checks <PR> --watch --interval 30 >/dev/null 2>&1; then
     echo "全チェック pass"
   else
     echo "失敗チェックあり"
   fi
   echo "=== 全チェック完了 ==="
   ```

   - `<PR>` は対象 PR 番号または URL。現在ブランチの PR を使う場合は省略する。
   - `>/dev/null 2>&1` で `--watch` の進捗表示を捨て、Monitor への通知を完了時の 2 行に絞る。
5. **結果を報告する**。完了通知が届いたら `gh pr checks <PR>` で最終状態を取得し、pass / fail を要約する。失敗があればジョブ名とログ URL を示す。すべて pass なら次のアクション（マージ等）を案内してよい。

## 注意点

- **ポーリング間隔は `--interval 30` 以上**: API レート制限を避ける。E2E 等で長時間かかる場合はさらに長くてよい。
- **`--fail-fast` オプション**: 最初の失敗で即座に終了させたい場合は `--fail-fast` を追加する。早期通知が優先ならこちらを使う。
- **起動後は自分でポーリング / sleep しない**: 完了通知（`=== 全チェック完了 ===`）が届いてから手順 5 へ進む。
- **timeout で kill された場合**: チェックが pending のまま timeout に達すると Monitor は kill される。その旨を報告し、必要なら `timeout_ms` を調整して再起動する。早期に止めたいときは `TaskStop`。

## トラブルシューティング

- `gh` が PR を見つけられない: 現在ブランチに PR があるか、または PR 番号 / URL を明示する。
- `gh pr checks --watch` が hang する: PR に pending のチェックがなく `--watch` が終わらない場合がある。手順 2 で事前に pending を確認する。
