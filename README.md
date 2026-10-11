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
| `docs/architecture/subagent-workspace.md` | 委譲の文脈・権限・成果返却の共通境界 |
| `agents/read-only.md` | 利用中のmodelを継承し、読み取り・検索だけを行う汎用担当 |
| `skills/` | 変更testの価値審査、Session Graph、UI設計、RelayGraph、日本語技術文書、自然な日本語の個人Skill |
| `hooks/implementation-restraint.ps1` | SessionStart・UserPromptSubmit・SubagentStartへ共通ルールの短い再通知を返す |
| `settings.example.json` | 個人hookの登録例。実設定はGit管理しない`settings.json`へ必要な項目だけ反映する |

共通ルールと個人Skillはユーザーhome直下の`~/.claude/`に配置する。`docs/`の詳細を一括importせず、`CLAUDE.md`の読む条件に応じて参照する。Skill内のscript・reference・assetは同じSkillの実pathから解決し、別repositoryのコピーへ依存しない。

`japanese-tech-writing-review`と`natural-japanese`は`disable-model-invocation: true`で明示起動だけにする。ユーザーが`/japanese-tech-writing-review`または`/natural-japanese`を呼び出す場合に使い、通常のREADME更新・開発報告へ自動で校正を追加しない。

変更testの審査は`docs/guides/test-changes.md`の必須条件に従う。runtimeに`review-test-value` Skillやread-only委譲手段が提供されていなければ、審査を免除せず、その審査に依存する作業・完了判断を未完了として報告する。

モデル別roleは本repositoryでは定義しない。model・effort、permission mode、MCP接続、auto memoryは利用中の端末local設定に従う。再通知hookはcontextを返すだけで、権限を付与したり操作を代理実行したりしない。

配置・更新後は新しいClaude Codeセッションで個人`CLAUDE.md`の読込、`/skills`の実path・重複・明示起動policy、`/hooks`のtrust・登録・出力を確認する。静的な配置確認と実際のルール適用・Skill起動を区別し、未実施のruntime確認を成功扱いしない。

## Codex／Claude間の変更反映

この節は`.codex`と`.claude`の保守にのみ適用し、共通ルールの適用先repositoryには適用しない。

- `.codex` と `.claude` は独立したrepositoryとして管理し、各repository内で規約・Skill・設定が完結する。相互importやリンク共有には依存しない。
- 自分で保守するルール・Skill・設定例・hook方針のうち、両製品に共通する変更は、原則として同じ変更作業で双方へ反映する。
- 反映では目的・制約・完了条件を揃える。モデル、tool、設定形式等の製品固有部分は、それぞれに適した定義を維持する。
- 製品固有の変更でも、もう一方への影響を確認する。反映不要なら、その理由を作業報告に示す。
- 双方の差分と必要な動作を確認し、反映・検証結果を報告する。権限不足や仕様差によって反映できない部分は、理由と未完了範囲を明示する。
