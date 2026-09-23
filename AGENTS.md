# Agent 指令

本文件是通用 Agent 的入口。权威在 [docs/governance/upper-governance.md](docs/governance/upper-governance.md)（环境模型、目录结构、职责 Index、SSOT）。不要在本文件复制第二套规范。

## 必读顺序

1. [README.md](README.md) — 项目入口
2. [docs/index.md](docs/index.md) — 持久文档导航
3. [docs/governance/upper-governance.md](docs/governance/upper-governance.md) — 上位治理与 SSOT
4. [docs/charter.md](docs/charter.md) — **仓库目标与边界（现行口径）**
5. [docs/user-scenarios.md](docs/user-scenarios.md) — 用户场景与验收
6. [docs/delivery/local-oss-stack.md](docs/delivery/local-oss-stack.md) — MCP 验证运行时选型与运维命令
7. [docs/architecture/local-physical-deployment.md](docs/architecture/local-physical-deployment.md) — 物理 / 部署拓扑
8. [docs/getting-started/local-mcp-stack.md](docs/getting-started/local-mcp-stack.md) — 验证最短路径

## 当前工作约束（摘要）

- **仓库目标**：agent / skill / MCP 的验证与开发；**项目** `.cursor/mcp.json` 为连本项目 Gateway 的客户端 SSOT；Rules/Skills 可在用户目录；**本地 K3s 相关均在工具区 `deploy/local/`**。见 [charter](docs/charter.md)。
- **不做**：统一 HTML 控制台；统一工作区/远程仓库产品；自研 Gateway 产品入口；把 K3s 清单拆到用户主目录另维一套。
- **跨项目本地平台**：用户 Cursor Rule `local-platform-rancher-k3s`（alwaysApply）+ skill `rancher-k3s-local`。Rancher Desktop K3s + **dockerd (Moby) MUST**；≠ Docker Desktop Kubernetes；≠ 本机 `docker run` / Toolkit 部署 MCP。Windows 工作区 hostPath：`C:\…` → `/mnt/c/…`，见 skill `references/host-mount-windows.md`（禁试错）。本仓 `docs/` 与 `deploy/local/` 只补充验证契约与 **K3s 实例/工具**，不得改换平台/公式。
- **验证运行时 / 工具区**：客户端走 **本项目 docker/mcp-gateway**（工具白名单）；能力后端 **trace-mcp**；清单与脚本只改 `deploy/local/`；跨项目触发 skill **`init-codebase`**。
- **物理部署**：见 [local-physical-deployment](docs/architecture/local-physical-deployment.md)（真源本机；能力 K8s + **挂载本地工作区**；一工作区一 trace；缓存在工作区 `.cache/trace-home`）。
- **运维命令**：见 [local-oss-stack](docs/delivery/local-oss-stack.md)；PVC 独占真源为非法路径。
- **MCP 生命周期**：Gateway/trace **常驻**；关 Cursor / 停 port-forward / 改 mcp.json **不**自动关集群。Unregister 只卸第二工作区；永久不用须用户授权后删 `project-<slug>-dev`（`-Force`），禁止动 `shared-infra`。详见 delivery §3.4 / skill `init-codebase`。
- **冲突**：与章程或物理部署/delivery 冲突时，以章程 + 物理部署 + delivery 为准；平台选择以用户级 Rule 为准。

## 权威边界（摘要）

- **上位**：环境建模、按职责 Index、SSOT 登记；冲突时下位让步。
- **Speckit 宪章**（`.specify/memory/constitution.md`）：**下位**，仅约束 Speckit / assess 工作流；不得覆盖 `docs/` 结论。
- **跨项目 Cursor Rule**（平台）：用户级 `local-platform-rancher-k3s`；本仓 SSOT 可加严，不得改平台。
- **本仓 Cursor Rules**（`.cursor/rules/`）：**尚未建立**；建立后不得高于本文件与本仓 `docs/` SSOT。
- **评估稿**（`.specify/assessments/`）：draft；晋升真相须写入已登记的 `docs/` SSOT。

## 放置

- 持久知识 → `docs/`；临时 Agent 材料 → `.agents/work/`（勿堆根目录杂项 Markdown）。
- 评估草稿 → `.specify/assessments/`；晋升为真相前须写入已登记的 `docs/` SSOT。
