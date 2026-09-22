# MCP Gateway 顶层架构、概念设计与交付方案

## 0. 文档定位与交付范围

本文面向架构设计、工程实现和最终交付，定义 MCP Gateway 的顶层结构、配置边界、概念模型、数据流、子系统职责、运行生命周期、安全约束和 MVP 交付路径。

最终交付物包括两个对外入口：

1. 面向用户的统一 HTML 工作区控制台；
2. 面向 codexcli 和自动化客户端的 MCP 服务及接入配置。

两者共享同一套 Gateway 能力模型。Gateway 是可安装、可随系统启动、可健康检查、可自动恢复的常驻服务。远程仓库在 k3s 内部统一使用 Git 管理，Codeup SSH、GitHub SSH、CodeGraph、Serena、RAG、k3s Job 和 PVC 都是内部依赖，不直接暴露给用户。

## 1. 架构目标

MCP Gateway 是 codexcli 唯一接入的常驻 MCP 服务，也是本方案的最终交付物。它随系统启动并持续运行，把项目上下文转换为用户级能力策略，再通过统一的 k3s Job 生命周期调用底层 CodeGraph、Serena 和 RAG 后端。

设计原则：

- **工作区与能力解耦**：工作区只声明源码范围，不能选择底层后端；该声明由系统内部维护。
- **稳定边界**：对外暴露固定的高层工具，内部后端可替换。
- **用户级治理**：镜像、模板、资源、权限、超时和策略集中管理。
- **服务与任务分离**：Gateway 服务常驻；一次能力调用对应受控的短生命周期任务，完成后自动回收。
- **安全优先**：路径、配置、并发写入和资源使用均在 Gateway 侧兜底。

## 2. 顶层架构

```text
┌──────────────────────┐
│ 用户 │ codexcli/自动化 │
└──┬───┴────────┬────────┘
   │ HTML       │ MCP
┌──▼────────────▼───────┐
│      MCP Gateway      │  WSL 常驻用户级服务
│  ┌────────────────┐  │
│  │ HTML/API Facade│  │  工作区控制台接口
│  ├────────────────┤  │
│  │ MCP Tool Facade│  │  服务与维护工具
│  ├────────────────┤  │
│  │ Context Resolver│  │  工作区配置、源码路径
│  ├────────────────┤  │
│  │ Policy Resolver │  │  全局策略、本地覆盖
│  ├────────────────┤  │
│  │ Job Orchestrator│  │  k3s Job 生命周期
│  ├────────────────┤  │
│  │ Backend Adapter │  │  HTTP/SSE/MCP 适配
│  ├────────────────┤  │
│  │ Guardrails      │  │  校验、超时、锁、清理
│  ├────────────────┤  │
│  │ Service Runtime │  │  监听、健康检查、优雅退出
│  └────────────────┘  │
└──────────┬───────────┘
           │ 内部 API / Kubernetes API
┌──────────▼──────────────────────┐
│              k3s                │
│  ┌─────────────┐ ┌────────────┐ │
│  │ CodeGraph   │ │ Serena     │ │
│  │ Job/Pod     │ │ Job/Pod    │ │
│  └─────────────┘ └────────────┘ │
│  ┌─────────────┐                │
│  │ RAG Job/Pod │                │
│  └─────────────┘                │
│          workspace-pvc          │
│  Workspace Manager              │
│  Git / Codeup SSH / GitHub SSH  │
└─────────────────────────────────┘
```

## 3. 配置与部署边界

### 3.1 用户级 Gateway 配置

位置：`~/.mcp-gateway/config.yaml`

负责定义：

- k3s kubeconfig、Job 模板位置、namespace 和 PVC。
- 默认 requests/limits、TTL、调用超时和最大并发。
- CodeGraph、Serena、RAG 的镜像和启用状态。
- 高层能力到后端的固定映射。
- 可选的全局安全策略和允许覆盖的字段。
- 工作区来源类型、远程 Git 地址和受控同步策略。
- Codeup/GitHub SSH 凭据引用方式；只引用本地 SSH agent 或受控凭据，不保存私钥内容。

Gateway 服务本身由系统服务管理机制安装和启动。系统服务配置属于用户环境资产，至少需要定义启动命令、工作目录、环境文件、自动重启策略和健康检查方式。

### 3.2 工作区内部配置

工作区的源码范围、文档范围和知识来源由 Gateway/Workspace Manager 在 k3s 内部维护。该配置不要求提交到远程代码仓库，也不向用户暴露仓库内的项目配置文件。

内部概念模型可以包含：

```yaml
source_root: "src"
```

该内部配置不得承载后端、镜像、向量、资源、k3s、Git 或 SSH 私钥内容。

### 3.3 用户级项目覆盖

位置：`~/.mcp-gateway/overrides/<workspace-name>.yaml`

覆盖用于本地实验或单项目差异化策略。合并顺序为：

```text
Gateway 默认配置 → 用户级项目覆盖 → 当前请求上下文
```

请求上下文只能提供工具参数和当前工作目录，不能修改受保护的后端、资源、权限和安全策略。

### 3.4 统一 Job 模板

位置：`~/.mcp-gateway/templates/mcp-job.yaml`

模板是 Gateway 的运维资产，渲染时注入镜像、源码路径、资源、环境变量、PVC、TTL 和必要的标签。项目仓库不包含该模板。

## 4. 概念模型

| 概念 | 说明 | 生命周期 |
| --- | --- | --- |
| WorkspaceContext | 工作区标识、源码范围、文档范围和知识来源 | 单次调用 |
| GatewayPolicy | 能力到后端的映射及全局约束 | 配置生命周期 |
| Capability | 对外稳定的高层工具能力 | 版本化契约 |
| Workspace | 用户可见的代码、文档和版本工作区 | 工作区生命周期 |
| RemoteSource | 工作区对应的远程 Git 来源 | 用户级配置 |
| Backend | CodeGraph、Serena、RAG 等内部实现 | 用户级配置 |
| KnowledgeSource | 代码、项目文档或用户本地知识库 | 索引/配置生命周期 |
| Execution | 一次工具调用对应的执行上下文 | 单次调用 |
| WorkerJob | k3s 中的临时 Job/Pod | 创建至清理 |
| WorkspaceMount | Job 对统一 workspace PVC 的挂载 | Job 生命周期 |
| RepositoryLock | 仓库级写操作互斥锁 | 写操作生命周期 |
| NormalizedResult | 去除内部实现细节后的统一结果 | 返回调用方后释放 |

## 5. 子系统边界

### 5.1 MCP Tool Facade

**职责**

- 注册并暴露工作区服务、维护、代码和知识能力工具。
- 校验工具参数并生成内部请求。
- 将内部结果映射为稳定的 MCP 响应。
- 将 `knowledge_search` 的查询范围统一映射到代码、文档和本地知识源。

**不负责**

- 选择具体后端。
- 直接创建 Pod 或访问 PVC。
- 将 Kubernetes 对象暴露给调用方。

### 5.2 HTML/API Facade

**职责**

- 提供统一 HTML 工作区控制台所需的页面数据和操作 API。
- 展示工作区列表、文件、任务、状态、结果和用户可见错误。
- 与 MCP Facade 复用同一套能力服务和结果模型。

**不负责**

- 直接执行 Git 或 Kubernetes 操作。
- 暴露远程仓库 URL、SSH 私钥、PVC、Pod 或 Job 名称。

### 5.3 Workspace Context Resolver

**职责**

- 根据工作区标识定位 k3s 内部工作区。
- 读取并解析系统内部的源码、文档和知识范围配置。
- 校验范围只能位于工作区内部。
- 生成后端可用的内部路径。

**不负责**

- 读取或修改全局后端策略。
- 访问源码内容之外的集群资源。

### 5.4 Policy Resolver

**职责**

- 加载 `config.yaml`。
- 按工作区标识加载可选 overrides。
- 校验配置完整性、后端启用状态和能力映射。
- 输出本次执行使用的不可变策略快照。

**不负责**

- 解析用户请求中的后端字段；此类字段应被拒绝。
- 绕过资源、权限和安全限制。

### 5.5 Execution Orchestrator

**职责**

- 将高层能力转换为一次 `Execution`。
- 协调锁、并发配额、超时和取消。
- 调用 Job Orchestrator 和 Backend Adapter。
- 汇总状态并确保清理路径执行。

**不负责**

- 实现 CodeGraph、Serena 或 RAG 算法。
- 修改工作区配置。

### 5.6 Job Orchestrator

**职责**

- 根据统一模板生成 Job manifest。
- 注入镜像、源码路径、资源、环境变量、PVC 和 TTL。
- 通过 Kubernetes SDK 创建、观察、取消和删除 Job。
- 关联 Job、Pod、Execution 的可诊断标识。

**不负责**

- 决定能力路由。
- 直接向 codexcli 返回后端原始协议。

### 5.7 Workspace Manager

**职责**

- 在 k3s 内创建、更新、同步和切换工作区。
- 内部统一使用 Git 访问远程仓库。
- 支持 Codeup SSH 和 GitHub SSH，并通过本地 SSH agent 或受控凭据引用完成认证。
- 管理工作区状态、版本、冲突、锁和索引一致性。
- 将 Git 命令结果转换为用户可理解的工作区状态。

**不负责**

- 向用户暴露 Git 命令、Repo 对象、远程 URL、分支/commit 内部细节或私钥内容。
- 将 SSH 私钥写入持久化工作区。

### 5.8 Backend Adapter

**职责**

- 按后端类型建立 HTTP/SSE/MCP 通信。
- 将高层请求转换为后端请求。
- 解析后端响应并转换为内部结果。
- 抽象 CodeGraph、Serena、RAG 的协议差异。

**不负责**

- 维护项目级策略。
- 绕过 Gateway 的超时、锁和资源治理。

### 5.9 Guardrails

**职责**

- 路径越界防护。
- YAML/schema 和工具参数校验。
- 最大并发和仓库级写锁。
- 调用、连接、等待和清理超时。
- 敏感信息过滤、错误分类和审计日志。

**不负责**

- 以默认值吞掉配置错误。
- 将失败执行伪装为成功结果。

### 5.10 Service Runtime

**职责**

- 作为系统启动项拉起 Gateway 常驻进程。
- 提供 MCP 监听端点、存活检查和就绪检查。
- 处理配置加载失败、k3s 不可用和依赖不可用等启动状态。
- 在停止或升级时执行优雅退出，等待或取消活动执行并释放锁。
- 配合系统服务管理机制执行异常自动重启。

**不负责**

- 代替 Job Orchestrator 管理后端 Job 生命周期。
- 将系统服务配置写入项目仓库。

## 6. 端到端数据流

```text
1. 用户 / codexcli
   └─ HTML 操作或 MCP 工具名 + 工作区标识 + 业务参数

2. HTML/API Facade 或 MCP Tool Facade
   └─ 形成 CapabilityRequest

3. Workspace Manager / Project Context Resolver
   ├─ 定位 k3s 内部工作区
   ├─ 读取工作区配置
   └─ 解析源码和知识来源范围

4. Policy Resolver
   ├─ 读取 ~/.mcp-gateway/config.yaml
   ├─ 合并用户级项目 override
   └─ 解析 capability → backend，并解析知识来源范围

5. Guardrails / Execution Orchestrator
   ├─ 校验能力、路径、资源和权限
   ├─ 获取并发额度
   └─ 写操作获取 RepositoryLock

6. Workspace Manager / Job Orchestrator
   ├─ 使用内部 Git 同步或切换工作区
   ├─ 通过 Codeup/GitHub SSH 凭据引用访问远程源
   └─ 渲染并创建后端 Job

7. Backend Adapter
   ├─ 发现后端服务端点
   ├─ 通过 HTTP/SSE/MCP 调用
   └─ 获取原始分析或变更结果

8. Orchestrator
   ├─ 处理完成、失败、超时或取消
   ├─ 释放锁和并发额度
   └─ 确认 Job 清理

9. HTML/API Facade 或 Tool Facade
   └─ 返回用户可见结果或 NormalizedResult
```

### 6.1 常驻服务生命周期

```text
系统启动
  → Service Runtime 启动 Gateway
  → 加载并校验用户级配置
  → 检查 MCP 端点、k3s 和必要依赖
  → READY
  → 持续接收多个项目的 MCP 请求
  → STOPPING
  → 取消/等待活动执行、释放锁、退出进程
```

配置错误或关键依赖不可用时，服务应进入 `NOT_READY` 或启动失败状态，并通过健康检查和日志暴露原因；不得以不完整能力报告 `READY`。

## 7. 状态与错误边界

一次执行至少应区分以下状态：

```text
RECEIVED
  → VALIDATED
  → SCHEDULED
  → RUNNING
  → COLLECTING
  → SUCCEEDED
```

失败分支包括：

```text
RECEIVED   → REJECTED
VALIDATED  → POLICY_ERROR
SCHEDULED  → CREATE_FAILED
RUNNING    → BACKEND_FAILED
RUNNING    → TIMEOUT
COLLECTING → RESULT_INVALID
任意阶段   → CANCELLED
```

清理是所有终态的共同要求。Job 的 `ttlSecondsAfterFinished` 是集群侧兜底，Gateway 还必须对超时、取消和创建后失联执行主动清理。

## 8. 关键约束与安全设计

### 路径约束

- `source_root` 只能是相对路径。
- 规范化后必须位于工作区根目录下。
- Job 中使用的路径由 Gateway 计算，不能直接接受调用方提供的宿主机路径。

### 配置约束

- 全局配置和模板缺失、格式错误或字段非法时，启动或调用应明确失败。
- 项目文件出现后端、镜像或资源字段时，应拒绝未知/越权配置，而不是静默忽略。
- override 只能修改显式允许的策略字段。

### 资源约束

- 每个 Job 必须设置 CPU 和内存 requests/limits。
- 使用全局最大并发限制。
- 使用 TTL 和超时防止资源长期占用。

### 写入约束

- `code_refactor` 等写操作必须声明写能力。
- 同一仓库的写操作持有互斥锁。
- 锁需在失败、取消和进程异常路径中尽可能释放，并设置失效机制。

### 权限约束

- Gateway 使用最小 Kubernetes RBAC，仅访问所需 namespace、Job、Pod 和日志/状态资源。
- 后端 Pod 不应获得超出源码分析所需的集群权限。
- 日志和错误响应不得泄露 kubeconfig、令牌或完整敏感环境变量。

## 9. 部署与演进边界

### MVP

1. 提供 `workspace-pv/workspace-pvc`。
2. 在用户级 Skill 中提供全局配置和 Job 模板。
3. 将 Gateway 安装为 WSL/系统启动项，并提供健康检查和自动重启。
4. Gateway 常驻运行，先实现 CodeGraph 和 `code_architecture_analysis`。
5. 验证 codexcli → 常驻 Gateway → k3s Job → 后端 → 结果的完整链路。

### 后续演进

- 增加 Serena 符号查询和受锁保护的重构能力。
- 增加 RAG 语义搜索和索引生命周期管理。
- 将语义检索统一扩展为代码、项目文档和用户本地知识库的多来源检索。
- 为工具响应定义版本化 schema。
- 增加执行指标、审计记录和后端健康检查。
- 允许后端镜像升级而不改变工作区配置和高层工具契约。

## 10. 架构验收标准

- Gateway 对外提供统一 HTML 控制台和 MCP 服务接入配置。
- MCP 工具同时覆盖工作区服务、工作区维护、代码能力和知识检索。
- Gateway 服务随系统启动并持续运行，系统服务管理机制负责健康检查和异常恢复。
- 远程仓库在 k3s 内部统一由 Git 管理，支持 Codeup SSH 和 GitHub SSH。
- 用户只需配置本地 SSH key，系统不得要求提交或复制私钥到工作区。
- 用户不接触 Git 命令、Repo 对象、远程仓库内部路径或 k3s 对象。
- `knowledge_search` 能统一返回代码、文档和本地知识库命中，并保留来源类型。
- Job 模板、镜像、资源、TTL、RBAC 和并发策略不进入项目仓库。
- 数据流中每个执行都能关联项目、能力、后端、Job 和最终状态。
- 任何终态都触发锁释放、并发额度释放和资源清理。
- 底层后端替换不要求修改工作区配置或 codexcli 的工具调用。
