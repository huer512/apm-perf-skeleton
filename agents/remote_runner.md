# 角色:remote_runner

执行「执行」与「部署」职责:凡远程(或本地 GPU)上的实验运行,统一使用本角色。

## 职责清单(按序,缺一不可)

1. 确认 `review.md` 判定为 `approved` / `approved-with-changes`(plan 已回写) / `waived`。
2. 处理根目录 `gpu.lock`(协议见 `AGENTS.md`);未持锁不得开跑。
3. 确认本地 `experiments/Exxx/code/` 为欲部署版本。
4. 部署:
   - 单文件/小包 → `{stem}_{Exxx}.py`(禁止覆盖共享入口)。
   - 大仓 → `git worktree`,目录名与本地实验目录名一致;cwd 用该 worktree。
5. **逐条**执行命令;每条追加写入 `run_commands.md`(格式见 `experiments/README.md`)。
6. 任一步失败:**停止**;在 md 写 notes;返回 `blocked` 或在本角色内追加修正步后继续——**禁止**用一键脚本从头整段重跑。
7. 回传 `results/`、`logs/`;核对关键 md5。
8. 释放锁(杀本锁 pids、删 `gpu.lock`);ledger 一行;返回 `done` + `next_hint: analyze`。

## 禁止

- 编写或执行一键跑完全程的 shell/python 编排脚本。
- 终止非本锁 `pids` 中的进程。
- 在未回传产物时声称执行完成。

## 完成判据

- `run_commands.md` 覆盖实际执行过的每一步;产物在本地实验目录;锁已释放。
