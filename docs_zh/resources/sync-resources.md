# 同步资源

Komodo 能够通过将 TOML 文件中声明的资源与现有资源进行比较，来创建、更新、删除和部署这些资源，
并根据差异应用更新。与堆栈类似，这些文件可以在 UI、本地文件或推送到远程 git 仓库的文件中进行配置。
Komodo Core 后端将轮询文件以获取任何更新，并在检测到差异时提醒待处理的更改。

您可以将资源声明分散在任意数量的文件中，
并使用任何嵌套的文件夹来组织根文件夹内的资源。
此外，您可以创建多个 `ResourceSyncs` 并配置 `Match Tags` 以筛选要同步的资源，
每个同步都将独立处理。这允许不同的同步按“每个项目”的基础管理资源。

UI 将显示计算出的同步操作，并且仅在手动确认后才执行它们。
或者可以在 git 仓库上配置同步执行 git webhook
以在推送到配置的分支时自动执行同步。

## 提交到同步

如果同步指向单个文件，您可以启用“托管模式”以允许 Core 将您在 UI 中所做的更新写回*文件*。
无论文件位于何处，此方法都有效，并将为基于仓库的文件创建对您的 git 仓库的提交。

## 示例声明

### 服务器

- [服务器配置模式](https://docs.rs/komodo_client/latest/komodo_client/entities/server/struct.ServerConfig.html)

```toml
[[server]] # 声明一个新服务器
name = "server-prod"
description = "生产服务器"
tags = ["prod"]
[server.config]
address = "http://localhost:8120"
region = "AshburnDc1"
enabled = true # 默认值：false
```

### 构建器和构建

- [构建器配置模式](https://docs.rs/komodo_client/latest/komodo_client/entities/builder/enum.BuilderConfig.html)
- [构建配置模式](https://docs.rs/komodo_client/latest/komodo_client/entities/build/struct.BuildConfig.html)

```toml
[[builder]] # 声明一个构建器
name = "builder-01"
tags = []
config.type = "Aws"
[builder.config.params]
region = "us-east-2"
ami_id = "ami-0e9bd154667944680"
# 这些东西来自您的特定设置
subnet_id = "subnet-xxxxxxxxxxxxxxxxxx"
key_pair_name = "xxxxxxxx"
assign_public_ip = true
use_public_ip = true
security_group_ids = [
  "sg-xxxxxxxxxxxxxxxxxx",
  "sg-xxxxxxxxxxxxxxxxxx"
]

##

[[build]]
name = "test_logger"
description = "在 INFO、WARN、ERROR 级别随机记录日志以测试日志记录设置"
tags = ["test"]
[build.config]
builder_id = "builder-01"
repo = "mbecker20/test_logger"
branch = "master"
git_account = "mbecker20"
image_registry.type = "Standard"
image_registry.params.domain = "github.com" # 或您的自定义域
image_registry.params.account = "your_username"
image_registry.params.organization = "your_organization" # 可选
# 设置 docker 标签
labels = """
org.opencontainers.image.source = https://github.com/mbecker20/test_logger
org.opencontainers.image.description = 在 INFO、WARN、ERROR 级别随机记录日志以测试日志记录设置
org.opencontainers.image.licenses = GPL-3.0
"""
```

### 部署

- [部署配置模式](https://docs.rs/komodo_client/latest/komodo_client/entities/deployment/struct.DeploymentConfig.html)

```toml
# 声明变量
[[variable]]
name = "OTLP_ENDPOINT"
value = "http://localhost:4317"

##

[[deployment]] # 声明一个部署
name = "test-logger-01"
description = "测试记录器部署 1"
tags = ["test"]
# sync 将部署容器：
#  - 如果它没有运行。
#  - 具有相关的配置更新。
#  - 附加的构建具有新版本。
deploy = true
[deployment.config]
server_id = "server-01"
image.type = "Build"
image.params.build = "test_logger"
# 设置卷/绑定挂载
volumes = """
# 支持注释
/data/logs = /etc/logs
# 以及其他格式（例如 yaml 列表）
- "/data/config:/etc/config"
"""
# 设置环境变量
environment = """
# 支持注释
OTLP_ENDPOINT = [[OTLP_ENDPOINT]] # 将变量插入到环境中。
VARIABLE_1 = value_1
VARIABLE_2 = value_2
"""
# 设置 Docker 标签
labels = "deployment.type = logger"

##

[[deployment]]
name = "test-logger-02"
description = "测试记录器部署 2"
tags = ["test"]
deploy = true
# 创建对 test-logger-01 的依赖。此部署仅在部署 test-logger-01 后才会部署。
# 此外，test-logger-01 的任何同步部署也将触发此部署的同步部署。
after = ["test-logger-01"]
[deployment.config]
server_id = "server-01"
image.type = "Build"
image.params.build = "test_logger"
volumes = """
/data/logs = /etc/logs
/data/config = /etc/config"""
environment = """
VARIABLE_1 = value_1
VARIABLE_2 = value_2
"""
# 设置 Docker 标签
labels = "deployment.type = logger"
```

### 堆栈

- [堆栈配置模式](https://docs.rs/komodo_client/latest/komodo_client/entities/stack/struct.StackConfig.html)

```toml
[[stack]]
name = "test-stack"
description = "堆栈测试"
deploy = true
after = ["test-logger-01"] # 堆栈可以依赖于部署，反之亦然。
tags = ["test"]
[stack.config]
server_id = "server-prod"
file_paths = ["mongo.yaml", "redis.yaml"]
git_provider = "git.mogh.tech"
git_account = "mbecker20" # 通过指定帐户克隆私有仓库
repo = "mbecker20/stack_test"
```

### 过程

- [过程配置模式](https://docs.rs/komodo_client/latest/komodo_client/entities/procedure/struct.ProcedureConfig.html)

```toml
[[procedure]]
name = "test-procedure"
description = "按特定顺序执行某些操作"
tags = ["test"]

[[procedure.config.stage]]
name = "构建东西"
executions = [
  { execution.type = "RunBuild", execution.params.build = "test_logger" },
  # 使用批处理版本，它通过模式匹配许多构建
  # 这个匹配所有以 `foo-`（通配符）和 `bar-`（正则表达式）为前缀的构建。
  { execution.type = "BatchRunBuild", execution.params.pattern = "foo-* , \\^bar-.*$\" },
  { execution.type = "PullRepo", execution.params.repo = "komodo-periphery" },
]

[[procedure.config.stage]]
name = "部署测试记录器 1"
executions = [
  { execution.type = "Deploy", execution.params.deployment = "test-logger-01" },
  { execution.type = "Deploy", execution.params.deployment = "test-logger-03", enabled = false },
]

[[procedure.config.stage]]
name = "部署测试记录器 2"
enabled = false
executions = [
  { execution.type = "Deploy", execution.params.deployment = "test-logger-02" }
]
```

### 仓库

- [仓库配置模式](https://docs.rs/komodo_client/latest/komodo_client/entities/repo/struct.RepoConfig.html)

```toml
[[repo]]
name = "komodo-periphery"
description = "构建外围二进制文件的新版本。需要在主机上安装 Rust。"
tags = ["komodo"]
[repo.config]
server_id = "server-01"
git_provider = "git.mogh.tech" # 使用备用 git 提供程序（默认为 github.com）
git_account = "mbecker20"
repo = "moghtech/komodo"
# 在拉取仓库后运行一个操作
on_pull.path = "."
on_pull.command = """
# 支持注释
/root/.cargo/bin/cargo build -p komodo_periphery --release
# 多行将使用 '&&' 组合在一起
cp ./target/release/periphery /root/periphery
"""
```

### 资源同步

- [资源同步配置模式](https://docs.rs/komodo_client/latest/komodo_client/entities/sync/type.ResourceSync.html)

```toml
[[resource_sync]]
name = "resource-sync"
[resource_sync.config]
git_provider = "git.mogh.tech" # 使用备用 git 提供程序（默认为 github.com）
git_account = "mbecker20"
repo = "moghtech/komodo"
resource_path = ["stacks.toml", "repos.toml"]
```

### 用户组：

- [用户组模式](https://docs.rs/komodo_client/latest/komodo_client/entities/toml/struct.UserGroupToml.html)

```toml
[[user_group]]
name = "groupo"
everyone = false # 设置为 true 以将这些权限授予所有用户。
users = ["mbecker20", "karamvirsingh98"]
# 配置具有所有特定权限的写入访问权限
all.Server = { level = "Write", specific = ["Attach", "Logs", "Inspect", "Terminal", "Processes"] }
# 在所有构建上附加执行的基本级别
all.Build = "Execute"
# 允许用户查看所有构建器，并向其附加构建。
all.Builder = { level = "Read", specific = ["Attach"] }
permissions = [
  # 按名称将权限附加到特定资源
  { target.type = "Repo", target.id = "komodo-periphery", level = "Execute" },
  # 将权限附加到名称与正则表达式匹配的许多资源（此正则表达式使用 '^(.+)-(.+)$'）
  { target.type = "Server", target.id = "\\\^(.+)-(.+)\\\", level = "Read" },
  { target.type = "Deployment", target.id = "\\\^immich\\\", level = "Execute" },
]
```

---
*This document has not been translated yet.*