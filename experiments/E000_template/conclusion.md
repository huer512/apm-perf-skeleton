# 实验结论

> 模板文件:analysis.md 完成后填写,并删除本横幅。analysis.md 未完成时不要填写本文件;
> 若实验失败无法分析,在 analysis.md 中记录失败原因后,本文件"是否有效"填 invalid。
> 合格标准见 experiments/README.md 的"结论验收规则"。

## 结论摘要
用几句话说明本实验结论,必须包含关键数字(基线值、当前值、变化幅度)。

## 结论适用范围
本结论仅在以下条件下成立,禁止无限定泛化:
- 环境:(硬件 / 系统 / 依赖版本 / 目标系统 commit)
- 负载:(数据集 / 请求构成 / 并发 / 时长)
- 指标口径:(统计方式)

## 是否有效
yes / no / partial / invalid(填写时只保留一个值)

## 是否支持关联假设
supported / rejected / inconclusive(填写时只保留一个值;假设状态联动规则见 hypotheses/README.md)

## 是否进入后续优化
yes / no / pending(填写时只保留一个值)

## 关键证据
按"EVDxxx + 结果文件路径"列出,并同步登记到 memory/evidence_index.md:
- EVDxxx — results/(文件路径)

## 新产生的洞察
说明是否产生了新的跨实验洞察(候选 Ixxx)。

## 后续动作
说明下一步要继续验证、合并、回滚还是放弃。
交接信息:下一实验应复现的最小负载描述与建议手段(供下个会话直接接手)。
