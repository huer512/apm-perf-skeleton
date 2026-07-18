# code/

本目录用于保存**本次实验实际用于远程推理的 `infer.py`**（或等价入口脚本），以及说明复现所需的最小补丁材料。

---

## 必须内容

| 文件 | 要求 |
| --- | --- |
| `infer.py` | **必须**（`status` 非 `planned` 时）。即 `run_commands.sh` 部署到远程并计时的推理入口 |
| `README.md` | 说明本目录内容与对照组关系 |

`status=planned` 时尚未执行，可暂缺 `infer.py`，但须在本文档标明 **planned** 及待开发补丁摘要。

---

## 按实验类型

### baseline（如 E001）

保存官方 `infer.py` 快照（来自仓库根 `code.tar.gz`），附 md5，例如：

```text
code/
├── README.md
├── infer.py              # md5 与 remote_ref.yaml / run_commands.sh preflight 一致
├── build_env.sh          # 可选，与提交包一致时一并存档
└── requirements.txt      # 可选
```

### 优化实验（如 E004）

保存相对 baseline 的**补丁版** `infer.py`（非仅 patch.diff——须保留完整可运行文件）：

```text
code/
├── README.md
├── infer.py              # 补丁后完整入口；run_commands.sh 推送此文件
├── patch.diff            # 推荐：相对 E001 code/infer.py 的 diff
└── changed_files.md      # 推荐：改动目的与风险
```

---

## 用途

- **复现**：他人仅读本目录 + `run_commands.sh` 即可在远程重跑同一版本
- **diff**：与对照组 `infer.py` 逐行对比，验证"一次只改少量变量"
- **审计**：`conclusion.md` / `analysis.md` 引用的优化点可追溯到具体源码

---

## 无代码改动时

若实验仅改运行配置（无 `infer.py` 变更），仍须存档当时远程使用的 `infer.py`（通常与对照组相同），并在 README 中说明：

```md
本次实验无 infer.py 改动；`code/infer.py` 与 E001 baseline 快照相同（md5=…）。
```

---

## 不建议保存的内容

* 完整大型源码仓库（除 `infer.py` 外的无关模块）
* 编译缓存、临时构建目录、二进制产物
* 密钥或私有配置

规范全文见上级 `experiments/README.md` 的「code/ 目录规范」。
