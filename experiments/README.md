# experiments/

本目录用于保存每一次实验的完整记录。

实验是本项目最重要的证据单位。  
所有性能结果、代码改动、运行命令、日志、分析和结论，都应能在对应实验目录中找到。

---

## 本目录应该存放什么

目录结构如下：

```text
experiments/
├── README.md
├── index.csv
├── E000_template/          # 模板目录，不参与实际任务，不要修改
│   ├── README.md
│   ├── plan.md
│   ├── review.md
│   ├── ledger.md
│   ├── remote_ref.yaml
│   ├── run_commands.md
│   ├── code/
│   ├── results/
│   ├── logs/
│   ├── analysis.md
│   ├── conclusion.md
│   └── audit.md
├── E001_baseline/          # 第一个实验：建立基线
│   └── ...
└── E002_xxx/
    └── ...
```

创建新实验时，复制 `E000_template/` 的结构，按 `E001_xxx`、`E002_xxx` 命名。

---

## 实验目录命名规范

实验目录命名必须使用：

```text
E编号_简短实验名称
```

示例：

```text
E000_template          # 模板，不参与实际任务
E001_baseline          # 第一个实验
E002_cache_policy_ab_test
E003_kernel_fusion_trial
E004_scheduler_fast_path
```

`E000` 保留为实验目录模板，实际任务从 `E001` 开始编号。编号一旦创建，不允许重复使用。

---

## index.csv

`index.csv` 用于总览所有实验，是唯一的机读索引。

必须使用以下格式（表头为英文机读列名，不要改动）：

```csv
exp_id,exp_name,hypotheses,status,valid,key_result,path,created,executor
E001,baseline,none,done,yes,建立基线,experiments/E001_baseline,2025-11-02,agent-s1102a
E002,cache_policy_ab_test,H001;H002,running,unknown,待完成,experiments/E002_cache_policy_ab_test,2025-11-05,agent-s1105b
```

列取值约定：

| 列 | 取值 |
| --- | --- |
| `hypotheses` | 关联假设编号，多个用分号分隔；基线或探索性实验填 `none`，不要编造假设 |
| `status` | 见下方实验状态表 |
| `valid` | `yes` / `no` / `partial` / `invalid`，与 `conclusion.md` 的"是否有效"一致；实验未完成时填 `unknown` |
| `key_result` | 一句话自由文本 |
| `created` | 实验创建日期 YYYY-MM-DD |
| `executor` | 执行者:人名或 Agent 会话标识 |

---

## 实验状态

| 状态         | 含义         |
| ---------- | ---------- |
| `planned`  | 已设计，未执行    |
| `running`  | 正在执行       |
| `done`     | 已完成        |
| `failed`   | 执行失败       |
| `invalid`  | 结果无效，不参与比较 |
| `analyzed` | 已完成分析      |
| `archived` | 已归档        |

---

## 单个实验必须包含的内容

每个实验目录至少应包含：

| 文件或目录             | 作用                             |
| ----------------- | ------------------------------ |
| `README.md`       | 说明该实验目录的用途和内容                  |
| `plan.md`         | 实验计划，说明目的、变量、对照组、成功标准          |
| `review.md`       | 实验计划评审记录（codex 意见处理与判定），执行前必须判定通过 |
| `ledger.md`       | 实验台账（append-only）：执行流水与断点恢复依据，失败尝试同样入账 |
| `remote_ref.yaml` | 如果实验在远程执行，通过 `server_id` 引用 `remote/servers.private.yaml`，并记录远程路径、分支、commit、环境等 |
| `run_commands.md` | 逐条执行记录（唯一执行/复现权威）；**禁止**一键脚本 |
| `code/`           | 保存**本次实验实际用于远程推理的 `infer.py`**（或等价入口脚本）及补丁说明 |
| `results/`        | 保存原始结果和解析后的指标                  |
| `logs/`           | 保存运行日志、构建日志、错误日志               |
| `analysis.md`     | 对结果进行分析                        |
| `conclusion.md`   | 给出实验结论和后续动作                    |
| `audit.md`        | 结论审计记录（合规性/有效性/复现性），登记 EVD 前必须判定通过 |

---

## code/ 目录规范（必须）

每个实验的 `code/` 目录**必须**包含本次实验在远程实际运行的推理入口脚本，默认文件名为 `infer.py`（与赛题提交包一致）。用途：**复现**（按 `run_commands.md` 逐条部署同源脚本）、**diff**（相对对照组逐行对比）、**审计**（结论与代码变更一一对应）。

| 实验类型 | `code/infer.py` 要求 |
| --- | --- |
| baseline（如 E001） | 官方代码包完整快照（权重可只记路径+校验和），入口脚本附 md5 |
| 优化实验（如 E004） | 相对 baseline 的补丁版；**先改本地再部署**；远程文件名须为 `infer_Exxx.py` 等隔离名 |
| 大项目（如 vLLM） | 远程用与实验目录同名的 git worktree；本地保留 patch/commit |
| 尚未执行（`status=planned`） | 可暂缺入口脚本，须在 `code/README.md` 标明 **planned** 及待开发内容 |

执行前（`status` 非 `planned`）若入口脚本缺失，执行与结论均不可信——须先补齐再跑。

推荐同步保存（有代码改动时）：

| 文件 | 作用 |
| --- | --- |
| `infer.py` | **必须**（或等价入口）；远程推理的唯一源码依据 |
| `README.md` | 说明快照/补丁来源、md5、与对照组关系 |
| `patch.diff` | 相对对照组 `infer.py` 的统一 diff（可选但推荐） |
| `changed_files.md` | 修改文件与目的（可选但推荐） |

模板示例见 `E000_template/code/README.md`；baseline 实例见 `E001_baseline/code/`。

---

## run_commands.md 规范（必须）

**禁止**使用 `run_commands.sh` 或任何「一键跑完全程」脚本作为执行方式。复现 = 另一 Agent 读取本 md 后逐条执行。

每一步使用以下结构（可追加 step N）：

```markdown
## step N — YYYY-mm-dd HH:MM:SS
- cwd:
- command: |
    ...
- exit_code:
- artifacts:
- notes:
```

失败时不得删改已成功步骤的记录；追加新 step 写明修正。GPU 租约见根目录 `gpu.lock` 协议（`AGENTS.md`）。

---

## 实验设计要求

每次实验应尽量保证：

1. 有明确关联假设；优化类 plan 必须引用 `current_state.last_diag_exp`。
2. 有明确对照组。
3. 一次只改变少量变量。
4. 记录完整运行环境。
5. 用 `run_commands.md` 记录完整运行命令（逐条）。
6. 保留原始结果。
7. 区分原始数据和人工分析。
8. 结论能追溯到具体指标和日志。
9. 无效实验也要记录原因。
10. 重要实验应能被另一 Agent 按 `run_commands.md` 逐条重复执行。
11. 远程实验结束后必须将结果与日志回传到本地 `results/` 与 `logs/`（见 `remote/README.md` 的"结果回传"）。
12. plan 声明 `evidence_class`: `optimization` 或 `diagnostic`（单值）。

---

## 证据登记（EVD）

结论审计之后，**按 `AGENTS.md` 的 EVD 强制表执行「必须登记」或「禁止登记」**，无「可登」裁量；由 `audit_clerk` 在 `register_evd` phase 执行：

* `audit.md` 必须含单值 `审计判定` 与 `rework_class`（见 AGENTS.md）。
* **同一实验的 a800 实验榜与真实榜共用一条 EVD**；`location`/`key_result`/`limits` 内分列两口径。
* 一次实验仍可登记多条 EVD（例如同时有 supports 与 refutes）；支持性与反驳性证据都要登记。
* EVD 编号从 EVD001 起全局递增，不复用。
* 冒烟/流程验证运行与未重复的单次测量，禁止登记为 EVD（见 AGENTS.md 红线）。
* 诊断类（`evidence_class: diagnostic`）若必须登记：`limits` 须含 `diagnostic-only; not for latency claim`。

---

## results/ 官方计分字段（必须）

每次实验 `results/` 除原始 latency/AUC/PCOC 外，**必须**按 `problem/scoring-and-sla.md` 官方公式计算并记录：

| 字段 | 说明 |
| --- | --- |
| `latency` | 前向 `time_sum`（秒） |
| `auc` | AUC |
| `pcoc` | PCOC |
| `score_latency` | `(latency_base - latency) / latency_base`，`latency_base=300` |
| `score_model` | 官方效果分（守门后公式） |
| `score_all` | `score_latency*70 + score_model*30` |

推荐格式：

1. **CSV 行**（`results/runN.csv`）：`metric,value,unit,notes` 行，含上述 6 项核心指标。
2. **校验**：`python3 scripts/compute_score.py --csv results/runN.csv` 与记录值交叉核对。

超时（latency≥300s）或 AUC/PCOC 越界时，`score_latency` 或 `score_model` 为 0，须在 `analysis.md` 标明原因。

---

## 结论验收规则

analysis.md 与 conclusion.md 的合格标准（本节为唯一定义处，模板内仅引用）：

* 必须包含：基线数字、当前数字、变化幅度、EVDxxx 引用、结论适用范围。
* 禁止：只写"有提升 / 已优化 / 应该是"而不给数字与证据编号；把 microbenchmark 结果表述为端到端结论。
* 失败或无效实验同样要完成两份文档，写明失败原因与日志位置。

---

## 不应放入本目录的内容

不建议长期保存：

* 大型数据集
* 大型模型文件
* 容器镜像
* 编译缓存
* 临时文件
* 与实验无关的下载包
* 含密钥的配置文件（SSH 凭据应放在 `remote/servers.private.yaml`，不要写入实验目录）

如必须保留，应使用压缩包、外部存储或远程路径引用，并在 `.gitignore` 中排除不应提交的内容。

---

## 维护要求

实验创建与收尾需要同步更新的文件，以 `AGENTS.md` 的收尾清单为唯一权威来源，此处不再重复罗列。

本目录的目标是让每个性能结论都有证据来源。