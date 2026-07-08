#!/usr/bin/env bash
# 实验计划外部评审:调用 codex 审查 plan.md 并产出修改意见。
#
# 用法:
#   scripts/codex_review.sh <实验目录>
#   例:scripts/codex_review.sh experiments/E001_baseline
#
# 产物:<实验目录>/review_codex_raw.md(codex 原始意见)。
# 后续:Agent 将意见逐条整理进 <实验目录>/review.md(adopted/rejected + 最终判定),
#      判定为 approved / approved-with-changes 后方可执行实验(见 AGENTS.md 硬门槛)。
#      adopted 的意见必须先回写 plan.md。
#
# 手工等价流程(codex 不可用时):把下方 PROMPT 各要点与送审材料(plan.md、关联假设、
# 评分规则)粘贴给任一独立评审模型或人工评审,意见同样整理进 review.md;
# 完全无法评审时按 AGENTS.md 降级路径,review.md 判定填 waived 并记录原因与风险。
#
# 评审模型固定为 gpt-5.5,reasoning effort 固定为 xhigh(评审是安全关键环节,用最强配置)。
# 可选环境变量:CODEX_REVIEW_ARGS 追加 codex exec 参数,置于默认参数之后,可覆盖模型与力度。

set -euo pipefail

EXP_DIR="${1:?用法: scripts/codex_review.sh <实验目录>}"
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

PLAN="$EXP_DIR/plan.md"
[ -f "$PLAN" ] || { echo "错误: $PLAN 不存在,先完成实验计划" >&2; exit 1; }

# 送审材料:plan.md + 关联假设(按 plan 中首个 Hxxx 引用解析)+ 评分规则
H_ID="$(grep -oE 'H[0-9]{3}' "$PLAN" | head -1 || true)"
H_FILE=""
if [ -n "$H_ID" ] && [ "$H_ID" != "H000" ]; then
  H_FILE="$(ls "hypotheses/${H_ID}"_*.md 2>/dev/null | head -1 || true)"
fi

{
  echo "你是独立、苛刻的实验评审员,审查一份性能优化实验计划。"
  echo "逐条输出意见,每条标注 severity(blocker / major / minor),重点检查:"
  echo "1) 实验设计:变量是否混杂、对照是否公平、重复次数与统计方法是否足以区分噪声;"
  echo "2) 与问题约束、评分规则是否冲突;"
  echo "3) 中止与作废条件、风险是否完备;"
  echo "4) 成功/失败标准是否可证伪,是否留有指标回归盲区(某指标恶化仍会被判成功);"
  echo "5) 可复现性:固定条件、环境与命令是否完整。"
  echo "只做评审,不要改写计划。最后单独一行给出总体判定:approved / approved-with-changes / rework。"
  echo
  echo "=== 实验计划 plan.md ==="
  cat "$PLAN"
  if [ -n "$H_FILE" ]; then
    echo
    echo "=== 关联假设 ${H_ID} ==="
    cat "$H_FILE"
  fi
  if [ -f problem/scoring-and-sla.md ]; then
    echo
    echo "=== 评分规则与 SLA(problem/scoring-and-sla.md) ==="
    cat problem/scoring-and-sla.md
  fi
} | codex exec -m gpt-5.5 -c model_reasoning_effort=xhigh ${CODEX_REVIEW_ARGS:-} \
    -s read-only --skip-git-repo-check \
    -o "$EXP_DIR/review_codex_raw.md" -

echo
echo "评审意见已写入 $EXP_DIR/review_codex_raw.md"
echo "下一步:整理意见到 $EXP_DIR/review.md(adopted 意见先回写 plan.md),判定通过后方可执行实验。"
