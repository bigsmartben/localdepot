# 本地物理与部署架构

> 本文是**工作区真源、进程落点与部署拓扑**的 SSOT（物理 / 部署范畴；**验证运行时**拓扑）。  
> 仓库目标见 [章程](../charter.md)；开源选型与运维命令见 [delivery/local-oss-stack.md](../delivery/local-oss-stack.md)。

## 1. 范围

**回答**

- 源码真源可以落在哪？有哪些合法部署模式？
- 能力后端与网关如何部署（作为 MCP 验证运行时）？
- 工作区目录与 **trace-mcp** 粒度？
- 索引/缓存落在哪一级？

**不回答**：具体命令（→ delivery）、用户级 agent/skill 开发流程（→ 章程）。

## 2. 硬约束（不变式）

**Cursor / Agent 的编辑面与 trace-mcp（经网关）必须看见同一棵工作区目录树。**

不满足则非法，无论用不用 Deployment。

合法满足方式见 §3（模式 A / B）。**不是**性能取舍问题。

### 2.1 平台与容器引擎（引用跨项目规范）

**跨项目平台戒律（权威）**：用户 Cursor Rule `local-platform-rancher-k3s`（`alwaysApply`）；执行与 ENV 全表见 skill `rancher-k3s-local` → `references/platform-requirements.md`。

| | 本地 | 生产 |
|--|------|------|
| 集群产品 | Rancher Desktop **K3s**（`rancher-desktop`） | **标准 Kubernetes** |
| 容器引擎 | **dockerd (Moby)**（MUST） | **Docker 引擎** |
| MCP 进程 | K8s 工作负载（`docker/mcp-gateway` + `trace-mcp`） | 同左 |

## 3. 部署模式

### 3.1 模式 A（优先）：真源在本机磁盘 + Pod 挂载

```text
本机磁盘 <workspace-root>/     ← Cursor 本地打开 / edit
        ↑ hostPath / bind
K8s: trace-mcp Deployment
K8s: docker/mcp-gateway → remote(trace-mcp)
```

**路径换算（跨项目）**：Windows → 节点 hostPath 公式与「一次探测 / 失败切 B / 禁止试错」见 skill `rancher-k3s-local` → `references/host-mount-windows.md`。本仓只登记实例，不另定公式。

本仓实例由脚本派生并写入 `deploy/local/patches/hostpath.yaml`（示例）：

`C:\Users\24598\Documents\github\localdepot` → hostPath `/mnt/c/Users/24598/Documents/github/localdepot` → Pod `/workspaces/project`

换工作区：`.\deploy\local\apply-workspace.ps1 -WorkspacePath <WindowsPath>`；第二实例加 `-Secondary`（自动写入网关 catalog）；注销 `-Unregister`。

### 3.2 模式 B（备选）：真源在集群内 + SSH 远程编辑

```text
K8s PVC <workspace-root>/
        ├── 挂载 → trace-mcp
        └── 同一树 ← Cursor 经 SSH 远程打开
K8s: docker/mcp-gateway
```

### 3.3 模式对照

| | 模式 A | 模式 B |
|--|--------|--------|
| 真源位置 | 本机磁盘 | 集群卷 |
| Cursor | 本地文件夹 | SSH 远程 |
| 能力 Deployment | 挂本机路径 | 挂同一 PVC |
| 硬约束 | 同一树 ✅ | 同一树 ✅ |

## 4. 原则

1. **同一棵树**（§2）。
2. **客户端只连本项目 mcp-gateway**（项目 `.cursor/mcp.json`）；工具白名单在网关。
3. **trace-mcp 粒度 = 工作区**：一工作区一实例；多仓为工作区根下子目录。
4. **缓存 = 工作区根** `.cache/trace-home/`（`TRACE_HOME`）；非用户级 `~` 全局索引。
5. 能力用 K8s Deployment 合理；**不是**因性能才进集群。

## 5. 工作区文件系统（逻辑布局）

```text
<workspace-root>/                 ← TRACE_PROJECT_ROOT；模式 A/B 挂载根
├── <repo-a>/
├── <repo-b>/
└── .cache/
    └── trace-home/               ← TRACE_HOME（~/.trace 落点）
```

### 5.1 并发

| 场景 | trace-mcp |
|------|-----------|
| 两工作区 | 两实例 |
| 同工作区多对话框 | 共享一实例 |
| 一工作区多仓 | 仍一实例（root = 工作区根） |

## 6. 部署单元

| 单元 | 类型 | 备注 |
|------|------|------|
| docker/mcp-gateway | K8s Deployment | 常驻；工具白名单；remote → trace |
| trace-mcp | K8s Deployment | 一工作区一实例；挂载工作区根 |

## 7. 明确非法 / 非主路径

- 双真源（本机 edit 一份 + 能力只打另一份 PVC）。
- 用户级家目录默认堆跨工作区索引。
- 客户端绕过 mcp-gateway。
- PVC 独占真源、无本机挂载。

## 8. 与其它文档

| 主题 | SSOT |
|------|------|
| 跨项目本地平台 | 用户 Rule + `rancher-k3s-local`（含 `host-mount-windows.md`） |
| 物理 / 部署（本文） | 本文件 |
| 选型与命令 | `docs/delivery/local-oss-stack.md` |

## 9. 修订

### 2026-09-23（项目 mcp.json + 每项目 Gateway）

客户端只连本项目 Gateway；URL SSOT 为项目 `.cursor/mcp.json`；并行靠可区分端口（见 delivery / `init-codebase`）。

### 2026-09-23（清理过时残余）

能力表只保留网关 + trace；非法路径见 §7。

### 2026-09-23（hostPath 参数化）

实例路径经 `apply-workspace.ps1` / `patches/hostpath.yaml`；多工作区用 `-Secondary` overlay。

### 2026-09-23（Windows hostPath 换算升跨项目 skill）

模式 A 路径公式与禁试错策略迁至 `rancher-k3s-local` → `host-mount-windows.md`；本文只保留实例映射。

### 2026-09-23（代码智能 → trace-mcp）

能力后端定为 trace-mcp；硬约束与布局为 trace 粒度与 `.cache/trace-home`。

### 2026-09-23（平台规格升为用户级）

§2.1 改为引用跨项目 Rule/skill。

### 2026-09-23（目标重定位）

定位改为 MCP **验证运行时**拓扑；引用 [章程](../charter.md)。

### 2026-09-22（模式 B / Deployment + 挂本地）

能力以 Deployment 为主；硬约束非性能。
