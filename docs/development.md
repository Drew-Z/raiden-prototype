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
- `res://scripts/game/game.gd`
- `res://scripts/game/stage_data.gd`
- `res://scripts/entities/player.gd`
- `res://scripts/entities/enemy.gd`
- `res://scripts/entities/pickup.gd`
- `res://scripts/ui/hud.gd`

## 本地运行

```powershell
& 'D:\Development\Godot\Godot_v4.6.1-stable_win64.exe' --path 'D:\workspace4Codex\raiden prototype'
```

## Headless 自动验证

项目内置了一个 `--autoplay` 验证模式，用于快速跑通一局并输出结果统计。

```powershell
$env:APPDATA='D:\workspace4Codex\raiden prototype\.godot-user'
$env:LOCALAPPDATA='D:\workspace4Codex\raiden prototype\.godot-user'
& 'D:\Development\Godot\Godot_v4.6.1-stable_win64_console.exe' `
  --headless `
  --path 'D:\workspace4Codex\raiden prototype' `
  --fixed-fps 60 `
  --quit-after 3600 `
  -- --autoplay
```

输出中会打印类似：

```text
RUN_RESULT victory=true score=6080 kill_rate=70.97 max_fire=4 route=Lv1 -> Lv2 -> Lv3 -> Lv4 bombs_used=2 lives=3
```

## 当前验证结论

已验证通过的点：

- 可以从主菜单进入战斗并完成一局
- 敌群波次与 Boss 能正常衔接
- 火力能明确从 Lv1 成长到更高等级
- 炸弹能触发清弹和对敌伤害
- 通关后能进入结果页并显示关键总结信息

## 提交建议

- 不要提交 `.godot-user`、日志或其他临时验证文件
- 如果后续加入素材资源，优先维持场景与脚本模块边界
- 新增敌群时优先改 `stage_data.gd`，避免把时间轴逻辑散落到主流程里

