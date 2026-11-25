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

$restraintContext = 'Use ~/.claude/CLAUDE.md in the OS user home (not the workspace or CLAUDE_CONFIG_DIR) for permissions and task-specific routes. When its Graph route applies, use the runtime session-graph skill to restore context and record changed conditions before dependent work.'

$restraintResponse = @{
    hookSpecificOutput = @{
        hookEventName = $restraintEvent
        additionalContext = $restraintContext
    }
} | ConvertTo-Json -Depth 3 -Compress
[Console]::Out.WriteLine($restraintResponse)
