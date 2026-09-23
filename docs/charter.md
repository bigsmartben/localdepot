# 仓库章程：目标与边界

> 本文是 **localdepot 目标与非目标** 的 SSOT。  
> 冲突时：本章程 + [本地交付栈](delivery/local-oss-stack.md) + [物理与部署架构](architecture/local-physical-deployment.md) 优先。

## 1. 目的

在可控本地栈上 **验证与开发 Agent、Skill、MCP 接线**：

- 沉淀可复用的验证清单、联调步骤与形状样例；
- 提供可重复的 **MCP 验证运行时**（本仓工具区 `deploy/local/`：docker/mcp-gateway + trace-mcp）；
- **本地环境中与 K3s 相关的清单、脚本与实例路径均在本仓工具区维护**（不以用户主目录另起一套 MCP 部署真相）；
- **项目级** `.cursor/mcp.json` 为 Cursor 连本项目 Gateway 的客户端 SSOT；Rules / Skills 等仍可在用户目录跨项目复用。

验收口径：能稳定验证 skill / agent / MCP 是否按预期工作（经本项目 Gateway + 白名单）。

用户场景见 [user-scenarios.md](user-scenarios.md)。

## 2. 非目的

- **不做**统一 HTML 工作区控制台。
- **不做**统一远程/工作区仓库产品（不以本仓或 Gateway 收拢多项目 Git 真源）。
- **不做**自研聚合 Gateway 作为跨仓库产品入口（验证运行时使用开源 docker/mcp-gateway）。
- **不把**用户级 `~/.cursor` / `~/.agents` **整树**收进本仓充当统一仓库；允许入库的是本项目 **`.cursor/mcp.json`**（仅 Gateway URL）。

## 3. 真相落点

| 类别 | 权威位置 | 本仓角色 |
|---|---|---|
| Cursor Rules / Skills | 用户级 `~/.cursor`（及跨项目 alwaysApply Rules） | 可引用、可对照验证；不复制为仓内第二套权威 |
| Agent Skills | 用户级 `~/.agents` 等 | 同上 |
| **MCP 客户端 URL** | **项目** `.cursor/mcp.json` | **SSOT**：`mcp-gateway` → 本项目可区分端口的 Gateway；统一 codebase 栈可另含 `projects`（要查询的仓库目录名列表，见 [delivery §3.3.1](delivery/local-oss-stack.md)） |
| 工具白名单 | `deploy/local` 网关 `tools.yaml` | 协议级 list+call 裁切 |
| 形状说明 | `examples/mcp-client/` | 说明；以仓库 `.cursor/mcp.json` 为准 |
| **本地 K3s 工具区** | **`deploy/local/`** | **本仓维护**：本项目 Gateway、trace-mcp、白名单、挂载脚本 |
| 跨项目本地平台 | 用户 Rule `local-platform-rancher-k3s` + skill `rancher-k3s-local` | 平台戒律与 hostPath **公式**在仓外；本仓只落 **实例** |

## 4. 本仓职责边界

**做**

- 文档化验证契约与最短联调路径（[getting-started](getting-started/local-mcp-stack.md)、[delivery](delivery/local-oss-stack.md)）。
- 在本仓工具区 **`deploy/local/`** 维护本项目 **K3s 相关**可执行产物（网关、trace-mcp、白名单、挂载脚本、overlay 等）。
- 维护项目 **`.cursor/mcp.json`**（Gateway URL）。

**不做**

- 产品化 HTML/API 控制台或「工作区统一入口」。
- 以本仓为中心统一管理多项目远程仓库。
- 用用户级 mcp.json 替代项目 `.cursor/mcp.json` 作为本验证栈客户端 SSOT。
- 把本仓 K3s 清单拆散到用户主目录另维一套「本地环境」真相。

## 5. 与验证运行时的关系

```text
项目 .cursor/mcp.json（mcp-gateway → 127.0.0.1:<port>/mcp）
        │
        ▼  port-forward
deploy/local：docker/mcp-gateway  ──remote──►  trace-mcp（挂载本机工作区）
                 tools.yaml 白名单
```

- 物理拓扑：[local-physical-deployment](architecture/local-physical-deployment.md)
- 选型与命令：[local-oss-stack](delivery/local-oss-stack.md)（含 **§3.4 生命周期**：常驻；Unregister ≠ 关整栈；删 ns 须授权）
- 平台：跨项目用户 Rule + `rancher-k3s-local`（仓外）
- 跨项目触发：skill `init-codebase`

## 6. 修订

### 2026-09-23（项目 MCP K3s 生命周期）

Gateway/trace 常驻；删项目 ns 须授权。见 [delivery §3.4](../delivery/local-oss-stack.md)。

### 2026-09-23（项目 mcp.json + 每项目 Gateway）

客户端 SSOT 为项目 `.cursor/mcp.json`（键名 `mcp-gateway`）；一项目一 Gateway + 可区分本地端口；工具选择在网关 `tools.yaml`。

### 2026-09-23

仓库目标重定位：agent / skill / MCP 验证与开发；`deploy/local` 为验证运行时与本地 K3s 工具区。过时 Gateway 产品长文、demoted 后端清单与自研脚手架已移出活跃树，不以正文引用。
