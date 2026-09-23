# 上位治理规范

> 上位治理的核心：**环境建模 → 目录与职责 Index → 登记 SSOT**。  
> 本文件是上位治理自身的单一权威来源。不在此重复产品、架构或 Speckit 原则正文。

## 1. 目的与非目的

### 1.1 目的

- 标明仓库内各「环境 / 参与方」的作用域与职责边界。
- 给出与实况一致的目录结构，并按目录标注职责。
- 按职责提供稳定入口（Index），避免多入口复制同一主题。
- 为每个主题登记唯一权威正文（SSOT）；其余位置只链接。
- 仓库现行目标以 [仓库章程](../charter.md) 与 [用户场景](../user-scenarios.md) 为准。

### 1.2 非目的

- 不替代章程、验证运行时交付文档、ADR 的正文。
- 不规定 Speckit 命令链内的设计原则（属宪章，下位）。
- 不在本仓库复制**跨项目**本地平台全文（权威在用户级 Cursor Rule `local-platform-rancher-k3s` + skill `rancher-k3s-local`）；本仓只引用并补充验证契约与实例路径。
- 不把用户级 `~/.cursor` / `~/.agents` **整树**收进本仓当统一权威；允许项目 `.cursor/mcp.json`（Gateway URL）入库。

## 2. 环境模型

| 环境 / 参与方 | 作用域 | 产出 / 消费 | 规范入口 |
|---|---|---|---|
| 人类贡献者 | 全仓库 | 读写 `docs/`、代码、配置 | [README.md](../../README.md) → [docs/index.md](../index.md) |
| 通用 Agent | 全仓库会话 | 须先读 Index / SSOT，再改文件 | [AGENTS.md](../../AGENTS.md)（本表） |
| Speckit（`.specify/`） | SDD 与 assess 工作流 | `specs/`、`assessments/`、宪章驱动的产出 | 宪章（下位）：[`.specify/memory/constitution.md`](../../.specify/memory/constitution.md) |
| 跨项目本地平台 | 用户级、所有仓库会话 | Rancher K3s + dockerd MUST 等 ENV | 用户 Rule `~/.cursor/rules/local-platform-rancher-k3s.mdc`；skill `rancher-k3s-local` |
| 本仓 Cursor Rules | 本仓库编辑器偏好 | `.cursor/rules/*.mdc` | **尚未建立**；建立后不得高于本文件与本仓 `docs/` 产品 SSOT |
| 可执行行为 | 运行时与 CI | `deploy/` 真实配置、流水线 | 以仓库内可执行产物为准 |
| Agent 临时工作区 | 可丢弃材料 | `.agents/work/`、`.agents/reports/` | 默认不提交；见 §5 |

冲突时：可执行行为 > 本上位治理与活跃 `docs/` SSOT（含章程）> 已批准 ADR > Speckit 宪章 > 本仓 Cursor Rules。  
**平台选择**（Rancher K3s / dockerd 等）：以跨项目用户 Rule 为准；本仓 SSOT 可加严，不得改换平台（如改用 Docker Desktop Kubernetes）。

## 3. 仓库目录结构

按**当前仓库实况**建模。标注职责归属；`(计划)` 表示约定位置但尚未落盘或尚无内容。不因「树看起来完整」而提交空目录。

```text
localdepot/
├── README.md                 # 项目总览入口
├── AGENTS.md                 # Agent 薄入口 → 本文件
├── .gitignore                # 含 .agents 临时目录忽略
│
├── pyproject.toml            # 工程元数据（无产品包）
├── .cursor/mcp.json          # 项目 MCP 客户端 SSOT（mcp-gateway URL）
├── examples/mcp-client/      # MCP 客户端说明（以 .cursor/mcp.json 为准）
├── tests/                    # (可选) 自动化测试
│
├── docs/                     # 持久知识（章程 / 场景 / 架构 / 治理 / 验证运行时）
│   ├── index.md              # docs 导航 Index
│   ├── charter.md            # 仓库目标与边界 SSOT
│   ├── user-scenarios.md     # 用户场景 SSOT
│   ├── governance/
│   │   └── upper-governance.md   # 上位治理 SSOT（本文件）
│   ├── architecture/
│   │   ├── local-physical-deployment.md  # 验证运行时物理/部署拓扑 SSOT
│   │   └── adr/              # 实现级 ADR（当前无活跃条目）
│   ├── delivery/
│   │   └── local-oss-stack.md    # MCP 验证运行时选型与运维命令
│   └── getting-started/
│       └── local-mcp-stack.md    # 验证最短路径
│
├── deploy/                   # 可执行部署清单
│   └── local/                # 本地 K3s 工具区（含 README）
│
├── .specify/                 # Speckit 环境（流程；宪章为下位）
│   ├── memory/constitution.md
│   ├── assessments/          # pre-SDD 评估；非 docs SSOT
│   ├── templates/
│   ├── scripts/
│   ├── workflows/
│   ├── extensions/
│   └── integrations/
│
├── .cursor/
│   ├── skills/               # 已版本化的 Speckit 等 Skills
│   └── rules/                # (计划) 本仓 Cursor Rules — 尚未建立
│
└── .agents/                  # Agent 工作材料；默认不提交
    ├── work/
    ├── reports/
    └── trash/                # 清理隔离区
```

### 3.1 目录职责速查

| 路径 | 职责 | 是否 SSOT 容器 |
|---|---|---|
| `README.md` / `AGENTS.md` | 入口与导航，不承载主题全文 | 入口级 canonical |
| `examples/mcp-client/` | MCP 客户端说明 | 否（说明；SSOT 为 `.cursor/mcp.json`） |
| `tests/` | 自动化测试（可选） | 否 |
| `docs/` | 持久章程、场景、架构、治理知识 | 是（按主题登记） |
| `deploy/local/` | 本地 K3s 工具区 | 可执行配置；行为以其实例为准 |
| `.specify/` | Speckit / assess 工作流与过程产物 | 宪章与评估为下位或 draft |
| `.cursor/skills/` | 可版本化的 Agent Skills | 工具说明，非产品真相 |
| `.cursor/rules/` | 本仓 Cursor 会话偏好 | **尚未**；平台见用户级 Rule |
| `.agents/` | 可丢弃 Agent 材料 | 否（ephemeral） |

## 4. 职责 Index

按职责只保留一个导航入口；正文见 SSOT 表。

| 职责 | Index 入口 | 说明 |
|---|---|---|
| 项目总览 | [README.md](../../README.md) | 对外第一入口；只链重要文档，不复制全文 |
| 持久文档导航 | [docs/index.md](../index.md) | `docs/` 权威目录 |
| 上位治理 / 目录 / SSOT | 本文件 | 环境、目录结构、职责、权威表 |
| Agent 行为入口 | [AGENTS.md](../../AGENTS.md) | 指向本文件与 docs Index；不另写第二套规则 |
| 仓库目标与边界 | [charter.md](../charter.md) | 项目 mcp.json + deploy/local 验证栈 |
| 用户场景 | [user-scenarios.md](../user-scenarios.md) | 覆盖 / 不覆盖场景与验收 |
| 本地物理 / 部署拓扑 | [architecture/local-physical-deployment.md](../architecture/local-physical-deployment.md) | 验证运行时真源落点、挂载、trace-mcp 粒度 |
| 验证运行时选型 / 运维 | [delivery/local-oss-stack.md](../delivery/local-oss-stack.md) | 开源选型与运维命令 |
| 跨项目本地平台 | 用户 Rule + skill `rancher-k3s-local`（仓外） | Rancher K3s + dockerd MUST |
| 验证最短路径 | [getting-started/local-mcp-stack.md](../getting-started/local-mcp-stack.md) | 本机 apply / port-forward / 冒烟 |
| 验证运行时清单（本地 K3s 工具区） | `deploy/local/`（说明见 [README](../../deploy/local/README.md)） | 本地环境 K3s 相关均在此维护 |
| 实现级决策（ADR） | `docs/architecture/adr/` | 当前无活跃条目；不得覆盖章程 / 验证运行时 SSOT |
| Speckit 流程原则 | `.specify/memory/constitution.md` | **下位**：仅约束 Speckit 工作流 |
| 想法评估（pre-SDD） | `.specify/assessments/` | 非章程/架构 SSOT；不得覆盖 `docs/` 结论 |
| Cursor 编辑偏好 | — | **尚未** |

## 5. SSOT 登记表

每个主题一行；新增主题须先占行再写正文。状态：`canonical` | `draft` | `missing` | `deferred`。

| 主题 | SSOT 路径 | 状态 | 备注 |
|---|---|---|---|
| 上位治理（环境 / 目录 / Index / SSOT） | `docs/governance/upper-governance.md` | canonical | 本文件 |
| 项目入口说明 | `README.md` | canonical | 导航摘要，非章程全文 |
| 持久文档导航 | `docs/index.md` | canonical | |
| Agent 总入口 | `AGENTS.md` | canonical | 薄入口，权威在本文件 |
| 仓库目标与边界 | `docs/charter.md` | canonical | 项目 mcp.json + deploy/local 验证栈 |
| 用户场景 | `docs/user-scenarios.md` | canonical | 覆盖 / 不覆盖与验收 |
| 本地物理 / 部署架构 | `docs/architecture/local-physical-deployment.md` | canonical | 验证运行时；真源本机；能力 K8s + 挂本地工作区 |
| 跨项目本地平台 ENV | 用户 `~/.cursor/rules/local-platform-rancher-k3s.mdc` + skill `rancher-k3s-local` | canonical（仓外） | 本仓不得改换平台 |
| 验证运行时选型 / 操作指令 | `docs/delivery/local-oss-stack.md` | canonical | 开源选型与运维命令 |
| 验证运行时部署（kustomize 等） | `deploy/local/` | canonical | 本地 K3s 工具区；操作说明：`deploy/local/README.md` |
| ADR | `docs/architecture/adr/` | canonical | 索引见该目录 README；当前无活跃条目 |
| MCP 客户端 URL | 项目 `.cursor/mcp.json` | canonical | 仅 Gateway；工具白名单在 deploy/local |
| MCP 客户端说明 | `examples/mcp-client/` | draft | 说明；以仓库 `.cursor/mcp.json` 为准 |
| 上手 / 验证最短路径（薄入口） | `docs/getting-started/local-mcp-stack.md` | canonical | 仅链到 delivery，不复制步骤 |
| 上手 / QUICKSTART（根） | `QUICKSTART.md` | deferred | 需要时建薄入口，链到 delivery |
| 文档放置细则（完整标准） | — | deferred | 当前以本文件 §3、§6 为准 |
| Speckit 宪章 | `.specify/memory/constitution.md` | draft | 模板占位；**下位** |
| Cursor Rules（本仓） | `.cursor/rules/` | deferred | **尚未** |
| Assess 材料 | `.specify/assessments/<slug>/` | draft | 评估过程产物，非交付真相 |

### 5.1 冲突处理

1. 行为与文档不一致：以可执行行为为准，并开事项修文档或修代码。
2. 下位（宪章 / 本仓 Cursor Rules）与本文件或 `docs/` 活跃 SSOT（含章程）冲突：**改下位**，不默改上位迁就。平台选择（K3s/dockerd）以跨项目用户 Rule 为准。
3. Assess / Agent 草稿与 `docs/` SSOT 冲突：以 `docs/` 为准；草稿须标注或回写经评审的变更。
4. 同一主题出现第二份「权威」叙述：保留 SSOT，其余改为链接或移出活跃树。

## 6. 放置与临时材料（最小集）

- 持久知识进入 `docs/`；根目录仅保留约定入口（如 `README.md`、`AGENTS.md`），不堆 `NOTES.md` / 日期总结等杂项。
- 验证运行时 / **本地 K3s 工具区**配置进入 `deploy/local/`；项目 MCP 客户端 URL 进入 **`.cursor/mcp.json`**；Rules/Skills 可留用户目录；不把 K3s 清单拆到用户主目录另维一套。
- Speckit 流程产物留在 `.specify/` 约定位置；评估材料在 `.specify/assessments/`，晋升为真相前须写入对应 `docs/` SSOT。
- Agent 可丢弃材料使用 `.agents/work/`、审计输出 `.agents/reports/`、隔离区 `.agents/trash/`（默认不版本化）。
- 不因「文件较旧」删除规范文档；清理须另授权，且不得触碰本表中的 canonical 入口。过时正文应移出活跃树，不以 superseded 长文继续挂在 `docs/` 导航下。

## 7. 修订

- 变更环境模型、**目录结构**、职责 Index 或 SSOT 表：更新本文件，并检查 [docs/index.md](../index.md)、[AGENTS.md](../../AGENTS.md)、[README.md](../../README.md) 的链接是否仍准确。
- 不在此文件展开产品或架构细节；改对应 SSOT 正文。

### 2026-09-23

登记跨项目用户级平台 Rule / skill；本仓 Cursor Rules 仍 deferred。

### 2026-09-23（目标重定位与清理）

登记 [charter.md](../charter.md) 与 [user-scenarios.md](../user-scenarios.md)；过时 Gateway 产品长文、脚手架 ADR、`src/mcp_gateway`、demoted 部署移出活跃树；`deploy/local` 为本地 K3s 工具区。

### 2026-09-23（工具区职责）

明确本地环境 K3s 相关均在本仓工具区 `deploy/local/` 维护；平台公式仍属用户级 Rule/skill。
