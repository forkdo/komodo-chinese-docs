# Swarm

Komodo 可以通过 `Swarm` 资源来管理 Docker Swarm 集群。连接你的 Swarm 管理节点，即可通过统一界面管理节点、服务、堆栈、配置（configs）和密钥（secrets）。

## 配置

一个 Swarm 资源指向一个或多个**管理节点（manager nodes）** —— 这些是已经安装了 Periphery 并作为管理节点加入 Docker Swarm 的服务器。如果某个管理节点不可达，Komodo 会尝试列表中的下一个。

```toml
[[swarm]]
name = "production-swarm"
[swarm.config]
server_ids = ["manager-01", "manager-02", "manager-03"]
send_unhealthy_alerts = true
```

### 配置字段

| Field | Description | Default |
|---|---|---|
| `servers` | Swarm 管理节点的服务器名称 / ID 列表。失败时会按顺序逐一尝试。 | `[]` |
| `send_unhealthy_alerts` | 当节点或任务不健康时发送告警。 | `true` |
| `maintenance_windows` | 抑制告警的计划维护窗口。 | `[]` |
| `links` | 资源头部显示的快捷链接。 | `[]` |

## 快速开始

要在 Komodo 中使用 Docker Swarm，你首先需要在某个已连接的服务器上初始化一个 Swarm。

### 1. 初始化 Swarm

SSH 进入你的服务器（或使用 Komodo 终端）并运行 [`docker swarm init`](https://docs.docker.com/reference/cli/docker/swarm/init/)：

```bash
docker swarm init --advertise-addr <SERVER_IP>
```

### 2. 在 Komodo 中创建 Swarm 资源

创建一个新的 Swarm 资源，并将该服务器添加为管理节点。创建完成后，Komodo 会检测到 Swarm 并显示其节点。

### 3. 加入更多节点

要向 Swarm 中添加更多服务器，进入 UI 中该 Swarm 的节点列表并点击 **Join（加入）** 按钮。这将显示带有正确令牌和地址的 [`docker swarm join`](https://docs.docker.com/reference/cli/docker/swarm/join/) 命令 —— 复制它并在你想添加的服务器上运行。

**worker（工作节点）** 和 **manager（管理节点）** 分别有不同的加入命令。

:::tip
节点加入后，请在 Komodo 中将其添加为一个服务器，并（对于管理节点）将其加入 Swarm 资源的 `servers` 列表以实现冗余。
:::

## 节点

查看 Swarm 中的所有节点及其角色、可用性、状态和其他信息。

## 服务

可以直接管理 Swarm 服务，也可以通过配置部署（Deployment）资源时使用 `swarm` 而非 `server` 来创建。

- 查看运行、期望和已完成的任务数量。
- 检查服务配置以及附加的 configs / secrets。
- 查看并搜索服务日志，支持 grep。

## 堆栈

使用 `docker stack deploy` 将基于 compose 的堆栈部署到 Swarm。**堆栈（Stack）** 资源可以通过在 Stack 配置中配置 `swarm` 而非 `server` 来以 Swarm 为目标。

- 在 UI、主机或 git 仓库中定义 compose 文件（与普通堆栈相同）。
- 查看构成堆栈的服务和任务。

## 配置与密钥（Configs and Secrets）

直接从 Komodo 管理 Docker Swarm 的 configs 和 secrets。

- **创建** 带有标签和可选模板驱动的 configs 与 secrets。
- **轮换** configs 和 secrets —— 由于它们在 Docker 中是不可变的，Komodo 会自动处理轮换流程：
  1. 创建一个临时替换项。
  2. 将所有引用该项的服务更新为使用临时版本。
  3. 移除原项并以新数据重新创建。
  4. 将服务更新回原始名称。
- **移除** configs 和 secrets。

:::note
Configs 和 secrets 的最大大小为 500KB。
:::

## 健康监控

Komodo 会跟踪每个 Swarm 的整体健康状况：

| State | Meaning |
|---|---|
| **Healthy（健康）** | 所有节点和任务都正常。 |
| **Unhealthy（不健康）** | 部分节点或任务不符合期望状态。 |
| **Down（宕机）** | 所有节点或任务都已宕机。 |
| **Unknown（未知）** | 无法确定状态。 |

当启用 `send_unhealthy_alerts` 时，Komodo 会通过你配置的 [Alerters](resources#alerter) 路由告警。

## 部署到 Swarm

**部署（Deployments）** 和 **堆栈（Stacks）** 都可以以 Swarm 而非单个服务器为目标：

- 在 **Deployment** 上，设置 `swarm` 以将容器部署为 Swarm 服务。你可以将 Swarm configs 和 secrets 附加到该服务。
- 在 **Stack** 上，设置 `swarm` 以通过 `docker stack deploy` 而非 `docker compose up` 部署。
