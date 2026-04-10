# Raiden Prototype

一个基于 Godot 4.6.1 的纵版射击最小可玩原型，用来验证第一阶段的核心玩法闭环是否成立。

## 当前阶段目标

- 验证纵版卷轴战斗的阅读性与短局节奏
- 验证敌群编排是否能支撑从开局到 Boss 的压力曲线
- 验证火力升级是否带来明确成长反馈
- 验证炸弹资源是否能在高压时刻形成有效逆转
- 验证一局结束后的结果页总结是否足够支撑复盘

## 当前可玩内容

- 主菜单与开始游戏
- 纵向卷轴战斗场景
- 玩家移动、持续自动射击、受伤、死亡
- 多波敌群编队进入
- 敌人概率掉落火力升级道具
- 玩家拾取升级并提升火力等级
- 炸弹资源与主动清屏
- 一个小型 Boss 段落
- HUD 显示生命、火力、炸弹、分数与 Boss 血条
- 死亡或通关后的结果页

## 操作说明

- 移动：`WASD` / 方向键
- 炸弹：`Space` / `Shift` / `X`
- 射击：自动持续开火

## 一局体验结构

1. 从主菜单进入战斗场景。
2. 在短时间内连续应对数波不同编队的杂兵。
3. 通过击破敌人争取火力升级，逐步从单发成长到多发。
4. 在高压时刻使用炸弹清弹并处理压场敌群。
5. 进入 Boss 段落，完成击破或失败结算。
6. 在结果页查看分数、击破率、最高火力与本局火力路线。

## 运行方式

如果本机 Godot 位于 `D:\Development\Godot`，可直接在项目根目录运行：

```powershell
& 'D:\Development\Godot\Godot_v4.6.1-stable_win64.exe' --path 'D:\workspace4Codex\raiden prototype'
```

Headless 验证示例：

```powershell
$env:APPDATA='D:\workspace4Codex\raiden prototype\.godot-user'
$env:LOCALAPPDATA='D:\workspace4Codex\raiden prototype\.godot-user'
& 'D:\Development\Godot\Godot_v4.6.1-stable_win64_console.exe' --headless --path 'D:\workspace4Codex\raiden prototype' --fixed-fps 60 --quit-after 3600 -- --autoplay
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

