# Claude 個人設定

本書はこのrepositoryの保守とGit管理対象の案内である。本書の保守規則を、Claudeが作業する他repositoryのルールとして適用しない。

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
| `hooks/implementation-restraint.ps1` | SessionStart・UserPromptSubmit・SubagentStartへ共通ルールの短い再通知を返す |
| `settings.example.json` | model・effort・委譲設定・個人hookの登録例。実設定はGit管理しない`settings.json`へ必要な項目だけ反映する |

共通ルールと個人Skillはユーザーhome直下の`~/.claude/`に配置する。`docs/`の詳細を一括importせず、`CLAUDE.md`の読む条件に応じて参照する。Skill内のscript・reference・assetは同じSkillの実pathから解決し、別repositoryのコピーへ依存しない。

`japanese-tech-writing-review`と`natural-japanese`は`disable-model-invocation: true`で明示起動だけにする。ユーザーが`/japanese-tech-writing-review`または`/natural-japanese`を呼び出す場合に使い、通常のREADME更新・開発報告へ自動で校正を追加しない。

変更testの審査は`docs/guides/test-changes.md`の必須条件に従う。runtimeに`review-test-value` Skillやread-only委譲手段が提供されていなければ、審査を免除せず、その審査に依存する作業・完了判断を未完了として報告する。

model・effortと担当の設定例は下記に定める。permission mode、MCP接続、auto memoryは利用中の端末local設定に従う。再通知hookはcontextを返すだけで、権限を付与したり操作を代理実行したりしない。

配置・更新後は新しいClaude Codeセッションで個人`CLAUDE.md`の読込、`/skills`の実path・重複・明示起動policy、`/hooks`のtrust・登録・出力を確認する。静的な配置確認と実際のルール適用・Skill起動を区別し、未実施のruntime確認を成功扱いしない。

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

## Codex／Claude間の変更反映

この節は`.codex`と`.claude`の保守にのみ適用し、共通ルールの適用先repositoryには適用しない。

- `.codex` と `.claude` は独立したrepositoryとして管理し、各repository内で規約・Skill・設定が完結する。相互importやリンク共有には依存しない。
- 自分で保守するルール・Skill・設定例・hook方針のうち、両製品に共通する変更は、原則として同じ変更作業で双方へ反映する。
- 反映では目的・制約・完了条件を揃える。モデル、tool、設定形式等の製品固有部分は、それぞれに適した定義を維持する。
- 製品固有の変更でも、もう一方への影響を確認する。反映不要なら、その理由を作業報告に示す。
- 双方の差分と必要な動作を確認し、反映・検証結果を報告する。権限不足や仕様差によって反映できない部分は、理由と未完了範囲を明示する。
