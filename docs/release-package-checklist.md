# 展示候选打包清单

## 当前版本

- 版本标识：`RC-0.4`
- 推荐入口：`Chapter Run`
- 当前定位：稳定展示候选版

## 打包前必须确认

- `tools/run_showcase_verification.cmd` 能完整通过
- 主菜单显示 `稳定展示候选 // RC-0.4`
- 中文模式下主菜单、简报、结果页、结尾页、总结页没有乱码
- 顶部 HUD 不遮挡主战场
- Boss 登场、过载、终结窗口和炸弹窗口提示都能正常出现
- 音量设置可以在主菜单和暂停菜单中调整

## 推荐交付内容

- `dist\raiden-prototype-showcase-rc-0.4-*.zip`
- Godot 项目完整目录
- `README.md`
- `docs/stable-showcase-release.md`
- `docs/manual-demo-guide.md`
- `docs/final-demo-checklist.md`
- `docs/showcase-qa-report.md`
- `tools/run_local_debug.cmd`
- `tools/run_showcase_verification.cmd`
- `tools/prepare_showcase_package.cmd`
- `tools/prepare_public_demo_packet.cmd`
- `docs/public-demo-release-note.md`
- `docs/public-demo-known-issues.md`
- `docs/asset-license-checklist.md`

## 不建议打包的内容

- `.git`
- `.godot-user`
- `.publish-final`
- `_downloads`
- `_audio_extract`
- `_audio_pick`
- 临时验证日志

## 打包说明

`tools/prepare_showcase_package.cmd` 会在 `dist` 下生成带随机后缀的 zip 包，避免旧包被 Windows 权限或杀毒软件短暂锁住时影响下一次 Demo 就绪检查。

## 对外说明口径

当前版本是一个双关纵版射击展示候选版，重点展示短局街机射击的成长、炸弹资源、敌群节奏、Boss 压迫和章节外层包装。

它不是完整商业关卡长度，也不是最终美术版本；它的价值在于已经能稳定展示一条完整的双关垂直切片。
