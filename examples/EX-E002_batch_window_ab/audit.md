# 实验结论审计记录

## 审计工具
codex(codex-cli 0.142.5,模型 gpt-5.5,effort xhigh;
经 `scripts/codex_audit.sh examples/EX-E002_batch_window_ab` 调用,
原始输出 audit_codex_raw.md 在本示例中省略,要点已摘入下表)

## 送审材料
- plan.md、conclusion.md、analysis.md、results/comparison.md
- code/patch.diff、code/changed_files.md、run_commands.sh
- problem/allowed-and-forbidden.md(示例:允许调整服务配置项;禁止修改评测负载与正确性路径)
- problem/scoring-and-sla.md(噪声阈值 4%,SLA 达标线 p99 ≤ 100ms)

## 审计意见与处理

| # | 维度 | severity | 意见摘要 | 处理 | 理由 |
|---|---|---|---|---|---|
| 1 | effectiveness | minor | comparison.md 只给中位值与极差,建议补逐轮数值指引以便第三方复核 −18.8% 是否稳定 | adopted | metrics_parsed.md 已注明逐轮原始值在 metrics_raw_round1..5.json,结论数字与其一致 |
| 2 | reproducibility | minor | run_commands.sh 用固定 `sleep 10` 预热,就绪时间依赖机器状态,严格复现应等健康检查信号 | deferred | 与基线采集方式一致(基线同为 sleep 10),单侧改动破坏可比性;记入后续动作,基线升级时统一改 |
| 3 | compliance | minor | 确认 patch 仅改 `batch_window_size` 单配置项,未触碰评测负载、正确性路径与禁止项 | adopted | changed_files.md 与 patch.diff 一致,确认性意见,无需改动 |

## 分维度结论
- 合规性:pass(单配置项改动,在允许清单内;评测负载与正确性路径未动,响应体抽样比对通过)
- 有效性:pass(同一冻结基线同一负载,5 轮重复,p99 −18.8% 远超 4% 噪声阈值;p50 回归已披露并纳入失败标准判定)
- 复现性:pass(负载为固定录制回放、无随机采样;环境快照与命令完整;#2 为改进建议,不构成不可复现)

## 审计判定
approved-with-changes

## 判定说明
#1、#3 已确认或回写;#2 转入后续动作(与评审意见 #2 同源,待基线升级统一处理)。
可以登记 EVD(EX-EVD002/003/004)并回写 EX-H001 状态。
