# localdepot

**Agent / Skill / MCP** 的验证与开发场：本仓提供可重复的 MCP 验证运行时（`deploy/local`）与文档契约；**项目** `.cursor/mcp.json` 为连本项目 Gateway 的客户端 SSOT；Rules / Skills 可在用户目录跨项目复用。**不做**统一控制台、**不做**统一仓库产品。

权威目标见 [docs/charter.md](docs/charter.md)。

## 文档入口

完整导航见 [docs/index.md](docs/index.md)。上位治理见 [docs/governance/upper-governance.md](docs/governance/upper-governance.md)。Agent 入口见 [AGENTS.md](AGENTS.md)。

**当前怎么跑（验证运行时）**

1. 章程：[docs/charter.md](docs/charter.md)
2. 用户场景：[docs/user-scenarios.md](docs/user-scenarios.md)
3. 物理 / 部署：[docs/architecture/local-physical-deployment.md](docs/architecture/local-physical-deployment.md)
4. 选型与命令：[docs/delivery/local-oss-stack.md](docs/delivery/local-oss-stack.md)
5. 最短命令入口：[docs/getting-started/local-mcp-stack.md](docs/getting-started/local-mcp-stack.md)

## 当前要点

- **目标**：验证 agent / skill / MCP；客户端 SSOT = **`.cursor/mcp.json`**（`mcp-gateway`）；运行时 = **`deploy/local/`**。
- **非目标**：统一 HTML 控制台；统一工作区/远程仓库产品；自研 Gateway 产品入口。
- **并行**：一项目一 Gateway + 可区分本地端口（本仓 **18080**）。
- **跨项目本地平台**：用户 Cursor Rule `local-platform-rancher-k3s` + skill `rancher-k3s-local`；落地触发 skill **`init-codebase`**。
- **验证运行时**：本机真源；**trace-mcp** + **docker/mcp-gateway**（工具白名单）。

## 本地最短命令（网关 + trace）

```powershell
docker build -t localdepot/trace-mcp:3.31.3 -f deploy/local/trace-mcp/Dockerfile deploy/local/trace-mcp
.\deploy\local\apply-workspace.ps1 -WorkspacePath (Get-Location).Path
kubectl --context rancher-desktop -n project-localdepot-dev port-forward --address 127.0.0.1 svc/docker-mcp-gateway 18080:8080
# → http://127.0.0.1:18080/mcp （见 .cursor/mcp.json）
```

详情：[local-oss-stack](docs/delivery/local-oss-stack.md) §3.2。
