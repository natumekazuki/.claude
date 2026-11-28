# WithMate Session Graphの廃止

[WithMate本体での廃止](https://github.com/natumekazuki/WithMate/issues/985)に伴い、Claude配布物からSession Graphの利用規則・専用Skill・起動時の誘導を廃止した。旧経路の互換・記録の移行は提供しない。[Codexでの廃止判断](https://github.com/natumekazuki/.codex/blob/0fce72f65c1716c2daf9987de896e0b0c4e295b2/docs/adr/0024-withmate-session-graph-removal.md)に合わせ、Claude固有の指示読込・通知hook・native設定は維持する。

Claudeの削除commit: `cb1164909c7175b5d9ea0a667948f6b662e8a730`。
