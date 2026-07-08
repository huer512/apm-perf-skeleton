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
│   ├── remote_ref.yaml
│   ├── run_commands.sh
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
exp_id,exp_name,hypotheses,status,valid,key_result,path
E001,baseline,none,done,yes,建立基线,experiments/E001_baseline
E002,cache_policy_ab_test,H001;H002,running,unknown,待完成,experiments/E002_cache_policy_ab_test
```

列取值约定：

| 列 | 取值 |
| --- | --- |
| `hypotheses` | 关联假设编号，多个用分号分隔；基线或探索性实验填 `none`，不要编造假设 |
| `status` | 见下方实验状态表 |
| `valid` | `yes` / `no` / `partial` / `invalid`，与 `conclusion.md` 的"是否有效"一致；实验未完成时填 `unknown` |
| `key_result` | 一句话自由文本 |

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
| `remote_ref.yaml` | 如果实验在远程执行，通过 `server_id` 引用 `remote/servers.private.yaml`，并记录远程路径、分支、commit、环境等 |
| `run_commands.sh` | 实验运行命令，尽量保证可复现                 |
| `code/`           | 保存补丁、改动说明或代码包                  |
| `results/`        | 保存原始结果和解析后的指标                  |
| `logs/`           | 保存运行日志、构建日志、错误日志               |
| `analysis.md`     | 对结果进行分析                        |
| `conclusion.md`   | 给出实验结论和后续动作                    |
| `audit.md`        | 结论审计记录（合规性/有效性/复现性），登记 EVD 前必须判定通过 |

---

## 实验设计要求

每次实验应尽量保证：

1. 有明确关联假设。
2. 有明确对照组。
3. 一次只改变少量变量。
4. 记录完整运行环境。
5. 记录完整运行命令。
6. 保留原始结果。
7. 区分原始数据和人工分析。
8. 结论能追溯到具体指标和日志。
9. 无效实验也要记录原因。
10. 重要实验应能被重复执行。
11. 远程实验结束后必须将结果与日志回传到本地 `results/` 与 `logs/`（见 `remote/README.md` 的"结果回传"）。

---

## 证据登记（EVD）

conclusion.md 完成时，必须为每条关键测量创建 EVD 并登记到 `memory/evidence_index.md`（格式见 memory/README.md）：

* 登记前实验必须通过结论审计：audit.md 判定为 approved / approved-with-changes / waived（见 AGENTS.md 硬门槛）。
* 一次实验可登记多条 EVD；支持性与反驳性证据都要登记。
* EVD 编号从 EVD001 起全局递增，不复用。
* 冒烟/流程验证运行与未重复的单次测量，禁止登记为 EVD（见 AGENTS.md 红线）。

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