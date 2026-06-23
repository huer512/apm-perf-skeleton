# logs/

本目录用于保存本次实验产生的日志文件。

日志用于排查错误、解释异常、复现实验过程和辅助分析性能瓶颈。

---

## 推荐结构

```text
logs/
├── README.md
├── build.log
├── run.log
├── benchmark.log
├── service.log
├── error.log
└── logs_index.md
```

---

## 文件说明

| 文件              | 作用                  |
| --------------- | ------------------- |
| `build.log`     | 编译、安装、构建过程日志        |
| `run.log`       | 主程序运行日志             |
| `benchmark.log` | 压测、评测或 benchmark 日志 |
| `service.log`   | 服务端日志               |
| `error.log`     | 错误、异常、崩溃、超时日志       |
| `logs_index.md` | 日志索引和说明             |

---

## logs_index.md 推荐格式

```md
# 日志索引

| 日志文件 | 来源命令 | 开始时间 | 结束时间 | 是否完整 | 说明 |
|---|---|---|---|---|---|
| build.log | bash build.sh |  |  | yes/no |  |
| benchmark.log | bash run_bench.sh |  |  | yes/no |  |
```

---

## 日志保存原则

1. 重要实验应保存完整日志。
2. 大日志可以压缩保存。
3. 不要只保存错误片段，应尽量保留上下文。
4. 如果日志过大，可保留索引和远程路径。
5. 日志中如果包含密钥、token、账号、私有路径，应先脱敏。
6. 不要覆盖旧日志，必要时添加时间戳。

---

## 推荐命名方式

```text
build_YYYYMMDD_HHMMSS.log
run_YYYYMMDD_HHMMSS.log
benchmark_YYYYMMDD_HHMMSS.log
service_YYYYMMDD_HHMMSS.log
error_YYYYMMDD_HHMMSS.log
```

---

## 维护要求

如果实验失败，也必须保存日志，并在上一级目录的 `analysis.md` 中说明失败原因。

本目录的目标不是堆积日志，而是让异常和性能变化能够被追溯。