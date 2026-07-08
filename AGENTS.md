# AGENTS.md — Agent 执行契约

本文件是 AI Agent(及人工执行者)在本仓库工作的入口契约,也是收尾清单与红线的**唯一权威来源**;其它文档与本文件冲突时,以本文件为准。

措辞约定:**必须 / 禁止** = 硬约束,违反即流程不合规;**建议** = 软偏好,可按情况取舍。

---

## 进场顺序(每个新会话必须依次执行)

1. 读 `memory/current_state.md`,恢复当前阶段、最佳实验、风险与下一步动作。
2. 检查 `problem/` 四个文件是否已初始化(各文件头部横幅有判据)。未初始化 → 先执行**第 0 步 intake**:从原始任务描述、需求材料中抽取填写 problem/ 四文件;不确定之处标注"待确认"并记入 current_state 风险,禁止编造外部规则。
3. 按需检索 memory/(`insight_bank.md`、`decision_log.md`、`gotchas.md`、`evidence_index.md`)与既往 Hxxx/Exxx。**记忆是线索不是证据**:引用洞察时注明编号,但旧洞察不能替代新测量。
4. 继续 current_state 中的下一步动作;没有未完成动作时,按根 README 的工作流推进:基线未冻结先建基线实验,再提假设、建实验。

---

## 收尾清单(每次会话结束前必须逐项完成)

1. 回写本轮涉及的 Hxxx:状态、关联实验、支持/反驳证据、后续动作(联动规则见 `hypotheses/README.md`)。
2. 更新 `experiments/index.csv`(status、valid、key_result)。
3. conclusion.md 已完成的实验:先做结论审计(`scripts/codex_audit.sh <实验目录>` → 意见整理进 audit.md,判定通过),再在 `memory/evidence_index.md` 登记 EVD(登记规则见 `experiments/README.md`)。
4. 必要时更新 `memory/insight_bank.md`、`memory/decision_log.md`、`memory/gotchas.md`。
5. 更新 `memory/current_state.md`(阶段、最佳实验、风险、下一步动作)。
6. 运行 `python3 scripts/validate.py` 并清零报错;无法运行脚本时,按脚本文件头部的手工核对清单逐项检查。
7. git 提交:每个实验收尾至少一次提交,message 格式建议 `Exxx: 一句话结论 (Hxxx)`,memory/ 与 index.csv 变更随同提交;收尾后 `git status` 中**禁止**残留未跟踪的研究文档(md/csv)。

---

## 硬门槛与降级路径

每道门都配有出口;走降级路径时必须留下记录,禁止伪造内容解锁流程。

| 硬门槛 | 降级路径 |
| --- | --- |
| plan.md 未完成,禁止执行实验 | 信息不足时在 plan.md 中显式写下假定值并标"待确认" |
| review.md 判定非 approved / approved-with-changes,禁止执行实验(默认用 codex 评审:`scripts/codex_review.sh <实验目录>`,adopted 意见须先回写 plan.md) | codex 与替代评审(其它独立模型/人工)均不可用 → review.md 判定填 waived,写明原因与风险后可执行 |
| analysis.md 未完成,禁止写 conclusion.md | 实验失败无法分析 → analysis.md 记录失败原因与日志位置,conclusion.md 的"是否有效"填 invalid |
| conclusion.md 未完成,禁止改写 Hxxx 状态 | 实验中止 → H 状态回 planned,并在"后续动作"记录原因 |
| audit.md 判定非 approved / approved-with-changes,禁止登记 EVD、禁止回写 Hxxx 状态、禁止把实验标为 analyzed(结论审计:`scripts/codex_audit.sh <实验目录>`,从合规性/有效性/复现性三维度审查) | codex 与替代审计(其它独立模型/人工)均不可用 → audit.md 判定填 waived,写明原因与风险后放行 |
| H 状态改为 rejected,必须引用至少一条反驳 EVD | 无正式证据但明确放弃该方向 → 状态用 deprecated,并在 memory/decision_log.md 记 Dxxx 说明理由 |

---

## 红线(防证据失真,全部为硬约束)

1. 工具或依赖缺失时,**必须**如实记录为环境缺口(current_state 风险 + 实验日志),**禁止**写成"目标系统不支持该功能"。
2. 测量全部失败时,实验**必须**标 failed 并保留日志,**禁止**产出看似正常的空 results 文件或编造数据。
3. 缩水的冒烟运行**必须**标注为"流程验证",**禁止**登记为性能证据(EVD)。
4. 单次测量**禁止**登记为 EVD;改进幅度低于 `problem/scoring-and-sla.md` 噪声阈值时,**必须**重复测量并报告统计量(重复次数与方法在 plan.md 声明)。
5. 收尾清理**必须**限于本实验产物与自己启动的进程,**禁止**清理共享缓存、他人工作目录或终止他人进程。

---

## 全库语言与机读性约定

- 机读内容(csv 表头、索引表头、枚举值、编号)**必须**用英文;叙述性内容用中文。
- 正式文件中的枚举字段**必须**只保留单个实际取值,**禁止**保留"a / b / c"式备选罗列。
- 编号约定以根 README 的表格为唯一定义;`examples/` 内使用 `EX-` 前缀,不占正式编号。
