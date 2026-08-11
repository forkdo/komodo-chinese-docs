---
slug: /intro
---

# Komodo 是什么？

Komodo 是一个用于管理服务器、构建、部署和自动化程序的 Web 应用程序。

- **连接服务器**。监控 CPU、内存和磁盘使用情况并发出警报。连接到 shell 会话。
- **部署容器**。创建、启动、停止和重新部署 Docker 容器。查看状态、日志并 exec 进入 shell。
- **部署 compose 堆栈**。在 UI 中、主机上或 git 仓库中定义 compose 文件，并在 push 时自动部署。
- **管理 Docker Swarms**。连接 swarm 管理器，并在集群中部署服务与堆栈。
- **构建镜像**。在 UI 中定义 dockerfile 或克隆 git 仓库。支持使用 AWS EC2 spot 实例实现可扩展的构建能力。
- **运行自动化**。使用过程和操编排多步骤工作流。定期调度自动化运行。
- **管理配置**。通过插值在所有资源间共享的变量和密钥。
- **完整的审计追踪**。记录每一次变更，包括由谁在何时执行。

您可以连接的服务器数量没有限制，将来也永远不会有限制。

## 架构

Komodo 由两个组件组成：**Core** 和 **Periphery**。

| 组件 | 角色 |
|---|---|
| **Core** | 托管 API 和浏览器 UI 的 Web 服务器。所有用户交互都流经 Core。 |
| **Periphery** | 在每个已连接服务器上运行的小型无状态代理。由 Core 调用以执行操作、报告系统使用情况并检索容器日志。 |

## API

Core 暴露用于编程访问的 REST 和 WebSocket API。可用的客户端库包括：

- [**Komodo CLI**](./ecosystem/cli.mdx)
- [**Rust crate**](https://crates.io/crates/komodo_client)
- [**NPM 包**](https://www.npmjs.com/package/komodo_client)
- [**curl 示例**](https://docs.rs/komodo_client/latest/komodo_client/api/index.html#curl-example)

## 权限

Komodo 具有细粒度的、基于角色的权限系统，使开发人员、运维人员和管理员团队能够安全地协作。详见 [权限](/docs/configuration/permissioning)。

用户登录支持 **用户名/密码** 和 **OAuth（GitHub、Google 以及通用 OIDC）**。请参阅 [核心设置](./setup/index.mdx)。

## Docker

Komodo 使用 [Docker](https://docs.docker.com/) 作为构建和部署的容器引擎。

:::info
[Podman](https://podman.io/) 也受支持，通过 `podman` → `docker` 别名实现。
:::
