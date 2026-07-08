# Experiment Directory Template

> **本目录为实验模板(E000),不参与实际任务记录。**
> 创建新实验时,复制本目录为 `E001_xxx`、`E002_xxx`(从 **E001** 开始编号),然后:
> ① 删除各文件顶部的"模板文件"横幅;
> ② 将本 README 改写为该实验的简介(实验目的、当前状态、关键产出的位置)。
> 各文件填写粒度参照 `examples/EX-E002_batch_window_ab/`(仅参照格式,不要引用其内容)。

---

本目录用于保存一次独立实验的完整材料。

一个实验应该能够回答:

1. 本次实验想验证什么?
2. 它关联哪个假设?
3. 相比对照组改了什么?
4. 如何运行?
5. 得到了什么结果?
6. 结果是否可信?
7. 该实验支持还是反驳了原假设?
8. 下一步应该怎么做?

---

## 目录结构

```text
.
├── README.md
├── plan.md
├── review.md
├── ledger.md
├── remote_ref.yaml
├── run_commands.sh
├── code/
├── results/
├── logs/
├── analysis.md
├── conclusion.md
└── audit.md
```

---

## 文件说明

各文件的填写要求以文件内的章节结构为准,此处只说明职责:

| 文件或目录             | 说明                        |
| ----------------- | ------------------------- |
| `plan.md`         | 实验计划,运行前编写                |
| `review.md`       | 实验计划评审记录:codex 意见的逐条处理与最终判定,判定通过才可执行(见 AGENTS.md 硬门槛) |
| `ledger.md`       | 实验台账(append-only):每个动作一行,含失败尝试与被否想法;断点恢复以此为准 |
| `remote_ref.yaml` | 远程实验通过 `server_id` 引用 `remote/servers.private.yaml`,并记录代码位置、commit、分支、产物路径;本地实验 `server_id` 填 `local` |
| `run_commands.sh` | 实验运行命令,含环境快照与日志落盘骨架       |
| `code/`           | 代码补丁、改动说明、代码包             |
| `results/`        | 原始结果、解析结果、指标对比            |
| `logs/`           | 服务日志、压测日志、构建日志、错误日志       |
| `analysis.md`     | 结果分析,运行后编写                |
| `conclusion.md`   | 实验结论,分析后编写                |
| `audit.md`        | 结论审计记录(合规性/有效性/复现性),判定通过才可登记 EVD 与回写假设(见 AGENTS.md 硬门槛) |

---

## 更新顺序

推荐按照以下顺序维护本目录:

```text
1. 创建实验目录
2. 编写 plan.md
3. 填写 remote_ref.yaml
4. 编写或复制 run_commands.sh
5. 评审:运行 scripts/codex_review.sh <实验目录>,把意见整理进 review.md,
   adopted 意见回写 plan.md,判定 approved / approved-with-changes 后才可继续
6. 执行实验
7. 保存 code/
8. 保存 results/
9. 保存 logs/
10. 编写 analysis.md
11. 编写 conclusion.md
12. 审计:运行 scripts/codex_audit.sh <实验目录>,把意见整理进 audit.md
    (合规性/有效性/复现性),判定通过后才可登记 EVD 与回写假设状态
13. 更新 experiments/index.csv
14. 更新 memory/
```

以上每完成一步,在 `ledger.md` 追加一行(time / action / result / next);会话中断后按台账最后一行恢复。

---

## 注意事项

* 不要覆盖原始结果。
* 不要只保存截图,尽量保存机器可读结果。
* 不要只写结论,必须保留支持结论的证据。
* 无效实验也要记录,避免后续重复踩坑;被否的想法与失败尝试记入 `ledger.md`。
* `run_commands.sh` 中的环境改动步骤必须可重入:apply 前先检查或先恢复,保证中断后重跑不会失败或叠加。
* 如果实验依赖远程服务器,必须在 `remote/servers.private.yaml` 中配置 SSH 信息,并在 `remote_ref.yaml` 中填写 `server_id`、远程路径、分支和 commit。
* 远程实验结束后,必须将结果与日志回传到本目录的 `results/` 与 `logs/`,并把拉取命令记入日志(见 `remote/README.md` 的"结果回传")。
