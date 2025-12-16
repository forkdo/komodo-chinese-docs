# 配置

## 选择 docker 镜像

有两种方法可以配置要部署的 docker 镜像。

### 附加 Komodo 构建
如果您要部署的软件是由 Komodo 构建的，您可以将构建直接附加到部署中。

默认情况下，Komodo 将部署构建的最新可用版本，您也可以使用版本下拉列表指定特定版本。

同样默认情况下，Komodo 将使用附加到构建的同一个 docker 帐户来拉取外围服务器上的镜像。如果该帐户在服务器上不可用，您可以指定另一个可用帐户来代替，该帐户只需要对 docker 存储库具有读取权限。

### 使用自定义镜像
您还可以手动指定镜像名称，例如 `mongo` 或 `ghcr.io/mbecker20/random_image:0.1.1`。

如果镜像存储库是私有的，您仍然可以选择一个可用的 docker 帐户来拉取镜像。

## 配置网络

docker 的一个特性是它允许在[容器之间创建虚拟网络](https://docs.docker.com/network/)。Komodo 允许您指定一个 docker 虚拟网络来连接容器，或者使用主机系统网络来绕过 docker 虚拟网络。

默认选择是 `host`，它绕过了 docker 虚拟网络层。

如果您选择除主机之外的网络，您可以使用 GUI 指定端口绑定。例如，如果您正在运行 mongo（默认为端口 27017），您可以使用以下映射：

```
27018 : 27017
```

在这种情况下，您将从容器外部通过端口 `27018` 访问 mongo。

请注意，这并不是使用非 `host` 网络的唯一效果。例如，在不同网络上运行的容器无法通信，而在同一网络上的容器即使在同一系统上运行也无法访问 `localhost` 上的其他容器。如果您不熟悉此行为，可能会有点混乱，可以通过仅使用 `host` 网络完全繞过此行为。

## 配置重启行为

Docker 与 systemd 类似，有几个处理容器退出时的选项。请参阅 [docker 重启策略](https://docs.docker.com/config/containers/start-containers-automatically/)。Komodo 允许您从这些选项中选择适当的重启行为。

## 配置环境变量

Komodo 使您能够轻松管理传递给容器的环境变量。
在 GUI 中，导航到部署页面上配置的环境选项卡。

您可以像使用 ```.env``` 文件一样传递环境变量：

```
ENV_VAR_1=some_value
ENV_VAR_2=some_other_value
```

## 配置卷

docker 容器的文件系统与主机的文件系统是隔离的。但是，容器仍然可以访问系统文件和目录，这是通过使用[绑定挂载](https://docs.docker.com/storage/bind-mounts/)来实现的。

假设您的容器需要读取位于系统上 `/home/ubuntu/config.toml` 的配置文件。您可以将绑定挂载指定为：

```
/home/ubuntu/config.toml : /config/config.toml
```

第一个路径是系统上的路径，第二个是容器中的路径。然后，您的应用程序将读取 `/config/config.toml` 处的文件以加载其内容。

这些可以在“卷”卡片中的 GUI 中轻松配置。您可以根据需要配置任意数量的绑定挂载。

## 额外参数

并非所有 docker 功能都由 Komodo 直接映射，只有最常用的功能。您仍然可以通过使用“额外参数”为 Komodo 指定要在 `docker run` 命令中包含的任何自定义标志。例如，您可以使用以下两个额外参数启用日志轮换：

```
--log-opt max-size=10M
```
```
--log-opt max-file=3
```

## 命令

有时您需要覆盖镜像中的默认命令，或指定一些直接传递给应用程序的标志。此处输入的内容将插入到镜像之后的 docker run 命令中。例如，要将 `--quiet` 标志传递给 MongoDB，docker run 命令将是：

```
docker run -d --name mongo-db mongo:6.0.3 --quiet
```

要使用 Komodo 实现此目的，只需将 `--quiet` 传递给“命令”。