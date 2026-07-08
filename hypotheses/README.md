# hypotheses/

本目录用于保存所有优化假设。

优化假设是指：在实验前提出的、关于性能瓶颈或优化收益的可验证猜想。

它不是最终结论，也不是实验记录。

---

## 本目录应该存放什么

建议存放以下内容：

```text
hypotheses/
├── README.md
├── H000_template/          # 模板，不参与实际任务，不要修改
│   └── README.md
├── H001_xxx.md
├── H002_xxx.md
└── H003_xxx.md
```

每个 `Hxxx` 文件代表一个独立假设。

`H000_template/` 是假设文件模板目录，只作为格式参考，不要在其中写入实际任务内容。  
实际假设从 `H001` 开始编号。

---

## 什么是合格的假设

一个合格的优化假设应该回答以下问题：

1. 我们怀疑哪里存在瓶颈？
2. 为什么怀疑这里？
3. 它可能影响哪些性能指标？
4. 它可能带来什么收益？
5. 它有什么风险？
6. 应该用什么实验验证？
7. 验证成功后如何进入最终方案？
8. 验证失败后如何记录和放弃？

---

## 命名规范

假设文件命名必须使用（不符合该模式的文件不会被 scripts/validate.py 识别）：

```text
H编号_简短英文或拼音描述.md
```

示例：

```text
H001_memory_fragmentation.md
H002_kernel_launch_overhead.md
H003_cache_policy.md
H004_scheduler_overhead.md
H005_io_bottleneck.md
```

编号一旦分配，禁止复用。

---

## 假设状态

每个假设应有明确状态：

| 状态           | 含义          |
| ------------ | ----------- |
| `proposed`   | 已提出，但尚未设计实验 |
| `planned`    | 已设计实验，等待执行  |
| `testing`    | 正在实验验证      |
| `supported`  | 实验结果支持该假设   |
| `rejected`   | 实验结果不支持该假设  |
| `paused`     | 暂停验证        |
| `merged`     | 已进入最终优化方案   |
| `deprecated` | 已废弃，不再考虑    |

---

## 状态联动规则

实验结束后，按 conclusion.md 的现有字段联动更新假设状态，不引入新的判定枚举：

| conclusion.md 的"是否支持关联假设" | 假设侧动作 |
| --- | --- |
| `supported` | H → `supported`；多个实验一致支持且路线被采纳（记 Dxxx）后 → `merged` |
| `rejected` | H → `rejected`，"反驳证据"必须至少引用一条 EVDxxx；无正式证据但明确放弃 → `deprecated` 并记 Dxxx |
| `inconclusive` | H 保持 `testing`，在"后续动作"写明派生实验或修订可证伪判据 |
| （实验 failed / invalid，未产生结论） | H 回 `planned`（可重试）或保持 `testing`；连续多次失败 → `paused` 并在 memory/current_state.md 记录阻塞原因 |

---

## 假设文件模板

假设文件格式以 [`H000_template/README.md`](H000_template/README.md) 为唯一模板来源，此处不再重复，避免两处不一致。

结论不单独维护字段，由状态推导（映射关系见模板内注释）。

---

## 维护要求

提出新实验前，应先检查是否已有对应假设。

如果没有，应先创建假设文件，再创建实验目录。

每个实验完成后，应回到对应假设文件中更新：

* 状态
* 关联实验
* 支持证据
* 反驳证据
* 后续动作

本目录的目标是避免无目的试错，让每次实验都服务于明确的优化判断。