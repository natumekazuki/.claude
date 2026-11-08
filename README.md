# Claude 個人設定

本書はこのrepositoryの保守とGit管理対象の案内である。本書の保守規則を、Claudeが作業する他repositoryのルールとして適用しない。

共通ルールは責務に基づく既存実装の削減と過剰追加の抑制、統合優先・修正分離、変更testの価値確認、ユーザー向けUIの設計品質を中心にする。ユーザー変更の保護、操作範囲、承認条件、必要な安全動作は維持する。

## Git管理対象

自分で保守するルール・Skill・設定例・hook定義をGit管理する。認証情報、実行時データ、端末localの実設定は管理しない。共有できる設定は、`settings.example.json`等の設定例として実設定と分ける。

`skills/synced/`はClaude.ai同期、`skills/withmate-glossary/`はWithMate管理のSkillであり、本repositoryでコピー・forkして保守しない。それ以外の自分で保守するSkillはGit管理できるようにする。

## 構成と利用

| 正本 | 内容 |
| --- | --- |
| `CLAUDE.md` | 個人共通ルールの入口、常時原則、操作境界、条件付き参照 |
| `docs/guides/` | 開発・review・統合、設計判断・文書化、変更test、UI、WithMateの作業別詳細 |
| `docs/architecture/subagent-workspace.md` | 担当の選択、委譲の文脈・権限・成果返却の境界 |
| `agents/` | 通常・手順確定・高度判断の3つの汎用担当と、読み取り・検索だけの`read-only`担当 |
| `skills/` | 変更testの価値審査、Session Graph、UI設計、RelayGraph、日本語技術文書、自然な日本語の個人Skill |
| `hooks/implementation-restraint.ps1` | SessionStartのstartup・resume・compactとSubagentStartへ共通ルールの短い再通知を返す |
| `settings.example.json` | model・effort・権限・委譲設定・個人hook・auto memory無効化の設定例。実設定はGit管理しない`settings.json`へ必要な項目だけ反映する |
| `mcp.example.json` | 個人MCPの登録例。実登録はuser scopeの`~/.claude.json`に置き、認証・Session固有値は保存しない |

共通ルールと個人Skillはユーザーhome直下の`~/.claude/`に配置する。`docs/`の詳細を一括importせず、`CLAUDE.md`の読む条件に応じて参照する。Skill内のscript・reference・assetは同じSkillの実pathから解決し、別repositoryのコピーへ依存しない。

`japanese-tech-writing-review`と`natural-japanese`は`disable-model-invocation: true`で明示起動だけにする。ユーザーが`/japanese-tech-writing-review`または`/natural-japanese`を呼び出す場合に使い、通常のREADME更新・開発報告へ自動で校正を追加しない。

変更testの審査は`docs/guides/test-changes.md`の必須条件に従う。runtimeに`review-test-value` Skillやread-only委譲手段が提供されていない場合も、審査を免除しない。

review指摘の採否・対応時期・統合可否は`docs/guides/development.md`の「統合優先・修正分離」に従って分ける。作成中のtest metadataとtest本文の不一致等は、今回必要で依頼範囲内の修正と必要確認で完結するなら仕上げとして対応する。後追いの基準を満たす残件だけを引き継ぎ、根拠のない追加test案や好みは不採用で終了できる。後追い非該当から即時修正を必須化せず、局所修正後に全体の改善探索を繰り返さない。

model・effortと担当、権限、MCP、auto memory無効化の設定例は下記に定める。再通知hookはcontextを返すだけで、権限を付与したり操作を代理実行したりしない。

配置・更新後は新しいClaude Codeセッションで個人`CLAUDE.md`の読込、`/skills`の実path・重複・明示起動policy、`/hooks`のtrust・登録・出力を確認する。静的な配置確認と実際のルール適用・Skill起動を区別し、未実施のruntime確認を成功扱いしない。

### 削減方針の確認

責務からの最小構成と比較の基準は[設計判断・文書化](docs/guides/design-decisions.md)、操作権限・維持境界・統合の判断は[開発・review・統合](docs/guides/development.md)に従う。方針変更時は入口・関連guide・再通知hookの整合に加え、次の条件を変更範囲に応じて確認する。配布元の静的確認と新規sessionでの実動作を分ける。

| 条件 | 確認する行動 |
| --- | --- |
| 不要なrevision取得・事前チェックに、内部の利用側・専用test・DB管理状態が依存する | 機構と付随物を一緒に除いた場合の責務への支障を調べる。内部依存やtestの存在だけで必要とせず、不要と判断できれば許可範囲で一体的に削減する。必要性不明は調査し、恒久的な維持理由にしない |
| 局所追加でも動くが、関連する複数経路の統合で継続負担を減らせる／無関係な別機能にも冗長処理がある | 前者は変更・移行・検証費用も含めて比較し、差分の小ささだけで却下しない。後者を無断で改修範囲へ混ぜない。全段階の試作や全repository監査は要求しない |
| 合意済みの維持期間・展開計画がある／将来使うかもしれないだけの仕組みがある | 前者は時間軸を含めて負担を比較するが先行実装の許可とはしない。後者を追加・温存の根拠にしない。必要でない保証・操作制限の導入は目的・支障・負担を示して明示承認を得る |
| 旧schemaとの互換性は維持不要だが、保持データや適用済みmigrationがある | 構造の簡素化と実データ破棄・適用済みmigration書換えの権限を分け、互換不要の合意を破壊的操作の許可へ広げない |

## 導入と更新

Session Graphは現在のMain Sessionと配下Auxiliaryの共有記録であり、保存・共有・表示はWithMateが担う。[Session Graph Skill](skills/session-graph/SKILL.md)は、現在のSessionへ提供されたMCPで何を読み、何をいつ記録するかを定める。呼出契約はruntimeのMCP instructions・tool説明・schemaに従う。

定義変更時は入口・Skill・関連guideの整合を確認し、変更範囲に応じて指示の先行記録、対象を絞った復元、全体置換時の情報保持、競合・結果不明時の再取得を確認する。配布元編集、live配置、Skill発見、MCP読書き、画面表示の確認を区別し、実施した確認と未確認の範囲を報告する。

正式版のtagに対応するsource archiveまたはcheckoutを、端末localの実設定とは別のdirectoryで取得する。`CLAUDE.md`・`docs/`・`agents/`・自分で保守する`skills/`・`hooks/`・設定例をユーザーhome直下の`~/.claude/`へ配置する。既存の同名資産がある場合は差分を確認して反映し、directory全体を削除・置換しない。第三者のLICENSE・NOTICEとSkill内のreference・script・assetも保持する。

`settings.example.json`は必要な項目だけを既存の`settings.json`へ統合する。theme・更新channel・既存hook・project/local/managed設定を設定例全体で上書きしない。個人MCPは「MCP接続」に従ってuser scopeへ個別登録する。WithMateのMemory／Glossary MCPはSessionへ自動供給されるため手動登録しない。既存登録・認証・Session binding実値は移動・複製しない。`skills/synced/`とWithMate管理Skill、既存Memory・履歴はこの配布物に含めず、更新時も保持する。

確認環境はNative WindowsのClaude Code 2.1.296であり、未確認の最低CLI versionや他OSでの動作は保証しない。利用する機能に応じて次の依存を用意する。

| 機能 | 依存 |
| --- | --- |
| Session Graph | WithMateからSessionへ提供されるSession-bound MCP |
| review-test-valueの抽出器 | Python 3.11以降（`tomllib`を使用）、Git |
| TypeScriptのtest抽出 | Node.js、npm、Skill内のlockfileに従う依存 |
| C#のtest抽出 | .NET 8の実行環境と対応SDK。Skill内のprojectをlocked restoreでbuildする |
| 個人hook | Windows PowerShell 5.1またはPowerShell 7 |
| 個人MCP登録例 | PowerShell 7.3以降、Claude CLI |
| WithMateのmanaged MCP | WithMate 6.3.29から起動するClaude provider Session |

TypeScriptの依存は配置先で次のように導入する。依存不足やadapterの失敗を抽出・審査の成功と扱わない。

```powershell
$typeScriptAdapterPath = Join-Path ([Environment]::GetFolderPath('UserProfile')) '.claude/skills/review-test-value/scripts/adapters/typescript'
npm ci --prefix $typeScriptAdapterPath
if ($LASTEXITCODE -ne 0) { throw 'TypeScript adapter dependency installation failed' }
```

更新後は変更した経路の確認を行い、既存の実設定・認証・Memory・共有記録を保護する。配布版の取得だけでは端末local設定や外部管理Skillが更新されたことにはならない。

ローカル起動・撮影と画像提示のルール変更時は、入口・[UI基準](docs/guides/ui.md)・UI Skillの整合に加え、対象repositoryの起動・撮影手順、取得画像の確認、返答の画像埋め込みまでを確認する。軽微な変更、保存先未取得、撮影不可、共有不可を必要な範囲で確認し、配布元の静的確認とlive配置・新規sessionでの実動作を分けて報告する。

## 課題管理とリリース

本repositoryの不具合・機能要求・後追い課題は[natumekazuki/.claudeのGitHub Issues](https://github.com/natumekazuki/.claude/issues)を正本とする。各課題の対応予定はIssueで扱い、対応versionの未指定はバックログとする。予定だけを理由に修正・統合・公開済みとは扱わない。共通資産の修正は「Codex／Claude／OpenCode間の変更反映」に従い、必要な対応範囲を課題へ明記する。

通常の統合先・既定branchは`master`、正式版は`vMAJOR.MINOR.PATCH` tagとGitHub Releaseで識別する。版別の内容・確認・維持対象・既知制約は`docs/releases/vMAJOR.MINOR.PATCH.md`に記載する。repositoryはpublicで管理し、公開範囲の変更は別に承認を受ける。

維持対象は、利用者が直接使うSkill名と導入・配置の入口、release noteで指定するreview-test-valueのCLI/result・metadata・source adapter・Git差分選択、およびSession Graph SkillのMCP利用方針とする。Session Graphの操作・schema・競合制御はruntimeが提供するMCP契約を正本とする。実設定・認証・既存Memory・既存共有記録等の利用者データはtagの有無にかかわらず保護する。外部サービスのmodel提供・費用・出力品質やWithMateの製品動作まで本repositoryの互換性保証へ含めない。

内部実装、指示の表現、開始値としてのmodel/effort、fixture、文書構成全体は、それ自体を固定しない。公表した維持契約を損なわない改善は可能とする。認証・認可・個別操作の承認境界を弱める変更は、version番号だけで許可しない。

維持契約を壊す変更はmajor、互換性を保つ機能追加はminor、互換性を保つ修正・説明訂正はpatchとする。tagのない開発途中の実装全体との互換性は保証しないが、実利用済みのデータ・操作境界を保護対象から外す根拠にしない。公開済みtagを付け替えず、変更は新しい版で公開する。

実装・review・統合・正式公開は別に判断する。統合には必須確認、ブロッカー解消、後追いの基準を満たす残件の登録が必要であり、非ブロッカー全件修正や全件登録は条件にしない。既定の管理先と操作権限の範囲内では記録まで行い、登録要否を定型質問に戻さず結果と参照先を報告する。正式公開には対象commitへの統合、release note、tagとReleaseの成立・対象確認が必要である。Issue書込み、既定branch変更、masterへの統合、push、Release作成・公開は操作・対象・scopeへの承認に従い、承認済みの範囲は再確認しない。

## 権限と実行環境

設定例の`permissions`を端末localの`settings.json`へ反映し、`acceptEdits`を既定にする。

| 対象 | 設定・扱い |
| --- | --- |
| 作業範囲の編集 | working directoryと明示的な追加directoryのfile編集、Claudeが認識する一般filesystem操作を自動許可する |
| shell command | Bash・PowerShellの包括allowは置かない。組込みread-only等を除き、一般commandの承認確認を残す |
| Webの読み取り | `WebSearch`と`WebFetch`をallowする。shellの通信、MCP、外部writeの承認を一括許可するものではない |
| 追加directory | taskに必要な範囲を`--add-dir <path>`または`/add-dir`で追加する。home全体、別repository、SessionFolderの実pathを共通設定へ固定しない |

依頼範囲、read-only、外部write・破壊的操作・push・default/protected branchへのcommit等の個別承認は`CLAUDE.md`の操作境界に従う。toolの自動許可は操作自体の承認を代替しない。`.git`・`.claude`等の保護pathにはClaude固有の追加確認があり、`acceptEdits`はそれを一括解除しない。既定を`auto`や`bypassPermissions`にはしない。

[Claude公式のsandbox仕様](https://code.claude.com/docs/en/sandboxing)ではNative Windowsのshell commandはOS sandboxなしで実行され、承認したcommandとその子processは作業範囲に隔離されない。Read/Editのpath規則やcommand文字列の許可規則も、任意のscriptや子processのfilesystem・networkアクセスを隔離する代替にはならない。OS隔離が必要な運用では、WSL2・container等の対応環境とそのsandbox設定を別途選定する。

設定例は個人の開始値であり、managed policyを置換しない。project/local設定、CLI・host指定等が実効値へ影響する。[設定の優先順位](https://code.claude.com/docs/en/settings#settings-precedence)に従い、新しいsessionで`/status`と`/permissions`から読込元・mode・規則を確認する。起動成功と、承認dialogや隔離の実動作確認は分ける。

## 会話をまたぐ記憶

Claudeのauto memoryは、個人`settings.json`の`autoMemoryEnabled: false`で無効にする。会話をまたぐ記憶の保持・想起はWithMate Memoryを使用する。通常会話での能動的なMemory読取、背景実行との責務分担、Character Affectの反映、継続的な許可・保存範囲は[Memory・Affect・共有情報の利用](docs/guides/withmate.md)、利用可能な操作・探索例・呼出契約は現在提供されているMCP instructions・tool説明・schemaに従う。Memoryの取得に失敗しても、Claude auto memoryや別の記憶storeを代替として作らない。

[Claude公式の無効化設定](https://code.claude.com/docs/en/memory#enable-or-disable-auto-memory)を使用し、[サブエージェントのpersistent memory](https://code.claude.com/docs/en/sub-agents#enable-persistent-memory)も無効にする。既存の記憶fileを削除・移行する設定ではなく、`CLAUDE.md`等の明示的な指示の読込は維持する。設定例・実設定に記憶directoryの置換や削除処理を追加しない。

設定の読込元・優先順位を確認し、新しいClaudeセッションの`/memory`でauto memoryがoffであることを確認する。WithMate Memoryの接続・保存・想起の動作確認は、この無効化とは分ける。

### Memory・Affect方針の検証

通常会話での能動的な読取、背景実行との責務分担、Character表現の適用範囲、Affectの反映は[Memory・Affect・共有情報の利用](docs/guides/withmate.md)、利用可能な操作・引数・scope等は現在のMCP／CLI提供契約を正本とする。[WithMate v6.5.0-preview.2の公開仕様](https://github.com/natumekazuki/WithMate/blob/edce188fd7f8e7cf6399821b40df9771d54eb63d/docs/releases/v6.5.0-preview.2.md)と、入口の読込条件・guide・提供契約を照合する。

WithMateに保存済みの背景登録指示は自動更新されない。この公開仕様の標準指示へ切り替える場合はSettingsで該当用途の`Use Preset`を選ぶ。ルール配布物の更新とSettingsでの選択は別の操作であり、既存のカスタム指示を無断で置き換えない。

変更範囲に応じて次の観点を確認する。実Memory・Affectへの架空の経験・情動の書込みや、恒久test基盤の追加は行わない。

| 条件 | 確認する行動・結果 |
| --- | --- |
| 過去の好み・判断・共有経験が会話や作業に関係する | 明示的な想起依頼を待たず、依存する判断・回答の前に検索し、関連entryの本文まで読む |
| 関連Memoryを探したいが検索語を作れない／検索0件 | 少量のentry・tag一覧を手掛かりにでき、検索0件を記憶全体の不存在と同一視しない |
| 必要な本文が現在のcontextにある／過去の記憶が関係しない | 既読の本文を再利用し、不要な検索・全件取得を行わない |
| 読取失敗／previewだけを取得／現在の発言と記憶が矛盾 | 未確認範囲を断定せず、必要な本文を取得し、現在の明示指示と正本を優先する |
| 通常会話で経験・感情変化が生じる／背景用途が未設定・失敗 | 通常会話から自動保存・appraisal・終了前の保存漏れ確認を行わず、背景側を代行しない |
| 明示的な保存依頼／許可された訂正・forget・move | runtime契約と承認境界に従い、実行結果を確認する。背景実行の存在だけで保存済みとしない |
| Affectの対象・強度・活性度が異なる | 口調・反応へ反映し、基本人格・事実・権限を維持する。作業への反応をユーザーの感情・性質へ誤投影しない |
| 非公開Graph・作業メモ／同じSessionFolder内のPR本文案・外部提出文書 | 前者の自然文にはCharacter表現を使い、後者は明示指定がない限り成果物の文体を保つ。主体・事実・状態・識別子・引用・検証結果は変えず、既存記録を一括変換しない |
| 単件登録／一括登録の途中失敗・結果不明 | 項目ごとの保存済み・失敗・結果不明・未実行を確認し、全件未保存扱いや無条件の再送をしない。件数上限撤廃と本文・添付・quota等の制限を区別する |
| Agentがcompletedで操作拒否・結果不明がある | 実行statusと各操作の成否・保存効果を分け、全件保存成功・実行全体のfailed・正常な登録不要へ読み替えない。保存の巻戻しや実行全体の自動再送をしない |
| Memory／Characterの公開入力schema拒否／unionの代替条件 | `WITHMATE_MEMORY_INVALID_INPUT`のtool・field位置・制約を読み、代替候補を全部必須とせず入力を修正する。`effect: none`を他操作の未保存とせず、権限拡大やCLI fallbackへ逃がさない |
| 許可された添付の取込・復元／read-only・plan／許可外path・既存出力ファイル | 呼出しごとの権限を守り、復元をwriteとして扱う。背景復元先を許可された`memory-exports/`内に限定し、上書きしない。復元不可でも許可された本文読取は維持する |
| 背景thread継続／前回失敗の情報が渡される | 過去応答を保存状態・権限の正本とせず、現在の指示・範囲・操作結果と必要な履歴を確認する。直後の自動再試行loopや通常会話からの代行をしない |
| 標準指示による背景Character Memory／対象Memory | Character本人の語りと観察事実・解釈の区別を保ち、対象Memoryの確定事実へCharacterの感想を混ぜない |
| 保存済みの背景登録指示がある | ルール更新だけで指示が変わったと扱わず、`Use Preset`による切替と既存カスタム指示の保持を区別する |

配布元の文言・参照整合、live配置、新規sessionでの読取と応答への利用、明示依頼による書込、背景生成、Affectの反映は分けて確認・報告する。文言の強化だけで行動改善を実証したとは扱わず、未確認の範囲を明記する。結果はSessionFolderのreview記録等へ残し、repositoryの契約・進捗・検証結果をMemoryへ写さない。

## MCP接続

個人MCPは[Claudeのuser scope](https://code.claude.com/docs/en/mcp#user-scope)へ登録する。実登録先は`~/.claude.json`であり、`settings.json`へ`mcpServers`を追加したり、このrepositoryの`.mcp.json`を全project共通設定として使ったりしない。既存登録・認証・project/local/managed設定を一括上書きしない。

| 登録名 | 接続・前提 |
| --- | --- |
| `openaiDeveloperDocs` | [OpenAI Docs](https://developers.openai.com/learn/docs-mcp)の公開read-only HTTP接続。OpenAI APIの実行権限や認証情報は不要 |

次の例はPowerShell 7.3以降で、未登録の各entryを個別に追加する。既存の同名entryがある場合は実登録と設定例を比較し、追加commandで置換しない。

```powershell
$PSNativeCommandArgumentPassing = 'Standard'
$mcpExamplePath = Join-Path ([Environment]::GetFolderPath('UserProfile')) '.claude/mcp.example.json'
$mcpEntries = (Get-Content -LiteralPath $mcpExamplePath -Raw | ConvertFrom-Json).mcpServers
foreach ($entry in $mcpEntries.PSObject.Properties) {
    $serverJson = $entry.Value | ConvertTo-Json -Depth 10 -Compress
    claude mcp add-json --scope user $entry.Name $serverJson
    if ($LASTEXITCODE -ne 0) { throw "MCP registration failed: $($entry.Name)" }
}
```

### WithMateのmanaged HTTP接続

Session GraphはWithMateから現在のSessionへ提供されるMCPを使用する。操作名・引数・schema・bindingはそのSessionのruntime提供を正本とし、user scopeやproject設定へ接続値を固定しない。Skillの静的確認とClaude providerでの実接続・読書きの確認は分け、未実施のruntime確認を成功扱いしない。

WithMate 6.3.29はClaude provider Sessionへ、共有localhost HTTP MCPの`withmate-memory`と`withmate-glossary`を自動供給する。endpointはそれぞれ`/mcp/memory`と`/mcp/glossary`である。接続URLと当turnの短命tokenは一時設定で渡されるため、user scopeやproject設定へ登録せず、設定例・実登録・ログへ保存しない。

WithMateから新しいClaude Sessionを開始し、そのSessionへ公開された`tools/list`と必要なread-only操作で接続を確認する。通常のCLIによる永続登録の一覧だけで、一時設定の接続成否を判定しない。接続確認だけを目的にMemory・Affect・Glossaryを書き込まない。手動登録もある場合は同じ機能の重複と利用経路を確認し、第三者MCPを一括変更しない。

未接続やbindingエラーでは起動元WithMateとSessionの対応を確認し、URL・tokenを推測したり別Sessionの値を転用したりしない。利用条件と再試行・CLI fallbackの可否は、現在のMCP instructions・tool説明・schema、[Memory・Affect・共有情報の利用](docs/guides/withmate.md)とruntime-managed Skillに従う。登録・接続・Session-bound toolの実動作確認は分ける。接続設定はtoolの包括許可や外部writeの承認を付与しない。

### 背景登録と添付の診断

背景処理の実行結果と操作診断はWithMateの`userData/logs/background-failures.jsonl`で、Agentの終了状態と個々のtool操作の成否・保存効果を分けて読む。`completed`は全件保存成功の証明ではなく、操作拒否の併存だけで実行全体を`failed`へ読み替えない。全操作拒否も正常な登録不要とは扱わない。

このログには正常終了した実行の操作拒否・失敗・結果不明も記録される。ログの存在だけから実行失敗を推定せず、先行する保存を巻き戻したり、実行全体を無条件に再送したりしない。

MCP／CLIが`WITHMATE_MEMORY_INVALID_INPUT`を返した場合は、`error.details.tool`と`error.details.issues`のfield位置・制約・代替条件を読んで入力を修正し、呼び直す。unionの候補内の条件はすべて必要だが、候補間は代替関係であり、全候補を同時に満たす必要はない。公開schemaでの拒否は当該呼出しが保存前に拒否されたことを示し、`effect: none`を他の操作の保存まで未実施という意味にしない。

この入力拒否を認可・通信・保存の障害やCLI fallbackの許可へ読み替えず、変更なしの要求を繰り返さない。Memory本文・会話本文・prompt・tool引数や応答本文・入力値全体・secret・認証情報を追加dumpしない。

背景thread・前回失敗・待機状態はアプリ再起動をまたいで復元されないが、保存済みMemory・Affectは保持される。threadの継続や失敗情報の有無から保存状態を推測しない。

添付の取込元・復元先とローカルwriteの可否は当該呼出しの許可範囲で確認する。復元の拒否をMCP全体の未接続と同一視したり、権限を緩めて迂回したりしない。適用境界は[WithMate利用guide](docs/guides/withmate.md)に従う。

### 手動STDIOによる開発・診断

手動clientの開発・診断では、WithMateが配置する`withmate-memory mcp-server`または`withmate-glossary mcp-server`をSTDIO server commandとして使用できる。Windowsのcommand shimは`PATH`から`cmd.exe /d /c`経由で起動し、端末のinstall pathは固定しない。この経路を通常の自動接続と重複登録したり、HTTP未接続時の自動的な迂回路にしたりしない。

当該provider Sessionの`WITHMATE_AGENT_RUNTIME_BINDING_REFERENCE`、`WITHMATE_AGENT_RUNTIME_BINDING_REQUIRED`、`WITHMATE_AGENT_RUNTIME_TURN_CAPABILITY`、`WITHMATE_MEMORY_RUNTIME_APPLICATION_INSTANCE_ID`、`WITHMATE_MEMORY_RUNTIME_GENERATION_ID`を診断用processへ渡す。bindingの実値は永続化・複製せず、欠落値を推測で補わない。手動STDIO設定は通常導入用の`mcp.example.json`へ追加しない。

## modelと担当

通常と手順が確定した作業にはSonnet 5.5、高度な判断にはOpus 5.5を使う。担当の区分は維持し、各区分へ別のmodelを割り当てることは必須にしない。Haikuの汎用担当は定義しない。委譲時の選択基準と権限は[Subagent Review Boundary](docs/architecture/subagent-workspace.md)が正本である。

| 用途 | model | effort |
| --- | --- | --- |
| 通常の親 | `claude-sonnet-5-5` | medium |
| 手動切替の上位親 | `claude-opus-5-5` | low |
| 通常の子／`general_sonnet` | `claude-sonnet-5-5` | medium |
| 手順確定担当／`general_sonnet_execution` | `claude-sonnet-5-5` | high |
| 高度判断担当／`general_opus` | `claude-opus-5-5` | medium |
| 汎用`read-only`担当の既定 | `claude-sonnet-5-5` | medium |

effortは開始値であり、製品間の性能等価や最適値を実証したものではない。[Claude公式のモデル選択案内](https://platform.claude.com/docs/en/about-claude/models/choosing-a-model)は、通常のcoding・agent作業におけるSonnetの速度と能力、高度なagentic codingにおけるOpus、低遅延・大量処理におけるHaikuの用途を示している。実際の品質・実行時間・消費枠は対象taskと利用契約に依存する。

`settings.example.json`の`model`とmodel別`modelSettings`を端末localの`settings.json`へ必要な範囲で反映する。手動で上位親を起動する場合は次を使う。CLI指定はそのsessionだけに適用し、通常親の既定を変更しない。

```powershell
claude --model claude-opus-5-5 --effort low
```

委譲設定の例は、model未指定の子の既定をSonnet、履歴forkを無効、子から孫への委譲を無効、通常のAgent起動の同時上限を24とする。同時上限は再開・workflow・agent team等を含む全実行の一律保証ではない。`CLAUDE_CODE_SUBAGENT_MODEL`は既定値であり、定義済みmodelを持つ組込みExplore・Planのmodelを変更しない。運用の担当は上表の定義から選び、組込み担当のmodelを同じと推測しない。

roleの`model`と`effort`は[Claudeのfrontmatter](https://code.claude.com/docs/en/sub-agents#frontmatter-reference)で定義する。per-call指定、環境変数、project・managed定義等が選択へ影響するため、委譲規約に従って実効model・effort・toolを確認する。実設定・既存hook・認証・MCPを設定例全体で上書きしない。配置後は新しいsessionで担当の発見と`/tasks`の実モデルを確認し、読込成功だけを実taskの品質確認へ読み替えない。

## Codex／Claude／OpenCode間の変更反映

この節は`.codex`、`.claude`、OpenCode設定の保守にのみ適用し、共通ルールの適用先repositoryには適用しない。Codexを基本の正本とし、ClaudeとOpenCode（`~/.config/opencode`）は独立して完結する構成を保つ。

- `.codex`、`.claude`、OpenCode設定は独立して完結させ、相互importやリンク共有に依存しない。
- 共通ルール、自分で保守するSkill、設定例、通知方針の変更は、目的・制約・完了条件を揃えて同じ作業で3者へ反映する。モデル、tool、設定形式等の製品固有部分は各製品に適した定義を維持する。
- ClaudeまたはOpenCode起点の共通改善はCodexへ逆反映する。製品固有の変更も他の2者への影響を確認し、反映しない場合は理由を作業報告に示す。
- 認証情報、実config、Session URL・token、Memory、履歴、cache、外部managed Skillは同期対象外とする。
- 3者の差分と必要な動作を確認し、反映・検証結果を報告する。
