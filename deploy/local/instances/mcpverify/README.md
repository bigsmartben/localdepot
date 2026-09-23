# Instance: mcpverify

Unified codebase remote for `C:\Users\24598\Documents\codeup`.

| | |
|--|--|
| Namespace | `project-mcpverify-dev` |
| Local port | **18082** → `svc/docker-mcp-gateway:8080` |
| Gateway URL | `http://127.0.0.1:18082/mcp` |
| Mount | codeup parent (all repos) |
| TRACE_HOME | `/mnt/c/Users/24598/Documents/.cache/mcpverify-trace-home`（在挂载树外，避免 watcher 反馈环） |
| Client scope | `.cursor/mcp.json` → same `url` + `projects: ["<repo>", ...]` |

> Port **18081** is often taken by other project stacks; mcpverify uses **18082**.

```powershell
.\deploy\local\apply-workspace.ps1 -Instance mcpverify -WorkspacePath C:\Users\24598\Documents\codeup
kubectl --context rancher-desktop -n project-mcpverify-dev port-forward --address 127.0.0.1 svc/docker-mcp-gateway 18082:8080
```
