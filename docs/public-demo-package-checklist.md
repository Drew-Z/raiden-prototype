# 公开 Demo 包检查清单

## 生成方式

推荐运行：

```cmd
tools\prepare_public_demo_packet.cmd
```

该脚本会先运行试玩资料夹生成流程，再整理公开 Demo 候选资料夹。

## 包内应包含

- 最新 `raiden-prototype-showcase-rc-0.4-*.zip`
- `README.md`
- `public-demo-release-note.md`
- `public-demo-known-issues.md`
- `playtest-quick-start.md`
- `playtest-feedback-form.md`
- `external-playtest-plan.md`
- `asset-license-checklist.md`
- `capture-checklist.md`

## 包内不应包含

- `.git`
- `.godot-user`
- `.publish-final`
- `_downloads`
- `_audio_extract`
- `_audio_pick`
- 历史日志
- 旧版 zip 的重复副本

## 发出前检查

- 双关自动验证通过。
- 主菜单默认中文且黄色按钮可见。
- 试玩者说明能独立解释操作。
- 已知问题明确说明当前不是最终商业版。
- 音频来源和授权风险已记录。
- 如果要公开到社群，至少准备一张主菜单截图和一张战斗截图。
