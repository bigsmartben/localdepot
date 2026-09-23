# 本地交付栈：MCP 验证运行时选型与命令

> 本文是 **MCP 验证运行时** 的开源选型、禁止项与运维命令 SSOT（**非** Gateway 产品交付物）。  
> **物理 / 部署拓扑**（真源落点、本机 vs 集群、工作区目录、能力粒度）见：  
> → **[本地物理与部署架构](../architecture/local-physical-deployment.md)**  
> 仓库目标见 [章程](../charter.md)。不得用其它叙事覆盖本文与物理部署文档。

## 1. 工作原则

1. **最小自研、最大开源复用**：能力优先挂现成 MCP；不自研聚合网关或 HTML 控制台；不做统一工作区/远程仓库产品。
2. **客户端只连聚合入口**：采用 **docker/mcp-gateway**（K8s Deployment）作为验证运行时；后端经网关暴露，客户端不直连。网关须能做 **工具白名单**（`--tools` / `tools.yaml`），不改上游 MCP 源码。
3. **部署契约服从物理架构 SSOT**：真源本机磁盘；能力用 K8s 工作负载并**挂载本地工作区**；客户端只连网关——全文见 [local-physical-deployment](../architecture/local-physical-deployment.md)。
4. **本地平台**：服从**跨项目**用户 Rule `local-platform-rancher-k3s` + skill `rancher-k3s-local`（Rancher K3s + **dockerd MUST**）。本仓 Development **匿名**。摘要见 [物理部署 §2.1](../architecture/local-physical-deployment.md)。
5. **可执行配置在工具区**：K3s 相关清单在 `deploy/local/`；**客户端 SSOT** 为项目 `.cursor/mcp.json`（仅 Gateway URL）；私钥与用户级 Rules/Skills 不入库冒充项目 MCP SSOT；工作区索引在 `.cache/`。
6. **冲突处理**：与「PVC 独占真源、与本机 edit 脱节」或「K3s 清单散落用户主目录」冲突时，以 [章程](../charter.md) + [物理部署](../architecture/local-physical-deployment.md) + 本文为准。平台选择冲突时以用户级平台 Rule 为准。
7. **多项目并行**：**一项目一 Gateway** + **可区分本地 port-forward 端口**；工具白名单在各项目网关 `tools.yaml`。
## 2. 选型结论

| 能力域 | 采用 | 备注 |
|--------|------|------|
| 物理 / 部署拓扑 | 见 [local-physical-deployment](../architecture/local-physical-deployment.md) | 真源、落点、目录、trace 粒度；§2.1 平台/引擎 |
| 本地平台 / 引擎 | 用户 Rule + `rancher-k3s-local` | Rancher K3s + **dockerd MUST** |
| MCP 聚合（集群） | **docker/mcp-gateway** | `deploy/local/docker-mcp-gateway.yaml`；`tools.yaml` 白名单；remote → trace-mcp |
| **代码智能（符号/图/影响/检索）** | **nikolai-vysotskyi/trace-mcp** | 一工作区一实例；挂载工作区；经网关 |
| 自研 Facade / HTML 控制台 | 不做 | 见 [章程](../charter.md) |
| 统一工作区/远程仓库产品 | 不做 | 见 [章程](../charter.md) |
| SSH | 主机 `~/.ssh` | 不入库 |
| PVC 独占真源（无本机挂载） | **非法 / 非验证路径** | 见物理架构 §7 |

### 2.1 能力边界（trace-mcp）

- **是**：跨语言代码图、框架边、变更影响、符号/用法、任务上下文；可选 MD vault 同图；网关层工具白名单。
- **否**：知识库产品 UI、独立向量库全家桶、绕过网关的客户端直连。
- **不改上游源码**：面裁切用网关 `tools.yaml`；trace 侧仅运行时 `tools.preset=minimal`（入口脚本写入 `~/.trace/.config.json`）。

## 3. Agent / 运维指令

### 3.1 目标形态

本机工作区为真源；**trace-mcp** 以 K8s Deployment 挂载该路径；客户端经 **docker/mcp-gateway**。此栈是 **MCP 验证运行时**。

当前本机挂载（模式 A）由 `apply-workspace.ps1` 写入 `patches/hostpath.yaml`。换算公式与禁试错：skill `rancher-k3s-local` → `references/host-mount-windows.md`。

```text
Windows:  C:\Users\24598\Documents\github\localdepot   ← 实例；换仓请跑脚本
hostPath: /mnt/c/Users/24598/Documents/github/localdepot   ← 公式派生，禁止写 C:\
  → Pod: /workspaces/project
索引/状态: /workspaces/project/.cache/trace-home  (= TRACE_HOME)
```

探测失败则切 [物理部署模式 B](../architecture/local-physical-deployment.md)，不要更换路径写法反复 apply。

### 3.2 聚合网关 + trace-mcp

```powershell
docker build -t localdepot/trace-mcp:3.31.3 -f deploy/local/trace-mcp/Dockerfile deploy/local/trace-mcp
# 参数化 hostPath（推荐）：写入 patches/hostpath.yaml 并 apply -k
.\deploy\local\apply-workspace.ps1 -WorkspacePath (Get-Location).Path
kubectl --context rancher-desktop -n project-localdepot-dev rollout status deploy/docker-mcp-gateway --timeout=180s
kubectl --context rancher-desktop -n project-localdepot-dev port-forward --address 127.0.0.1 svc/docker-mcp-gateway 18080:8080
```

第二工作区（独立 Deployment + **自动写入网关 catalog**）：

```powershell
.\deploy\local\apply-workspace.ps1 -WorkspacePath <OtherWorkspace> -Secondary
# → overlays/<slug>/ + gateway/secondaries/<slug>.yaml
# → 重建 gateway/configmap.yaml 与 --servers=trace-mcp,trace-mcp-<slug>
# 注销：
.\deploy\local\apply-workspace.ps1 -Unregister -WorkspaceSlug <slug>
# 仅重建 catalog：
.\deploy\local\apply-workspace.ps1 -SyncCatalog
```

| 用途 | URL |
|------|-----|
| 聚合 MCP（streaming） | http://127.0.0.1:18080/mcp |

默认网关白名单（可改 ConfigMap `tools.yaml`）：`search`, `get_outline`, `get_symbol`, `find_usages`, `get_change_impact`, `get_task_context`, `get_call_graph`, `get_project_map`, `load_tools`, `get_preset_info`。

### 3.3 客户端入口（项目级 Cursor，SSOT）

仓库根 **`.cursor/mcp.json`**（可入库）。键名固定 `mcp-gateway`。

**本机 port-forward 端口登记**（多项目并行须互不占用；新项目另选空闲端口并写入该仓 mcp.json）：

| 项目 / ns | 本地端口 | Gateway URL |
|-----------|----------|-------------|
| localdepot / `project-localdepot-dev` | **18080** | `http://127.0.0.1:18080/mcp` |

> 本机 **8080** 常被 Rancher Desktop `host-switch` 占用；本地 port-forward 使用 **18080→svc:8080**，勿与集群内网关容器端口混淆。

```json
{
  "mcpServers": {
    "mcp-gateway": {
      "url": "http://127.0.0.1:18080/mcp"
    }
  }
}
```

工具选择：**不在** mcp.json；见网关 ConfigMap `tools.yaml`。说明见 `examples/mcp-client/`。

### 3.4 生命周期（项目 MCP ↔ K3s）

本项目 Gateway / trace 为 **常驻**，不随 Cursor 或 mcp.json 自动关闭。

| 场景 | 操作 |
|------|------|
| 暂时不用客户端 | 停 port-forward 即可；**保留** `project-localdepot-dev` |
| 卸第二工作区 | `.\deploy\local\apply-workspace.ps1 -Unregister -WorkspaceSlug <slug>` |
| 永久不用本项目 MCP 验证栈 | 用户明确授权后删除 ns：`project-localdepot-dev`（经 `rancher-k3s-local`，须 `-Force`）；**勿**删 `shared-infra` |

关 IDE、删 `.cursor/mcp.json`、空闲超时 → **都不**作为关停 Deployment 的信号。

### 3.5 明确不要做

- 不要改用 Kind / Minikube / 独立 k3s / Docker Desktop Kubernetes。
- 不要用本机裸 `docker run` / Desktop Toolkit CLI 充当产品入口；网关与 trace 均以 K8s Deployment 运行。
- 不要让客户端默认直连 trace-mcp 而绕过网关。
- 不要把 SSH 私钥、kubeconfig 机密写入仓库。
- 不要在未获授权时删除 `shared-infra` 或其他项目命名空间。
- 物理落点禁止项见 [物理部署 §7](../architecture/local-physical-deployment.md)。

## 4. 与本仓代码的关系

- 本仓**不以**自研 Python 包为客户端入口。
- 验证入口：docker/mcp-gateway → trace-mcp；目标见 [章程](../charter.md)。

## 5. 已完成项（验证栈）

1. 聚合网关 + 工具白名单（docker/mcp-gateway）。
2. 代码智能：trace-mcp（gateway list 白名单；禁调 `-32602`；`get_project_map` 可达）。
3. 多工作区 hostPath 参数化（`apply-workspace.ps1` + `-Secondary` / `-Unregister` / `-SyncCatalog`）。
4. 仓库目标重定位（章程 canonical）。

## 6. 修订

### 2026-09-23（扫尾：端口登记 + 注释 ASCII）

§3.3 增加本机 port-forward 端口登记表；`patches/hostpath.yaml` 与 `apply-workspace.ps1` 生成注释改为 ASCII，避免乱码。

### 2026-09-23（项目 MCP K3s 生命周期）

常驻 Deployment；仅在用户明确授权删除项目 ns 时关闭整栈；Unregister 只卸第二工作区。

### 2026-09-23（项目 mcp.json + 每项目 Gateway）

客户端 SSOT = 项目 `.cursor/mcp.json`（`mcp-gateway`）；一项目一 Gateway + 可区分端口；工具白名单仍在网关 `tools.yaml`。

### 2026-09-23（清理过时残余）

活跃树只保留验证主路径；过时材料不进入 `docs/` 正文导航。

### 2026-09-23（目标重定位）

文首与原则改为「MCP 验证运行时」；引用章程；明确不做统一控制台/统一仓库；用户级真相仓外。

### 2026-09-23（secondary → 网关 catalog）

`-Secondary` 自动合并 remote 与 tools 白名单，并更新 `--servers`；注销用 `-Unregister`。

### 2026-09-23（hostPath 参数化）

`deploy/local/apply-workspace.ps1` + kustomize `patches/hostpath.yaml`；清单内不再把单一用户路径当全局真理。

### 2026-09-23（Windows hostPath → 跨项目 skill）

挂载换算与禁试错升至 `rancher-k3s-local` / `host-mount-windows.md`；本文只保留本仓实例路径。

### 2026-09-23（代码智能 → trace-mcp；聚合 → docker/mcp-gateway）

验证栈定为 docker/mcp-gateway + trace-mcp；网关协议级工具白名单。

### 2026-09-23（平台规格 → 用户级跨项目）

平台 ENV 权威迁至用户 Always Rule + `rancher-k3s-local`。
