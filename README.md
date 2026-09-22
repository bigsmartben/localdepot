# localdepot
A local repository service — your self-hosted depot for artifacts, packages, and code.

## MCP Gateway documentation

The repository contains the current product and architecture baseline for the MCP Gateway workspace service:

- [Product requirements and user scenarios](docs/mcp-gateway-user-scenarios.md) - user-facing HTML console, MCP access, workspace lifecycle, code and knowledge capabilities, SSH access, and k3s runtime admission requirements.
- [Top-level architecture and delivery](docs/mcp-gateway-top-level-architecture.md) - external entry points, Gateway boundaries, internal k3s Workspace Manager, data flow, subsystem responsibilities, lifecycle, and delivery scope.

Read the product requirements first to understand the user-visible behavior, then read the architecture document for the internal design and delivery boundaries. Both documents describe the same workspace model: users interact through the HTML console or MCP, while Git, SSH, k3s, and backend services remain internal implementation details.
