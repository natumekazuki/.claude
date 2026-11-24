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

$restraintContext = '実行ユーザーのhome直下の ~/.claude/CLAUDE.md を入口に、今回の作業に該当するガイドとSkillを読む。再開時は同じ入口から有効な条件を復元する。'

$restraintResponse = @{
    hookSpecificOutput = @{
        hookEventName = $restraintEvent
        additionalContext = $restraintContext
    }
} | ConvertTo-Json -Depth 3 -Compress
[Console]::Out.WriteLine($restraintResponse)
