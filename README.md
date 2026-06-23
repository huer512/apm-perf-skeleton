# Performance Optimization Workflow

本项目用于管理一个以性能优化为目标的工程研究流程。  
它不直接等同于被优化系统的源码仓库，而是作为本地研究中枢，用于组织问题定义、优化假设、实验记录、结果分析、长期记忆和最终报告材料。

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
├── problem/       # 问题定义、约束、评分规则、提交要求
├── hypotheses/    # 优化假设、瓶颈猜想、待验证方向
├── experiments/   # 每次实验的完整记录，包括方案、代码、结果、日志、分析
└── memory/        # 跨实验长期记忆，包括洞察、证据索引、决策日志、当前状态
```

---

## 核心原则

本项目遵循以下原则：

1. 问题与方案分离
  `problem/` 只记录外部规则和约束，不记录个人猜想和实验结论。
2. 假设与实验分离
  `hypotheses/` 记录“可能有效的优化方向”，`experiments/` 记录“实际验证过程”。
3. 证据与结论分离
  原始结果、日志和数据放在 `experiments/`，跨实验总结和长期洞察放在 `memory/`。
4. 本地与远程分离
  如果被优化项目源码、运行环境或大文件位于远程服务器，本地只保存引用、补丁、配置、结果摘要和分析，不直接保存大体积源码、模型、数据集或构建产物。
5. 所有结论必须能追溯
  每个洞察、决策和最终报告中的性能提升结论，都应能追溯到具体实验编号和结果文件。

---

## 推荐工作流

一次完整优化流程建议如下：

```text
阅读 problem/
        ↓
提出 hypotheses/Hxxx
        ↓
创建 experiments/Exxx
        ↓
执行实验并保存代码、结果和日志
        ↓
编写 analysis.md 和 conclusion.md
        ↓
更新 memory/evidence_index.md
        ↓
更新 memory/insight_bank.md 或 memory/decision_log.md
        ↓
决定继续优化、回滚或进入最终方案
```

---

## 编号约定


| 类型  | 前缀     | 示例                             |
| --- | ------ | ------------------------------ |
| 假设  | Hxxx   | H001_memory_bottleneck         |
| 实验  | Exxx   | E003_cache_policy_ab_test      |
| 证据  | EVDxxx | EVD007                         |
| 洞察  | Ixxx   | I004_decode_is_bandwidth_bound |
| 决策  | Dxxx   | D002_drop_static_optimization  |


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

如确实需要保存，应在 `.gitignore` 中排除，或只保留文件路径、校验值、下载方式和说明。

---

## 推荐维护习惯

每完成一次实验，至少更新以下文件：

- `experiments/index.csv`
- 对应实验目录下的 `analysis.md`
- 对应实验目录下的 `conclusion.md`
- `memory/evidence_index.md`
- 必要时更新 `memory/insight_bank.md`
- 必要时更新 `memory/decision_log.md`

本项目的目标不是保存所有东西，而是让每一次优化都能被复现、被解释、被比较、被继承。