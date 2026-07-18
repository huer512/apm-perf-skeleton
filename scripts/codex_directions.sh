#!/usr/bin/env bash
# 优化方向生成:在 direction_gen 且 planner 自认无新方向时,调用 codex 索取候选大方向。
#
# 用法:
#   scripts/codex_directions.sh [诊断实验编号]
#   例:scripts/codex_directions.sh E116
#   省略编号时:从 memory/current_state.md 的 last_diag_exp 读取。
#
# 触发条件(见 AGENTS.md / agents/planner.md):
#   planner 自己认为没有未关闭的新方向时 **必须** 运行本脚本;有方向可入队时不必运行。
#   禁止「可调可不调」。
#
# 产物:memory/direction_codex_raw.md(codex 原始意见;每次覆盖)。
# 后续:planner 将可用方向写入 current_state.queue 并创建/更新 Hxxx;
#      仍无新方向 → 对照 report/README.md 终止白名单 → report 或 blocked。
#
# 手工等价流程(codex 不可用时):把下方要点与送审材料粘贴给独立模型/人工,意见同样
# 整理进 queue/Hxxx;完全不可用时记入 current_state 风险并 blocked,禁止空队列进入 plan_next。
#
# 模型固定 gpt-5.5,reasoning effort 固定 xhigh。
# 可选环境变量:CODEX_REVIEW_ARGS 追加 codex exec 参数。

set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

STATE="memory/current_state.md"
OUT="memory/direction_codex_raw.md"

[ -f "$STATE" ] || { echo "错误: $STATE 不存在" >&2; exit 1; }

DIAG_ID="${1:-}"
if [ -z "$DIAG_ID" ]; then
  DIAG_ID="$(grep -E '^\s*-\s*last_diag_exp:\s*' "$STATE" | head -1 | sed -E 's/.*last_diag_exp:\s*//;s/[[:space:]]+$//' || true)"
fi
if [ -z "$DIAG_ID" ] || [ "$DIAG_ID" = "none" ]; then
  echo "错误: 未指定诊断实验且 current_state.last_diag_exp 为空/none;禁止无诊断生成方向" >&2
  exit 1
fi
if ! [[ "$DIAG_ID" =~ ^E[0-9]{3}$ ]]; then
  echo "错误: 诊断实验编号格式非法: $DIAG_ID(期望 Exxx)" >&2
  exit 1
fi

DIAG_DIR="$(ls -d experiments/${DIAG_ID}_* 2>/dev/null | head -1 || true)"
[ -n "$DIAG_DIR" ] && [ -d "$DIAG_DIR" ] || {
  echo "错误: 找不到诊断实验目录 experiments/${DIAG_ID}_*" >&2
  exit 1
}

emit_if_exists() {  # $1=标题 $2=路径
  if [ -f "$2" ]; then
    echo
    echo "=== $1($2) ==="
    cat "$2"
  fi
}

# 从 current_state 截取「已关闭的优化线」及附近段落(若存在),避免整文件过长时丢关键否决信息
emit_closed_lines() {
  if grep -q '已关闭的优化线' "$STATE" 2>/dev/null; then
    echo
    echo "=== 已关闭的优化线(摘自 memory/current_state.md) ==="
    # 从该标题到下一个二级标题或文件尾
    awk '
      /^## 已关闭的优化线/ {p=1}
      p && /^## / && !/^## 已关闭的优化线/ {exit}
      p {print}
    ' "$STATE"
  fi
}

{
  echo "你是性能优化方向顾问。本地 planner 在读完当前栈的诊断结论后,自认没有未关闭的新方向。"
  echo "请基于送审材料提出 3-7 条**候选优化大方向**(不是细参数扫描清单)。"
  echo "每条必须包含:"
  echo "1) 短标题(英文蛇形或拼音编号友好);"
  echo "2) 机制说明(一段完整文字,约 4-8 句,不要压成一句话):"
  echo "   - 现状/瓶颈:对应诊断里哪一段耗时或行为;"
  echo "   - 拟改动:改哪些模块/算子/数据通路/精度路径(具体到可立项的粒度);"
  echo "   - 为何可能降延迟或涨分:因果链写清楚(例如减少重复计算、合并 launch、削 H2D、提高算术强度);"
  echo "   - 预期作用范围:主要影响 latency / 墙钟 / score_model 中的哪些项,以及可能无效的条件;"
  echo "3) 依据(引用诊断结论中的瓶颈或证据线索,勿编造未给出的数字);"
  echo "4) 主要风险与是否可能触碰禁止项;"
  echo "5) 建议验证方式(对照什么、看哪些指标、需要何种对拍/质量闸);"
  echo "6) 相对其它候选的优先级(高/中/低)及一句话排序理由。"
  echo "约束:"
  echo "- 不要重复「已关闭的优化线」与 gotchas 中已否决且未给出重开条件的路线;"
  echo "- 不要因预期收益小而省略方向;小优化也要列出;"
  echo "- 不要输出可执行代码补丁;不要改写仓库文件;"
  echo "- 若材料显示确无任何合规新方向,明确写「无新方向」并说明理由(对照终止条件思维),仍列出你曾考虑但否决的方向。"
  echo "最后单独给出一行:方向数量: N(N 为你建议入队的条数;无新方向时为 0)。"

  emit_if_exists "工作流当前状态" "$STATE"
  emit_closed_lines
  emit_if_exists "诊断实验结论" "$DIAG_DIR/conclusion.md"
  emit_if_exists "诊断实验分析" "$DIAG_DIR/analysis.md"
  emit_if_exists "诊断实验计划" "$DIAG_DIR/plan.md"
  # 常见画像产物
  emit_if_exists "诊断 breakdown" "$DIAG_DIR/results/breakdown.md"
  emit_if_exists "已知坑 gotchas" "memory/gotchas.md"
  emit_if_exists "决策日志(节选可整读)" "memory/decision_log.md"
  emit_if_exists "允许与禁止" "problem/allowed-and-forbidden.md"
  emit_if_exists "评分规则与 SLA" "problem/scoring-and-sla.md"
  emit_if_exists "终止条件" "report/README.md"
} | codex exec -m gpt-5.5 -c model_reasoning_effort=xhigh ${CODEX_REVIEW_ARGS:-} \
    -s read-only --skip-git-repo-check \
    -o "$OUT" -

echo
echo "方向建议已写入 $OUT"
echo "诊断依据: $DIAG_DIR"
echo "下一步:planner 将可用方向写入 memory/current_state.md 的 queue 并创建/更新 Hxxx;"
echo "      若方向数量为 0 → 对照 report/README.md 终止白名单 → report 或 blocked(禁止空队列 plan_next)。"
