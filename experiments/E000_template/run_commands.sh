#!/usr/bin/env bash
# 实验运行命令。复制到新实验目录后按需修改,保证可复现。
#
# 本地实验:直接运行本脚本。
# 远程实验:在 remote_ref.yaml 指定的服务器上执行等价命令
#          (或用 ssh 包装下方命令),结束后将结果与日志
#          回传到本实验目录的 results/ 与 logs/。
set -euo pipefail

EXP_DIR="$(cd "$(dirname "$0")" && pwd)"
TS="$(date +%Y%m%d_%H%M%S)"
mkdir -p "$EXP_DIR/results" "$EXP_DIR/logs"

# 1. 记录环境快照(按需补充:硬件信息、软件版本、关键配置)
{
  echo "timestamp: $TS"
  uname -a
  # 示例:nvidia-smi、python --version、git -C <repo> rev-parse HEAD
} > "$EXP_DIR/logs/env_snapshot_${TS}.log" 2>&1

# 2. 在下方填写真实实验命令,所有输出必须落到 logs/
# your_benchmark_command --arg value 2>&1 | tee "$EXP_DIR/logs/run_${TS}.log"

# 3. 远程实验:回传产物到本地(本地实验可删除本段;要求见 remote/README.md"结果回传")
# rsync -av "<user>@<host>:<artifact_path>/" "$EXP_DIR/results/" 2>&1 | tee "$EXP_DIR/logs/fetch_${TS}.log"

echo "TODO: 填写实验命令后删除本行" >&2
exit 1
