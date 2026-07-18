#!/usr/bin/env bash
# 实验结论审计:conclusion.md 完成后,调用 codex 从合规性/有效性/复现性三维度审查改动与结论。
#
# 用法:
#   scripts/codex_audit.sh <实验目录>
#   例:scripts/codex_audit.sh experiments/E002_cache_policy
#
# 产物:<实验目录>/audit_codex_raw.md(codex 原始意见)。
# 后续:Agent 将意见整理进 <实验目录>/audit.md(逐条处理 + 分维度结论 + 最终判定),
#      判定 approved / approved-with-changes 后才可登记 EVD、回写假设状态(见 AGENTS.md 硬门槛)。
#
# 手工等价流程(codex 不可用时):把下方 PROMPT 各要点与送审材料粘贴给任一独立审计模型/人工,
# 意见同样整理进 audit.md;完全无法审计时判定填 waived 并记录原因与风险。
#
# 审计模型固定为 gpt-5.5,reasoning effort 固定为 xhigh(与评审门一致,用最强配置)。
# 可选环境变量:CODEX_REVIEW_ARGS 追加 codex exec 参数,置于默认参数之后,可覆盖模型与力度。

set -euo pipefail

EXP_DIR="${1:?用法: scripts/codex_audit.sh <实验目录>}"
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

[ -f "$EXP_DIR/conclusion.md" ] || { echo "错误: $EXP_DIR/conclusion.md 不存在,审计发生在结论完成之后" >&2; exit 1; }

# 送审材料:计划与结论、分析、对比结果、代码改动、运行命令、关联假设、问题规则
H_ID="$(grep -oE 'H[0-9]{3}' "$EXP_DIR/plan.md" 2>/dev/null | head -1 || true)"
H_FILE=""
if [ -n "$H_ID" ] && [ "$H_ID" != "H000" ]; then
  H_FILE="$(ls "hypotheses/${H_ID}"_*.md 2>/dev/null | head -1 || true)"
fi

emit_if_exists() {  # $1=标题 $2=路径
  if [ -f "$2" ]; then
    echo
    echo "=== $1($2) ==="
    cat "$2"
  fi
}

{
  echo "你是独立、苛刻的实验结论审计员。一次性能优化实验已完成并写出结论。"
  echo "先做理解性走读:用 3-5 句复述该实验改了什么、测得什么结果、下了什么结论,"
  echo "复述与材料对不上的地方本身就是审计线索。然后再开始审计,"
  echo "从三个维度逐条审查其改动与结论,每条意见标注 [维度][severity: blocker/major/minor]:"
  echo "1) 合规性:代码/配置改动与实验手段是否触碰 allowed-and-forbidden 中的禁止项或 Rxxx 规则;"
  echo "   是否绕过或修改了评测流程/评测负载;是否以牺牲正确性换取性能。"
  echo "2) 有效性:性能提升是否真实——对比是否基于同一冻结基线与同一负载;改进幅度是否超过噪声阈值"
  echo "   且重复次数足够;结论中的数字与 results 数据是否一致;是否存在被掩盖的指标回归"
  echo "   (某指标好转但其它关键指标恶化未披露或未纳入判定)。"
  echo "3) 复现性:是否引入未受控的随机性或不确定性来源(未固定种子、时间依赖、缓存/预热状态、并发竞态);"
  echo "   命令与环境记录是否足以让第三方复现;结论适用范围声明是否与实际测量条件一致。"
  echo "只做审计,不要改写文档。最后按以下格式输出四行:"
  echo "合规性: pass / concerns / fail"
  echo "有效性: pass / concerns / fail"
  echo "复现性: pass / concerns / fail"
  echo "总体判定: approved / approved-with-changes / rework"

  emit_if_exists "实验计划" "$EXP_DIR/plan.md"
  emit_if_exists "实验结论" "$EXP_DIR/conclusion.md"
  emit_if_exists "实验分析" "$EXP_DIR/analysis.md"
  emit_if_exists "指标对比" "$EXP_DIR/results/comparison.md"
  emit_if_exists "指标摘要" "$EXP_DIR/results/metrics_parsed.md"
  emit_if_exists "代码改动 diff" "$EXP_DIR/code/patch.diff"
  emit_if_exists "改动文件清单" "$EXP_DIR/code/changed_files.md"
  emit_if_exists "运行命令" "$EXP_DIR/run_commands.md"
  if [ -n "$H_FILE" ]; then
    echo
    echo "=== 关联假设 ${H_ID} ==="
    cat "$H_FILE"
  fi
  emit_if_exists "允许与禁止(合规基准)" "problem/allowed-and-forbidden.md"
  emit_if_exists "评分规则与 SLA" "problem/scoring-and-sla.md"
} | codex exec -m gpt-5.5 -c model_reasoning_effort=xhigh ${CODEX_REVIEW_ARGS:-} \
    -s read-only --skip-git-repo-check \
    -o "$EXP_DIR/audit_codex_raw.md" -

echo
echo "审计意见已写入 $EXP_DIR/audit_codex_raw.md"
echo "下一步:整理意见到 $EXP_DIR/audit.md,判定通过后方可登记 EVD、回写假设状态。"
