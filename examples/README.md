# examples/

本目录存放一条**填写完成的全链路示例**:一个假设(EX-H001)加一个实验(EX-E002),
展示各模板应填到什么粒度。

> **声明:这是格式与粒度示范,不是可引用的结论。**
> 场景与数字为虚构的领域中性案例(某内部 HTTP 服务的批处理聚合窗口调优),
> 禁止把其中的结论、数值或场景当作先例引用到实际任务中。
> 本目录使用 `EX-` 前缀,不占用正式编号,scripts/validate.py 不检查本目录。

## 内容

```text
examples/
├── README.md
├── EX-H001_batch_window_tail_latency.md   # 填写完成的假设(含状态流转历史)
└── EX-E002_batch_window_ab/               # 填写完成的实验目录
    ├── plan.md
    ├── review.md                          # codex 评审意见的处理记录(执行前门槛)
    ├── remote_ref.yaml
    ├── run_commands.sh
    ├── results/
    │   ├── metrics_parsed.md
    │   └── comparison.md
    ├── analysis.md
    ├── conclusion.md
    ├── audit.md                           # codex 结论审计记录(合规/有效/复现,EVD 登记前门槛)
    └── memory-updates.md                  # 收尾时各索引/memory 文件的更新片段示例
```

示例假定的上下文:虚构的基线实验 EX-E001(批处理窗口=8,p99=118.4ms),
噪声阈值 4%(p99),SLA 达标线 p99 ≤ 100ms。
