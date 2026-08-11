# 开发

如果您希望为 Komodo 做贡献，本页面是设置 Komodo 开发环境的起点。

## 依赖

从[源代码](https://github.com/moghtech/komodo)运行 Komodo 需要 [Docker](https://www.docker.com/)（并且可以使用附带的 [devcontainer](https://code.visualstudio.com/docs/devcontainers/containers)），或者可以在本地安装开发依赖项：

* 后端（核心/外围 API）
    * 通过 [rustup 安装程序](https://rustup.rs/) 安装稳定的 [Rust](https://www.rust-lang.org/)
    * 本地可用的 [MongoDB](https://www.mongodb.com/) 或 [FerretDB](https://www.ferretdb.com/)。
    * 在 Debian/Ubuntu 上：需要 `apt install build-essential pkg-config libssl-dev` 来构建 rust 源代码。
* Web UI
    * [Node](https://nodejs.org/en) >= 18.18 + NPM
        * [Yarn](https://yarnpkg.com/) - (提示：安装 `node` 后使用 `corepack enable` 来使用 `yarn`)
    * [typeshare](https://github.com/1password/typeshare)
    * [Deno](https://deno.com/) >= 2.0.2

### runnables-cli

[mbecker20/runnables-cli](https://github.com/mbecker20/runnables-cli) 可以用作一个方便的 CLI，用于运行 `runfile.toml` 中的常见项目任务。否则，您可以通过引用 `runfile.toml` 中的 `cmd` 来创建自己的项目任务。下面的所有说明都将使用 runnables-cli v1.3.7+。

## Docker

对项目进行更改后，运行 `run dev-compose-build` 以重新构建 Komodo，然后运行 `run dev-compose-exposed` 以启动一个 Komodo 容器，其 UI 可在 `localhost:9120` 访问。对源文件所做的任何更改都将需要重新运行 `dev-compose-build` 和 `dev-compose-exposed` 命令。

## Devcontainer

使用附带的 `.devcontainer.json` 和 VSCode 或其他兼容的 IDE，一键启动一个完整的环境，包括数据库。

提供了用于构建和运行 Komodo 的 [VSCode 任务](https://code.visualstudio.com/Docs/editor/tasks)。

使用 devcontainer 打开存储库后，运行 `Init` 任务以构建 ui/后端。然后，可以使用 `Run Komodo` 任务来运行 ui/后端。还提供了用于重建/仅运行堆栈的一个组件（核心 API、外围 API、UI）的其他任务。

## 本地

您也可以在本地运行各个组件，仅使用 Docker 来运行数据库。

### 初始一次性设置

创建本地配置目录。

```sh
mkdir -p .dev/keys .dev/periphery
```

添加 `.dev/core.config.toml`，内容如下：

```toml
host = "http://localhost:9120"
private_key = "file:.dev/keys/core.key"
local_auth = true
enable_new_users = true
jwt_secret = "a_random_secret"
first_server_address = "http://localhost:8120"
cors_allowed_origins = ["http://localhost:5173"]
cors_allow_credentials = true
session_allow_cross_site = true

database.address = "localhost:27017"
database.username = "komodo"
database.password = "komodo"
```

添加 `.dev/periphery.config.toml`：

```toml
ssl_enabled = false
root_directory = ".dev/periphery"
```

创建 `ui/.env.development`，内容如下：

```
VITE_KOMODO_HOST=http://localhost:9120
```

确保您的 Rust 工具链是最新的，并安装 CLI 工具：

```sh
rustup update
cargo install typeshare-cli runnables-cli
run link-client
```

### 启动服务

在 Docker 中启动一个 Mongo 实例：

```sh
docker run -d --name komodo-mongo \
-p 27017:27017 \
-v komodo-mongo-data:/data/db \
-v komodo-mongo-config:/data/configdb \
-e MONGO_INITDB_ROOT_USERNAME=komodo \
-e MONGO_INITDB_ROOT_PASSWORD=komodo \
mongo
```

在单独的终端中，分别运行 Core、Periphery 和 UI。

```sh
run dev-core
```

```sh
run dev-periphery
```

```sh
run dev-ui      # 以开发（监视）模式启动
```

一切运行后，打开 `http://localhost:5173` 并创建一个用户账户。

### 重建前端客户端

在 API 发生变更后，使用以下命令重建客户端：

```bash
run gen-client  # 在 API 变更后重建客户端（after API changes）
```

## 文档站点开发

使用 `run dev-docsite` 以开发模式启动 [Docusaurus](https://docusaurus.io/) Komodo 文档站点。对 `./docsite` 中文件所做的更改将由服务器自动重新加载。
