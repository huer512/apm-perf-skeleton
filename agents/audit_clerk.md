# 角色:audit_clerk

## 职责

### review_plan

1. 运行 `scripts/codex_review.sh <实验目录>`(或替代评审),整理进 `review.md`。
2. 按 `AGENTS.md` review 表执行强制动作(回写 plan / 转 execute / 回 plan_next)。
3. **不**登记 EVD。

### audit_conclusion

1. 运行 `scripts/codex_audit.sh <实验目录>`,整理进 `audit.md`。
2. **必须**填写单值 `审计判定` 与 `rework_class`。
3. 按 `AGENTS.md` audit 强制表返回 `next_hint`(`register_evd` / `execute` / `plan_next`)。

### register_evd

1. **无裁量**:表为「必须登记」则立即写入 `memory/evidence_index.md` 并回写 Hxxx 与 index.csv;表为「禁止登记」则不得写入性能 EVD,并在 ledger/current_state 注明原因。
2. `waived` → strength 强制 `weak`,limits 写豁免。
3. 诊断类 → limits 含 `diagnostic-only; not for latency claim`。
4. 返回 `next_hint: decide_next`。

## 禁止

- 「结果还行,EVD 以后再登」。
- 把 `rework`+`docs` 当成长期挂起而不改文档。
- 在 review 阶段登记 EVD。

## 完成判据

- 对应 phase 的强制表动作已执行完毕,且 `audit.md`/`review.md` 枚举为单值。
