# 配置

Komodo 只需要一些信息就可以构建您的镜像。

### 提供商配置
Komodo 支持通过 http/s 克隆仓库，支持任何使用 `git clone https://<Token>@git-provider.net/<Owner>/<Repo>` 克隆私有仓库的提供商。

可以在[核心配置](../../setup/advanced.mdx#mount-a-config-file)或[外围配置](../../setup/connect-servers.mdx#manual-install-steps---binaries)中配置帐户/访问令牌。

### 仓库配置
要指定要构建的 git 仓库，只需在*仓库配置*下提供仓库名称和分支。名称的格式为 `moghtech/komodo`，它包括拥有该仓库的用户名/组织。

许多仓库是私有的，在这种情况下，构建服务器需要访问令牌。
它可以来自核心配置中定义的提供商，
也可以来自构建服务器的外围配置。

### Docker 构建配置

为了进行 docker 构建，Komodo 只需要知道构建目录和 Dockerfile 相对于仓库的路径，您可以在*构建配置*部分中配置这些。

如果构建目录是存储库的根目录，则将构建路径传递为“.”。如果构建目录是仓库的某个文件夹，只需传递该文件夹的名称即可。不要传递前面的“/”。例如`build/directory`

dockerfile 的路径是相对于构建目录给出的。因此，如果您的构建目录是 `build/directory` 并且 dockerfile 位于 `build/directory/Dockerfile.example` 中，则只需将 dockerfile 路径指定为 `Dockerfile.example`。

### 镜像注册表

Komodo 支持推送到任何 docker 注册表。
在核心配置和构建器之间为特定注册表指定的任何帐户都将可用于针对该注册表进行身份验证。
此外，可以在核心配置上指定 docker 注册表上允许的组织并将其附加到构建中。
这样做将导致镜像在组织的命名空间下发布，而不是在帐户的命名空间下发布。

将构建连接到部署时，默认行为是让部署继承构建中的注册表配置。
如果该帐户在部署中不可用，则可以在部署配置中选择另一个可用帐户。

:::note
为了发布到 Github 容器注册表，您的 Github 访问令牌必须被授予 `write:packages` 权限。
请参阅此处的 Github 文档 [here](https://docs.github.com/en/packages/working-with-a-github-packages-registry/working-with-the-container-registry#authenticating-with-a-personal-access-token-classic)。
:::

### 添加构建参数

Dockerfile 可能会使用[构建参数](https://docs.docker.com/engine/reference/builder/#arg)。可以通过导航到配置中的“构建参数”选项卡，使用 gui 传递构建参数。它们在菜单中的传递方式与在 .env 文件中的传递方式相同：

```
BUILD_ARG1=some_value
BUILD_ARG2=some_other_value
```

请注意，这些值在使用 `docker history` 的最终镜像中是可见的，因此不应用于传递构建时秘密。请改用[秘密挂载](https://docs.docker.com/engine/reference/builder/#run---mounttypesecret)。

### 添加构建秘密

Dockerfile 也可能使用[构建秘密](https://docs.docker.com/build/building/secrets)。

它们在 GUI 中的配置方式与构建参数相同。此处传递的值可用于 Dockerfile 中的 RUN 命令：
```
RUN --mount=type=secret,id=SECRET_KEY \
  SECRET_KEY=$(cat /run/secrets/SECRET_KEY) ...
```

使用 `docker history` 命令将看不到这些值。