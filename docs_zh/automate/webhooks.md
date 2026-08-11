# 配置 Webhook

多个 Komodo 资源可以利用您的 git 提供商的 webhook。Komodo 支持使用 Github 或 Gitlab webhook 身份验证类型的传入 webhook，Gitea 等其他提供商也支持此类型。

:::note
在 Gitea 上，默认的“Gitea” webhook 类型可与 Github 身份验证类型一起使用 👍
:::

## 复制 Webhook URL

在 UI 中找到资源，例如 `Build`、`Repo` 或 `Stack`。
转到 `Config` 部分，找到“Webhooks”，然后复制您想要的操作的 webhook。

webhook URL 的构造如下：

```shell
https://${HOST}/listener/${AUTH_TYPE}/${RESOURCE_TYPE}/${ID_OR_NAME}/${EXECUTION}
```
- **`HOST`**：您用于接收 webhook 的 Komodo 端点。
	- 如果您的 Komodo 位于专用网络中，
	  您将需要设置一个公共代理以将 `/listener` 请求转发到 Komodo。
- **`AUTH_TYPE`**：
	- 选项：`github` | `gitlab`
	- `github`：验证附加了 `X-Hub-Signature-256` 的签名。[参考](https://docs.github.com/en/webhooks/using-webhooks/validating-webhook-deliveries)
	- `gitlab`：检查附加到 `X-Gitlab-Token` 的秘密是否有效。[参考](https://docs.gitlab.com/ee/user/project/integrations/webhooks.html#create-a-webhook)
- **`RESOURCE_TYPE`**：
	- 选项：`build` | `repo` | `stack` | `sync` | `procedure` | `action`
- **`ID_OR_NAME`**：
	- 按 ID 或名称引用特定资源。如果名称可能会更改，最好使用 ID。
- **`EXECUTION`**：
	- 可用的执行取决于 `RESOURCE_TYPE`。构建只有 `/build` 操作。
		仓库可以在 `/pull`、`/clone` 或 `/build` 之间进行选择。堆栈有 `/deploy` 和 `/refresh`，资源同步有 `/sync` 和 `/refresh`。
	- 对于 **过程和操作**，这将是 **要侦听推送的分支**，或 `__ANY__` 以在
		推送到任何分支时触发。

## 在 Git 提供商上创建 webhook

导航到您的 git 提供商上的仓库页面，然后转到仓库的设置。
找到 Webhook 设置，然后单击以创建新的 webhook。

您将必须输入一些信息。

1. `Payload URL` 是您在上述步骤中复制的链接，即 `复制资源负载 URL`。
2. 对于内容类型，选择 `application/json`
3. 对于秘密，输入您在 Komodo Core 配置中配置的秘密 (`KOMODO_WEBHOOK_SECRET`)。
4. 如果您为 git 提供商设置了正确的 TLS（推荐），请启用 SSL 验证。
5. 对于“触发 webhook 的事件”，大多数人只想要推送请求。
6. 当然，请确保 webhook 处于“活动”状态，然后点击创建。

## 何时触发？

您的 git 提供商现在将在*每次*推送到*任何*分支时将此 webhook 推送到 Komodo。但是，您的 `Build`、`Repo`
等只关心仓库的特定分支。

因此，webhook 将 **仅在推送到资源上配置的分支时** 触发操作。

例如，如果我创建一个构建，我可能会将该构建指向特定仓库的 `release` 分支。如果我设置一个 webhook，并推送到 `main` 分支，则该操作将*不会触发*。它只会在推送到 `release` 分支时触发。