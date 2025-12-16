# 资源

Komodo 可通过 **资源** 抽象进行扩展。像 `Server`、`Deployment` 和 `Stack` 这样的实体都是 **Komodo 资源**。

所有资源都具有共同的特征，例如在同一资源类型的所有其他资源中具有唯一的 `name` 和 `id`。
所有资源都可以分配 `tags`，用于对相关资源进行分组。

:::note
许多资源需要访问 git 仓库/docker 注册中心。有一个内置的令牌管理系统（在 UI 或配置文件中管理），用于为资源提供访问凭据。
所有依赖于 git 仓库/docker 注册中心的资源都能够使用这些凭据访问私有仓库。
:::

## [服务器](../setup/connect-servers.mdx)

- 配置与外围代理的连接。
- 设置警报阈值。
- 可由 **部署**、**堆栈**、**仓库** 和 **构建器** 附加。

## [部署](./deploy-containers/index.mdx)

- 在附加的服务器上部署 docker 容器。
- 在容器级别管理服务，使用 **过程** 和 **资源同步** 执行编排。

## [堆栈](./docker-compose.md)

- 使用 docker compose 部署。
- 在 UI 中提供 compose 文件，或将文件移动到 git 仓库并使用 webhook 在推送时自动重新部署。
- 支持使用 `docker compose -f ... -f ...` 组合多个 compose 文件。
- 传递可在 compose 文件中使用的环境变量。在应用范围的变量/秘密中进行插值。

## 仓库

- 将脚本放入 git 仓库，并在服务器上或使用构建器运行它们。
- 可以构建二进制文件、执行自动化，基本上您可以想到的任何事情。

## [构建](./build-images/index.mdx)

- 将应用程序源代码构建到 docker 映像中，并将其推送到配置的注册表。
- 源代码可以是任何包含 Dockerfile 的 git 仓库。

## [构建器](./build-images/builders.md)

- 指向连接的服务器，或保存用于启动一次性 AWS 实例以构建映像的配置。
- 可附加到 **构建** 和 **仓库**。

## [过程](./procedures.md#procedures)

- 在其他资源类型上组合许多操作，例如 `RunBuild` 或 `DeployStack`，并通过按钮按下（或使用 webhook）运行它。
- 可以在并行的“阶段”中运行一个或多个操作，并组合一系列并行阶段以顺序运行。

## [操作](./procedures.md#actions)

- 在 Typescript 中编写调用 Komodo API 的脚本
- 在脚本中使用预初始化的 Komodo 客户端，无需 api 密钥。
- UI 编辑器中的类型感知。在您键入时获取建议并查看深度文档。
- Typescript 客户端也[发布在 NPM 上](https://www.npmjs.com/package/komodo_client)。

## [资源同步](./sync-resources.md)

- 通过在 `toml` 文件中声明性地定义所有配置来编排所有配置，这些文件被检入 git 仓库。
- 如果建议更改，可以部署 **部署** 和 **堆栈**。
- 使用 `after` 数组指定部署顺序。（类似于 docker compose `depends_on`，但可以跨服务器。）

## 警报器

- 将警报路由到各个端点。
- 可以在每个警报器上配置规则，例如资源白名单、黑名单或警报类型过滤器。