#!/usr/bin/env pwsh

$ErrorActionPreference = 'Stop'
# Windows PowerShell 5.1 reads this UTF-8 BOM file; hook I/O remains UTF-8.
[Console]::InputEncoding = [Text.UTF8Encoding]::new($false)
[Console]::OutputEncoding = [Text.UTF8Encoding]::new($false)
$restraintInput = [Console]::In.ReadToEnd() | ConvertFrom-Json
$restraintEvent = $restraintInput.hook_event_name
if ($restraintEvent -notin @('SessionStart', 'SubagentStart')) {
    throw 'Unsupported hook event.'
}

$restraintContext = @"
Implementation restraint / delegation:
- WithMateのSession Graph MCPによる共有記録は、共通CLAUDE.mdの条件付き参照に従いruntimeの実pathのsession-graph Skillを使う。記録対象の指示は依存作業の前に保存し、対象選択・同期・復元の詳細は同Skillに従う。記録操作で権限を広げず、保存失敗を成功扱いしない。
- 現在の要求・契約・具体的な不具合に根拠を持つ、最も単純な完全解を作る。不要な抽象化、互換層、fallback、管理文書、testや無関係な整理を増やさない。
- 共通文書の参照先はユーザーhome直下の~/.claude/に固定する。~は実行環境のユーザーhomeを指し、読み取り前に絶対pathへ解決する。作業対象repositoryや配布元checkout、CLAUDE_CONFIG_DIRによる別配置へ切り替えず、参照先が欠けても同名文書で代用しない。
- 複雑さは必要な保証への効果と継続負担で評価する。共有判断の不足・矛盾や方針・現行説明の変更を扱う時は、~/.claude/docs/guides/design-decisions.mdを読む。必要な調査・推奨案・草案まで自ら進め、未合意の判断の採否を確認する。草案を有効な方針とせず、権限・着手禁止を維持する。
- 失敗を成功に見せない。必要な確認で終え、明示要求、入力検証、安全性、accessibility、データ保護を保つ。
- 共通CLAUDE.mdの「条件付き参照」に従い、実装を伴わない課題・対応予定の管理でも、~/.claude/docs/guides/development.mdと対象repositoryが明示する関連運用文書を読む。開発・review・リリース範囲の確定・統合・公開判断等の読込条件も同入口に従う。互換性境界や残件管理先の不足は、実際の変更影響と依存先を調べ、その判断に依存する変更・引継ぎだけを止める。独立した作業は進め、未合意の保護対象を独断で確定・廃止しない。必須確認と権限を満たして統合し、現在の変更や依存先を非ブロッカーの全件修正待ちにしない。
- review-test-valueでは、testの新規追加・意味変更・削除・移設をGit差分から抽出し、通常のread-only reviewへ渡す。対象を都合よく選び直したり、審査を通すために契約を弱めたりしない。
- 委譲前に~/.claude/docs/architecture/subagent-workspace.mdを読み、対象・必要な文脈・完了条件・実効権限を渡す。モデルとeffortはユーザー指定と利用中のClaude設定を維持し、他製品のmodel名・role名・tool引数を流用しない。
"@

$restraintResponse = @{
    hookSpecificOutput = @{
        hookEventName = $restraintEvent
        additionalContext = $restraintContext
    }
} | ConvertTo-Json -Depth 3 -Compress
[Console]::Out.WriteLine($restraintResponse)
