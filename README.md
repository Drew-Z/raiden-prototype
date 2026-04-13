# Raiden Prototype

一个基于 Godot 4.6.1 的纵版射击展示原型，用来验证并演示短局街机射击的节奏、成长、资源决策、Boss 收束，以及两关章节串联是否成立。

## 当前阶段目标

- 把短局原型推进成更适合展示的街机射击案例
- 强化战斗可读性、阶段提示和 Boss 段落完成感
- 强化火力成长、炸弹决策和一局结束后的总结反馈
- 保持单关短流程，但让开始、战斗、结算更完整

## 当前可玩内容

- 主菜单与开始游戏
- 主菜单可选择 `Stage 01`、`Stage 02` 与 `Chapter Run`
- 纵向卷轴战斗场景
- 玩家移动、持续自动射击、受伤、死亡
- 多波敌群编队进入，包含点射压位机、切线突进机、屏障火力机与补给载具
- 敌人概率掉落火力升级道具
- 玩家拾取升级并提升火力等级
- 炸弹资源与主动清屏
- 一个带阶段变化的小型 Boss 段落
- HUD 显示生命、火力、炸弹、分数、阶段进度、战场建议与 Boss 血条
- 死亡或通关后的结果页，含成绩标签和奖励拆分
- 章节模式下的关卡衔接、资源继承与章节总结
- 暂停、重开、返回主菜单与上一局结果回显

## 操作说明

- 移动：`WASD` / 方向键
- 炸弹：`Space` / `Shift` / `X`
- 射击：自动持续开火

## 一局体验结构

1. 从主菜单进入战斗场景。
2. 在短时间内连续应对数波不同编队的杂兵。
3. 通过击破敌人争取火力升级，逐步从单发成长到多发。
4. 在高压时刻使用炸弹清弹并处理压场敌群。
5. 进入 Boss 段落，在阶段变化和炸弹窗口中完成压制。
6. 击破 Boss 后进入短促收束演出，再进入结果页查看奖励拆分与本局总结。
7. 在 `Chapter Run` 中，`Stage 01` 通关后会保留生命、火力并获得最小炸弹补给，再进入 `Stage 02`。

## 当前章节结构

- `Stage 01 // Scramble`：当前最完整的展示路线，用于表现节奏、成长与 Boss 收束
- `Stage 02 // Storm Front`：已打磨为可展示的第二关，强化侧压、屏障火力、压制扇面敌机和更重的 Boss 压迫
- `Chapter Run`：`Stage 01 -> Stage 02` 的双关章节流，用于验证资源继承和更长短流程的成立性

## 当前版本定位

- 当前状态：双关可展示原型，已完成单局展示、章节串联、章节收束和第二关敌群深化验证
- 开发阶段：已完成“最小可玩验证”“展示可读性强化”“视听反馈强化”“第二关骨架验证”“双关章节串联验证”“第二关展示打磨”和“章节收束增强”，正在向“垂直切片早期”推进
- 当前重点：继续深化第二关与第一关的差异、抬高章节演出完成度，并评估是否进入更完整的双关垂直切片

## 运行方式

如果本机 Godot 位于 `D:\Development\Godot`，可直接在项目根目录运行：

```bash
"D:/Development/Godot/Godot_v4.6.1-stable_win64.exe" --path "D:/workspace4Codex/raiden prototype"
```

Headless 验证示例：

```cmd
set APPDATA=D:\workspace4Codex\raiden prototype\.godot-user
set LOCALAPPDATA=D:\workspace4Codex\raiden prototype\.godot-user
"D:\Development\Godot\Godot_v4.6.1-stable_win64_console.exe" --headless --path "D:\workspace4Codex\raiden prototype" --fixed-fps 60 --quit-after 4200 -- --autoplay
```

双关章节验证示例：

```cmd
set APPDATA=D:\workspace4Codex\raiden prototype\.godot-user
set LOCALAPPDATA=D:\workspace4Codex\raiden prototype\.godot-user
"D:\Development\Godot\Godot_v4.6.1-stable_win64_console.exe" --headless --path "D:\workspace4Codex\raiden prototype" --fixed-fps 60 --quit-after 9000 -- --autoplay --chapter
```

## 目录结构

- `project.godot`：项目配置与入口场景
- `scenes/ui`：主菜单与结果页场景
- `scenes/game`：战斗场景
- `scripts/autoload`：全局运行状态与场次统计
- `scripts/entities`：玩家、敌人、掉落
- `scripts/game`：子弹、关卡编排、战斗主流程、背景滚动
- `scripts/ui`：HUD 与界面逻辑

## 文档

- [第一阶段设计文档](D:/workspace4Codex/raiden prototype/docs/phase-1-design.md)
- [开发与验证说明](D:/workspace4Codex/raiden prototype/docs/development.md)
- [当前进度记录](D:/workspace4Codex/raiden prototype/docs/progress.md)
