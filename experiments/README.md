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
├── E000_baseline/
│   ├── README.md
│   ├── plan.md
│   ├── remote_ref.yaml
│   ├── run_commands.sh
│   ├── code/
│   ├── results/
│   ├── logs/
│   ├── analysis.md
│   └── conclusion.md
└── E001_xxx/
    ├── README.md
    ├── plan.md
    ├── remote_ref.yaml
    ├── run_commands.sh
    ├── code/
    ├── results/
    ├── logs/
    ├── analysis.md
    └── conclusion.md
```

---

## 实验目录命名规范

实验目录命名必须使用：

```text
E编号_简短实验名称
```

示例：

```text
E000_baseline
E001_cache_policy_ab_test
E002_kernel_fusion_trial
E003_scheduler_fast_path
E004_memory_pool_config
```

编号一旦创建，不建议复用。

---

## index.csv

`index.csv` 用于总览所有实验。

必须使用以下格式：

```csv
实验编号,实验名称,关联假设,状态,是否有效,关键结果,位置
E000,baseline,H001,done,yes,建立基线,experiments/E000_baseline
E001,xxx,H002,running,unknown,待完成,experiments/E001_xxx
```

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
| `remote_ref.yaml` | 如果实验在远程执行，记录远程路径、分支、commit、环境等 |
| `run_commands.sh` | 实验运行命令，尽量保证可复现                 |
| `code/`           | 保存补丁、改动说明或代码包                  |
| `results/`        | 保存原始结果和解析后的指标                  |
| `logs/`           | 保存运行日志、构建日志、错误日志               |
| `analysis.md`     | 对结果进行分析                        |
| `conclusion.md`   | 给出实验结论和后续动作                    |

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

---

## 不应放入本目录的内容

不建议长期保存：

* 大型数据集
* 大型模型文件
* 容器镜像
* 编译缓存
* 临时文件
* 与实验无关的下载包
* 含密钥的配置文件

如必须保留，应使用压缩包、外部存储或远程路径引用，并在 `.gitignore` 中排除不应提交的内容。

---

## 维护要求

每创建一个实验目录，都应同步更新：

* `index.csv`
* 关联假设文件
* 实验目录中的 `README.md`
* 实验完成后的 `analysis.md`
* 实验完成后的 `conclusion.md`
* `memory/evidence_index.md`

本目录的目标是让每个性能结论都有证据来源。