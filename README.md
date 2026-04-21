# Raiden Prototype

一个基于 Godot 4.6.1 的纵版射击展示原型，用来验证并展示短局街机射击的节奏、成长、资源决策、Boss 收束，以及双关章节串联是否成立。

## 当前版本

- 版本标识：`RC-0.4`
- 当前定位：稳定展示候选版
- 推荐入口：`Chapter Run`
- 推荐验证：`tools/run_showcase_verification.cmd`

## 当前阶段目标

- 保留 `RC-0.4` 作为稳定展示基线
- 进入公开 Demo 准备阶段，优先补首屏体验、外部试玩、发布包和素材授权清单
- 暂时不继续横向堆系统，先确认真实玩家是否认可当前双关节奏
- 当前主菜单已按 Demo 试玩重排：优先显示完整 Demo 入口，单关入口作为可选练习路线保留
- 当前已启动视听第一印象打磨：主菜单动态背景、玩家机轮廓、爆炸层次和混音疲劳度进入 Demo 2 调整范围

## 当前可玩内容

- 主菜单，可选择 `Stage 01`、`Stage 02` 和 `Chapter Run`
- 玩家移动、自动持续射击、受伤、死亡
- 敌群编排、掉落升级、火力成长、炸弹清屏
- 两个可打通的关卡：`Stage 01 // Scramble` 与 `Stage 02 // Storm Front`
- 第一关到第二关的章节继承：生命、炸弹、火力可跨关保留
- 第一关结算后的独立 `ChapterBriefing` 中场过场
- 双关通关后的独立 `ChapterEnding` 章节结尾镜头
- 双关结束后的独立 `ChapterOutro` 章节尾声
- `ChapterEnding` 现在带 route seal 封板、路线收束带和章节结尾提示音
- 第二关新增风暴十字封线互动，纵向落雷会与横向扫掠共同压缩安全区域，并可带出支援敌群
- 第二关 Boss 现在也会在相位切换和 overdrive 时带出风暴机关联动
- 第二关 Boss 终盘现在带有更明确的“最后安全窗口”预警
- Boss 段落、HUD、结果页、章节总评和重开流程

## 当前一条完整体验

1. 从主菜单进入 `Stage 01` 或 `Chapter Run`
2. 在短局战斗中通过击破敌人获取火力升级，逐步成长到高火力
3. 在高压波次和 Boss 段落中使用炸弹维持节奏
4. 通关 `Stage 01` 后进入结果页，并在章节模式下转入 `ChapterBriefing`
5. 经 briefing 确认继承装载后进入 `Stage 02`
6. 通关双关后进入结果页，并在章节模式下依次转入 `ChapterEnding -> ChapterOutro`

## 当前章节结构

- `Stage 01 // Scramble`：当前最完整的展示开场，负责建立成长、炸弹节奏和 Boss 收束
- `Stage 02 // Storm Front`：更强调侧压、风暴互动、屏障火力和更重的 Boss 压迫
- `Stage 02 // Storm Front`：中后段已接入 `storm_cross` 十字封线，并会带出支援敌群，开始形成更明确的环境联动
- `Stage 02 // Storm Front`：Boss 相位切换和 overdrive 现在也会接入风暴机关，关底段落更像完整关卡高潮
- `Stage 02 // Storm Front`：Boss 终盘现在会明确提示 `LAST SAFE WINDOW -> OVERDRIVE -> FINISH WINDOW` 三段决策节拍
- `Stage 02 // Storm Front`：`FINISH WINDOW` 现在会带出独立 `FINAL BREACH` 终盘编排，最终破口更像正式关底收束
- `Chapter Run`：`Stage 01 -> Results -> ChapterBriefing -> Stage 02 -> Results -> ChapterEnding -> ChapterOutro`
- `ChapterEnding`：现在会额外显示 `SLICE VERDICT` 和三张章节评审就绪卡，用来总结当前 build 的收口状态
- `ChapterEnding`：现在还会显示 `FINAL PASS` 面板，把当前 build 是否适合作为 review build 展示说得更明确
- 主菜单现在会直接显示当前 build 状态和封版摘要
- `ChapterOutro` 现在会直接给出 `FINAL PACKAGE` 与 `NEXT STEP`，方便把当前版本作为封版候选阅读

## 当前版本定位

- 当前状态：稳定展示候选版
- 所处阶段：双关垂直切片已经完成展示候选收口
- 当前重点：发布包装、人工试玩微调和正式资源替换，而不是继续默认扩系统

## 操作说明

- 移动：`WASD` / 方向键
- 炸弹：`Space` / `Shift` / `X`
- 射击：自动持续开火
- 继续 / 确认：`Enter`
- 重开：`R`
- 返回：`Esc`

## 运行方式

如果本机 Godot 位于 `D:\Development\Godot`，可在项目根目录运行：

```bash
"D:/Development/Godot/Godot_v4.6.1-stable_win64.exe" --path "D:/workspace4Codex/raiden prototype"
```

推荐本地试玩：

```cmd
tools\run_local_debug.cmd
```

推荐展示版自检：

```cmd
tools\run_showcase_verification.cmd
```

推荐 Demo 就绪检查：

```cmd
tools\run_demo_readiness_check.cmd
```

准备外部试玩资料夹：

```cmd
tools\prepare_playtest_packet.cmd
```

可选打包脚本：

```cmd
tools\prepare_showcase_package.cmd
```

打包脚本会在 `dist` 下生成带随机后缀的 `raiden-prototype-showcase-rc-0.4-*.zip`，方便反复验证时避开旧包权限残留。

Headless 单关验证示例：

```cmd
set APPDATA=D:\workspace4Codex\raiden prototype\.godot-user
set LOCALAPPDATA=D:\workspace4Codex\raiden prototype\.godot-user
"D:\Development\Godot\Godot_v4.6.1-stable_win64_console.exe" --headless --path "D:\workspace4Codex\raiden prototype" --fixed-fps 60 --quit-after 6200 -- --autoplay
```

双关章节验证示例：

```cmd
set APPDATA=D:\workspace4Codex\raiden prototype\.godot-user
set LOCALAPPDATA=D:\workspace4Codex\raiden prototype\.godot-user
"D:\Development\Godot\Godot_v4.6.1-stable_win64_console.exe" --headless --path "D:\workspace4Codex\raiden prototype" --fixed-fps 60 --quit-after 11600 -- --autoplay --chapter
```

## 目录结构

- `project.godot`：项目配置与入口场景
- `scenes/ui`：主菜单、结果页、章节 briefing、章节 ending、章节 outro
- `scenes/game`：战斗场景
- `scripts/autoload`：全局运行状态、章节状态和结算数据
- `scripts/entities`：玩家、敌人、掉落等实体逻辑
- `scripts/game`：关卡数据、战斗流程、Boss、特效、环境互动
- `scripts/ui`：HUD、菜单、结果页、章节过场、章节 ending 和章节尾声

## 文档

- [第一阶段设计文档](D:/workspace4Codex/raiden prototype/docs/phase-1-design.md)
- [开发与验证说明](D:/workspace4Codex/raiden prototype/docs/development.md)
- [当前进度记录](D:/workspace4Codex/raiden prototype/docs/progress.md)
- [双关垂直切片评估](D:/workspace4Codex/raiden prototype/docs/vertical-slice-review.md)
- [封版总结](D:/workspace4Codex/raiden prototype/docs/final-slice-summary.md)
- [最终项目总总结](D:/workspace4Codex/raiden prototype/docs/final-project-report.md)
- [当前封版候选说明](D:/workspace4Codex/raiden prototype/docs/release-candidate-note.md)
- [最终交付说明](D:/workspace4Codex/raiden prototype/docs/final-delivery-note.md)
- [当前封版交接说明](D:/workspace4Codex/raiden prototype/docs/final-handoff-note.md)
- [最终封版清单](D:/workspace4Codex/raiden prototype/docs/final-freeze-checklist.md)
- [人工演示步骤说明](D:/workspace4Codex/raiden prototype/docs/manual-demo-guide.md)
- [当前封版公告](D:/workspace4Codex/raiden prototype/docs/final-release-announcement.md)
- [稳定展示版说明](D:/workspace4Codex/raiden prototype/docs/stable-showcase-release.md)
- [展示版 QA 记录](D:/workspace4Codex/raiden prototype/docs/showcase-qa-report.md)
- [展示候选打包清单](D:/workspace4Codex/raiden prototype/docs/release-package-checklist.md)
- [公开 Demo 准备路线](D:/workspace4Codex/raiden prototype/docs/public-demo-roadmap.md)
- [商业成品差距分析](D:/workspace4Codex/raiden prototype/docs/commercial-gap-analysis.md)
- [外部试玩计划](D:/workspace4Codex/raiden prototype/docs/external-playtest-plan.md)
- [试玩者快速说明](D:/workspace4Codex/raiden prototype/docs/playtest-quick-start.md)
- [试玩反馈表](D:/workspace4Codex/raiden prototype/docs/playtest-feedback-form.md)
- [试玩场次记录模板](D:/workspace4Codex/raiden prototype/docs/playtest-session-notes.md)
- [试玩反馈决策矩阵](D:/workspace4Codex/raiden prototype/docs/playtest-decision-matrix.md)
