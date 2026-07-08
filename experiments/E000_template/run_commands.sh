#!/usr/bin/env bash
# 实验运行命令。复制到新实验目录后按需修改,保证可复现。
#
# 本地实验:直接运行本脚本。
# 远程实验:在 remote_ref.yaml 指定的服务器上执行等价命令(或用 ssh 包装下方命令),
#          结束后将结果与日志回传到本实验目录的 results/ 与 logs/。
set -euo pipefail

EXP_DIR="$(cd "$(dirname "$0")" && pwd)"
TS="$(date +%Y%m%d_%H%M%S)"
mkdir -p "$EXP_DIR/results" "$EXP_DIR/logs"

# 0. 测前干扰检查(共享机器纪律):记录当前占用;发现其它任务干扰测量时先等待,
#    无法排除则停止并按 plan.md 中止条件标 invalid,禁止硬跑。
{
  echo "timestamp: $TS"
  uptime
  # 按平台选择:nvidia-smi / top -bn1 | head -20 / who
} > "$EXP_DIR/logs/preflight_${TS}.log" 2>&1

# 1. 环境能力快照(复现性证据:第三方必须能据此核对本次结果来自什么环境;
#    按需增删,但不要只留 uname 一行)
{
  echo "timestamp: $TS"
  uname -a
  # 被测系统版本:git -C <repo> rev-parse HEAD,或镜像 tag、包版本
  # 关键工具版本与能力:<tool> --version;必要时保留 <tool> --help 关键段
  # 被测服务配置快照:cat <config 文件>
  # 硬件与资源:nvidia-smi / lscpu / free -h
  # 输入数据校验:md5sum <负载/数据集文件>
} > "$EXP_DIR/logs/env_snapshot_${TS}.log" 2>&1

# 2. 在下方填写真实实验命令,所有输出必须落到 logs/
# your_benchmark_command --arg value 2>&1 | tee "$EXP_DIR/logs/run_${TS}.log"

# 3. 远程实验:回传产物到本地(本地实验可删除本段;要求见 remote/README.md"结果回传")
# rsync -av "<user>@<host>:<artifact_path>/" "$EXP_DIR/results/" 2>&1 | tee "$EXP_DIR/logs/fetch_${TS}.log"

# 4. 测后复位与归零确认:停止本实验启动的进程,确认资源已释放,输出留档
#    (只清理本实验产物与自己启动的进程,见 AGENTS.md 红线)
# { <stop 命令>; <资源确认命令>; } > "$EXP_DIR/logs/postflight_${TS}.log" 2>&1

echo "TODO: 填写实验命令后删除本行" >&2
exit 1
