# AGENTS.md — Agent 执行契约

本文件是 AI Agent(及人工执行者)在本仓库工作的入口契约,也是收尾清单、状态机、红线的**唯一权威来源**;其它文档与本文件冲突时,以本文件为准。

措辞约定:**必须 / 禁止** = 硬约束,违反即流程不合规;**建议** = 软偏好,可按情况取舍。

角色细则见 [`agents/`](agents/README.md)。主 Agent 必须按本文件状态机调度。

**「调用 xx 角色」的唯一定义**:主调度(scheduler)启动一个 subagent,并在其任务书中按 [`agents/README.md`](agents/README.md) 的**固定模板**要求其**首先读取** `AGENTS.md` 与 `agents/<role>.md`,再执行该角色职责。不是「主 Agent 自己假装该角色」、也不是只 @ 文件而不开 subagent(主会话本身担任 scheduler 时除外)。

---

## 进场顺序(每个新会话必须依次执行)

1. 读 `memory/current_state.md`,恢复 **工作流状态机** 字段(`phase` / `active_exp` / `last_diag_exp` / `queue`)、最佳实验、风险与下一步。
2. 检查 `problem/` 四个文件是否已初始化(各文件头部横幅有判据)。未初始化 → 由 scheduler 将 `phase` 写为 `intake`,再调用 intake 角色。
3. 按需检索 `references/`、`memory/`(`insight_bank.md`、`decision_log.md`、`gotchas.md`、`evidence_index.md`、`component_index.md`)及既往 Hxxx/Exxx。**记忆是线索不是证据**:引用洞察时注明编号,但旧洞察不能替代新测量。
4. 以 `current_state.md` 中的 `phase` 为准调用对应角色推进;接手进行中的实验时,先读该实验的 `ledger.md`,按最后一行的 next 恢复断点。`phase` 缺失时由 scheduler 按下方状态机从合法起点**写入文件后**再调度,禁止跳步。

---

## phase 存哪里、谁能改、如何避免并行打架

### 持久真相(文件)

- `phase` / `active_exp` / `last_diag_exp` / `queue` 的**持久真相**写在 `memory/current_state.md` 的「工作流状态机」节。
- **只有 scheduler 可以改写这四个字段**(在一次 subagent 调用返回之后、下一次调用之前更新)。
- subagent **禁止**修改 `current_state.md` 中的状态机四字段;需要转移时只返回 `next_hint`,由 scheduler 校验合法边后再落盘。

### 调用时快照(任务书)

- 每次调用角色时,scheduler 把**当时文件中的四字段**抄进任务书的 `当前:` 行,作为该 subagent 的**只读快照**。
- subagent 以任务书快照为准执行本步;若发现文件与快照不一致 → 返回 `blocked`,不得擅自以文件为准继续改全局状态。

### 并行策略(硬约束)

| 规则 | 要求 |
| --- | --- |
| 默认 | **串行**:同一时刻只允许 1 个角色 subagent 处于运行中(scheduler 自身推理不算) |
| 禁止 | 并行两个会写 `current_state` 状态机字段、或争用同一 `gpu.lock`、或改同一 `active_exp` 目录的 subagent |
| 例外(可选并行) | 仅当任务互不共享上述资源时允许,例如:两个**只读**检索、或两个已隔离 worktree 且**各持不同 GPU**且**不写状态机字段**的辅助任务;主状态机推进仍必须串行 |
| 落盘时机 | scheduler 必须在「上一个角色 subagent 已结束并已更新 current_state」之后,才启动下一个推进状态机的角色 |

因此:phase **既写在文件里**(跨会话恢复),**也写在每次任务书里**(本次调用契约);靠「单写者 + 默认串行」避免并行互相覆盖。

---

## 工作流状态机(全自动推进的唯一剧本)

主调度(scheduler)维护 `memory/current_state.md` 中的:

| 字段 | 含义 |
| --- | --- |
| `phase` | 下方枚举之一 |
| `active_exp` | 当前操作的 Exxx,无则 `none` |
| `last_diag_exp` | 针对**当前最佳栈**的最近一次诊断实验 Exxx,无则 `none` |
| `queue` | 待测方向/假设编号列表;空列表必须用 `[]` 写明 |

### phase 枚举与合法转移

```text
intake
  → baseline_setup          # problem 四文件齐
baseline_setup
  → baseline_run            # 本地已留存完整上游代码;远程已按官方包落地
baseline_run
  → baseline_freeze         # 基线数字进 E001 results;run_commands.md 完整
baseline_freeze
  → diagnose                # 强制:先诊断再优化
diagnose
  → direction_gen           # 诊断实验 conclusion 完成
direction_gen
  → plan_next               # queue 非空
  → report                  # 仅当命中 report/README 终止白名单(见 direction_gen 规则)
plan_next
  → review_plan             # plan.md 写完
review_plan
  → execute                 # review ∈ {approved, approved-with-changes(已回写 plan), waived}
  → plan_next               # review = rework
execute
  → analyze                 # 产物回传完成
analyze
  → audit_conclusion        # analysis.md + conclusion.md 齐
audit_conclusion
  → register_evd            # audit ∈ {approved, approved-with-changes(文档已改完), waived}
  → execute                 # rework_class = remeasure
  → plan_next               # rework_class = recode
diagnose                    # 从 decide_next 转入(最佳栈变更)
register_evd
  → decide_next             # EVD/H/index 已按强制表更新
decide_next
  → diagnose                # 最佳栈变更,或 last_diag_exp 不是当前最佳栈
  → plan_next               # queue 非空且栈未变
  → direction_gen           # queue 为空且未命中终止白名单
  → report                  # 命中 report/README 终止白名单
```

### 调度硬约束

1. **禁止**在 `last_diag_exp` 为 `none`、或其结论所针对的栈 ≠ 当前最佳实验时,进入优化类实验的 `plan_next` / `execute`。
2. **禁止**跳过 `audit_conclusion` / `register_evd` 直接改 H 状态或写 insight 为定论。
3. **禁止**在 `execute` 阶段编写分析结论或登记 EVD。
4. **禁止**跳过状态机自创 phase 或合并多个角色一步做完(除非本文件明确允许同一角色覆盖相邻子步,如 baseline)。
5. subagent 返回的 `next_hint` 必须能映射到上表某条合法边;不能映射则 `blocked`,写入 current_state 风险并停机。
6. **禁止**并行推进状态机(见上文「并行策略」);「调用角色」必须走固定任务书模板(见 `agents/README.md`)。

### direction_gen 与 codex(无灰色地带)

- planner 若能依据 `last_diag_exp` 写出 **≥1 条**可入队新方向 → 写入 `queue` / 创建或更新 Hxxx → `phase → plan_next`。**此情形不必调 codex**。
- planner **自己认为没有新方向**(即将交出空队列、或仅重复已关闭线) → **必须**运行 `scripts/codex_directions.sh`(可传诊断 Exxx;默认读 `last_diag_exp`),产物写入 `memory/direction_codex_raw.md`;禁止「可调可不调」、禁止空队列直接进入 `plan_next`。
- codex 返回后仍无法产生任何未关闭新方向 → **必须**对照 `report/README.md` 终止白名单:命中则 `phase → report`;未命中则 `blocked`(记风险与已尝试的方向生成记录),**禁止**假装到顶并停更。
- **禁止**因「预期收益小」拒绝入队;小优化仍须入队并测量。

---

## 角色路由(主调度必须遵守)

| phase | 调用角色 | 角色文档 |
| --- | --- | --- |
| intake | intake | [`agents/intake.md`](agents/intake.md) |
| baseline_setup / baseline_run / baseline_freeze | baseline | [`agents/baseline.md`](agents/baseline.md) |
| diagnose | profiler | [`agents/profiler.md`](agents/profiler.md) |
| direction_gen / plan_next | planner | [`agents/planner.md`](agents/planner.md) |
| review_plan / audit_conclusion / register_evd | audit_clerk | [`agents/audit_clerk.md`](agents/audit_clerk.md) |
| execute | remote_runner | [`agents/remote_runner.md`](agents/remote_runner.md) |
| analyze | analyst | [`agents/analyst.md`](agents/analyst.md) |
| decide_next / report | scheduler | [`agents/scheduler.md`](agents/scheduler.md) |

互动协议与任务书格式见 [`agents/README.md`](agents/README.md)。

---

## Review / Audit → EVD(无「可登」裁量)

两道门分离。**只有 audit_clerk 在 `register_evd` phase 写入 EVD**;调度者与其它角色不得决定「这次先不登」。

### review.md(执行前,不涉及 EVD)

| 判定 | 强制动作 |
| --- | --- |
| `approved` | `phase → execute` |
| `approved-with-changes` | **必须先回写 plan.md**,再 `phase → execute` |
| `rework` | `phase → plan_next`(改 plan,重新 review) |
| `waived` | `phase → execute`;plan/ledger 必须记豁免原因与风险 |

### audit.md(结论后)

`audit.md` **必须**含单值字段:

- `审计判定`: `approved` / `approved-with-changes` / `rework` / `waived`
- `rework_class`: `none` / `docs` / `remeasure` / `recode`  
  (`approved` / `approved-with-changes` / `waived` 时必须为 `none`)

| 判定 + rework_class | 强制动作 |
| --- | --- |
| `approved` + `none` | **必须登记 EVD**;必须回写 H;`phase → register_evd` 完成后 `decide_next` |
| `approved-with-changes` + `none` | **必须先改文档**(analysis/conclusion/limits 等)至通过态 → **必须登记 EVD**;**禁止**因文档问题重跑实验 |
| `rework` + `docs` | 按 `approved-with-changes` 处理(**不重跑**);不得以 docs 为由长期卡在 rework |
| `rework` + `remeasure` | **禁止登记 EVD**;`phase → execute`(同代码补测);H 保持 `testing` |
| `rework` + `recode` | **禁止登记 EVD**;`phase → plan_next`;H 回 `planned` 或保持 `testing`(clerk 在结论后续动作写明) |
| `waived` + `none` | **必须登记 EVD**,且 `strength` **强制为 `weak`**,`limits` **必须**写豁免原因 |

`plan.md` 声明 `evidence_class: diagnostic` 的诊断实验:仍按上表 **必须/禁止** 登记 EVD;若登记,其 `limits` **必须**含 `diagnostic-only; not for latency claim`,**禁止**用该 EVD 声称端到端加速。

冒烟/流程验证/单次未重复测量:**禁止**登记为性能 EVD(见红线)。

---

## 执行记录与部署

1. **禁止**编写或执行「部署 + 跑完 + 取数」一体化、试图一次跑完全程的脚本(含 `run_commands.sh` 一类一键复现脚本)。
2. 执行权威仅为实验目录内的 **`run_commands.md`**:逐条记录命令、时间、退出码、产物路径与 md5;复现时由 Agent **再逐条执行**该文件中的命令,中间出错必须停下思考并追加修正步。
3. 代码变更:**必须**先落本地 `experiments/Exxx/code/`,再部署远程。
   - 单文件/小包:远程文件名 **必须**为 `{stem}_{Exxx}.py`(或等价),**禁止**覆盖共享入口。
   - 大项目(如 vLLM):远程以 git 仓库为底,**必须**使用与本地实验目录**同名**的 `git worktree`,测量 cwd 指向该 worktree。
4. Baseline:官方代码包**必须**在本地完整留存(权重可只记远程路径与校验和),并在远程忠实按包跑通后再冻结 E001。

---

## GPU 锁协议(单机单仓库)

项目根目录文件 `gpu.lock`(键值文本)。当前不考虑多机多仓库。

建议字段:

```text
holder=E046
gpus=0
expires_at=2026-07-18T21:00:00+08:00
lease_token=<uuid>
pids=1234,1235
```

| 条件 | 动作 |
| --- | --- |
| 无锁或 `expires_at` 已过期 | 仅终止锁内 `pids` 所列进程(无 pids 则只告警并抢锁,**禁止**默认杀光全部 GPU 进程);写入新锁后开始实验 |
| 锁未过期且 `holder` 是本实验 | 可续约 `expires_at`;继续执行 |
| 锁未过期且 `holder` 是其它实验 | **等待**至过期或锁释放;**禁止**抢杀 |
| 实验正常/异常结束 | 终止本锁 `pids`,删除 `gpu.lock` |

`gpu.lock` 已加入 `.gitignore` 时不必入库;ledger 中记录租约起止即可。

---

## 收尾清单(每次会话结束前必须逐项完成)

1. 回写本轮涉及的 Hxxx:状态、关联实验、支持/反驳证据、后续动作(联动规则见 `hypotheses/README.md`)。
2. 更新 `experiments/index.csv`(status、valid、key_result)。
3. 处于或经过 `register_evd` 的实验:按本文件 EVD 强制表登记或确认已禁止登记;更新 `memory/evidence_index.md`。
4. 必要时更新 `memory/insight_bank.md`、`memory/decision_log.md`、`memory/gotchas.md`;实验触碰的组件登记到 `memory/component_index.md`。
5. 更新 `memory/current_state.md`(含状态机四字段、阶段叙述、最佳实验、风险、下一步)。
6. 运行 `python3 scripts/validate.py` 并清零报错;无法运行脚本时,按脚本文件头部的手工核对清单逐项检查。
7. git 提交:每个实验收尾至少一次提交,message 格式建议 `Exxx: 一句话结论 (Hxxx)`,memory/ 与 index.csv 变更随同提交;收尾后 `git status` 中**禁止**残留未跟踪的研究文档(md/csv)。

---

## 硬门槛与降级路径

| 硬门槛 | 降级路径 |
| --- | --- |
| plan.md 未完成,禁止执行实验 | 信息不足时在 plan.md 中显式写下假定值并标"待确认" |
| review.md 判定非 approved / approved-with-changes / waived,禁止执行 | codex 与替代评审均不可用 → `waived`,写明原因与风险 |
| analysis.md 未完成,禁止写 conclusion.md | 实验失败无法分析 → analysis 记失败原因与日志位置,conclusion「是否有效」填 invalid |
| conclusion.md 未完成,禁止改写 Hxxx 状态 | 实验中止 → H 回 planned,并在「后续动作」记录原因 |
| 未按 EVD 强制表完成 register_evd 动作,禁止把优化结论写入 insight 定论、禁止标 analyzed | audit 不可用 → `waived` 后仍**必须**登记 EVD(strength=weak) |
| H 状态改为 rejected,必须引用至少一条反驳 EVD | 无正式证据但明确放弃 → `deprecated`,并在 decision_log 记 Dxxx |

---

## 红线(防证据失真,全部为硬约束)

1. 工具或依赖缺失时,**必须**如实记录为环境缺口(current_state 风险 + 实验日志),**禁止**写成「目标系统不支持该功能」。
2. 测量全部失败时,实验**必须**标 failed 并保留日志,**禁止**产出看似正常的空 results 文件或编造数据。
3. 缩水的冒烟运行**必须**标注为「流程验证」,**禁止**登记为性能证据(EVD)。
4. 单次测量**禁止**登记为 EVD;改进幅度低于 `problem/scoring-and-sla.md` 噪声阈值时,**必须**重复测量并报告统计量(重复次数与方法在 plan.md 声明)。
5. 收尾清理**必须**限于本实验产物与**本锁登记的 pids**,**禁止**清理共享缓存、他人工作目录或终止未在锁内登记的进程。
6. **禁止**编写/执行一键跑完全程的实验脚本;执行与复现只通过 `run_commands.md` 逐条进行。
7. **禁止**因「提升很小 / 可能已到顶」跳过入队或跳过测量;终止只能走 `report/README.md` 白名单。

---

## 全库语言与机读性约定

- 机读内容(csv 表头、索引表头、枚举值、编号)**必须**用英文;叙述性内容用中文。
- 正式文件中的枚举字段**必须**只保留单个实际取值,**禁止**保留「a / b / c」式备选罗列。
- 编号约定以根 README 的表格为唯一定义;`examples/` 内使用 `EX-` 前缀,不占正式编号。
