# 构建器

构建器是一台运行 Komodo Periphery 代理（通常还有 docker）的机器，能够处理来自 Komodo 核心的 RunBuild / BuildRepo 命令。连接到 Komodo 的任何服务器都可以选择作为构建的构建器。

在运行生产软件的机器上进行构建通常不是一个好主意，因为这个过程会占用大量系统资源。更好的方法是启动一个专门用于构建的临时云机器，然后在构建完成后将其关闭。Komodo 支持 AWS EC2 来完成此任务。

## AWS 构建器

构建器现在是 Komodo 资源，通过核心 API 进行管理/可以使用 UI 进行更新。
要使用此功能，您需要一个 AWS EC2 AMI，其中 docker 和 Komodo Periphery 配置为在系统启动时运行。
一旦您创建了构建器并添加了必要的配置，它就可以附加到构建中。

### 设置实例

创建一个 EC2 实例，并在其上安装 Docker 和 Periphery。

以下脚本是在 Ubuntu/Debian 实例上安装 Docker 和 Periphery 的示例：
```sh
#!/bin/bash
apt update
apt upgrade -y
curl -fsSL https://get.docker.com | sh
systemctl enable docker.service
systemctl enable containerd.service
curl -sSL https://raw.githubusercontent.com/moghtech/komodo/main/scripts/setup-periphery.py | HOME=/root python3
systemctl enable periphery.service
```

:::note
AWS 提供了一个“用户数据”功能，它将以 root 用户身份运行提供的脚本。以上内容可以与 AWS 用户数据一起使用
以提供免手动设置。
:::

### 从实例制作 AMI

实例启动并运行后，ssh 登录并使用以下命令确认 Periphery 正在运行：

```sh
sudo systemctl status periphery.service
```

如果不是，则安装尚未完成，您应该稍等片刻。可能需要 5 分钟或更长时间（全部用于更新/安装 Docker，Periphery 只是一个 12 MB 的二进制文件要下载）。

Periphery 运行后，您可以导航到 AWS UI 中的实例，然后选择“操作”->“映像和模板”->“创建映像”。只需命名映像并点击创建即可。

AMI 将提供一个以 `ami-` 开头的唯一 ID，将其与构建器配置一起使用。

### 配置安全组/防火墙
构建器将需要来自 Komodo Core 的端口 8120 上的入站访问权限，请务必向构建器配置中添加具有此规则的安全组。

## 使用 Docker Buildx 进行多平台构建

如果您需要为多个平台（例如 ARM 和 x86）构建 Docker 映像，Docker Buildx 提供了一种简单的方法。

    多平台构建可能比单平台构建花费更长的时间。
    当模拟不同的体系结构（例如，在 x86 主机上构建 ARM 映像）时，由于基于 QEMU 的仿真，预计会需要额外的时间。

### 1. 创建并使用 Buildx 构建器实例
```sh
docker buildx create --name builder --use --bootstrap
```
此命令创建一个名为 `builder` 的新构建器，并将其设置为当前 Docker 上下文的活动构建器。

---

### 2. 将 Buildx 设置为 `docker build` 的默认值
```sh
docker buildx install
```
这将默认的 `docker build` 命令替换为 Buildx，因此所有构建都会自动使用当前的构建器实例。

---

### 3. （可选）查看可用的构建器
```sh
docker buildx ls
```
使用此命令列出所有构建器实例并检查哪个是活动的。

---

完成这些步骤后，任何 `docker build` 命令都将默认使用 Buildx，从而可以轻松创建多平台映像。

---

### 在 Komodo 中选择平台
在 **Komodo** 中构建时，您可以在构建配置期间在构建“额外参数”字段中直接在 Komodo UI 中指定目标平台（例如 `linux/amd64`、`linux/arm64`）。

**额外参数的示例平台字符串：**
```
--platform linux/amd64,linux/arm64
```