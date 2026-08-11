# Providers

Providers（提供商）允许 Komodo 代表你的资源，对外部 git 提供商和 docker 镜像仓库进行身份认证。配置完成后，提供商账户即可附加到构建（Builds）、仓库（Repos）、堆栈（Stacks）和资源同步（Resource Syncs）上。

### 用途

在配置引用了私有仓库的构建、仓库、堆栈或资源同步时，在该资源的配置中选择匹配的 git 提供商和账户。Komodo 将使用该令牌进行克隆的身份认证。

## 在 UI 中管理 Providers

最简单的配置方式是通过 Komodo UI。进入 **Settings > Providers（设置 > 提供商）** 来管理你的 git 和镜像仓库账户。在此页面你可以：

- **添加** 新的 git 提供商或 docker 镜像仓库账户（域名、用户名和访问令牌）。
- **查看** 通过 UI 添加的账户，以及从配置文件加载的账户。
- **编辑或删除** 由数据库管理的账户。

## 通过配置文件进行配置

作为 UI 的替代方案，也可以在配置文件中定义提供商：

- **Core 配置**（`core.config.toml`）：账户对所有资源全局可用。参见 [高级配置](../setup/advanced.mdx#mount-a-config-file)。
- **Periphery 配置**（`periphery.config.toml`）：账户仅对运行在该特定服务器上的资源可用。参见 [连接服务器](../setup/connect-servers.mdx)。

配置文件中定义的账户也会出现在 UI 的 **Settings > Providers** 下，但其令牌无法通过 API 或 UI 读回。

## Git Providers

Komodo 支持通过 HTTP/S 从任何支持以下方式的提供商克隆仓库：

```shell
git clone https://<Username>:<Token>@<domain>/<Owner>/<Repo>
```

或

```shell
git clone https://<Token>@<domain>/<Owner>/<Repo>
```

这包括 GitHub、GitLab、[Bitbucket](https://github.com/moghtech/komodo/issues/387#issuecomment-3240726344)、Forgejo、Gitea，以及许多其他 git 提供商。

### 字段

| Field | Default | Description |
|-------|---------|-------------|
| `domain` | `github.com` | git 提供商的 hostname（主机名）。不要包含协议（`http://` 或 `https://`）。 |
| `https` | `true` | 是否通过 HTTPS 克隆。设为 `false` 表示使用 HTTP（例如本地开发）。 |
| `accounts` | `[]` | 一组 `{ username, token }` 对。每个账户都可访问该用户可见的仓库。 |

### 配置

```toml
# in core.config.toml or periphery.config.toml

[[git_provider]]
domain = "github.com"
accounts = [
  { username = "my-user", token = "ghp_xxxxxxxxxxxx" },
]

[[git_provider]]
domain = "git.example.com" # 自托管的 Gitea、GitLab 等
accounts = [
  { username = "my-user", token = "access_token" },
]

[[git_provider]]
domain = "localhost:3000"
https = false # 通过 http:// 克隆
accounts = [
  { username = "my-user", token = "access_token" },
]
```

## Docker Registries

Komodo 支持从任何 Docker 兼容的镜像仓库推送和拉取镜像，包括 Docker Hub、GitHub Container Registry（GHCR）以及自托管镜像仓库。

### 字段

| Field | Default | Description |
|-------|---------|-------------|
| `domain` | `docker.io` | 镜像仓库的 hostname。对于不安全的镜像仓库可以包含 `http://`，但这需要在你的主机上启用 [insecure registries](https://docs.docker.com/reference/cli/dockerd/#insecure-registries)。 |
| `accounts` | `[]` | 用于镜像仓库认证的 `{ username, token }` 对列表。 |
| `organizations` | `[]` | 可选的组织 / 命名空间名称列表。当附加到构建时，镜像将发布在该组织的命名空间下，而不是账户名下。 |

### 配置

```toml
# in core.config.toml or periphery.config.toml

[[image_registry]]
domain = "docker.io"
accounts = [
  { username = "my-user", token = "dckr_pat_xxxxxxxxxxxx" },
]
organizations = ["MyOrg"]

[[image_registry]]
domain = "ghcr.io"
accounts = [
  { username = "my-user", token = "ghp_xxxxxxxxxxxx" },
]

[[image_registry]]
domain = "registry.example.com" # 自托管镜像仓库
accounts = [
  { username = "my-user", token = "access_token" },
]
organizations = ["MyTeam"]
```

:::note
你的 GitHub 访问令牌必须具有 `write:packages` 权限才能推送镜像。
例如，参见 [GitHub 关于访问令牌的文档](https://docs.github.com/en/packages/working-with-a-github-packages-registry/working-with-the-container-registry#authenticating-with-a-personal-access-token-classic)。
:::

### 用途

在配置构建时，选择要推送镜像的镜像仓库域名和账户。如果定义了组织，你可以选择发布到组织的命名空间下。

当构建（Build）连接到部署（Deployment）时，部署默认会继承该镜像仓库配置。如果该账户对部署所在的服务器不可用，你可以在部署配置中选择另一个账户。
