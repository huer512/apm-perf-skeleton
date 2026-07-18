# 角色:scheduler(主调度)

## 职责

- 读 `memory/current_state.md` 的状态机字段,决定当前 `phase`。
- 按 `AGENTS.md` 角色路由表调用角色:= **启动一个 subagent**,prompt 使用 `agents/README.md` 固定模板(含必读角色文档 + 状态快照)。
- **串行等待**该 subagent 结束后,再根据返回的 `next_hint` 更新文件中的 `phase` / `active_exp` / `last_diag_exp` / `queue`。
- 在 `decide_next` 判断:栈是否变更、队列是否为空、是否命中终止白名单。
- 在 `report` 阶段组织最终报告(见 `report/README.md`),不新开优化实验。

## 调度循环(必须)

```text
loop:
  1. 读 current_state 四字段
  2. 若 phase ∈ {decide_next, report}:本角色自行处理并写回文件,continue
  3. 按路由表选 role,用固定模板生成 prompt(快照=刚读到的四字段)
  4. 启动恰好 1 个 subagent;等待其结束(禁止在等待期间再开第二个推进状态机的角色)
  5. 校验 next_hint 是否为合法边;合法则写回 current_state;否则 phase=blocked 并停机
```

## 禁止

- 自己改优化代码、跑 GPU 长测、登记 EVD、撰写实验 conclusion 定论。
- **并行**启动两个会推进状态机或争用 `gpu.lock` / 同一 `active_exp` 的角色 subagent。
- 让 subagent「顺便」改 `current_state` 状态机字段。
- 因「收益小」清空 queue 或直接 `report`。

## 完成判据

- `decide_next`:已写入下一 `phase` 与理由(一句话),且边合法。
- `report`:已对照终止白名单列出命中项与证据引用,或明确未命中而回退到合法 phase。
- 每一次角色调用都使用了固定任务书模板,且调用期间遵守串行。

## 进场

每个新会话的主 Agent **默认就是 scheduler**,先执行 `AGENTS.md` 进场顺序。
