# 收尾更新片段示例

> 本文件不是实验模板的一部分,只演示收尾清单各步骤写出来长什么样。

## experiments/index.csv 追加行

```csv
EX-E002,batch_window_ab,EX-H001,analyzed,yes,p99 -18.8% 进入 SLA;p50 +12.4% 待评估,experiments/EX-E002_batch_window_ab,2025-11-05,agent-s1105b
```

## memory/evidence_index.md 追加行

(登记前提:audit.md 审计判定为 approved-with-changes,过程见 audit.md。)

```md
| EX-EVD002 | EX-E002 | EX-H001 | supports | confirmed | p99 118.4→96.2ms(-18.8%) | examples/EX-E002_batch_window_ab/results/comparison.md | bash run_commands.sh | 无低谷段负载,窗口退化场景未验证 |
| EX-EVD003 | EX-E002 | EX-H001 | supports | confirmed | 吞吐 2140→2612 rps(+22.1%) | examples/EX-E002_batch_window_ab/results/comparison.md | bash run_commands.sh | — |
| EX-EVD004 | EX-E002 | none | supports | confirmed | p50 42.1→47.3ms(+12.4%)观察项 | examples/EX-E002_batch_window_ab/results/comparison.md | bash run_commands.sh | — |
```

## 假设文件回写

EX-H001 状态 testing → supported;"支持证据"填入 EX-EVD002、EX-EVD003;"后续动作"更新为 p50 评估。

## memory/current_state.md 更新要点

- 当前阶段:优化验证
- 当前最佳实验:EX-E002
- 当前主要风险:p50 +12.4% 可能触碰上游超时预算(待确认)
- 下一步动作:评估 p50 影响;设计连接池扩容对照实验

## git 提交

```text
EX-E002: batch window 32 puts p99 into SLA, p50 regression pending (EX-H001)
```
