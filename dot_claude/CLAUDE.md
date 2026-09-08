# 開発指針

一貫性、可読性、保守性を重視しシンプルな実装を心がける。
不明瞭な指示は質問を行い明確にする。
公式ドキュメント等の1次ソースをまず調査する。
非自明な変更では、実装に着手する前にインターフェース仕様（シグネチャ・型・エラー仕様など）を確定する。
テストは実装をなぞらず仕様・インターフェースに対して書き、実装より先に書く。実装中に設計を見直したときは仕様とテストを揃えて更新し、実装がそう動くからという理由でテストだけを直さない。

# GitHub の記法

同一リポジトリの issue / PR を参照するときは `#123` 形式かフル URL をそのまま使う（`redirect.github.com` 経由にすると `Fixes #123` などのクローズキーワードが認識されず、マージ時の自動クローズが働かない）。
作業リポジトリが `yami-beta/*` のときに限り、他リポジトリへのリンクは `https://redirect.github.com/{org}/{repo}/...` に書き換えてバックリンク通知を避ける。`yami-beta/*` 以外のリポジトリで作業しているときは書き換えずそのまま使う。
https://docs.github.com/en/get-started/writing-on-github/working-with-advanced-formatting/autolinked-references-and-urls#avoiding-backlinks-to-linked-references
