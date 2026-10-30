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
- 共通ルールの入口は~/.claude/CLAUDE.md。~は実行環境のユーザーhomeへ解決し、作業対象repositoryや別配置で代用しない。入口の操作境界と条件付き参照に従い、作業に必要なguide・runtimeのSkillを読む。
- 追加前の削減・統合と、保守者が修正できる構造を優先する。設計の選択基準は~/.claude/docs/guides/design-decisions.md、開発・review・統合の判断は~/.claude/docs/guides/development.mdを正本とする。
- WithMate Session Graphの利用条件は共通入口に従い、runtimeのsession-graph Skillで必要な指示を依存作業前に保存する。記録を権限拡大や未実施の確認の代わりにしない。
- 委譲前に~/.claude/docs/architecture/subagent-workspace.mdを読む。モデルとeffortはユーザー指定と利用中のClaude設定を維持する。
"@

$restraintResponse = @{
    hookSpecificOutput = @{
        hookEventName = $restraintEvent
        additionalContext = $restraintContext
    }
} | ConvertTo-Json -Depth 3 -Compress
[Console]::Out.WriteLine($restraintResponse)
