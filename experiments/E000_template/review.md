# 实验评审记录

> 模板文件:plan.md 完成后、实验执行前必须完成本文件,并删除本横幅。
> 默认评审方式:`scripts/codex_review.sh <实验目录>`,codex 原始意见存于 review_codex_raw.md;
> codex 不可用时的降级路径见 AGENTS.md 硬门槛表。
> 填写粒度参照 `examples/EX-E002_batch_window_ab/review.md`。

## 评审工具
codex(版本:____,模型 gpt-5.5,effort xhigh)/ 其它独立评审者(说明是谁)

## 送审材料
- plan.md(版本或时间点)
- 关联假设 Hxxx
- problem/scoring-and-sla.md

## 评审意见与处理

| # | severity | 意见摘要 | 处理 | 理由 |
|---|---|---|---|---|
| 1 | blocker / major / minor | | adopted / rejected / deferred | |

(处理为 adopted 的意见,必须先回写 plan.md,再进入判定;rejected 必须写理由。)

## 评审判定
approved / approved-with-changes / rework / waived(填写时只保留一个值)

- `approved`:无需修改,可执行。
- `approved-with-changes`:adopted 意见已回写 plan.md,可执行。
- `rework`:存在未解决的 blocker,修改 plan.md 后必须重新评审,禁止执行。
- `waived`:评审不可用,记录原因与风险后放行(见 AGENTS.md 降级路径)。

## 判定说明
(approved-with-changes:列出已完成的修改;waived:写明评审不可用的原因与自担风险。)
