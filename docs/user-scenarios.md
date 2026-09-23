# 用户场景

> 本文是现行用户场景 SSOT。目标与非目的见 [章程](charter.md)。  
> 验收：下列场景能走通，即满足本仓定位。

## 1. 角色

| 角色 | 关注点 |
|---|---|
| 本地开发者 | 在用户目录迭代 Rules/Skills；经**项目** `.cursor/mcp.json` 连本项目 Gateway |
| 本地运维（通常同一人） | 在本仓工具区维护 K3s 验证栈，保证联调可用 |

## 2. 场景

### 场景 A：开发用户级 Skill

1. 在 `~/.cursor` 或 `~/.agents` 编写或修改 Skill。  
2. 用 Cursor Agent 按 Skill 触发执行。  
3. 需要 MCP 能力时，经本仓验证运行时调用白名单工具。  

**成功**：Skill 行为符合预期；Skill 正文仍在用户目录，不要求提交进本仓。

### 场景 B：开发用户级 Agent 行为

1. 依赖用户级 Rules / Skills 与 Cursor Agent 完成任务。  
2. 本仓提供验证环境与契约文档，不托管 Agent 定义。  

**成功**：Agent 会话可复现预期行为；不以本仓为 Agent 配置仓库。

### 场景 C：接线 MCP 客户端

1. 使用项目根 **`.cursor/mcp.json`**（键名 `mcp-gateway` → 本项目可区分端口，本仓为 `18080`）。  
2. 本仓 `deploy/local` 已启动 docker/mcp-gateway 并完成 port-forward。  

**成功**：客户端列出的工具面与网关白名单一致。见仓库 `.cursor/mcp.json` 与 `examples/mcp-client/`。

### 场景 D：验证 MCP 能力可用

1. 经网关调用白名单工具（如 `get_project_map`、`search`）。  
2. 确认禁调工具被拒绝；允许工具返回合理结果。  

**成功**：验证运行时稳定可达；不绕过网关直连后端。

### 场景 E：挂载 / 切换本机工作区

1. 运行 `apply-workspace.ps1`（或 `-Secondary`）使 trace-mcp 挂载目标工作区。  
2. Cursor 编辑面与 MCP 看见同一目录树。  

**成功**：路径按跨项目公式换算；索引落在工作区 `.cache/trace-home`。

### 场景 F：维护本地 K3s 验证栈

1. 仅在 `deploy/local/` 修改清单、白名单、脚本、overlay。  
2. apply 后网关与 trace 恢复健康。  

**成功**：本地环境 K3s 相关不在用户主目录或其它仓另维一套。
