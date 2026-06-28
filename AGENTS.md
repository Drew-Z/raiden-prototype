# AGENTS.md

请始终使用简体中文与用户沟通。
代码、命令、路径、报错信息可保留原文；解释、说明、总结必须使用中文。
除非用户明确要求，否则不要切换为英文回复。

## Project Context

- 这是一个 Godot 项目目录，当前结构以：
  - `scenes/entities`
  - `scenes/game`
  - `scenes/ui`
  - `scripts/autoload`
  - `scripts/entities`
  - `scripts/game`
  - `scripts/ui`
  为主。
- 当前更像“已规划目录结构的 Godot 项目骨架”，后续开发应优先沿用这些目录，而不是随手新增平行目录。
- 如果后续发现缺少 `project.godot`、主场景、autoload 或输入映射，先检查现状并说明，再补最小必要项。

## Shell Preference

- 默认优先使用 Git Bash 执行命令。
- 如果 Git Bash 不方便、不兼容，或命令只适合 Windows 原生命令行，再使用 cmd。
- 除非明确必要，否则不要使用 PowerShell。
- 如果任务需要管理员权限，优先使用管理员模式的 cmd，而不是 PowerShell。
- 面向用户提供命令时，默认优先给出 Git Bash 写法；仅在必须时再补充 cmd 写法。
- 执行命令时，优先采用：
  - `bash -lc "<command>"`
  - `cmd /c <command>`
- 避免使用 PowerShell 专属语法，除非用户明确要求，或任务本身只能依赖 PowerShell。

## Godot Workflow

- 先检查目录结构、场景文件、脚本分层，再开始修改。
- 新场景优先放入既有目录：
  - 实体放 `scenes/entities`
  - 游戏流程或关卡放 `scenes/game`
  - UI 放 `scenes/ui`
- 新脚本优先和场景职责对应：
  - 实体脚本放 `scripts/entities`
  - 游戏控制放 `scripts/game`
  - UI 脚本放 `scripts/ui`
  - 全局状态才考虑放 `scripts/autoload`
- 不要因为一时方便把大量逻辑全塞进一个脚本或一个场景。
- 修改节点路径、信号连接、导出变量时，要同步检查对应 `.tscn` 和 `.gd` 是否一致。
- 如果需要新增输入操作，先检查现有输入映射，再做最小必要补充。
- 优先保证“能跑通一条完整流程”，再补更多功能或表现。

## Coding Workflow

- 优先做最小必要改动，避免无关重构。
- 不要擅自删除用户已有场景、资源、脚本或配置。
- 如果发现现有目录规划与任务冲突，先说明风险，再继续。
- 占位资源可以使用，但要保证结构清晰，后续能方便替换成正式资源。
- 玩法、UI、全局状态尽量分开，不要把战斗逻辑和菜单逻辑混在一起。

## Godot Verification

- 修改完成后，尽量执行可行的 Godot 级验证，而不只是静态查看文件。
- 优先验证：
  - 主场景是否能进入
  - 关键节点脚本是否已绑定
  - 输入映射是否能触发
  - 一条最小玩法闭环是否能跑通
- 如果当前环境缺少 Godot 可执行文件，或无法直接运行项目，要明确说明阻塞原因。

## project.godot / Scene Safety

- 除非任务明确需要，否则不要随意重排 `project.godot` 配置。
- 新增主场景、autoload、输入映射时，要说明改动目的。
- 不要手动大范围改写 `.tscn` 中无关字段。
- 如果只是小改逻辑，优先保持现有节点结构稳定。

## Git Workflow

- 不要使用破坏性 Git 命令，例如：
  - `git reset --hard`
  - `git checkout -- <file>`
  - `git clean -fd`
- 除非用户明确要求，否则不要改写历史，不要强推。
- 提交前先确认本次改动范围。
- 提交信息尽量简洁清晰，说明改动目的。

## Output Preference

- 回复尽量简洁、直接、可执行。
- 先说结论，再补必要说明。
- 如果是阶段开发，优先说明：
  - 已完成什么
  - 现在能怎么玩
  - 还缺什么
  - 下一步建议做什么

## Safety

- 不要执行用户未明确同意的高风险操作。
- 涉及删除、覆盖、移动大量资源文件时，先确认目标路径和影响范围。
- 涉及 Godot 全局配置、导出设置、输入映射重做、autoload 调整时，先说明将要做什么。
