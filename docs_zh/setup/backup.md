# 备份和还原

Komodo 可以按计划自动备份其数据库，并从任何先前的快照还原。备份经过 gzip 压缩并存储在磁盘或远程服务器上，默认情况下保留最近的 14 个备份。备份和还原操作由 [Komodo CLI](../ecosystem/cli) 处理，为方便起见，它已打包到 Core 镜像中。

## 计划备份

从 **v1.19.0** 开始，新的 Komodo 安装将自动创建
**备份核心数据库**[程序](../automate/procedures#procedures)，每日计划。
如果您没有，这是 Toml：

```toml
[[procedure]]
name = "Backup Core Database"
description = "在计划的时间触发核心数据库备份。"
tags = ["system"]
config.schedule = "每天 01:00"

[[procedure.config.stage]]
name = "Stage 1"
enabled = true
executions = [
  { execution.type = "BackupCoreDatabase", execution.params = {}, enabled = true }
]
```

:::info
您还能够将 `BackupCoreDatabase` 集成到其他过程中，例如在启动备份容器之前触发
此过程。此过程没有什么特别之处，
只是为了指导/方便而默认创建的。
:::

## 备份

当 Komodo 进行数据库备份时，它会创建一个**以备份时间命名的文件夹**，
并将 gzip 压缩的文档转储到此文件夹中的文件中。
为了将备份存储到磁盘，请在 Komodo Core 容器中**将主机路径挂载到 `/backups`**。

由于其体积较大且相对不重要，因此`Stats`集合（包含历史服务器 cpu / mem / 磁盘使用情况）
不包含在带日期的备份中。只有最新的统计信息会保存在备份文件夹的顶层。

为了防止无限增长，备份过程实现了一个修剪功能，该功能将确保
只保留最近的 14 个备份文件夹。要更改此数字，请在 `core.config.toml`、`komodo.cli.toml` 或 Core 容器环境中设置 `max_backups` (`KOMODO_CLI_MAX_BACKUPS`)
。

```
# 文件夹结构
/backups
| 2025-08-12_03-00-01
| | Action.gz
| | Alerter.gz
| | ...
| 2025-08-13_03-00-01
| 2025-08-14_03-00-01
| ...
| Stats.gz
```

:::warning
目前不支持内置加密，
因此，如果您的备份解决方案本身不支持加密，您可能需要在远程备份之前加密文件。
:::

## 远程备份

由于数据库备份实际上是 [Komodo CLI](../ecosystem/cli) 的一个功能，您还可以使用 `ghcr.io/moghtech/komodo-cli` 镜像直接备份到
远程服务器。此服务将备份一次然后退出，因此计划的部署仍应使用过程或操作进行：

```yaml
services:
  cli:
    image: ghcr.io/moghtech/komodo-cli
    command: km database backup -y
    volumes:
      - /path/to/komodo/backups:/backups
    environment:
      ## 数据库端口必须可达。
      KOMODO_DATABASE_ADDRESS: komodo.example.com:27017
      KOMODO_DATABASE_USERNAME: <db username>
      KOMODO_DATABASE_PASSWORD: <db password>
      KOMODO_DATABASE_DB_NAME: komodo
      KOMODO_CLI_MAX_BACKUPS: 30 # 根据您的偏好设置
```

## 还原

Komodo CLI 也处理数据库还原。

```yaml
services:
  cli:
    image: ghcr.io/moghtech/komodo-cli
    ## （可选）使用 `--restore-folder` 指定特定文件夹，
    ## 否则还原最近的备份。
    command: km database restore -y # --restore-folder 2025-08-14_03-00-01
    volumes:
      # 与上述备份文件相同的挂载
      - /path/to/komodo/backups:/backups
    environment:
      ## 数据库端口必须可达。
      ## 请注意与备份相比所需的不同环境变量。
      ## 这是为了防止任何意外还原。
      KOMODO_CLI_DATABASE_TARGET_ADDRESS: komodo.example.com:27017
      KOMODO_CLI_DATABASE_TARGET_USERNAME: <db username>
      KOMODO_CLI_DATABASE_TARGET_PASSWORD: <db password>
      KOMODO_CLI_DATABASE_TARGET_DB_NAME: komodo-restore
```

:::warning
还原过程可以使用相同的备份文件多次运行，并且不会创建任何额外的副本。
但是，它不会事先“清除”目标数据库。如果还原数据库已经填充，
那些旧文档也将保留。在这种情况下，您可能需要在还原之前
删除/删除目标数据库。
:::

## 一致性

只要备份过程成功完成，生成的文件就始终可以还原，
无论 Komodo 实例在备份时有多活跃。但是，在备份过程中发生的写入，
例如对资源配置的更新，可能会或可能不会包含在备份中，
具体取决于时间。

虽然在还原时这很少会引起任何问题，但如果您的
Komodo 在所有时间都承受大量使用，并且您担心一致性，
您可以考虑在备份前[锁定](https://www.mongodb.com/docs/manual/reference/method/db.fsyncLock/#mongodb-method-db.fsyncLock)
Mongo。只要确保之后[解锁](https://www.mongodb.com/docs/manual/reference/method/db.fsyncUnlock/)
数据库即可。