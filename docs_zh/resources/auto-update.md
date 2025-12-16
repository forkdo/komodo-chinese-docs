# 自动更新

从 **v1.19.0** 开始，新的 Komodo 安装将自动创建
**全局自动更新** [程序](../resources/procedures#procedures)，每日定时执行。
如果您没有，这是 Toml 内容：

```toml
[[procedure]]
name = "Global Auto Update"
description = "使用 'poll_for_updates' 或 'auto_update' 拉取并自动更新堆栈和部署。"
tags = ["system"]
config.schedule = "每天 03:00"

[[procedure.config.stage]]
name = "Stage 1"
enabled = true
executions = [
  { execution.type = "GlobalAutoUpdate", execution.params = {}, enabled = true }
]
```

:::info
您也可以将 `GlobalAutoUpdate` 集成到其他程序中
以协调与其他进程（例如备份）的时间。这个程序没有什么特别之处，
只是为了指导/方便而默认创建的。
:::

### 工作原理

堆栈和部署都允许您配置 **轮询更新** 或 **自动更新**。
当 [**GlobalAutoUpdate**](https://docs.rs/komodo_client/latest/komodo_client/api/execute/struct.GlobalAutoUpdate.html)
运行时，Komodo 将循环遍历所有启用了这两个选项之一的资源，
并运行 [**PullStack**](https://docs.rs/komodo_client/latest/komodo_client/api/execute/struct.PullStack.html) / [**PullDeployment**](https://docs.rs/komodo_client/latest/komodo_client/api/execute/struct.PullDeployment.html)
以获取任何 **具有相同标签** 的较新镜像。
请注意，为了正常工作，它需要使用“滚动”镜像标签，例如 `:latest`。

:::info
如果您使用 git 源堆栈并希望自动更新镜像标签，请查看
[Renovate](https://github.com/renovatebot/renovate?tab=readme-ov-file#what-is-the-mend-renovate-cli)
:::

对于启用了 **轮询更新** 并配置了警报器的资源，它将
发送一个警报，通知有新镜像可用，并在 UI 中显示可用更新指示器。

对于启用了 **自动更新** 的资源，它将继续重新部署 *仅* 带有
较新镜像的服务（默认情况下）。如果配置了警报器，它还将发送警报通知此事件。