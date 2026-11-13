# 委譲と作業領域

## WithMateの通常子Sessionとnativeサブエージェント

独立した会話・Character・実行設定・担当状態として継続して追う仕事はWithMateの通常子Session、担当内で成果を回収・統合する分業は製品nativeのサブエージェントを基本とする。調査／実装／review、規模、長さ、Modelだけで固定せず、分業が不要なら自分で行う。同じ仕事を両方へ重複委譲しない。

WithMateの子は別の参加者であり、[Session間の協同](../guides/withmate-collaboration.md)でRole・背景確認・Coordination・明示報告・Turn終了と再開を扱う。同じ担当範囲の追加依頼には継続可能な既存Sessionを使う。native子は別のWithMate参加者や独立したCharacter Memory／Affect所有者とはみなさず、製品nativeの通知・返却・待機契約を使う。

どちらも既存の委譲許可、必須専門審査、操作権限とruntime制限に従う。以下のnative用model・tool制限をWithMate全Providerのallowlistへ広げず、WithMateのカタログをnativeの許可拡大にも使わない。WithMate通常子の[実行条件の選定](../guides/withmate-collaboration.md#実行条件の選定)は協同guideに従う。

## nativeサブエージェント

委譲前に読む。汎用`general_sonnet`、`general_sonnet_execution`、`general_opus`と`read-only`担当へ、対象、必要な結果、権限を依頼ごとに渡す。調査だけの依頼では編集しない。履歴継承に頼らず、review依頼には主要動作、後続の依存、[開発・review・統合](../guides/development.md)の統合基準と、非ブロッカーを全件修正待ちにしないことを含める。必要な参照先は参照元文書から解決した実pathで渡し、全規約を無条件に複製しない。

委譲時は現在のSessionFolderと、作業に必要な共有情報・参照先を渡す。子がtool制限等でMemory・Session Graph・Glossaryを直接利用できない場合は、親が許可範囲内で必要な取得・記録を担い、子へ必要な結果を渡す。子のtool権限とSession bindingの制約を守る。

共有する設計判断に関わる依頼では、必要な要求・前提、採用済みの判断と適用状況、未合意事項、[設計判断・文書化](../guides/design-decisions.md)の参照先も渡す。同じ前提の判断を再利用し、現行実装や草案を採用根拠に置き換えない。不足の調査・推奨案・草案作成までを依頼できるが、親からの委譲を未合意方針の採用や操作権限の拡大と解釈しない。

## modelと担当の選択

native子の使用modelは`claude-sonnet-5-5`と`claude-opus-5-5`。設定値と採用理由は[README](../../README.md#modelと担当)に記載する。

- Sonnetを通常の親と一般childの既定にする。`general_sonnet`は調査、設計、実装、debug、reviewを担当する。
- `general_sonnet_execution`は、進め方・手順・期待結果がほぼ決まっている抽出、定型調査、設計済みの実装、判断済みの基準に沿った照合等を担当する。範囲が小さいことだけで選ばず、未解決の設計・安全性の判断を押し込まない。
- `general_opus`は、高度な判断が要求される設計の選択、契約間の矛盾の解消、難しい反例の検討等を、非Opus親から必要な問題に絞って渡す場合に使う。Opus親はその判断を自ら担当し、Opus親からOpus子への委譲は禁止する。

上位modelの選択に下位modelの失敗を要求せず、作業に必要な判断で直接選ぶ。形式的な試行、念のための多重reviewは追加しない。専門審査の手順と必須条件は該当Skillに従う。modelの変更を審査免除や権限拡大に使わない。

read-only依頼にも同じ判断基準を使い、tool制限を持つ`read-only`担当を選ぶ。既定はSonnet/mediumで、手順確定の作業は必要に応じてSonnet/high、高度判断は非Opus親からOpus/mediumをper-callで指定する。汎用担当へread-onlyと書くだけで、このtool制限を代替しない。

## runtimeと権限

ユーザーの明示指定は尊重し、指定がなければ上記の担当分けと開始値を使う。指定modelがruntimeで利用できない場合は許可された構成の親で可能な範囲を続ける。親の自己評価で審査済みにしない。

role名だけで実modelを推測せず、起動するsessionのmodel IDとeffortを確認する。Claudeではper-callのmodelがfrontmatterより優先され、`CLAUDE_CODE_EFFORT_LEVEL`は担当別effortより優先される。`CLAUDE_CODE_SUBAGENT_MODEL_FORCE`で全担当を同じmodelへ固定したり、一律のeffort環境変数で担当の開始値を潰したりしない。project・managedの同名定義やhost設定が優先される場合は、その実体と実効値を確認する。

親は起動前に自分のmodelと委譲先を確認し、上記の担当分けに従って子を選ぶ。

Agent起動は現在のtool schemaに従う。対象・必要な文脈・完了条件を起動時の依頼へ含め、親の会話や既読fileが子へ渡ることを前提にしない。設定例は`CLAUDE_CODE_FORK_SUBAGENT=0`で履歴forkを無効にし、`CLAUDE_CODE_MAX_SUBAGENT_SPAWN_DEPTH=1`で子から孫への委譲を無効にする。必要な資料だけを渡す通常の独立した委譲を使い、設定例を配置しただけで実効性を確認済みとしない。

read-onlyの依頼は文面だけでなく、利用するagentのtool制限と実効権限を確認する。permissionModeだけを読み取り専用の保証にしない。shell、編集・write、外部writeを行えるMCP等を一律に引き継いだまま、制限済みと報告しない。必要なread-only構成が利用できない場合は、その委譲に依存する完了判断を止め、権限を無断で追加・迂回しない。

本repositoryの汎用read-only担当は[`agents/read-only.md`](../../agents/read-only.md)である。toolはRead・Glob・Grepだけに限定する。review観点は依頼ごとに渡し、test専用roleにはしない。runtimeでこの担当と有効なtool構成を確認し、同名のproject・managed定義が優先される場合はその実体を確認する。

待機・再開・結果取得はClaudeの現在のAgent契約に従い、通知と完了見込みを使う。短い間隔のポーリングを避ける。

## 統合と成果返却

test価値reviewの抽出、read-onlyサブエージェントへの委譲、review観点、完了判断は、runtimeが提供するreview-test-value Skillを正本とする。専用roleや独自のworker、scheduler、artifact storeは使わない。必須Skillやread-only担当が利用できない場合も審査を免除しない。

同じworking treeで作業する場合は編集範囲と生成物の競合を避け、ユーザーと他の担当の変更を保護する。子は結果、根拠、実行した確認、未解決事項を親へ返し、親が統合と最終確認を行う。通常の成果返却に専用文書は不要である。

親は上記の開発・統合基準で指摘の採否と対応時期を判断し、今回の仕上げと後追いを分ける。非ブロッカーを一律に別タスク化せず、後追いの着手・完了を現在の変更の完了・統合条件にしない。

## Git worktreeの配置

worktreeやcommit固定は具体的な隔離・再現の必要に応じて使い、全reviewへ一律には要求しない。

WithMateでの配置先取得と結果の使い分けは、協同guideの[Worktreeの配置先](../guides/withmate-collaboration.md#worktreeの配置先)を正本とする。ここでは独自のroot・分類・layoutやpath組み立てを定義しない。

親が、登録先の実体とbranch、分岐元のbranch・commit、作成先の占有、未コミット変更を確認し、必要なGit操作を行う。配置候補の取得を作成済み・利用可能の証拠とせず、準備した実体の絶対pathを子のWorkspaceへ渡す。既存worktreeの移設・削除や他者の作業領域の上書きは、この準備の許可に含めない。
