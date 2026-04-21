# 展示版 QA 记录

## 本轮目标

围绕当前双关纵版切片，确认以下事项：

- 主菜单、设置、简报、战斗、结算、结尾、总结链路完整
- HUD、音效和中文文案达到展示版可用状态
- 火力成长、炸弹窗口和 Boss 压力符合当前短局展示目标

## 已执行验证

### 1. 引擎启动验证

- 命令：`Godot --headless --quit`
- 结果：通过

### 2. 单关自动流程验证

- 模式：`--autoplay --stage2`
- 结果：通过
- 输出：
  - `RUN_RESULT victory=true score=26685 kill_rate=97.50 max_fire=5 route=Lv3 -> Lv4 -> Lv5 bombs_used=6 lives=3`

### 3. 双关章节自动流程验证

- 模式：`--autoplay --chapter`
- 结果：通过
- 输出：
  - `RUN_RESULT victory=true score=22230 kill_rate=86.90 max_fire=5 route=Lv1 -> Lv2 -> Lv3 -> Lv4 -> Lv5 bombs_used=4 lives=3`
  - `RUN_RESULT victory=true score=27047 kill_rate=100.00 max_fire=5 route=Lv5 bombs_used=4 lives=3`
  - `CHAPTER_RESULT victory=true total_score=49277 kill_rate=93.29 stages=2 highest_fire=5`

### 4. 发布仓库展示版自检

- 使用 `tools/run_showcase_verification.cmd` 在 `.publish-final` 仓库内再次执行
- 结果：通过
- 说明：这一步额外抓到了第一关旧脚本 `game.gd` 的拾取信号签名兼容问题，并已修复

## 本轮检查结论

- 当前主流程稳定可跑通
- 结果页详情、暂停面板、清场提示等当前活跃中文文案已统一
- HUD 顶部结构已经从“信息堆叠”收紧为“常驻层 / Boss 警戒层 / 短时提示层”
- 第二关与 Boss 段压力比之前更合理，但仍保持可展示与可通关
- 发布仓库与当前工作区的展示链路已重新同步，发布版验证结果与当前工作区一致
- 最新一轮试玩反馈打磨后，`Lv5` 的成长辨识度更高，Boss 后段压迫和炸弹窗口也更贴近展示目标

## 当前已知非阻塞项

- Windows 环境仍会出现根证书仓读取告警，不影响项目运行
- 需要下一轮结合人工试玩继续校准音效和高火力段手感
- 当前仍属于“稳定展示版候选”，不是正式长流程发布版

## 建议的下一步

- 做一轮真实人工试玩并记录主观反馈
- 基于试玩反馈微调 Boss、炸弹窗口与高火力后段
- 准备最终对外演示包与演示说明
