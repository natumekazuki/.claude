# Claude 個人設定

`natumekazuki/.claude` は、Claudeに配置する共通指示・Skill・設定例の配布元である。作業時の入口は [CLAUDE.md](CLAUDE.md)。本書は配布物の導入・検証と、このrepository自身の保守を扱う。他のrepositoryの課題管理先や公開手順を定めるものではない。

## 構成

| 探したいもの | 場所 |
| --- | --- |
| 作業中の判断・必須参照 | [共通入口](CLAUDE.md)、[用途別guide](docs/guides/)、[委譲と作業領域](docs/architecture/subagent-workspace.md) |
| 専門手順・実行資産 | [配布するSkill](skills/)、[native role](agents/)、[hook登録](settings.example.json)と[スクリプト](hooks/) |
| 親・子の設定 | [共有config例](settings.example.json)、[MCP設定例](mcp.example.json) |
| 導入・診断、記入例 | [用途別runbook](docs/runbooks/)、[ADR・review記録の記入例](templates/)（任意） |
| 過去の判断と公開版 | [ADR](docs/adr/)、[版別リリースノート](docs/releases/README.md)（変更に伴う影響） |

## このrepositoryの管理先とリリース境界

バグ・後追い残件の管理先は [natumekazuki/.claude のGitHub Issues](https://github.com/natumekazuki/.claude/issues)。Issueの登録・更新・closeは外部writeとして、共通入口の承認範囲に従う。

### 本repositoryの開発・リリース境界

- `vMAJOR.MINOR.PATCH` タグが指すcommitを配布版とする。タグのないcommitやbranch上の途中状態は互換保証の対象としない。
- 維持するのは各タグのリリースノートで明示した利用者向け契約であり、実装全体ではない。
- 破壊的な契約変更はmajor、互換な変更はminorまたはpatchを上げて新しいタグへ記録する。リリースごとに [一覧](docs/releases/README.md) と `docs/releases/vMAJOR.MINOR.PATCH.md` を更新し、変更内容とその互換性・移行・利用・安全上の影響を記録する。

統合先は `master`。GitHub Releaseと版別ノートは同じタグで公開する。公開版の変更は[版別ノート](docs/releases/README.md)を参照する。Skill名・導入と配置の入口・Session GraphのMCP利用方針も維持対象である。MCPのschema・認可はruntimeが定める。

### この設定ホームでGit管理するもの

新しいパスは既定で除外し、配布専用の文書・開発資産と、明示した設定例・ソースだけを許可する。Skillはパッケージごとに登録する。実設定・認証、端末専用のSkill／pluginや生成物は配布しない。Gitignoreは追跡済みファイルの変更や機密の中身までは除外しないので、stageする内容も確認する。

新しい配布物を追加するときは、必要な親ディレクトリと対象だけを `.gitignore` で許可し、`git check-ignore -v --no-index -- <path>` と `git add -n -- <path>` で正しく追加できるか確かめる。除外を変更するときは、Git Bash等で `git ls-files -z | git check-ignore -z --no-index --stdin` を実行し、既存の追跡パスが出力されないことも確認する。`git add -f` で回避せず、実設定とは別の見本を配布する。

### Codex／Claude／OpenCode間の変更反映

共通ルール・自主管理Skill・設定例・通知方針はCodexを基本の正本とし、通常の保守では目的・制約・完了条件を揃えて同じ作業で3者に反映する。各配布元（`.codex`、`.claude`、`~/.config/opencode`）は相互importや共有リンクに依存せず独立して使える構成とする。Claude・OpenCode起点の共通改善はCodexにも戻す。

model・tool・設定形式など製品固有の機構は各製品に合わせる。対象製品を限定した依頼を他の配布元への書込権限としない。認証、実config、Session URL・token、Memory・履歴・cache、外部managed Skillは同期しない。

## 配置と検証

共通文書の読取先は実行ユーザーのhome直下の `~/.claude/`。直接checkoutするか、別checkoutから次の配布物を同じ相対配置にコピー・linkする。配布元を編集しても、別の端末配置は更新されない。

- `CLAUDE.md`、`docs/guides/` 全体、`docs/architecture/subagent-workspace.md`、[Glossaryの接続・障害調査runbook](docs/runbooks/withmate-repository-glossary.md) を揃える。別repositoryのrootと下位ディレクトリから、実際に読んだ共通入口・詳細と、そのrepository固有の管理先・互換性定義を確認する。参照が欠けたら配置を修復し、cwdや別の `CLAUDE_CONFIG_DIR` の同名文書で埋めない。

- WithMateのGlossary／Session Graph／SessionのHTTP接続とmanaged `withmate-glossary` SkillはWithMateが供給する。通常の導入で手動登録・forkや短命tokenの永続化はしない。Glossaryの手動STDIOはrunbookの開発・診断用途に限る。通常子の選定・配送は[協同guide](docs/guides/withmate-collaboration.md)、Worktreeの配置先決定と実体の確認は[作業領域guide](docs/architecture/subagent-workspace.md#git-worktreeの配置)に従う。端末固有の方針ファイルは配布・自動移行しない。

### 導入と更新

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

## modelとrole

Claude nativeの開始値は[設定例](settings.example.json)の親Sonnet 5.5/medium、手動切替のOpus 5.5/low。上位親を今回だけ使う例は `claude --model claude-opus-5-5 --effort low`。子ごとのmodel・effort・toolは [agent定義](agents/)、どの担当に渡すかは[委譲ガイド](docs/architecture/subagent-workspace.md#nativeサブエージェント)を参照する。これはWithMateの通常子を選ぶmodel表ではない。

設定例の子modelは未指定時の既定であり、組込み担当を含め全員を上書きしない。履歴forkを無効、孫の起動を無効、通常のAgent起動の同時上限を24とする。[Claudeのagent設定](https://code.claude.com/docs/en/sub-agents)に従い、per-call指定・環境変数・同名のproject／managed定義による実効model・toolを確認する。全担当を固定する `CLAUDE_CODE_SUBAGENT_MODEL_FORCE` や一律の `CLAUDE_CODE_EFFORT_LEVEL` で担当別の開始値を潰さない。

## Skillの配布

このrepositoryで保守するのは、UIの [design-ui-information](skills/design-ui-information/)、Crewの共有記録を扱う [session-graph](skills/session-graph/)、採用済みrepositoryを扱う [relaygraph](skills/relaygraph/)、明示的な文章推敲用の [japanese-tech-writing-review](skills/japanese-tech-writing-review/) と [natural-japanese](skills/natural-japanese/) である。導入時はSkill本文とmetadataを揃える。

`natural-japanese` の[同期元](https://github.com/coji/natural-japanese)・commit・licenseは [NOTICE](skills/natural-japanese/NOTICE) と [LICENSE](skills/natural-japanese/LICENSE) を参照。

`disable-model-invocation: true` のSkillは利用者の明示呼出しに限る。

## このrepositoryのGit pre-commit

この配布元のcheckoutで、Python 3.12とPowerShell 7（`pwsh`）を使う。有効にする前に `git config --show-origin --get core.hooksPath` で既存の設定を確認し、別のhookがある場合は上書きせず併用方法を決める。このrepositoryの既存設定と競合しなければ `git config --local core.hooksPath .githooks` で有効化できる。同じGit repositoryのworktreeにも影響する。設定を変えずに一度だけ使う場合は `git -c core.hooksPath=.githooks commit`、事前に同じ検査を手動で行う場合は `python -B -X utf8 scripts/check-repo.py --staged` を使う。

staged差分の空白・競合マーカーと、このrepositoryの検査スクリプトで追加・変更したPython宣言のdocstringを検査する。外部由来の `natural-japanese` はdocstring検査に含めず、関連する変更ではPythonの構文と同梱fixtureによる実行例を確認する。設定例・通知hookの変更では、公開の設定例とテスト用入力で入出力を確認する。本文コメントの意味はreviewで確認する。CIは変更差分を検査し、Windows・Ubuntuで維持対象の検査を実行する。Git hookはClaudeの実行時設定とは別で、チェックアウトしただけでは有効にならない。

## 配布時の確認

変更が影響する契約を確認する。配布元の文書を確認しただけなら、端末での適用や実動作まで確認したとは扱わない。出力比較が依頼された場合は、[比較手順](docs/runbooks/compare-subagent-roles.md#役割指示を比較する時)を参照する。

モデル実行やsecretを公開CIへ追加しない。確認した対象・条件・結果と判断に響く未確認は既存の[review記録](docs/guides/development.md#sessionfolderのreview記録と対応管理)等に残し、文書の一致を実動作の証拠にしない。

- 変更に応じて、Markdownの参照、Skillとagentのfrontmatter、設定JSONと対応するhookの入出力を確認する。実設定や会話本文を検証用に出力・転送しない。
