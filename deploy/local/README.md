# 本地部署（Rancher Desktop K3s）

> **本地 K3s 工具区**：本验证环境相关的 K8s 清单与脚本均在此目录维护。  
> **Agent / 交付指令 SSOT**：[`docs/delivery/local-oss-stack.md`](../../docs/delivery/local-oss-stack.md)；目标边界见 [`docs/charter.md`](../../docs/charter.md)。

## 验证主路径：docker/mcp-gateway + trace-mcp

**推荐（参数化 hostPath，勿手改清单写死路径）**：

```powershell
docker build -t localdepot/trace-mcp:3.31.3 -f deploy/local/trace-mcp/Dockerfile deploy/local/trace-mcp
.\deploy\local\apply-workspace.ps1 -WorkspacePath (Get-Location).Path
kubectl --context rancher-desktop -n project-localdepot-dev port-forward --address 127.0.0.1 svc/docker-mcp-gateway 18080:8080
# → http://127.0.0.1:18080/mcp （项目 .cursor/mcp.json → mcp-gateway）
```

- 客户端 SSOT：仓库根 `.cursor/mcp.json`（仅 Gateway URL）；工具白名单在网关 ConfigMap。
- **生命周期**：gateway/trace **常驻**。停 port-forward ≠ 关 Deployment；`-Unregister` 只卸第二工作区；永久不用须用户授权后删 ns `project-localdepot-dev`（勿删 `shared-infra`）。全文：[delivery §3.4](../../docs/delivery/local-oss-stack.md)。
- `apply-workspace.ps1`：按公式写 `patches/hostpath.yaml` 并 `apply -k`。
- 第二工作区：`-Secondary` → overlay + **自动注册网关 catalog**（`gateway/secondaries/`、`--servers`）。
- 注销第二工作区：`-Unregister -WorkspaceSlug <slug>`。
- 仅重建 catalog：`-SyncCatalog`。
- 工具白名单：ConfigMap `tools.yaml`（每 server 一份 allowlist）。

一键（沿用已生成的 patch）：`kubectl --context rancher-desktop apply -k deploy/local`

## 本目录内容

| 路径 | 说明 |
|------|------|
| `docker-mcp-gateway.yaml` / `gateway/` | 聚合网关 + catalog / tools |
| `trace-mcp.yaml` / `trace-mcp/` | 代码智能后端 |
| `apply-workspace.ps1` / `patches/` | hostPath 与 `--servers` 参数化 |
| `overlays/` | 第二工作区实例（由脚本生成） |
