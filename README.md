# Claude 個人設定

このrepositoryはClaude Codeの個人用指示、Skill、agentと設定例の配布元である。作業時の入口は [CLAUDE.md](CLAUDE.md)。本書の導入・保守・リリース手順は、この配布物にだけ適用する。

## 構成と利用

| 探したいもの | 正本 |
| --- | --- |
| 作業の判断と承認 | [共通入口](CLAUDE.md)から[目的別のガイド](docs/guides/)へ。ガイド全文を起動時にimportしない |
| 専門手順 | [個人Skill](skills/)とその配下のscript・reference・asset。用語集はWithMateが別途提供する |
| 委譲先とWorkspace | [Claude nativeと作業領域](docs/architecture/subagent-workspace.md)、[WithMate通常Sessionの協同](docs/guides/withmate-collaboration.md) |
| ホストの開始値 | [設定例](settings.example.json)、[agent定義](agents/)、[起動通知](hooks/implementation-restraint.ps1)、[個人MCPの登録例](mcp.example.json) |
| 利用者向け変更 | [v4.1.1の変更と移行](docs/releases/v4.1.1.md)・[版別リリースノート一覧](docs/releases/) |

## 導入と更新

個人用の配置先は実行ユーザーのhome直下の `~/.claude/`。ここで直接checkoutしている場合は、branch・remoteと既存差分を確かめ、対象の配布commitへfast-forwardできるときに更新する。別checkout・正式タグのsource archiveから手動配置する場合は、`CLAUDE.md`、本README、`docs/`、`agents/`、自主管理の各Skill、`hooks/`、設定例を同じ相対配置で揃える。第三者のLICENSE・NOTICEと参照資産を含め、同名の個人変更があれば差分を確認する。設定ディレクトリ全体を置き換えない。

`settings.example.json` は必要な項目だけを利用者の `settings.json` へ統合するための例であり、実設定ではない。`skills/synced/`、WithMate管理の `skills/withmate-glossary/`、個人の認証・MCP登録・Memory・履歴・ローカル方針・cacheは配布しない。既存の登録やworkspaceの信頼状態を更新のために変更しない。

[Claudeの指示読込](https://code.claude.com/docs/en/memory)と[Skillの探索](https://code.claude.com/docs/en/skills)は別経路である。新規Sessionでは `/context all` のMemory filesで読込元、`/skills` でSkillの実path・重複、`/agents` でagentの出所を確認できる。明示起動の `/japanese-tech-writing-review` と `/natural-japanese` を通常のREADME編集や短い報告に自動適用しない。

## 権限と実行環境

設定例では `acceptEdits` を使い、WebSearch・WebFetchだけを明示allowする。必要な範囲で `--add-dir <path>` または `/add-dir` を使う。shell・外部writeを包括許可せず、自動許可を作業上の承認と取り違えない。保護path、project・local設定、managed policyを尊重し、実効値は `/status`・`/permissions` で確認する。[Native WindowsではshellをOS sandboxで隔離しない](https://code.claude.com/docs/en/sandboxing)。承認後の子processまで作業範囲に閉じ込める必要があれば、対応する隔離環境が別に必要となる。

個人hookはWindows PowerShell 5.1またはPowerShell 7で、SessionStartのstartup・resume・compactとSubagentStartに共通入口を通知する。[hook登録とtrust](https://code.claude.com/docs/en/hooks)はホストで解決される。`/hooks` の登録・出力は必要なSessionで確認する。通知がなくても個人CLAUDE.mdは別経路で読み込まれ、通知自体は操作を許可・拒否しない。

## 会話をまたぐ記憶

設定例の `autoMemoryEnabled: false` で[auto memory](https://code.claude.com/docs/en/memory#enable-or-disable-auto-memory)を無効にし、個人agentにもpersistent memoryを設定しない。既存の記憶を消す設定ではなく、明示的なCLAUDE.mdの読込やWithMateのSession Graphを置き換えない。実効状態は `/memory` で確認する。

## MCP接続

個人用の例は公開read-onlyの `openaiDeveloperDocs`。[Claudeのuser scope](https://code.claude.com/docs/en/mcp#user-scope)は `~/.claude.json` を使い、`settings.json` の項目ではない。新規登録は同名entryが未登録であることを確認し、[設定例](mcp.example.json)から必要なentryだけを選ぶ。以下はPowerShell 7.3以降の例。

```powershell
$PSNativeCommandArgumentPassing = 'Standard'
$examplePath = Join-Path ([Environment]::GetFolderPath('UserProfile')) '.claude/mcp.example.json'
$entry = (Get-Content -Raw -LiteralPath $examplePath | ConvertFrom-Json).mcpServers.openaiDeveloperDocs
claude mcp add-json --scope user openaiDeveloperDocs ($entry | ConvertTo-Json -Depth 10 -Compress)
```

WithMateのClaude SessionではGlossary・Session Graph・Session MCPを起動元が一時的なHTTP接続として供給する。そのSessionの `tools/list` と必要なreadで確認し、user scopeへ重複登録しない。接続できなければ起動元とSession bindingを確認する。別SessionのURL・短命token・bindingは流用せず、設定例・ログ・報告にも出さない。

手動clientの開発・診断に限り、WithMateの `withmate-glossary mcp-server` をSTDIOで起動できる。Windowsのcommand shimはPATHから `cmd.exe /d /c` 経由で起動し、当該Sessionのbindingだけを使用する。HTTP未接続時の自動fallbackや通常の永続登録には使わない。

## modelと担当

Claude nativeの開始値は[設定例](settings.example.json)の親Sonnet 5.5/medium、手動切替のOpus 5.5/low。上位親を今回だけ使う例は `claude --model claude-opus-5-5 --effort low`。子ごとのmodel・effort・toolは [agent定義](agents/)、どの担当に渡すかは[委譲ガイド](docs/architecture/subagent-workspace.md#nativeサブエージェント)を参照する。これはWithMateの通常子を選ぶmodel表ではない。

設定例の子modelは未指定時の既定であり、組込み担当を含め全員を上書きしない。履歴forkを無効、孫の起動を無効、通常のAgent起動の同時上限を24とする。[Claudeのagent設定](https://code.claude.com/docs/en/sub-agents)に従い、per-call指定・環境変数・同名のproject／managed定義による実効model・toolを確認する。全担当を固定する `CLAUDE_CODE_SUBAGENT_MODEL_FORCE` や一律の `CLAUDE_CODE_EFFORT_LEVEL` で担当別の開始値を潰さない。

## 配布物の確認

変更の影響に必要な確認を選び、既存の必須CIがあれば通す。規約の更新だけを理由に、対照例や実行条件の一致、生成比較を受入に求めない。比較自体が依頼なら、問いに応じて揃える条件を選び、揃わない条件が結論に与える影響を示す。

- 変更に応じて、Markdownの参照、Skillとagentのfrontmatter、設定JSONと対応するhookの入出力を確認する。実設定や会話本文を検証用に出力・転送しない。
- 変更test抽出器の既存回帰検査は `python -X utf8 -m unittest discover -s skills/review-test-value/scripts -p "test_extract_test_values*.py"`。抽出にはPython 3.11以降とGit、TypeScriptにはNode.jsと `npm ci --prefix skills/review-test-value/scripts/adapters/typescript`、C#には.NET 8の実行環境と対応SDKが必要。抽出器のテストと、実際の変更test全件の独立審査は別である。
- WithMateの通常子の選定、実呼出元への相談、保存後配送・受入を確認する場合は、そのSessionが提供するMCPを使う。静的な規約や設定の一致だけを配送成功の証拠にしない。

## 課題管理とリリース

不具合・要求・後追いは [GitHub Issues](https://github.com/natumekazuki/.claude/issues) で管理し、対応版が未指定の課題はバックログとする。

共通ルール・自主管理Skill・配布設定の共通部分はCodexを基準に、通常は同じ変更でClaude・OpenCodeを含む各配布元へ反映する。Claude起点の共通改善も基準側へ戻す。製品固有の起動・tool・権限はそれぞれの設定を使う。比較用の参照は実行時の依存ではなく、一製品の担当に別製品へのwriteを認めるものでもない。

通常の統合先は `master`。正式版は `vMAJOR.MINOR.PATCH` タグとGitHub Releaseで識別する。統合・公開は別の判断であり、公開済みタグは付け替えない。版別ノートは統合対象の差分に含め、変更内容と利用・互換・移行への影響を [docs/releases/](docs/releases/) に記載する。

維持対象はSkill名と導入・配置の入口、[変更test抽出のCLI・result・metadata・言語adapter・Git差分選択](skills/review-test-value/references/)、[Session GraphのMCP利用方針](skills/session-graph/SKILL.md)である。内部構造・指示の言い回し・modelの開始値は固定しない。維持契約を壊す変更はmajor、互換な機能追加はminor、互換な修正はpatch。実データと認証・認可の境界はタグの有無を問わず保護する。
