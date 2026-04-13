# 开发与验证说明

## 环境

- 引擎版本：Godot 4.6.1
- 当前本地可执行文件路径：`D:\Development\Godot\Godot_v4.6.1-stable_win64.exe`
- 控制台版本路径：`D:\Development\Godot\Godot_v4.6.1-stable_win64_console.exe`

## 主要场景

- `res://scenes/ui/MainMenu.tscn`
- `res://scenes/game/Game.tscn`
- `res://scenes/ui/ResultsScreen.tscn`

## 主要脚本

- `res://scripts/autoload/run_state.gd`
- `res://scripts/game/game_stage2.gd`
- `res://scripts/game/stage_data_v2.gd`
- `res://scripts/entities/player.gd`
- `res://scripts/entities/enemy.gd`
- `res://scripts/entities/pickup.gd`
- `res://scripts/ui/hud_v2.gd`
- `res://scripts/ui/main_menu_stage2.gd`
- `res://scripts/ui/results_screen_stage2.gd`

## 本地运行

```cmd
"D:\Development\Godot\Godot_v4.6.1-stable_win64.exe" --path "D:\workspace4Codex\raiden prototype"
```

## Headless 自动验证

项目内置了一个 `--autoplay` 验证模式，用于快速跑通一局并输出结果统计。

```cmd
set APPDATA=D:\workspace4Codex\raiden prototype\.godot-user
set LOCALAPPDATA=D:\workspace4Codex\raiden prototype\.godot-user
"D:\Development\Godot\Godot_v4.6.1-stable_win64_console.exe" --headless --path "D:\workspace4Codex\raiden prototype" --fixed-fps 60 --quit-after 4200 --log-file stage3_smoke3.log -- --autoplay
```

输出中会打印类似：

```text
RUN_RESULT victory=true score=16070 kill_rate=83.33 max_fire=5 route=Lv1 -> Lv2 -> Lv3 -> Lv4 -> Lv5 bombs_used=2 lives=3
```

## 当前验证结论

已验证通过的点：

- 可以从主菜单进入战斗并完成一局
- 敌群波次、阶段提示与 Boss 段落能正常衔接
- 火力能稳定从 Lv1 成长到 Lv5
- 炸弹能触发清弹、压制 Boss 并形成资源提示
- 通关后会触发 Boss 击破收束并进入结果页
- 结果页会显示奖励拆分、成绩标签和下一步建议

## 当前结构说明

- 第一阶段旧脚本仍保留在仓库中，便于对照，但当前主流程已切到 `stage2` 版本脚本
- 战斗反馈相关模块目前拆在：
  - `res://scripts/game/bomb_effect.gd`
  - `res://scripts/game/impact_effect.gd`
  - `res://scripts/game/explosion_effect.gd`
- 如果继续扩展展示层，建议优先沿用现有模块，不要把反馈逻辑重新塞回主控

## 提交建议

- 不要提交 `.godot-user`、日志或其他临时验证文件
- 如果后续加入素材资源，优先维持场景与脚本模块边界
- 新增敌群时优先改 `stage_data_v2.gd`，避免把时间轴逻辑散落到主流程里
- 继续推进时建议按“小阶段”更新 README 和 `docs/progress.md`
