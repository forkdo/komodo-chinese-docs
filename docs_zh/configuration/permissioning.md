# 权限

Komodo 有一个精细的、基于层的权限系统，只为非管理员用户提供对预期资源的访问权限。

## 用户组

虽然 Komodo 可以直接向特定用户分配权限，但建议 **创建用户组并向其分配权限**，就像它们是一个用户一样。

然后可以将用户 **添加到多个用户组**，他们将 **继承该组的权限**，类似于 linux 权限。
用户组还有一个 `Everyone` 模式，如果启用此模式，则 **所有用户都隐式获得该组的权限**。

对于大规模权限管理，用户可以在[**资源同步中定义用户组**](/docs/automate/sync-resources#user-group)。

## 权限级别

用户/组可以在资源上获得 4 个权限级别：

 1. **无**。用户将无法访问该资源。用户 **不会在 GUI 中看到它，如果用户直接查询 Komodo API，它也不会显示**。所有查看或更新资源的尝试都将被阻止。这是非管理员的默认设置，除非使用 `KOMODO_TRANSPARENT_MODE=true`。

 2. **读取**。这是授予任何访问权限的第一个权限级别。它将使用户能够 **在 GUI 中查看资源并读取配置**。任何更新配置或触发任何操作的尝试都 **将被阻止**。使用 `KOMODO_TRANSPARENT_MODE=true` 将使此级别成为所有资源上所有用户的基本级别。

 3. **执行**。此级别将允许用户对资源执行操作，**例如发送构建命令** 或 **触发重新部署**。用户仍将被阻止更新资源上的配置。

 4. **写入**。用户拥有对资源的完全配置写入权限，**他们可以执行任何操作、更新配置和删除资源**。

## 特定权限

仅靠权限级别不足以提供精细的访问控制。
某些功能还受到该功能的特定权限的限制。

- **`Logs`**：用户可以在关联的资源上检索 docker/docker compose 日志。
  - 在 `Server`、`Stack`、`Deployment` 上有效。
  - 对于希望默认情况下所有具有读取权限的用户都拥有此权限的管理员，请参阅下面关于默认用户组的部分。
- **`Inspect`**：用户可以“检查”docker 容器。
  - 在 `Server`、`Stack`、`Deployment` 上有效。
  - **在服务器上**：对此 api 的访问将暴露给定服务器上的所有容器环境，
  如果不加以保护，很容易导致秘密泄露给非预期用户。
- **`Terminal`**：用户可以访问关联资源的终端。
  - 如果在 `Server` 上授予，则允许服务器级终端访问和所有容器执行权限（包括附加的 `Stacks`/`Deployments`）。
  - 如果在 `Stack` 或 `Deployment` 上授予，则允许容器执行终端（即使在 `Server` 上没有 `Terminal` 权限）。
- **`Attach`**：用户可以将*其他资源*“附加”到该资源。
  - 如果在 `Server` 上授予，则允许用户附加 `Stacks`、`Deployments`、`Repos` 和 `Builders`。
  - 如果在 `Builder` 上授予，则允许用户附加 `Builds` 和 `Repos`。
  - 如果在 `Build` 上授予，则允许用户将其附加到 `Deployments`。
  - 如果在 `Repo` 上授予，则允许用户将其附加到 `Stacks`、`Builds` 和 `Resource Syncs`。
- **`Processes`**：用户可以在 `Server` 上检索完整的正在运行的进程列表。

## 按资源类型进行权限管理

可以为用户或用户组授予特定类型的所有资源（例如堆栈）的基本权限级别。
在 TOML 表单中，这看起来像：

```toml
[[user_group]]
name = "groupo"
users = ["mbecker20", "karamvirsingh98"]
all.Build = "Execute" # <- 组成员可以运行所有构建（但不能更新配置），
all.Stack = { level = "Read", specific = ["Logs"] }    # <- 并查看所有堆栈/日志（无部署/更新、检查或终端访问）。
```

用户/组仍然可以在选定的资源上获得更高的权限级别：

```toml
permissions = [
  # 授予额外的特定权限（上面已经授予了日志）
  { target.type = "Stack", target.id = "my-stack", level = "Execute", specific = ["Inspect", "Terminal"] },
  # 使用正则表达式匹配多个资源，例如，为 john 的所有堆栈授予执行权限
  { target.type = "Stack", target.id = "\\^john-(.+)$$\", level = "Execute" },
]
```

## 管理

用户可以由“超级管理员”授予管理员权限（只有第一个用户被授予此状态，在数据库的用户文档中设置 `super_admin: true`）。超级管理员将在用户页面 `/users/${user_id}` 上看到“设为管理员”按钮。

这些用户对所有 Komodo 资源具有不受限制的访问权限。此外，这些用户可以更新其他（非管理员）用户对资源的权限。

Komodo 管理员还负责管理用户帐户。当用户首次登录 Komodo 时，他们不会立即被授予访问权限（这可以使用 `KOMODO_ENABLE_NEW_USERS=true` 进行更改）。管理员必须首先 **启用** 该用户，这可以从 `Settings` 页面的 `Users` 选项卡完成。用户也可以随时被管理员 **禁用**，这将阻止他们对 GUI 和 API 的所有访问。

用户还具有一些可配置的全局权限，这些是：

 - 创建服务器权限
 - 创建构建权限

只有具有这些权限的用户（以及管理员）才能向 Komodo 添加其他服务器，并分别创建其他构建。

---
*This document has not been translated yet.*