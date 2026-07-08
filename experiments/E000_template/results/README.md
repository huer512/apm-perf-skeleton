# results/

本目录用于保存本次实验的结果数据和指标摘要。

这里存放的是"实验产生了什么结果",不是"我们如何解释结果"。
结果解释应写在上一级目录的 `analysis.md` 和 `conclusion.md` 中。

---

## 必备文件

```text
results/
├── README.md
├── metrics_raw.json     # 原始机器可读指标,尽量不要手工修改
├── metrics_parsed.md    # 从原始指标解析出的人工可读摘要
└── comparison.md        # 与对比基线的指标对比
```

除以上三个必备文件外,其余结果文件按 `problem/scoring-and-sla.md` 定义的核心指标**按需创建**(例如按指标类别拆分的明细文件),不设固定清单。

---

## 原始结果原则

原始结果文件应尽量保持不变。

如果需要清洗、筛选或重新计算,应生成新文件,例如:

```text
metrics_raw.json
metrics_cleaned.json
metrics_parsed.md
comparison.md
```

不要直接覆盖原始结果。

多级产物(raw → parsed → comparison)之间只增列不删行,保证每一级都能反向核对上一级。

---

## 指标记录建议

根据项目类型不同,可记录以下指标,但不要局限于此:

| 类别  | 示例指标                               |
| --- | ---------------------------------- |
| 吞吐  | requests/s、tokens/s、queries/s、MB/s |
| 延迟  | mean、median、P90、P95、P99、max        |
| 资源  | CPU、GPU、内存、显存、磁盘、网络                |
| 稳定性 | 失败率、超时率、错误码、重试次数                   |
| 正确性 | 精度、误差、回归测试通过率、一致性                  |
| 成本  | 能耗、运行时间、资源占用成本                     |

指标键名建议带统计量前缀(如 `p99_latency_ms`、`mean_throughput_rps`),消除口径歧义。

---

## comparison.md 格式

```md
# 实验对比

## 对照组
Exxx

## 当前实验
Exxx

## 公平性自检
- same_hardware: yes/no
- same_input_data: yes/no
- same_measurement_path: yes/no(同一测量工具、统计口径、预热策略)
- 对照组配置说明:(对照组是否获得同等调优机会;拿调优后的实验组对比默认配置的对照组,必须在此声明并在结论适用范围中限定)
- notes:(任何 no 都必须解释,并相应限定结论适用范围)

## 完整指标对比

| metric | baseline | current | delta | repeats | exceeds_noise |
|---|---:|---:|---:|---:|---|
| p99_latency_ms |  |  |  |  | yes/no |

## 结论摘要
简要说明结果是否有价值。
```

(`exceeds_noise`:变化幅度是否超过 `problem/scoring-and-sla.md` 的噪声阈值;`repeats`:重复测量次数。)

---

## 可选:批量候选实验的结果行格式

一次实验扫描多个候选配置(参数扫描、A/B/N 对比)时,建议增加 `candidates.jsonl`,每候选一行:

```json
{"candidate_id": "batch32", "status": "ok", "failure_reason": null, "p99_latency_ms": 96.2, "command": "...", "artifacts": "results/batch32/"}
```

- `status` 枚举:`ok` / `failed` / `oom` / `timeout` / `skipped`;失败行必须保留,不要删除。
- 缺失的测量填 `null`,禁止填 0。

---

## 维护要求

每次实验完成后,应至少保存:

* 原始指标
* 解析后的指标摘要
* 与对照组的对比(含重复次数)
* 如果涉及正确性要求,应保存正确性检查结果
* 如果涉及资源优化,应保存资源占用结果

本目录的目标是保证实验结论有明确数据支撑。
