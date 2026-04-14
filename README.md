# Raiden Prototype

一个基于 Godot 4.6.1 的纵版射击展示原型，用来验证并展示短局街机射击的节奏、成长、资源决策、Boss 收束，以及双关章节串联是否成立。

## 当前阶段目标

- 把短局原型推进成更适合展示的街机射击案例
- 让单关展示提升为双关章节展示，并补齐章节交接与章节尾声
- 在不做大规模资源替换的前提下，持续强化可读性、反馈和演出完成度

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
- `Chapter Run`：`Stage 01 -> Results -> ChapterBriefing -> Stage 02 -> Results -> ChapterEnding -> ChapterOutro`

## 当前版本定位

- 当前状态：双关可展示原型
- 所处阶段：已经完成最小可玩闭环，正在向双关垂直切片早期推进
- 当前重点：按路线 A 持续把双关 build 往“可交付垂直切片”方向收口

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
