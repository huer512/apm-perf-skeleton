# 实验评审记录

## 评审工具
codex(codex-cli 0.142.5,模型 gpt-5.5,effort xhigh;
经 `scripts/codex_review.sh examples/EX-E002_batch_window_ab` 调用,
原始输出 review_codex_raw.md 在本示例中省略,要点已摘入下表)

## 送审材料
- plan.md(2025-11-05 版本)
- 关联假设 EX-H001
- problem/scoring-and-sla.md(噪声阈值 4%,SLA 达标线 p99 ≤ 100ms)

## 评审意见与处理

| # | severity | 意见摘要 | 处理 | 理由 |
|---|---|---|---|---|
| 1 | major | 计划自己预期 p50 会上升,但失败标准未对 p50 设边界——p50 严重回归也会被判"成功",存在指标回归盲区 | adopted | 失败标准增补"p50 上升 >15% 即失败",阈值对齐上游调用方超时预算,已回写 plan.md |
| 2 | minor | 建议每轮丢弃预热片段数据,避免冷缓存拉高首轮延迟 | rejected | 基线 EX-E001 采集时未丢弃预热段,单侧改动破坏可比性;记入后续动作,待基线升级时统一处理 |
| 3 | minor | 建议同步采集数据库侧指标(连接池等待计数)作为机制证据,而不是只看端到端延迟 | adopted | analysis 增加 pool wait 次数统计用于归因(最终成为 p99 归因的关键证据) |

## 评审判定
approved-with-changes

## 判定说明
意见 #1、#3 已回写 plan.md 并复核;#2 拒绝理由已记录。可以执行实验。
