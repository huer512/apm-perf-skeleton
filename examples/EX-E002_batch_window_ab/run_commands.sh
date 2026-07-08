#!/usr/bin/env bash
# EX-E002:批处理窗口 8 → 32 A/B 实验(本地执行)
set -euo pipefail

EXP_DIR="$(cd "$(dirname "$0")" && pwd)"
TS="$(date +%Y%m%d_%H%M%S)"
mkdir -p "$EXP_DIR/results" "$EXP_DIR/logs"

# 1. 环境快照
{
  echo "timestamp: $TS"
  uname -a
  python3 --version
  psql --version
  git -C /home/dev/order-service rev-parse HEAD
  md5sum /home/dev/loadgen/orders-replay-50k.bin
} > "$EXP_DIR/logs/env_snapshot_${TS}.log" 2>&1

# 2. 应用配置变更并重启服务(仅 batch_window_size: 32)
#    可重入:先恢复配置基态再打补丁,中断后重跑不会因补丁已应用而失败
cd /home/dev/order-service
git checkout -- config/service.yaml
git apply "$EXP_DIR/code/patch.diff"
systemctl --user restart order-service
sleep 10   # 预热窗口,与基线一致

# 3. 固定负载重复 5 轮
for i in 1 2 3 4 5; do
  loadgen --replay /home/dev/loadgen/orders-replay-50k.bin \
          --concurrency 200 --duration 600s \
          --out "$EXP_DIR/results/metrics_raw_round${i}.json" \
          2>&1 | tee "$EXP_DIR/logs/run_round${i}_${TS}.log"
done

# 4. 还原环境
git -C /home/dev/order-service checkout -- config/service.yaml
systemctl --user restart order-service
