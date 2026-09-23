# 项目文档

本页是持久文档的权威导航入口。按职责索引；正文以 [上位治理 · SSOT 登记](governance/upper-governance.md) 为准。

## 治理

- [上位治理规范](governance/upper-governance.md) — 环境模型、目录结构、职责 Index、SSOT
- **跨项目本地平台**（仓外）：用户 Cursor Rule `local-platform-rancher-k3s` + skill `rancher-k3s-local`（Rancher K3s + dockerd MUST）

## 章程与验证运行时

- [仓库章程：目标与边界](charter.md) — **现行目标 SSOT**（项目 mcp.json + deploy/local 验证栈）
- [用户场景](user-scenarios.md) — 覆盖 / 不覆盖与验收
- [本地交付栈：验证运行时选型与命令](delivery/local-oss-stack.md) — 开源选型、禁止项、运维命令
- [本地物理与部署架构](architecture/local-physical-deployment.md) — 真源 / 落点 / 工作区目录
- [本地 MCP 栈（验证最短路径）](getting-started/local-mcp-stack.md) — 薄入口 → delivery
- [deploy/local/README.md](../deploy/local/README.md) — **本地 K3s 工具区**
- [Architecture Decision Records](architecture/adr/README.md)
- [examples/mcp-client/](../examples/mcp-client/) — 客户端 URL 形状示例（非运行真相）

## 尚未建立的区域

以下区域在 SSOT 表中为 `missing` / `deferred`，有真实内容后再补链接，不建空占位：

- 根目录 `QUICKSTART.md`（需要时可做薄入口链到 [delivery/local-oss-stack.md](delivery/local-oss-stack.md)）
- Guides / Reference / Operations（通用运维手册；验证运行时见上）
- 本仓 `.cursor/rules/`（平台已在用户级 Rule；本仓文件级 Rules 仍未建立）
