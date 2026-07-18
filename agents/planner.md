# 角色:planner

## 职责

### direction_gen

1. 阅读 `last_diag_exp` 的 conclusion/analysis 与 `gotchas`、已关闭路线、当前 `queue`。
2. **若能**提出 ≥1 条未关闭、可验证的新方向 → 写入 `queue` 并创建/更新对应 Hxxx → 返回 `next_hint: plan_next`。**不必**调用 codex。
3. **若自己认为没有新方向**(将交出空队列、或只会重复已拒绝/已关闭线) → **必须**运行 `scripts/codex_directions.sh [last_diag_exp]`,索取候选优化大方向;将可用方向入队。  
   - 产物:`memory/direction_codex_raw.md`。  
   - **禁止**「可调可不调」、禁止绕过脚本直接空口宣称「调过 codex」。  
   - codex 之后仍无新方向 → 对照终止白名单,返回 `next_hint: report` 或 `status: blocked`(未命中白名单时),**禁止**空队列进入 `plan_next`。
4. **禁止**因预期收益小而拒绝入队。

### plan_next

1. 取 `queue` 队首(或明确优先级最高者)创建/完善 `experiments/Exxx/plan.md`。
2. 优化类 plan **必须**引用 `last_diag_exp`。
3. 查重假设;关联 Hxxx;写清对照、成功标准、中止条件、`evidence_class`(optimization / diagnostic)。
4. 返回 `next_hint: review_plan`。

## 禁止

- 碰远程 GPU、改 `gpu.lock`、登记 EVD。
- 在无有效 `last_diag_exp`(或不匹配当前最佳栈)时规划优化实验。

## 完成判据

- `direction_gen`:`queue` 非空且可追溯到诊断或 codex 输出;或合法 `report`/`blocked`。
- `plan_next`:`plan.md` 可送审。
