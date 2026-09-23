# MCP 客户端配置（项目级 SSOT）

客户端真相：仓库根 **`.cursor/mcp.json`**（可入库）。  
本仓约定端口 **18080**（与其它项目并行时对方应使用不同端口；本机 8080 常被 RD host-switch 占用）。

```json
{
  "mcpServers": {
    "mcp-gateway": {
      "url": "http://127.0.0.1:18080/mcp"
    }
  }
}
```

- 只连本项目 Gateway；工具选择见 `deploy/local` 网关 `tools.yaml`。
- 形状与运行真相一致时以仓库 `.cursor/mcp.json` 为准；本目录仅说明。
