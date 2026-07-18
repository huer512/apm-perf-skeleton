# Performance Optimization Workflow

本项目用于管理一个以性能优化为目标的工程研究流程。  
它不直接等同于被优化系统的源码仓库，而是作为本地研究中枢，用于组织问题定义、优化假设、实验记录、结果分析、长期记忆和最终报告材料。

**AI Agent（或人工执行者）开始工作前，必须先阅读 [`AGENTS.md`](AGENTS.md)** —— 状态机、角色调度、EVD 强制表、收尾清单与红线的**唯一权威来源**。  
角色细则与固定任务书模板见 [`agents/`](agents/README.md)。

本项目适用于以下场景：

- 系统性能优化
- 推理服务优化
- 数据库性能优化
- 编译器或运行时优化
- GPU / NPU / CPU 程序调优
- 网络服务压测与调参
- 其它需要“假设—实验—证据—结论”闭环的工程项目

---

## 目录结构

```text
.
├── AGENTS.md      # Agent 执行契约：状态机、EVD 强制表、红线（唯一权威来源）
├── agents/        # 角色契约与固定任务书模板（scheduler 调 subagent 时使用）
├── problem/       # 问题定义、约束、评分规则、提交要求（先填 intake.md）
├── hypotheses/    # 优化假设、瓶颈猜想、待验证方向
├── experiments/   # 每次实验的完整记录（含 run_commands.md 逐条执行记录）
├── memory/        # 长期记忆；current_state.md 含工作流状态机四字段
├── remote/        # 远程服务器与 SSH 连接配置（敏感信息不入库）
├── references/    # 领域先验：判读规则与排查决策树
├── report/        # 最终报告（终止条件白名单见其 README）
├── examples/      # 全链路填写示例（EX- 前缀，不占正式编号）
└── scripts/       # validate.py；codex_review / codex_audit / codex_directions
```

---

## 远程环境配置

若实验在远程服务器执行，先配置 SSH 信息：

```bash
cp remote/servers.example.yaml remote/servers.private.yaml
# 编辑 servers.private.yaml，填入 host、user、identity_file 等
```

各实验目录的 `remote_ref.yaml` 通过 `server_id` 引用上述配置，详见 [`remote/README.md`](remote/README.md)。

---

## 设计原则

1. 问题与方案分离：`problem/` 只记外部规则，不记个人猜想与实验结论。
2. 假设与实验分离：`hypotheses/` 记方向，`experiments/` 记验证过程。
3. 证据与结论分离：原始结果在实验目录，跨实验沉淀在 `memory/`。
4. 本地与远程分离：大文件与完整源码副本不入库；凭据只在 `servers.private.yaml`。
5. 结论可追溯：洞察/决策/报告中的性能结论必须能指到 Exxx / EVDxxx。
6. 调度可恢复：`memory/current_state.md` 的 `phase` / `active_exp` / `last_diag_exp` / `queue` 是跨会话真相；推进状态机默认串行。

---

## 工作流（摘要）

细则与合法转移边以 [`AGENTS.md`](AGENTS.md) 为准。主会话 Agent 默认是 **scheduler**：按 `phase` 启动角色 subagent（固定任务书模板见 `agents/README.md`），**禁止**主 Agent 冒充执行角色长跑实验。

```text
intake → baseline_setup → baseline_run → baseline_freeze
        ↓
diagnose（profiler；更新 last_diag_exp）
        ↓
direction_gen
  · 有可入队新方向 → 写入 queue
  · 自认无方向 → 必须 scripts/codex_directions.sh（禁止可调可不调）
        ↓
plan_next → review_plan（scripts/codex_review.sh）
        ↓
execute（remote_runner：隔离部署 + run_commands.md 逐条 + gpu.lock）
        ↓
analyze → audit_conclusion（scripts/codex_audit.sh，含 rework_class）
        ↓
register_evd（必须登记或禁止登记，无「可登」裁量）
        ↓
decide_next → diagnose | plan_next | direction_gen | report
```

### 相对旧流程的关键约定

| 主题 | 约定 |
| --- | --- |
| 执行记录 | 只用 `run_commands.md` **逐条**执行与复现；**禁止**一键跑完全程的脚本 |
| 基线 | 上游代码包本地完整留存（权重可只记路径+校验和），远程忠实落地后再冻结 |
| 部署 | 单文件：`名_Exxx.py`；大仓：与实验目录同名的 git worktree；禁止覆盖共享入口 |
| 诊断优先 | 无匹配当前最佳栈的 `last_diag_exp` 时，禁止开优化类 `plan_next` / `execute` |
| 方向生成 | 自认无方向时必须跑 `codex_directions.sh`；禁止因「收益小」拒入队 |
| 证据 | audit 通过后 **必须**登 EVD（或按表 **禁止**登）；`rework_class` 区分改文档 / 补测 / 改代码 |
| GPU | 根目录 `gpu.lock` 租约；默认只杀锁内 pids；状态机角色默认串行 |
| 终止 | 仅 `report/README.md` 白名单；不得空口「已到顶」 |

脚本入口：

```bash
python3 scripts/validate.py
scripts/codex_review.sh <实验目录>       # 执行前计划评审
scripts/codex_audit.sh <实验目录>        # 结论审计
scripts/codex_directions.sh [Exxx]       # direction_gen 且自认无方向时
```

---

## 编号约定

**000 编号保留为模板，不参与实际任务记录。**  
所有任务相关的存储从 **001** 开始编号。例如：第一个实验是 `E001_baseline`，第一个假设是 `H001_xxx.md`。  
模板文件（如 `H000_template/`、`E000_template/`）只作为格式参考，不要在模板中写入实际任务内容。

| 类型  | 前缀     | 示例                             | 起始编号 |
| --- | ------ | ------------------------------ | ---- |
| 假设  | Hxxx   | H001_memory_bottleneck         | H001 |
| 实验  | Exxx   | E003_cache_policy_ab_test      | E001 |
| 证据  | EVDxxx | EVD007                         | EVD001 |
| 洞察  | Ixxx   | I004_decode_is_bandwidth_bound | I001 |
| 决策  | Dxxx   | D002_drop_static_optimization  | D001 |
| 规则  | Rxxx   | R003_no_dataset_change         | R001 |

本表是编号约定的唯一定义处。`examples/` 内使用 `EX-` 前缀，不占用上述编号。

---

## 不建议放入本仓库的内容

除非项目特别要求，否则不要将以下内容提交到本仓库：

- 大型模型权重
- 大型数据集
- 容器镜像
- 编译缓存
- 临时构建产物
- 过大的原始日志
- 与实验无关的中间文件
- 远程完整源码副本
- SSH 私钥、密码及 `remote/servers.private.yaml`
- `gpu.lock`（运行时租约，已在 `.gitignore`）

如确实需要保存，应在 `.gitignore` 中排除，或只保留文件路径、校验值、下载方式和说明。远程连接配置见 `remote/README.md`。

---

## 推荐维护习惯

每次会话收尾动作以 [`AGENTS.md`](AGENTS.md) 的收尾清单为唯一权威来源（含状态机四字段、EVD 强制动作、`validate.py`）。

研究产物（假设、计划、分析、结论、memory）必须提交入库：每轮收尾后 `git status` 中不应残留未跟踪的 md/csv 研究文档。建议每个实验收尾至少一次提交，commit message 引用编号（如 `E003: cache policy rejected (H002)`）。

本项目的目标不是保存所有东西，而是让每一次优化都能被复现、被解释、被比较、被继承。
