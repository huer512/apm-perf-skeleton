# memory/

本目录用于保存跨实验的长期记忆。

这里不存放完整实验数据，而是存放从多个实验中沉淀出来的稳定信息，包括项目上下文、当前状态、证据索引、洞察库和决策日志。

---

## 本目录和 experiments/ 的区别

```text
experiments/ = 每次实验的完整证据
memory/      = 跨实验的压缩记忆和长期结论
```

例如：

- 单次实验的原始指标，应放在 `experiments/Exxx/results/`
- 单次实验的日志，应放在 `experiments/Exxx/logs/`
- 多次实验共同支持的洞察，应放在 `memory/insight_bank.md`
- 重大技术路线选择，应放在 `memory/decision_log.md`

---

## 文件结构

```text
memory/
├── README.md
├── global_context.md
├── current_state.md
├── insight_bank.md
├── evidence_index.md
└── decision_log.md
```

---

## 文件说明


| 文件                  | 作用                      |
| ------------------- | ----------------------- |
| `global_context.md` | 项目长期背景、目标系统、核心指标、优化边界   |
| `current_state.md`  | 当前阶段、当前最佳实验、当前风险、下一步计划  |
| `insight_bank.md`   | 已沉淀的跨实验洞察               |
| `evidence_index.md` | 证据索引，记录哪些实验支持哪些结论       |
| `decision_log.md`   | 重大决策记录，包括采用、放弃、回滚某路线的原因 |


---

## global_context.md 格式

```md
# 全局上下文

## 项目目标
说明本项目要优化什么系统，以及最终希望提升什么指标。

## 固定条件
说明哪些环境、参数、接口、数据或流程是固定的。

## 核心指标
列出最重要的性能、正确性、稳定性或资源指标。

## 主要约束
说明不能违反的边界。

## 主要优化方向
列出当前允许探索的优化方向。

## 外部依赖
说明依赖的远程服务器、源码仓库、数据路径或工具链。  
远程连接细节（host、user、密钥路径）写在 `remote/servers.private.yaml`；此处只记录 `server_id` 及用途说明，不保存 SSH 凭据。
```

---

## current_state.md 格式

```md
# 当前状态

## 当前阶段
问题理解 / baseline 建立 / 瓶颈定位 / 优化验证 / 合并验证 / 最终整理

## 当前最佳实验
Exxx

## 当前关注假设
- Hxxx
- Hxxx

## 当前主要风险
- 风险 1
- 风险 2

## 最近完成
- 事项 1
- 事项 2

## 下一步动作
- 动作 1
- 动作 2
```

---

## insight_bank.md 格式

```md
# 洞察库

## Ixxx 洞察标题

### 洞察内容
说明跨实验沉淀出的结论。

### 支持证据
- EVDxxx
- Exxx

### 可信度
高 / 中 / 低

### 影响
说明这个洞察如何影响后续优化方向。

### 是否进入最终报告
yes / no / pending
```

---

## evidence_index.md 格式

```md
# 证据索引

| 证据编号 | 来源实验 | 支持假设 | 关键结果 | 结果位置 | 可信度 |
|---|---|---|---|---|---|
| EVD001 | E001 | H001 | 建立 baseline | experiments/E001_baseline/results/ | 高 |
```

---

## decision_log.md 格式

```md
# 决策日志

## Dxxx 决策标题

### 日期
YYYY-MM-DD

### 状态
accepted / rejected / superseded / deprecated

### 背景
说明为什么需要做这个决策。

### 决策
说明最终选择。

### 原因
说明做出该选择的依据。

### 替代方案
说明考虑过但没有采用的方案。

### 影响
说明该决策对后续实验、代码、报告或风险的影响。

### 关联证据
- EVDxxx
- Exxx
```

---

## 维护要求

每完成一次有效实验，应考虑更新：

- `current_state.md`
- `evidence_index.md`
- `insight_bank.md`

每做出一次重要路线选择，应更新：

- `decision_log.md`

如果某个洞察被新实验推翻，应在 `insight_bank.md` 中保留原记录，并标记为：

```text
rejected / superseded / outdated
```

不要直接删除旧洞察。

---

## 注意事项

本目录不是草稿纸。
所有写入 memory 的内容都应该具有长期价值，能够帮助后续 Agent 或团队成员快速理解项目状态。

不要把以下内容放入 memory：

- 大段原始日志
- 单次实验的完整结果
- 临时代码片段
- 未经验证的随口猜想
- 与项目无关的讨论记录

本目录的目标是让项目具备可持续的工程记忆。