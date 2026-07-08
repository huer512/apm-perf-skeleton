# 实验结论审计记录

> 模板文件:conclusion.md 完成后填写,并删除本横幅。审计判定通过前,禁止登记 EVD、
> 禁止回写假设状态、禁止把实验标为 analyzed(见 AGENTS.md 硬门槛)。
> 默认审计方式:`scripts/codex_audit.sh <实验目录>`,codex 原始意见存于 audit_codex_raw.md。
> 填写粒度参照 `examples/EX-E002_batch_window_ab/audit.md`。

## 审计工具
codex(版本:____,模型 gpt-5.5,effort xhigh)/ 其它独立审计者(说明是谁)

## 送审材料
- plan.md、conclusion.md、analysis.md、results/comparison.md
- code/patch.diff、code/changed_files.md、run_commands.sh
- problem/allowed-and-forbidden.md、problem/scoring-and-sla.md

## 审计意见与处理

| # | 维度 | severity | 意见摘要 | 处理 | 理由 |
|---|---|---|---|---|---|
| 1 | compliance / effectiveness / reproducibility | blocker / major / minor | | adopted / rejected / deferred | |

(adopted 的意见必须先回写对应文档——结论、分析或补充测量——再进入判定;rejected 必须写理由。)

## 分维度结论
- 合规性(不触碰禁止项、不绕过评测、不牺牲正确性):pass / concerns / fail
- 有效性(同基线同负载、超噪声阈值、数字与原始数据一致、无被掩盖的回归):pass / concerns / fail
- 复现性(无未受控随机性、命令与环境完整、适用范围与测量条件一致):pass / concerns / fail

## 审计判定
approved / approved-with-changes / rework / waived(填写时只保留一个值)

- `approved`:三维度均 pass,可登记 EVD、回写假设状态。
- `approved-with-changes`:adopted 意见已回写处理,无 fail 项。
- `rework`:存在 fail 或未解决的 blocker——按意见补测或修订结论后重新审计;必要时将 conclusion 的"是否有效"降级。
- `waived`:审计不可用,记录原因与风险后放行(见 AGENTS.md 降级路径)。

## 判定说明
(waived 的原因与风险;approved-with-changes 时列出已完成的修改与 deferred 项去向。)
