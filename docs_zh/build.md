# Build

Komodo 通过运行 `docker build` 并将构建结果推送到配置好的镜像仓库，来构建 Docker 镜像。

## Dockerfile 来源

Komodo 支持三种提供 Dockerfile 和构建上下文的方式：

1. **在 UI 中编写** —— 直接在 Komodo 中定义 Dockerfile 内容。支持变量和密钥插值。
2. **主机上的文件** —— 指向构建机器上已存在的 Dockerfile 和构建上下文。设置 `files_on_host = true` 并使用 `build_path` / `dockerfile_path` 指定路径。
3. **Git 仓库** —— 克隆包含 Dockerfile 的仓库。这是默认模式。配置 `repo`、`branch`，私有仓库还可选配置 `git_account`。

## 配置

```toml
[[build]]
name = "my-app"
[build.config]
builder = "builder-01"
repo = "myorg/my-app"
branch = "main"
git_account = "my-user"
image_registry = [
  { domain = "ghcr.io", account = "my-user", organization = "my-org" }
]
```

### 配置字段

| Field | Description | Default |
|---|---|---|
| `builder` | 运行构建的 Builder 资源。 | — |
| `version` | 当前构建版本（`major.minor.patch`）。 | `0.0.0` |
| `auto_increment_version` | 每次构建自动递增补丁号（patch）。 | `true` |
| `image_name` | 备用镜像名称（为空时使用构建名称）。 | `""` |
| `image_tag` | 额外的标签后缀，例如 `aarch64` → `:1.2.3-aarch64`。 | `""` |
| `include_latest_tag` | 推送 `:latest` / `:latest-{image_tag}` 标签。 | `true` |
| `include_version_tags` | 推送 semver 标签（`:1.2.3`，`:1.2`，`:1`）。 | `true` |
| `include_commit_tag` | 推送提交哈希标签（`:a6v8h83`）。 | `true` |
| `linked_repo` | 用于获取文件的 Komodo Repo 资源。 | `""` |
| `git_provider` | Git 提供商域名。 | `github.com` |
| `git_https` | 使用 HTTPS 克隆（相对于 HTTP）。 | `true` |
| `git_account` | 用于私有仓库的 Git 提供商账户。 | `""` |
| `repo` | `owner/repo` 格式的仓库。 | `""` |
| `branch` | 要克隆的分支。Webhook 仅在该分支收到推送时触发。 | `main` |
| `commit` | 固定到特定提交哈希。 | `""` |
| `files_on_host` | 从构建机器上已有的文件获取 Dockerfile 和构建上下文。 | `false` |
| `dockerfile` | UI 中定义的 Dockerfile 内容。支持变量 / 密钥插值。 | `""` |
| `build_path` | 构建上下文目录，相对于仓库根目录（当 `files_on_host` 时则为绝对路径）。 | `.` |
| `dockerfile_path` | Dockerfile 路径，相对于构建目录。 | `Dockerfile` |
| `image_registry` | 推送镜像的目标仓库（域名 + 账户 + 可选组织）。 | `[]` |
| `build_args` | `KEY=value` 格式的构建参数。在 `docker history` 中可见。 | `""` |
| `secret_args` | `KEY=value` 格式的构建密钥。通过 `RUN --mount=type=secret,id=KEY` 访问。在镜像历史中不可见。 | `""` |
| `skip_secret_interp` | 跳过 build_args 中的密钥插值。 | `false` |
| `extra_args` | 传递给 `docker build` 的额外标志。 | `[]` |
| `use_buildx` | 使用 `docker buildx build` 代替 `docker build`。 | `false` |
| `pre_build` | 克隆之后、运行 `docker build` 之前执行的命令。 | — |
| `labels` | `key=value` 格式的 Docker 标签。 | `""` |
| `webhook_enabled` | 是否允许入站 webhook 触发构建。 | `true` |
| `webhook_secret` | 备用 webhook 密钥（为空时使用配置中的默认值）。 | `""` |
| `links` | 资源头部显示的快捷链接。 | `[]` |

## 镜像版本与标签

Komodo 使用 `major.minor.patch` 版本号方案。默认情况下，每次构建会自动递增补丁号。你可以通过以下选项精确控制推送哪些标签：

### 标签类型

| Option | Tags produced | Example |
|---|---|---|
| `include_version_tags` | 完整的 semver、次版本、主版本 | `:1.2.3`，`:1.2`，`:1` |
| `include_latest_tag` | 最新标签 | `:latest` |
| `include_commit_tag` | 简短提交哈希 | `:a6v8h83` |

默认情况下三者全部启用。禁用任意组合可以控制推送哪些标签。

### 镜像标签后缀

`image_tag` 字段会为所有生成的标签附加一个后缀。这对于多平台或变体构建很有用：

| `image_tag` | Version tag | Latest tag | Commit tag |
|---|---|---|---|
| _(空)_ | `:1.2.3` | `:latest` | `:a6v8h83` |
| `aarch64` | `:1.2.3-aarch64` | `:latest-aarch64` | `:a6v8h83-aarch64` |

当设置了 `image_tag` 时，还会额外推送一个纯标签：`:aarch64`。

### 自定义镜像名称

默认使用构建的名称作为镜像名称。设置 `image_name` 可以覆盖此行为，例如当构建名称与镜像仓库上期望的镜像名称不一致时。

### 手动版本管理

设置 `auto_increment_version = false` 来自己管理 `version` 字段。主版本和次版本始终手动设置 —— 只有补丁号会自动递增。

## 镜像仓库

Komodo 支持推送到任何 Docker 兼容的镜像仓库。在 [Providers](configuration/providers.md) 中配置账户。

一个构建可以**同时推送到多个镜像仓库**。`image_registry` 字段接受一个列表 —— 每个条目指定一个域名、账户和可选的组织：

```toml
[build.config]
image_registry = [
  { domain = "ghcr.io", account = "my-user", organization = "my-org" },
  { domain = "docker.io", account = "my-user" },
]
```

当部署（Deployment）连接到构建（Build）时，默认使用列表中的第一个镜像仓库。

:::note
GitHub 访问令牌必须具有 `write:packages` 权限才能推送到 GHCR。
参见 [GitHub 文档](https://docs.github.com/en/packages/working-with-a-github-packages-registry/working-with-the-container-registry#authenticating-with-a-personal-access-token-classic)。
:::

当构建（Build）连接到部署（Deployment）时，部署默认会继承构建的镜像仓库凭据。如果构建器的账户对部署所在的服务器不可用，请在部署配置中选择另一个账户。


## 多平台构建（Buildx）

要构建多个平台（例如 ARM + x86），请在构建器上设置 Docker Buildx：

```sh
docker buildx create --name builder --use --bootstrap
docker buildx install   # 使 buildx 成为 `docker build` 的默认
```

然后在构建的 **Extra Args（额外参数）** 中传入目标平台：

```
--platform linux/amd64,linux/arm64
```

## 构建器（Builders）

`Builder` 资源定义了构建运行在**哪里**。任何连接到 Komodo 的服务器都可以用作构建器，但不建议在生产服务器上构建。

### 服务器构建器

将构建器指向一个已安装 Periphery 的现有服务器。

### AWS EC2 构建器

Komodo 可以为每次构建启动一个临时的 EC2 实例，并在完成后关闭它。

```toml
[[builder]]
name = "builder-01"
[builder.config]
type = "Aws"
params.region = "us-east-2"
params.instance_type = "c5.2xlarge"
params.ami_id = "ami-xxxxxxxxxxxxxxxxxx"
params.subnet_id = "subnet-xxxxxxxxxxxxxxxxxx"
params.key_pair_name = "ssh-key"
params.assign_public_ip = true ## 除非你有网络网关，否则需要公网出口访问
params.use_public_ip = true ## 设为 'false' 则使用私有 IP（当 Komodo Core 在同一子网时）
params.security_group_ids = ["sg-xxxxxxxxxxxxxxxxxx"]
params.user_data = """
#!/bin/bash
curl -sSL \
   https://raw.githubusercontent.com/moghtech/komodo/main/scripts/setup-periphery.py | \
  HOME=/root python3 - --version=v2.X.X
"""
```

创建 AMI：

1. 启动一个 EC2 实例并安装 Docker：
   ```shell
   apt update && apt upgrade -y
   curl -fsSL https://get.docker.com | sh
   systemctl enable docker.service containerd.service
   ```
2. 在 AWS 控制台中从该实例创建 AMI。
3. 创建安全组，并确保允许来自 Komodo Core 的 **8120** 端口入站访问。

实例的 `user_data` 会在实例启动时安装 Periphery 代理，随后 Komodo Core 将连接并构建镜像。
