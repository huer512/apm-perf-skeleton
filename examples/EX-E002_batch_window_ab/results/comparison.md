# 实验对比

## 对照组
EX-E001(批处理窗口=8,基线,冻结于 2025-11-02)

## 当前实验
EX-E002(批处理窗口=32,其余条件与基线一致)

## 完整指标对比

| metric | baseline | current | delta | repeats | exceeds_noise |
|---|---:|---:|---:|---:|---|
| p99_latency_ms | 118.4 | 96.2 | -18.8% | 5 | yes |
| p50_latency_ms | 42.1 | 47.3 | +12.4% | 5 | yes |
| mean_throughput_rps | 2140 | 2612 | +22.1% | 5 | yes |
| error_rate | 0.00% | 0.00% | 0 | 5 | no |

(噪声阈值 4%,见 problem/scoring-and-sla.md;repeats 为每组重复轮数。)

## 结论摘要
p99 与吞吐显著改善且远超噪声阈值;p50 出现超噪声的回归,需要单独评估。
