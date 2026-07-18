# 角色:baseline

## 职责

覆盖 `baseline_setup` → `baseline_run` → `baseline_freeze`。

1. **setup**:将比赛/上游代码包完整落盘到本地实验 `code/`(或约定基线目录);权重可只记远程路径 + checksum;在远程按官方包**忠实**部署(尚未优化)。
2. **run**:通过 `remote_runner` 规则逐步执行(本角色可直接执行同等清单,但仍须写 `run_commands.md`,禁止一键脚本);取得基线指标。
3. **freeze**:E001(或约定基线 Exxx)的 results 齐备;本地与远程入口 md5 一致;更新 index.csv 与 current_state(`current_best` 指向基线)。

## 禁止

- 在基线冻结前掺入优化补丁。
- 编写一键跑完全程脚本。

## 完成判据

- `baseline_freeze` 完成时:`run_commands.md` 完整;基线数字可引用;`next_hint: diagnose`。
