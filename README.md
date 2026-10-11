# Claude 個人設定

本書はこのrepositoryの保守とGit管理対象の案内である。本書の保守規則を、Claudeが作業する他repositoryのルールとして適用しない。

## Git管理対象

自分で保守するルール・Skill・設定例・hook定義をGit管理する。認証情報、実行時データ、端末localの実設定は管理しない。共有できる設定は、`settings.example.json`等の設定例として実設定と分ける。

`skills/synced/`はClaude.ai同期、`skills/withmate-glossary/`はWithMate管理のSkillであり、本repositoryでコピー・forkして保守しない。それ以外の自分で保守するSkillはGit管理できるようにする。

## Codex／Claude間の変更反映

この節は`.codex`と`.claude`の保守にのみ適用し、共通ルールの適用先repositoryには適用しない。

- `.codex` と `.claude` は独立したrepositoryとして管理し、各repository内で規約・Skill・設定が完結する。相互importやリンク共有には依存しない。
- 自分で保守するルール・Skill・設定例・hook方針のうち、両製品に共通する変更は、原則として同じ変更作業で双方へ反映する。
- 反映では目的・制約・完了条件を揃える。モデル、tool、設定形式等の製品固有部分は、それぞれに適した定義を維持する。
- 製品固有の変更でも、もう一方への影響を確認する。反映不要なら、その理由を作業報告に示す。
- 双方の差分と必要な動作を確認し、反映・検証結果を報告する。権限不足や仕様差によって反映できない部分は、理由と未完了範囲を明示する。
