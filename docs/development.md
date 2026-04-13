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
- 战斗中会显示得分弹字、拾取奖励和危急状态强化提示

## 当前结构说明

- 第一阶段旧脚本仍保留在仓库中，便于对照，但当前主流程已切到 `stage2` 版本脚本
- 战斗反馈相关模块目前拆在：
  - `res://scripts/game/bomb_effect.gd`
  - `res://scripts/game/impact_effect.gd`
  - `res://scripts/game/explosion_effect.gd`
  - `res://scripts/game/score_popup.gd`
  - `res://scripts/game/sfx_controller.gd`
- 当前有一套程序生成的占位音效，正常游玩会启用；`headless` 自动验证中会跳过音效节点，以保证日志更干净
- Boss 现在带有相位切换后的“核心暴露”短窗口，相关状态仍集中在 `enemy.gd` 与 `game_stage2.gd`，便于后续继续扩展弱点或破甲机制
- 结果页已改为脚本构建的展示面板，统计、战绩摘要和下一步建议仍统一从 `run_state.gd` 取数，便于后续继续补动画或更多复盘指标
- Boss 击破后的战场清场总结卡由 `hud_v2.gd` 承担，只在收束阶段短暂显示，结果页仍负责最终复盘
- Boss 入场提示也已拆到 `hud_v2.gd` 的事件卡接口里，主控只负责在刷 Boss 时触发，不直接拼 UI
- 事件卡现在支持带时长的临时提示，关卡事件可以在 `stage_data_v2.gd` 里直接附加 `detail`、`card_duration` 和 `card_color`
- Boss 相位切换与 overdrive 的战术提示目前仍由 `game_stage2.gd` 触发，因为它们依赖运行中的血量状态，而不是固定时间轴事件
- 侧入波次的边缘预警目前由 `game_stage2.gd` 在刷波前触发，HUD 只提供左右入口提示接口，不负责解析波次数据
- Boss 入场锁定特效已拆到 `boss_intro_effect.gd`，命中与爆炸也继续沿用独立效果脚本强化，便于后续统一升级演出层
- Boss 击破冲击特效已拆到 `boss_break_effect.gd`，炸弹表现仍集中在 `bomb_effect.gd`，方便后续继续补更强的屏幕节拍
- 现在新增了 `bgm_controller.gd` 作为程序生成的占位音乐层；和音效一样，`headless` 自动验证中不会创建音频节点
- HUD 现在还承担电影边栏包装，Boss 入场、击破和失败收束都只通过 HUD 接口触发，不直接改场景结构
- 持续危险压屏也统一走 `hud_v2.gd`，主控只负责传入强度和颜色，不直接操作覆盖节点
- BGM 现在区分普通战斗、Boss、Boss overdrive、失败和通关收束，仍然保持程序生成占位实现
- 如果继续扩展展示层，建议优先沿用现有模块，不要把反馈逻辑重新塞回主控

## 提交建议

- 不要提交 `.godot-user`、日志或其他临时验证文件
- 如果后续加入素材资源，优先维持场景与脚本模块边界
- 新增敌群时优先改 `stage_data_v2.gd`，避免把时间轴逻辑散落到主流程里
- 继续推进时建议按“小阶段”更新 README 和 `docs/progress.md`
