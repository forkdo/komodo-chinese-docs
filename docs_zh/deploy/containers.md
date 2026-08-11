# Containers

Komodo 可以通过 `Deployment` 资源部署 Docker 容器。它会将你的配置转换为 `docker run` 命令，并通过 Periphery 代理在目标服务器上执行。

## 配置

```toml
[[deployment]]
name = "my-app"
[deployment.config]
server = "server-prod"
image.type = "Image"
image.params.image = "ghcr.io/myorg/my-app:latest"
network = "host"
restart = "on-failure"
environment = """
DB_HOST = db.example.com
LOG_LEVEL = info
"""
volumes = """
/data/my-app/data:/app/data
/data/my-app/config:/app/config
"""
```

### 配置字段

| Field              | Description                                                                                                    | Default          |
| ------------------ | -------------------------------------------------------------------------------------------------------------- | ---------------- |
| `server`           | 要部署到的服务器。                                                                                       | —                |
| `image`            | Docker 镜像 —— 可以是自定义的镜像字符串，也可以是一个附加的 Komodo Build。                                       | —                |
| `network`          | 要连接的 Docker 网络。`host` 会绕过虚拟网络层。                                       | `host`           |
| `restart`          | 重启策略（`no`、`on-failure`、`always`、`unless-stopped`）。                                               | `unless-stopped` |
| `ports`            | 未使用 `host` 网络时的端口映射（例如 `27018:27017`）。                                              | `[]`             |
| `volumes`          | `host_path:container_path` 格式的绑定挂载。                                                              | `""`             |
| `environment`      | `KEY=value` 格式的环境变量。支持 [变量插值](../configuration/variables.md)。 | `""`             |
| `labels`           | `key=value` 格式的 Docker 标签。                                                                           | `""`             |
| `command`          | 覆盖镜像的默认命令。在 `docker run` 中追加在镜像之后。                                  | `""`             |
| `extra_args`       | 直接传递给 `docker run` 的额外标志。                                                              | `""`             |
| `send_alerts`      | 容器状态变化时发送告警。                                                                        | `true`           |
| `auto_update`      | 当存在更新的镜像 digest（相同标签）时自动重新部署。                                      | `false`          |
| `poll_for_updates` | 检查更新的镜像并显示更新指示（不自动部署）。                                  | `false`          |
| `links`            | 资源头部显示的快捷链接。                                                                      | `[]`             |

### 镜像来源

有两种方式指定镜像：

- **Komodo Build** —— 附加一个 Build 资源，Komodo 部署最新（或固定）版本。镜像仓库凭据默认从 Build 继承。
- **自定义镜像** —— 直接指定一个镜像字符串，例如 `mongo` 或 `ghcr.io/myorg/my-app:1.0.0`。如果镜像是私有的，请选择一个 Docker 镜像仓库账户。

## 容器生命周期

Komodo 会跟踪容器状态，并提供管理生命周期的操作：

| Action                | Description                                                                                                                               |
| --------------------- | ----------------------------------------------------------------------------------------------------------------------------------------- |
| **Deploy / Redeploy（部署 / 重新部署）** | 销毁现有容器（如果有）并使用当前配置创建一个新容器。配置变更只有在重新部署后才会生效。 |
| **Start（启动）**             | 使用现有配置启动一个已停止的容器。                                                                                      |
| **Stop（停止）**              | 停止容器但保留其日志和状态。                                                                                     |
| **Remove（移除）**            | 彻底销毁容器。                                                                                                          |

:::note
停止和启动容器 **不会** 应用配置变更 —— 为此你必须重新部署。
:::

## 部署到 Swarm

除了以单个服务器为目标，部署（Deployment）还可以以 **Swarm** 为目标，将容器部署为 Swarm 服务。你可以将 Swarm 配置（configs）和密钥（secrets）附加到该服务。详见 [Swarm](../swarm.md)。
