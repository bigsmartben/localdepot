# 本地 MCP 栈（验证最短路径）

- 章程 / 目标 → **[仓库章程](../charter.md)**
- 用户场景 → **[用户场景](../user-scenarios.md)**
- 物理 / 部署 → **[本地物理与部署架构](../architecture/local-physical-deployment.md)**
- 选型与命令 → **[本地交付栈（验证运行时）](../delivery/local-oss-stack.md)**
- 操作入口 → **[deploy/local/README.md](../../deploy/local/README.md)**（`apply-workspace.ps1`）

**跨项目触发**：`init codebase` / `init trace mcp` → skill **`init-codebase`**（先分析仓库清单/mcp.json/端口，再落地）。

**已确认接线模型**：

- **每项目一 Gateway** + 可区分本地端口；工具白名单在网关 `tools.yaml`。
- 客户端 SSOT = 项目 **`.cursor/mcp.json`**（仅 `mcp-gateway` → 本项目 URL）。
- 运行时 = 项目 **`deploy/local/`**（Gateway + trace 等）。
- 不做架构文档生成；不以用户级 mcp.json 为本流程 SSOT。
- **生命周期**：K3s 上 gateway/trace **常驻**；关 Cursor / 停 forward / 改 mcp.json **不**自动删 ns。永久不用时须用户授权后删 `project-<slug>-dev`（见 delivery §3.4 / skill `init-codebase`）。

本页不另写第二套步骤，避免漂移。
