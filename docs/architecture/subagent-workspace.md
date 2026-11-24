# 委譲と作業領域

委譲先は責任の持たせ方で選ぶ。独立した会話・Character・担当状態として成果を追うならWithMateの通常子、Workerが担当内で回収する分業・独立reviewなら許可されたnative子を使う。同じ仕事を二重に渡さない。統括の責任・通常子の選定と配送は[Session間の協同](../guides/withmate-collaboration.md)に従う。nativeは別のWithMate参加者ではなく、製品の通知・返却経路を使う。

## 子の作業領域と親の準備

WithMateの通常Mainは統括・Workerともに1 Sessionにつき1専有Workspaceを使う。起動する直接親が起動前に実体を準備し、その絶対pathを渡す。準備だけのWorkerを立てず、失敗時は子の起動を保留する。他SessionのWorkspaceを共用したり、追加directory経由で直接編集したりしない。許可されたread-only参照は共同編集と区別する。

Git管理下の通常子にはreviewでも専用Worktreeを用い、並行作業は別branchとする。特定commitへの固定は再現・隔離が必要な時に選ぶ。Auxiliaryとnative子には一律の専用Workspaceを課さず、編集所有・衝突・権限と必要な隔離から決める。

## Git worktreeの配置

1. WithMateでは対象repository・branchを `session.resolve_worktree` で解決する。利用可能な既存登録を優先し、返された配置先を使う。未設定なら配置に必要な不足だけ確認する。今回限りの指定は新規候補にだけ適用し、保存方針・既存登録を変更しない。SessionFolder・Crew Folderからpathを組み立てない。
2. 配置候補は実体ではない。直接親が分岐元のbranch・commit、実体とbranch、他Sessionの占有、未コミット変更を確認して必要なGit操作を行う。同じbranchをforceで複数checkoutしない。既存領域の移設・削除・上書きは準備の範囲外。追加writeが要るなら専用の狭い範囲で通常の承認を求め、拒否を権限拡大で迂回しない。
3. 子へ渡すのは利用可能と確かめたWorkspace。WithMateはGitの作成・統合を代行しない。実体・branch・占有が変わった事情がなければ確認結果を再利用できる。

## 非Gitの作業領域

親が専用directoryに必要な入力だけをコピーし、子は原本を直接編集しない。親は受入時の原本と照合し、必要な成果だけを戻す。継続的な並行統合にGitが必要なら提案し、合意なしの `git init` や一括commitはしない。DBや外部サービスなどdirectory分離では保護できない対象は準備前に方式を相談する。

## 作業領域の再利用と回収

同じSession・同じ担当の続きには元の領域を使う。idle・経過日数を理由に待機中・中断中・修正待ちの領域を回収しない。親が回収できるのは、この運用で**新規に作った**子用Worktree、ローカルtask branch、非Git専用領域だけ。既存領域、remote・default・protected branchを含めない。

回収は受入・必要な統合の後に行う。実行中・予約済みの作業や他Sessionの利用がなく、成果・参照資料が保全されていることを確認する。未コミット・未追跡・ignoredのデータも対象とし、未統合commitや採否未決の成果を捨てない。中止・不採用なら保存か破棄かを先に決める。Worktreeとbranchは別々に扱い、通常削除の拒否からforceへ切り替えない。

割当Workspaceの不在で送信が拒否されたら、送信元が元の割当pathに復旧する。Gitなら保存したbranch・commit、非Gitなら保全した入力から再準備する。実体を確認できなければ再送を保留し、自分で復旧できない子へ任せない。再送可否は[受付の証拠](../guides/withmate-collaboration.md#通常送信と実行中の補足)で判断する。専用の回収台帳は作らない。

## nativeサブエージェント

Claude Codeの `Agent` には目的・担当範囲・成果・操作権限と、実際に読める対象path、SessionFolder、必要な採用判断・維持契約を渡す。親の履歴や別Sessionのbindingは仮定しない。共有判断には[設計guide](../guides/design-decisions.md)、reviewには[統合基準](../guides/development.md#統合優先修正分離)を添える。子が取得できないGraph・Glossaryの情報は親が権限内で取得・記録する。

担当は [`agents/`](../../agents/) の定義から、必要な判断と結果で選ぶ。通常の調査・設計・実装は `general_sonnet`、手順と期待結果が定まった作業は `general_sonnet_execution`。難しい反例や契約間の矛盾は非Opus親から問題を絞って `general_opus` へ渡せる。Opus親は自分で判断し、Opus子へ委譲しない。下位modelの試行を条件にはしない。

調査・専門reviewなど読み取りだけを許す依頼は [`read-only`](../../agents/read-only.md) を使う。起動時に実際のtoolがRead・Glob・Grepだけであることを確認する。permissionModeや汎用担当への文面だけでは、shell・編集・MCP writeを制限できない。同名のproject・managed定義が優先される場合も実体を確かめる。read-only担当も必要な判断に合わせてSonnet/medium、手順確定はSonnet/high、高度判断は非Opus親からOpus/mediumを選べる。必要な構成が使えなければ、その委譲に依存する判定を保留する。

起動には現在のtool schemaを使い、実model・effortと権限を確かめる。配布設定の開始値と優先順位は[Claudeの設定案内](../../README.md#modelと担当)を参照する。通知hookは操作やmodelを制限しない。Agentの完了通知で受け取り、必要な根拠と未解決だけを親へ返す。親は共有の変更を保護し、統合・最終確認を行う。変更testの独立審査はruntimeの `review-test-value` Skillに従い、親や汎用担当の自己評価で代替しない。
