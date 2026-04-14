# 开发与验证说明

## 环境

- 引擎版本：Godot 4.6.1
- 当前本地可执行文件路径：`D:\Development\Godot\Godot_v4.6.1-stable_win64.exe`
- 控制台版本路径：`D:\Development\Godot\Godot_v4.6.1-stable_win64_console.exe`

## 主要场景

- `res://scenes/ui/MainMenu.tscn`
- `res://scenes/ui/ChapterBriefing.tscn`
- `res://scenes/ui/ChapterEnding.tscn`
- `res://scenes/ui/ChapterOutro.tscn`
- `res://scenes/game/Game.tscn`
- `res://scenes/ui/ResultsScreen.tscn`

## 主要脚本

- `res://scripts/autoload/run_state.gd`
- `res://scripts/game/game_stage2.gd`
- `res://scripts/game/stage_catalog.gd`
- `res://scripts/game/stage_data_v2.gd`
- `res://scripts/game/stage_data_v3.gd`
- `res://scripts/game/storm_sweep.gd`
- `res://scripts/entities/player.gd`
- `res://scripts/entities/enemy.gd`
- `res://scripts/entities/pickup.gd`
- `res://scripts/ui/hud_v2.gd`
- `res://scripts/ui/chapter_briefing.gd`
- `res://scripts/ui/chapter_ending.gd`
- `res://scripts/ui/chapter_outro.gd`
- `res://scripts/ui/main_menu_stage2.gd`
- `res://scripts/ui/results_screen_stage2.gd`

## 本地运行

```cmd
"D:\Development\Godot\Godot_v4.6.1-stable_win64.exe" --path "D:\workspace4Codex\raiden prototype"
```

## Headless 自动验证

项目内置了 `--autoplay` 验证模式，用于快速跑通单关并输出结果统计。

```cmd
set APPDATA=D:\workspace4Codex\raiden prototype\.godot-user
set LOCALAPPDATA=D:\workspace4Codex\raiden prototype\.godot-user
"D:\Development\Godot\Godot_v4.6.1-stable_win64_console.exe" --headless --path "D:\workspace4Codex\raiden prototype" --fixed-fps 60 --quit-after 5200 --log-file stage6_stage2.log -- --autoplay --stage2
```

双关章节验证可以使用：

```cmd
set APPDATA=D:\workspace4Codex\raiden prototype\.godot-user
set LOCALAPPDATA=D:\workspace4Codex\raiden prototype\.godot-user
"D:\Development\Godot\Godot_v4.6.1-stable_win64_console.exe" --headless --path "D:\workspace4Codex\raiden prototype" --fixed-fps 60 --quit-after 13600 --log-file stage14_chapter.log -- --autoplay --chapter
```

输出中会打印类似：

```text
RUN_RESULT victory=true score=23630 kill_rate=85.71 max_fire=5 route=Lv1 -> Lv2 -> Lv3 -> Lv4 -> Lv5 bombs_used=3 lives=3
RUN_RESULT victory=true score=28025 kill_rate=96.25 max_fire=5 route=Lv5 bombs_used=2 lives=3
CHAPTER_RESULT victory=true total_score=51655 kill_rate=90.85 stages=2 highest_fire=5
```

## 当前验证结论

已验证通过的点：

- 可以从主菜单进入 `Stage 01`、`Stage 02` 和 `Chapter Run`
- 可以从主菜单进入 `Chapter Run` 并连续完成两关
- 敌群波次、阶段提示与 Boss 段落能正常衔接
- 火力能稳定从 Lv1 成长到 Lv5
- 炸弹能触发清弹、压制 Boss 并形成资源提示
- 通关后会触发 Boss 击破收束并进入结果页
- 结果页会显示奖励拆分、成绩标签、章节交接与下一步建议
- `Stage 01 -> Stage 02` 会正确继承生命、炸弹与火力，并在结果页承接下一关
- `Stage 01 -> Results -> ChapterBriefing -> Stage 02 -> Results -> ChapterEnding -> ChapterOutro` 这条链路已经可以完整跑通
- 第二关新的 `storm_cross` 十字封线和支援敌群联动可以与章节链路共存，不会打断 `--autoplay --chapter`
- 第二关 Boss 相位切换和 overdrive 触发的风暴机关也可以与章节链路共存，不会打断 `--autoplay --chapter`
- 第二关 Boss 终盘现在会依次触发 `LAST SAFE WINDOW` 与 `FINISH WINDOW`，终盘读图和资源决策更清楚
- 第二关 Boss 终盘现在还会补一段 `FINAL BREACH` 终盘编排，把最终破口和中心突破线讲得更直接

## 当前结构说明

- 第一阶段旧脚本仍保留在仓库中，便于对照，但当前主流程已切到 `stage2` 版本脚本
- 当前战斗主流程已经从“写死单关”切到“由 `stage_catalog.gd` 选择关卡数据脚本”的结构
- 当前战斗主流程已经支持 `Stage 01`、`Stage 02` 与 `Chapter Run` 三种入口
- `Chapter Run` 现在带有独立的 `ChapterBriefing` 中场场景和 `ChapterOutro` 章节尾声，不再由结果页单独承担完整章节包装
- `Chapter Run` 现在还带有独立的 `ChapterEnding` 收束场景，用来承接双关完成后的章节镜头
- 第二关单独入口现在使用展示用中段装载，更接近章节第二段的真实体验
- 战斗反馈相关模块目前拆在：
  - `res://scripts/game/bomb_effect.gd`
  - `res://scripts/game/impact_effect.gd`
  - `res://scripts/game/explosion_effect.gd`
  - `res://scripts/game/score_popup.gd`
  - `res://scripts/game/sfx_controller.gd`
  - `res://scripts/game/bgm_controller.gd`
- 当前有一套程序生成的占位音效和占位音乐；正常游玩会启用，`headless` 自动验证中不会创建音频节点，以保证日志更干净
- Boss 现在带有相位切换后的“核心暴露”短窗口，相关状态仍集中在 `enemy.gd` 与 `game_stage2.gd`，便于后续继续扩展弱点或破甲机制
- `Stage 02` Boss 已拆出独立 `storm` 风格，仍然复用通用 Boss 管线，但火力节奏、外观和文案已可单独配置
- 第二关新增的 `suppressor` 敌机职责使用宽扇面火力做路线封锁，和 `screener`、`pincer` 的作用已经明确区分
- 第二关新增的 `storm_strike` 互动点由独立脚本 `storm_strike.gd` 管理，通过时间轴事件触发，不和常规敌机逻辑混在一起
- 第二关新增的 `storm_sweep` 互动点由独立脚本 `storm_sweep.gd` 管理，并可通过 `storm_cross` 事件与 `storm_strike` 组合
- `storm_cross` 现在还支持通过事件数据带出 `support_wave`，用于把环境机关和支援敌群编排在同一个节奏点里
- `stage_data_v3.gd` 的 Boss 配置现在也支持 `phase_2_hazard`、`phase_3_hazard` 和 `overdrive_hazard`
- `starfield.gd` 现在支持按关卡主题切换背景视觉，第二关会使用更明显的风暴主题层
- 结果页已改为脚本构建的展示面板，统计、战绩摘要和下一步建议仍统一从 `run_state.gd` 取数，便于后续继续补动画或更多复盘指标
- Boss 击破后的战场清场总结卡由 `hud_v2.gd` 承担，只在收束阶段短暂显示，结果页仍负责最终复盘
- 事件卡现在支持带时长的临时提示，关卡事件可以在 `stage_data_v2.gd` 和 `stage_data_v3.gd` 里直接附加 `detail`、`card_duration` 和 `card_color`
- Boss 相位切换与 overdrive 的战术提示目前仍由 `game_stage2.gd` 触发，因为它们依赖运行中的血量状态，而不是固定时间轴事件
- 侧入波次的边缘预警目前由 `game_stage2.gd` 在刷波前触发，HUD 只提供左右入口提示接口，不负责解析波次数据
- 新增的 `screener` 敌机职责已经接入通用敌人脚本；第二关主要用它来验证“屏障火力”在关卡中的可读性和成本
- `RunState` 现在既负责单关统计，也负责双关章节模式、阶段交接资源和章节总计
- `RunState` 现在还负责章节总评、章节交接文案和双关结束后的总成绩摘要
- 结果页在章节模式下现在只负责阶段结算与跳转，不再单独承接完整章节尾声
- 结果页在章节完成后现在会先进入 `ChapterEnding`，再进入 `ChapterOutro`
- `ChapterBriefing` 和 `ChapterOutro` 现在都会展示章节卡片，让双关路线在中场和尾声里更容易阅读
- `ChapterOutro` 现在会先播一个短暂的 ending 封板，再进入完整 debrief 面板
- Boss 级风暴联动依然通过主控触发、数据脚本配置的方式接入，没有把环境逻辑重新塞回敌人脚本
- 当前仓库里已经补了一份 `docs/vertical-slice-review.md`，用于明确判断当前 build 是否进入双关垂直切片收口阶段
- `ChapterEnding` 现在还会播放独立章节结尾提示音，并先给出 route seal 封板，再展开完整 ending 内容
- `ChapterEnding` 现在还会显示 `SLICE VERDICT` 与章节评审就绪卡，方便把当前 build 直接作为 review build 说明
- `ChapterEnding` 现在再补了一张 `FINAL PASS` 面板，用来明确当前章节是否已经处在 review-ready 状态
- 主菜单现在会直接显示当前 build 状态摘要，`ChapterOutro` 也会直接给出封版 package 结论与下一步建议
- 第二关 Boss 现在还带有独立的“最后安全窗口”提示，用于更明确地暴露 overdrive 前的资源决策点
- 章节结束后的 `Retry` 现在可以直接重开整个 `Chapter Run`，不会误重开为单独第二关
- 如果继续扩展展示层，建议优先沿用现有模块，不要把反馈逻辑重新塞回主控

## 提交建议

- 不要提交 `.godot-user`、日志或其他临时验证文件
- 如果后续加入素材资源，优先维持场景与脚本模块边界
- 新增敌群时优先改 `stage_data_v2.gd` 或 `stage_data_v3.gd`，避免把时间轴逻辑散落到主流程里
- 继续推进时建议按“大阶段”同步更新 README 和 `docs/progress.md`
- 路线 A 已经进入封版总结阶段，后续更适合做演示包装、最终总结和范围冻结，而不是继续扩系统
- 当前仓库还补了一份 `docs/final-project-report.md`，用来把项目定位、完成度、亮点和后续建议一次性收口
