# 实验台账(append-only)

| time | action | result | next |
|---|---|---|---|
| 2025-11-05 14:10 | plan.md 完成 | 已含先验检索与中止条件 | 送 codex 评审 |
| 2025-11-05 14:40 | codex 评审返回 | 3 条意见,#1 major(p50 盲区) | 处理意见 |
| 2025-11-05 15:05 | 意见处理完毕 | #1/#3 adopted 回写 plan,#2 rejected;review.md 判定 approved-with-changes | 执行实验 |
| 2025-11-05 15:20 | round 1-2 完成 | p99 94.8 / 96.2ms,正常 | 继续 round 3-5 |
| 2025-11-05 16:05 | (会话中断) | round 3 进行中,产物齐至 round 2 | 从 round 3 重跑 |
| 2025-11-05 16:30 | 新会话接手,round 3-5 完成 | 5 轮齐,极差 93.4–99.5ms | 解析与对比 |
| 2025-11-05 17:00 | 曾考虑顺手把 flush_interval 5ms→2ms 一起测 | 放弃:违反"一次只改少量变量",记入后续假设候选 | 写 analysis |
| 2025-11-06 10:20 | analysis.md / conclusion.md 完成 | supported,p50 回归待评估 | 送 codex 审计 |
| 2025-11-06 11:00 | codex 审计返回并处理 | audit.md 判定 approved-with-changes | 登记 EVD,回写 EX-H001 |
| 2025-11-06 11:15 | EVD 登记 + H 回写 + index/memory 更新 | 收尾完成,validate 通过 | 提交 |
