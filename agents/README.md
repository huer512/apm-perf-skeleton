# agents/ — 角色契约

本目录存放各角色细则。何谓「调用角色」、phase 存取与并行策略以根目录 [`AGENTS.md`](../AGENTS.md) 为准;冲突时以 `AGENTS.md` 为准。

本文件只补充:**角色文档索引**与**固定任务书模板**。

## 角色一览

| 角色 | 文档 | 典型 phase |
| --- | --- | --- |
| scheduler | [`scheduler.md`](scheduler.md) | 会话入口、`decide_next`、`report` |
| intake | [`intake.md`](intake.md) | `intake` |
| baseline | [`baseline.md`](baseline.md) | `baseline_*` |
| profiler | [`profiler.md`](profiler.md) | `diagnose` |
| planner | [`planner.md`](planner.md) | `direction_gen`、`plan_next` |
| remote_runner | [`remote_runner.md`](remote_runner.md) | `execute`、`baseline_run` 的远程步骤 |
| analyst | [`analyst.md`](analyst.md) | `analyze` |
| audit_clerk | [`audit_clerk.md`](audit_clerk.md) | `review_plan`、`audit_conclusion`、`register_evd` |

## 固定任务书模板

scheduler 每次调用角色 subagent 时,`prompt` **必须**以如下结构开头(字段换成实值):

```text
必读:
- <项目路径>/AGENTS.md
- <项目路径>/agents/<role>.md

角色: <role>
调用ID: <scheduler 生成的 uuid 或时间戳,用于日志>

当前快照(只读,禁止你改 current_state 状态机字段):
- phase: <从 memory/current_state.md 抄写>
- active_exp: <...>
- current_best: <...>
- last_diag_exp: <...>
- queue: <...>

本步完成判据:
- <从 agents/<role>.md「完成判据」抄一条>

写入许可:
- 允许写入: <该角色文档列出的路径,如 experiments/Exxx/run_commands.md>
- 禁止写入: memory/current_state.md 的工作流状态机四字段;以及角色文档「禁止」节

完成后返回(纯文本,勿改 phase 文件):
status: done | blocked
next_hint: <合法后继 phase 名,或 rework_class 提示>
notes: <一句话>
artifacts: <关键路径>
```

其后可附本步特有材料(计划要点、对照 md5、远程 host 等)。
