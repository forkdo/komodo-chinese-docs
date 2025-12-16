---
slug: /intro
---

# Komodo 是什么？

Komodo 是一个 Web 应用程序，为管理您的服务器、构建、部署和自动化程序提供结构。

通过 Komodo 您可以：

 - 连接所有服务器，对 CPU 使用率、内存使用率和磁盘使用率进行警报，并连接到 shell 会话。
 - 在连接的服务器上创建、启动、停止和重启 Docker 容器，查看其状态和日志，并连接到容器 shell。
 - 部署 docker compose 堆栈。文件可以在 UI 中定义，也可以在 git 仓库中定义，并通过 git push 自动部署。
 - 将应用程序源代码构建为自动版本化的 Docker 镜像，通过 webhook 自动构建。部署一次性使用的 AWS 实例以实现无限容量。
 - 管理连接服务器上的存储库，这些存储库可以通过脚本/webhook 执行自动化。
 - 管理所有配置/环境变量，具有共享的全局变量和秘密插值。
 - 记录所有执行的操作以及执行者。

您可以连接的服务器数量没有限制，也永远不会有。您可以用于自动化的 API 数量没有限制，也永远不会有。这里没有“商业版”。

## Docker

Komodo 在设计上是有主见的，并使用 [docker](https://docs.docker.com/) 作为构建和部署的容器引擎。

:::info
Komodo 还支持 [**podman**](https://podman.io/) 来替代 docker，方法是利用 `podman` -> `docker` 别名。
对于 podman 的堆栈/docker compose 支持，请查看 [**podman-compose**](https://github.com/containers/podman-compose)。感谢 `u/pup_kit` 对此进行检查。
:::

## 架构和组件

Komodo 由一个核心和任意数量运行外围应用程序的连接服务器组成。

### 核心
Komodo Core 是一个托管核心 API 和浏览器 UI 的 Web 服务器。所有与连接服务器的用户交互都通过核心进行。

### 外围
Komodo Periphery 是一个在所有连接服务器上运行的小型无状态 Web 服务器。它公开一个由 Komodo Core 调用的 API，用于在服务器上执行操作、获取系统使用情况以及容器状态/日志。它仅应从核心访问，并具有地址白名单以限制允许调用此 API 的 IP。

## 核心 API

Komodo 通过核心的 REST 和 Websocket API 公开强大的功能，使基础架构工程师能够以编程方式管理其基础架构。有一个 [rust crate](https://crates.io/crates/komodo_client) 和 [npm package](https://www.npmjs.com/package/komodo_client) 可以简化与 API 的编程交互，但通常可以使用任何可以发出 REST 请求的编程语言来完成。

## 权限

Komodo 是一个旨在供许多用户使用的系统，无论是开发人员、运维人员还是管理员。影响应用程序状态的能力非常强大，因此 Komodo 有一个精细的权限系统，只向预期的用户提供此功能。权限系统在[权限](/docs/resources/permissioning)部分有详细说明。

用户可以使用用户名/密码或 Oauth（Github 和 Google）登录。请参阅[核心设置](./setup/index.mdx)。