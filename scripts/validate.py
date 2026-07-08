#!/usr/bin/env python3
"""apm-perf-skeleton 结构校验器(仅用标准库,无第三方依赖)。

用法:python3 scripts/validate.py [--root 仓库路径]

检查范围锁定为四类结构问题;内容质量由 experiments/README.md 的"结论验收规则"约束,不在此检查:

1. 编号唯一:H / E / EVD / I / D / R 各自无重复编号。
2. 交叉引用存在:H 引用的 Exxx 目录存在;experiments/index.csv 与 E 目录一一对应;
   H 与 conclusion.md 引用的 EVD 在 memory/evidence_index.md 已登记;实验目录含 plan.md;
   执行过的实验(status 非 planned)必须有判定通过的 review.md(评审门,见 AGENTS.md);
   已分析的实验(status 为 analyzed/archived)与登记过 EVD 的实验必须有判定通过的
   audit.md(结论审计门,见 AGENTS.md)。
3. 枚举取值合法:H 状态、index.csv 的 status/valid、evidence_index 的 relation/strength、
   review.md 的评审判定、audit.md 的审计判定。
4. 模板横幅残留:正式的 Hxxx 文件与实验目录文档中不得残留"模板文件:"等横幅标记
   (复制模板后必须删除横幅)。

无法运行本脚本时的等价手工核对清单:
  a. ls hypotheses/ experiments/,确认 H/E 编号无重复;
  b. grep -oE 'EVD[0-9]{3}' memory/evidence_index.md | sort | uniq -d 应无输出;
  c. 逐个打开 Hxxx,确认"关联实验"中的 Exxx 目录存在、引用的 EVD 已登记;
  d. 逐行核对 experiments/index.csv 与 experiments/E* 目录一一对应,每个实验目录有 plan.md;
  e. 核对 H 状态、index.csv 的 status/valid 取值在对应 README 的约定集合内;
  f. 确认 status 非 planned 的实验目录有 review.md,且评审判定为
     approved / approved-with-changes / waived;
  g. 确认 status 为 analyzed/archived 的实验与 evidence_index 中出现过的实验
     有 audit.md,且审计判定为 approved / approved-with-changes / waived;
  h. grep -l '模板文件:' hypotheses/H*_*.md experiments/E*/ 应无输出(横幅残留)。

跳过:examples/、E000/H000 模板、含 xxx 的占位引用(如 Exxx、EVDxxx)。
退出码:有 ERROR 返回 1,否则 0(WARN 不影响退出码)。
"""

import argparse
import csv
import re
import sys
from pathlib import Path

H_STATUS = {"proposed", "planned", "testing", "supported", "rejected", "paused", "merged", "deprecated"}
E_STATUS = {"planned", "running", "done", "failed", "invalid", "analyzed", "archived"}
E_VALID = {"yes", "no", "partial", "invalid", "unknown"}
EVD_RELATION = {"supports", "refutes"}
EVD_STRENGTH = {"confirmed", "strong", "weak"}
REVIEW_VERDICT = {"approved", "approved-with-changes", "rework", "waived"}
PASSING_VERDICT = {"approved", "approved-with-changes", "waived"}
EXECUTED_STATUS = {"running", "done", "failed", "invalid", "analyzed", "archived"}
INDEX_HEADER = ["exp_id", "exp_name", "hypotheses", "status", "valid", "key_result", "path"]
BANNER_MARKERS = ("模板文件:", "本目录为实验模板", "本目录为假设模板")

errors: list[str] = []
warnings: list[str] = []


def err(msg: str) -> None:
    errors.append(msg)


def warn(msg: str) -> None:
    warnings.append(msg)


def section_value(text: str, title: str) -> str:
    """返回 '## title' 小节内第一个非空、非注释行。"""
    lines = text.splitlines()
    inside = False
    for line in lines:
        if line.strip().startswith("## "):
            inside = line.strip()[3:].strip() == title
            continue
        if inside:
            s = line.strip()
            if not s or s.startswith("<!--") or s.startswith("("):
                continue
            return s
    return ""


def check_duplicates(ids: list[str], kind: str, where: str) -> None:
    seen = set()
    for i in ids:
        if i in seen:
            err(f"{kind} 编号重复: {i} ({where})")
        seen.add(i)


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--root", default=None, help="仓库根目录,默认取脚本上级目录")
    args = parser.parse_args()
    root = Path(args.root).resolve() if args.root else Path(__file__).resolve().parent.parent

    # ---- 收集假设 ----
    h_files = sorted(p for p in (root / "hypotheses").glob("H[0-9][0-9][0-9]_*.md") if "000" != p.name[1:4])
    h_ids = [p.name[:4] for p in h_files]
    check_duplicates(h_ids, "H", "hypotheses/")
    h_id_set = set(h_ids)

    # ---- 收集实验目录 ----
    e_dirs = sorted(
        p for p in (root / "experiments").glob("E[0-9][0-9][0-9]_*")
        if p.is_dir() and p.name[1:4] != "000"
    )
    e_nums = [p.name[:4] for p in e_dirs]
    check_duplicates(e_nums, "E", "experiments/")
    e_id_set = set(e_nums)

    for d in e_dirs:
        if not (d / "plan.md").exists():
            err(f"实验目录缺少 plan.md: {d.relative_to(root)}")
        for name in ("README.md", "plan.md", "analysis.md", "conclusion.md", "review.md", "audit.md"):
            f = d / name
            if f.exists():
                t = f.read_text(encoding="utf-8")
                for m in BANNER_MARKERS:
                    if m in t:
                        err(f"{f.relative_to(root)}: 残留模板横幅标记({m}),复制模板后应删除横幅")
                        break

    # 结论审计判定(供 EVD 登记与完成态检查使用)
    audit_verdicts: dict[str, str] = {}
    for d in e_dirs:
        af = d / "audit.md"
        if af.exists():
            v = section_value(af.read_text(encoding="utf-8"), "审计判定")
            audit_verdicts[d.name[:4]] = v
            if v and v not in REVIEW_VERDICT:
                err(f"{af.relative_to(root)}: 审计判定取值非法: {v!r}(合法: {sorted(REVIEW_VERDICT)})")

    # ---- evidence_index ----
    evd_ids: list[str] = []
    evd_rows = []
    evidence_file = root / "memory" / "evidence_index.md"
    if evidence_file.exists():
        for line in evidence_file.read_text(encoding="utf-8").splitlines():
            s = line.strip()
            if not s.startswith("| EVD"):
                continue
            cells = [c.strip() for c in s.strip("|").split("|")]
            if len(cells) < 5:
                err(f"evidence_index 行列数不足: {s[:60]}")
                continue
            evd_rows.append(cells)
            evd_ids.append(cells[0])
    check_duplicates(evd_ids, "EVD", "memory/evidence_index.md")
    evd_id_set = set(evd_ids)

    for cells in evd_rows:
        evd_id, exp_id, hyp, relation, strength = cells[0], cells[1], cells[2], cells[3], cells[4]
        if exp_id not in e_id_set:
            err(f"{evd_id}: 来源实验 {exp_id} 不存在于 experiments/")
        elif audit_verdicts.get(exp_id) not in PASSING_VERDICT:
            err(f"{evd_id}: 来源实验 {exp_id} 尚未通过结论审计(audit.md 判定须为 "
                f"approved / approved-with-changes / waived),不得登记证据")
        if hyp != "none" and hyp not in h_id_set:
            err(f"{evd_id}: 关联假设 {hyp} 不存在于 hypotheses/")
        if relation not in EVD_RELATION:
            err(f"{evd_id}: relation 取值非法: {relation}(合法: {sorted(EVD_RELATION)})")
        if strength not in EVD_STRENGTH:
            err(f"{evd_id}: strength 取值非法: {strength}(合法: {sorted(EVD_STRENGTH)})")

    # ---- 假设文件内部检查 ----
    for p in h_files:
        text = p.read_text(encoding="utf-8")
        rel = p.relative_to(root)
        status = section_value(text, "状态")
        if status and status not in H_STATUS:
            err(f"{rel}: 状态取值非法: {status!r}(合法: {sorted(H_STATUS)})")
        elif not status:
            warn(f"{rel}: 未找到状态取值")
        for e_ref in set(re.findall(r"\bE\d{3}\b", text)):
            if e_ref != "E000" and e_ref not in e_id_set:
                err(f"{rel}: 引用的实验 {e_ref} 不存在")
        for evd_ref in set(re.findall(r"\bEVD\d{3}\b", text)):
            if evd_ref not in evd_id_set:
                err(f"{rel}: 引用的证据 {evd_ref} 未在 evidence_index 登记")
        if status == "rejected" and not re.search(r"\bEVD\d{3}\b", text):
            err(f"{rel}: 状态为 rejected 但未引用任何反驳 EVD(见 AGENTS.md 硬门槛)")
        for m in BANNER_MARKERS:
            if m in text:
                err(f"{rel}: 残留模板横幅标记({m}),复制模板后应删除横幅")
                break

    # ---- index.csv ----
    index_file = root / "experiments" / "index.csv"
    row_ids: list[str] = []
    if index_file.exists():
        with index_file.open(encoding="utf-8") as f:
            reader = csv.reader(f)
            rows = [r for r in reader if r and any(c.strip() for c in r)]
        if rows and [c.strip() for c in rows[0]] != INDEX_HEADER:
            err(f"index.csv 表头不符: {rows[0]}(应为 {INDEX_HEADER})")
        for r in rows[1:]:
            if len(r) < len(INDEX_HEADER):
                err(f"index.csv 行列数不足: {r}")
                continue
            exp_id, _, hyps, status, valid, _, path = [c.strip() for c in r[:7]]
            row_ids.append(exp_id)
            if not re.fullmatch(r"E\d{3}", exp_id):
                err(f"index.csv: exp_id 格式非法: {exp_id}")
            elif exp_id not in e_id_set:
                err(f"index.csv: {exp_id} 在 experiments/ 下无对应目录")
            if status not in E_STATUS:
                err(f"index.csv {exp_id}: status 取值非法: {status}(合法: {sorted(E_STATUS)})")
            if valid not in E_VALID:
                err(f"index.csv {exp_id}: valid 取值非法: {valid}(合法: {sorted(E_VALID)})")
            if hyps != "none":
                for h in hyps.split(";"):
                    if h.strip() not in h_id_set:
                        err(f"index.csv {exp_id}: 关联假设 {h.strip()} 不存在(无假设应填 none)")
            if path and not (root / path).exists():
                err(f"index.csv {exp_id}: path 不存在: {path}")
        check_duplicates(row_ids, "index.csv exp_id", "experiments/index.csv")
        for e_num, d in zip(e_nums, e_dirs):
            if e_num not in set(row_ids):
                err(f"实验目录未登记到 index.csv: {d.name}")
            else:
                # 已完成状态的实验必须有 conclusion.md
                pass
    else:
        warn("experiments/index.csv 不存在")

    # ---- conclusion 中的 EVD 引用与完成态检查 ----
    status_by_id = {}
    if index_file.exists():
        for r in rows[1:]:
            if len(r) >= 7:
                status_by_id[r[0].strip()] = r[3].strip()
    for d in e_dirs:
        concl = d / "conclusion.md"
        st = status_by_id.get(d.name[:4], "")
        executed = st in EXECUTED_STATUS
        review = d / "review.md"
        if review.exists():
            verdict = section_value(review.read_text(encoding="utf-8"), "评审判定")
            if verdict and verdict not in REVIEW_VERDICT:
                err(f"{review.relative_to(root)}: 评审判定取值非法: {verdict!r}(合法: {sorted(REVIEW_VERDICT)})")
            if executed and verdict not in PASSING_VERDICT:
                err(f"{d.name}: index.csv 状态为 {st} 但评审判定为 {verdict or '缺失'}"
                    f"(执行前须 approved / approved-with-changes / waived,见 AGENTS.md)")
        elif executed:
            err(f"{d.name}: index.csv 状态为 {st} 但缺少 review.md(执行前必须评审,见 AGENTS.md)")
        if st in {"analyzed", "archived"}:
            av = audit_verdicts.get(d.name[:4])
            if d.name[:4] not in audit_verdicts:
                err(f"{d.name}: index.csv 状态为 {st} 但缺少 audit.md(结论生效前必须审计,见 AGENTS.md)")
            elif av not in PASSING_VERDICT:
                err(f"{d.name}: index.csv 状态为 {st} 但审计判定为 {av or '缺失'}"
                    f"(须 approved / approved-with-changes / waived,见 AGENTS.md)")
        if concl.exists():
            for evd_ref in set(re.findall(r"\bEVD\d{3}\b", concl.read_text(encoding="utf-8"))):
                if evd_ref not in evd_id_set:
                    err(f"{concl.relative_to(root)}: 引用的证据 {evd_ref} 未在 evidence_index 登记")
        elif st in {"done", "analyzed", "archived"}:
            err(f"{d.name}: index.csv 状态为 {st} 但缺少 conclusion.md")
        if not (d / "analysis.md").exists() and st in {"done", "analyzed", "archived"}:
            err(f"{d.name}: index.csv 状态为 {st} 但缺少 analysis.md")

    # ---- I / D / R 编号 ----
    for fname, prefix, kind in [
        ("memory/insight_bank.md", r"I\d{3}", "I"),
        ("memory/decision_log.md", r"D\d{3}", "D"),
        ("problem/allowed-and-forbidden.md", r"R\d{3}", "R"),
    ]:
        f = root / fname
        if f.exists():
            ids = re.findall(rf"^#{{2,3}}\s+({prefix})\b", f.read_text(encoding="utf-8"), re.M)
            check_duplicates(ids, kind, fname)

    # ---- 输出 ----
    for w in warnings:
        print(f"WARN:  {w}")
    for e in errors:
        print(f"ERROR: {e}")
    print(f"\n检查完成: {len(errors)} 个错误, {len(warnings)} 个警告 "
          f"(假设 {len(h_ids)} 个, 实验 {len(e_nums)} 个, 证据 {len(evd_ids)} 条)")
    return 1 if errors else 0


if __name__ == "__main__":
    sys.exit(main())
