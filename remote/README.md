# remote/

本目录用于保存远程服务器与 SSH 连接信息。

性能优化实验常在远程 GPU / 评测机上执行。本地仓库不保存完整源码与大文件，但需要能**快速定位并连接**到对应环境。本目录提供统一的远程连接配置，供实验记录、Agent 和人工操作引用。

---

## 本目录应该存放什么

```text
remote/
├── README.md
├── servers.example.yaml    # 配置模板（可提交）
└── servers.private.yaml    # 实际 SSH 信息（不提交，见 .gitignore）
```

首次使用时：

```bash
cp remote/servers.example.yaml remote/servers.private.yaml
# 编辑 servers.private.yaml，填入真实 host、user、密钥路径等
```

---

## 安全原则

1. **密钥与密码不入库**：`servers.private.yaml`、私钥文件（`*.pem`、`*.key`）已在 `.gitignore` 中排除。
2. **示例文件不含真实信息**：`servers.example.yaml` 只保留字段说明和占位值。
3. **实验目录只引用 server_id**：各实验的 `remote_ref.yaml` 通过 `server_id` 指向本目录配置，不重复抄写 SSH 账号密码。
4. **优先使用 SSH 密钥**：避免在配置文件中保存明文密码；如必须使用密码，只写在 `servers.private.yaml` 且绝不提交。

---

## servers.private.yaml 格式

```yaml
servers:
  gpu-a100-01:
    host: 10.0.0.11
    port: 22
    user: researcher
    identity_file: ~/.ssh/id_ed25519
    # proxy_jump: bastion-01   # 可选，值为另一 server id
    description: A100 开发机，vLLM 压测环境
    default_workspace: /data/workspaces/vllm-bench
    tags:
      - gpu
      - a100
      - primary

  bastion-01:
    host: jump.example.com
    port: 22
    user: jumpuser
    identity_file: ~/.ssh/id_ed25519
    description: 跳板机
    tags:
      - bastion

defaults:
  server_id: gpu-a100-01
```

### 字段说明

| 字段 | 必填 | 说明 |
| --- | --- | --- |
| `host` | 是 | 主机名或 IP |
| `port` | 否 | SSH 端口，默认 22 |
| `user` | 是 | 登录用户名 |
| `identity_file` | 推荐 | 私钥路径，相对于本机 `~` |
| `proxy_jump` | 否 | 跳板机，填写 `servers` 中另一台的 id |
| `description` | 否 | 人类可读说明 |
| `default_workspace` | 否 | 该机上常用工作目录 |
| `tags` | 否 | 便于筛选，如 `gpu`、`eval`、`staging` |
| `defaults.server_id` | 否 | 未指定时的默认服务器 |

---

## 与实验目录的关系

每个实验目录下的 `remote_ref.yaml` 记录**该次实验**在远程环境中的代码位置与版本，通过 `server_id` 关联本目录：

```yaml
server_id: gpu-a100-01
repo_path: /data/workspaces/vllm-bench/vllm
branch: feat-cache-opt
commit: a1b2c3d4
env_notes: CUDA 12.4, Python 3.11, ROCm 6.0
artifact_paths:
  - /data/workspaces/vllm-bench/runs/E003/results/
```

连接远程时：先查 `remote/servers.private.yaml` 得到 SSH 参数，再结合 `remote_ref.yaml` 定位代码与产物路径。

---

## 结果回传

远程实验结束后，必须把结果与日志回传到本地实验目录，证据链才算闭合：

```bash
# 结合 servers.private.yaml 的连接参数与 remote_ref.yaml 的 artifact_paths
rsync -av <user>@<host>:<artifact_path>/ experiments/Exxx/results/
rsync -av <user>@<host>:<remote_log_path>/ experiments/Exxx/logs/
```

回传要求：

1. 回传后核对文件清单与大小，确认完整。
2. 拉取命令与时间记入 `run_commands.md` 的对应 step，并保留 `logs/` 中的原始输出。
3. `remote_ref.yaml` 中 `artifact_paths` 列出的每个远程路径，都应能在本地 `results/` 或 `logs/` 找到对应产物，或在 analysis.md 中写明未回传原因（如超大文件只留校验值与远程路径）。

---

## 与 memory/ 的关系

`memory/global_context.md` 的「外部依赖」一节可引用 `server_id` 列表，说明项目长期依赖哪些远程环境，但**不要把完整 SSH 凭据写进 memory**。

---

## 不建议放入本目录的内容

- 私钥文件本身（放在 `~/.ssh/`，此处只记录路径）
- 明文密码（如无法避免，仅存在于 `servers.private.yaml`）
- 大型源码、模型、数据集
- 与连接无关的实验结果或日志

本目录的目标是：让每一次远程实验都能被定位、被连接、被复现，同时不把敏感信息提交到版本库。
