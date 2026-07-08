# Performance Optimization Workflow

本项目用于管理一个以性能优化为目标的工程研究流程。  
它不直接等同于被优化系统的源码仓库，而是作为本地研究中枢，用于组织问题定义、优化假设、实验记录、结果分析、长期记忆和最终报告材料。

**AI Agent（或人工执行者）开始工作前，必须先阅读 [`AGENTS.md`](AGENTS.md)** —— 它是进场顺序、收尾清单与红线的唯一权威来源。

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
├── AGENTS.md      # Agent 执行契约：进场顺序、收尾清单、硬门槛、红线（唯一权威来源）
├── problem/       # 问题定义、约束、评分规则、提交要求
├── hypotheses/    # 优化假设、瓶颈猜想、待验证方向
├── experiments/   # 每次实验的完整记录，包括方案、代码、结果、日志、分析
├── memory/        # 跨实验长期记忆，包括洞察、证据索引、决策日志、已知坑、当前状态
├── remote/        # 远程服务器与 SSH 连接配置（敏感信息不入库）
├── report/        # 最终方案与最终报告（终止条件白名单见其 README）
├── examples/      # 填写完成的全链路示例（格式与粒度示范，不占正式编号）
└── scripts/       # 轻量校验工具（stdlib-only；无脚本时流程可全手工执行）
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

本项目遵循以下原则：

1. 问题与方案分离
  `problem/` 只记录外部规则和约束，不记录个人猜想和实验结论。
2. 假设与实验分离
  `hypotheses/` 记录“可能有效的优化方向”，`experiments/` 记录“实际验证过程”。
3. 证据与结论分离
  原始结果、日志和数据放在 `experiments/`，跨实验总结和长期洞察放在 `memory/`。
4. 本地与远程分离
  如果被优化项目源码、运行环境或大文件位于远程服务器，本地只保存引用、补丁、配置、结果摘要和分析，不直接保存大体积源码、模型、数据集或构建产物。SSH 连接信息统一放在 `remote/servers.private.yaml`（已 gitignore），各实验通过 `remote_ref.yaml` 的 `server_id` 引用，不重复保存凭据。
5. 所有结论必须能追溯
  每个洞察、决策和最终报告中的性能提升结论，都应能追溯到具体实验编号和结果文件。

---

## 推荐工作流

一次完整优化流程建议如下：

```text
阅读 problem/（未初始化 → 先执行 AGENTS.md 的第 0 步 intake）
        ↓
建立并冻结基线实验（plan.md 填写"基线契约"）
        ↓
提出 hypotheses/Hxxx（先完成查重与先验检索）
        ↓
创建 experiments/Exxx 并完成 plan.md
        ↓
执行实验并保存代码、结果和日志（远程实验回传产物）
        ↓
编写 analysis.md 和 conclusion.md
        ↓
登记 EVD 到 memory/evidence_index.md，并回写 Hxxx 状态（联动规则见 hypotheses/README.md）
        ↓
更新 experiments/index.csv 与 memory/current_state.md（完整收尾清单见 AGENTS.md）
        ↓
决定继续优化、修订假设，或命中终止条件后进入 report/ 最终报告
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

如确实需要保存，应在 `.gitignore` 中排除，或只保留文件路径、校验值、下载方式和说明。远程连接配置见 `remote/README.md`。

---

## 推荐维护习惯

每次会话收尾动作（回写假设、更新索引、登记证据、更新 memory、校验、提交）以 [`AGENTS.md`](AGENTS.md) 的收尾清单为唯一权威来源，此处不再重复罗列。

研究产物（假设、计划、分析、结论、memory）必须提交入库：每轮收尾后 `git status` 中不应残留未跟踪的 md/csv 研究文档，否则证据链在版本库层面会丢失。建议每个实验收尾至少一次提交，commit message 引用编号（如 `E003: cache policy rejected (H002)`），让 git log 成为免费的审计索引。

本项目的目标不是保存所有东西，而是让每一次优化都能被复现、被解释、被比较、被继承。