# results/

本目录用于保存本次实验的结果数据和指标摘要。

这里存放的是“实验产生了什么结果”，不是“我们如何解释结果”。  
结果解释应写在上一级目录的 `analysis.md` 和 `conclusion.md` 中。

---

## 目录结构

```text
results/
├── README.md
├── metrics_raw.json
├── metrics_parsed.md
├── throughput.md
├── latency.md
├── memory.md
├── correctness.md
└── comparison.md
```

---

## 文件说明

| 文件                  | 作用                    |
| ------------------- | --------------------- |
| `metrics_raw.json`  | 原始机器可读指标，尽量不要手工修改     |
| `metrics_parsed.md` | 从原始指标解析出的人工可读摘要       |
| `throughput.md`     | 吞吐相关结果                |
| `latency.md`        | 延迟相关结果                |
| `memory.md`         | 内存、显存、缓存、资源占用等结果      |
| `correctness.md`    | 正确性、精度、一致性或回归测试结果     |
| `comparison.md`     | 与 baseline 或其它实验的指标对比 |

---

## 原始结果原则

原始结果文件应尽量保持不变。

如果需要清洗、筛选或重新计算，应生成新文件，例如：

```text
metrics_raw.json
metrics_cleaned.json
metrics_parsed.md
comparison.md
```

不要直接覆盖原始结果。

---

## 指标记录建议

根据项目类型不同，可记录以下指标，但不要局限于此：

| 类别  | 示例指标                               |
| --- | ---------------------------------- |
| 吞吐  | requests/s、tokens/s、queries/s、MB/s |
| 延迟  | mean、median、P90、P95、P99、max        |
| 资源  | CPU、GPU、内存、显存、磁盘、网络                |
| 稳定性 | 失败率、超时率、错误码、重试次数                   |
| 正确性 | 精度、误差、回归测试通过率、一致性                  |
| 成本  | 能耗、运行时间、资源占用成本                     |

---

## comparison.md 格式

```md
# 实验对比

## 对照组
Exxx

## 当前实验
Exxx

## 完整指标对比

| 指标 | 对照组 | 当前实验 | 变化 | 是否符合预期 |
|---|---:|---:|---:|---|
| 指标 1 | 0 | 0 | 0% | yes/no |
| 指标 2 | 0 | 0 | 0% | yes/no |

## 结论摘要
简要说明结果是否有价值。
```

---

## 维护要求

每次实验完成后，应至少保存：

* 原始指标
* 解析后的指标摘要
* 与对照组的对比
* 如果涉及正确性要求，应保存正确性检查结果
* 如果涉及资源优化，应保存资源占用结果

本目录的目标是保证实验结论有明确数据支撑。
