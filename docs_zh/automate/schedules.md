# Schedules

Komodo 可以根据配置的调度计划，自动运行 [**过程（Procedures）和动作（Actions）**](procedures)。

## 配置

为任意过程或动作添加调度字段：

```toml
[[procedure]]
name = "nightly-backup"
[procedure.config]
schedule_format = "English"
schedule = "Every day at 03:00"
schedule_enabled = true
schedule_timezone = "America/New_York"
schedule_alert = true
failure_alert = true
```

### 调度字段

| Field | Description | Default |
|---|---|---|
| `schedule_format` | `English` 表示自然语言，`Cron` 表示 cron 表达式。 | `English` |
| `schedule` | 调度表达式（见下方格式说明）。 | `""` |
| `schedule_enabled` | 调度是否处于激活状态。 | `true` |
| `schedule_timezone` | [TZ 标识符](https://en.wikipedia.org/wiki/List_of_tz_database_time_zones)（例如 `America/New_York`）。若留空则使用 Core 的时区。 | `""` |
| `schedule_alert` | 每次调度运行时发送一次告警。 | `true` |
| `failure_alert` | 调度运行失败时发送告警。 | `true` |

## 调度格式

### English（自然语言）

设置 `schedule_format = "English"`，然后将调度写成一句话：

- `Every day at 03:00`
- `Every 5 minutes`
- `At midnight on the 1st and 15th of the month`
- `Every Monday at 09:00`

Komodo 内部使用 [english-to-cron](https://crates.io/crates/english-to-cron) crate 将这些表达式转换为 cron。

### Cron

设置 `schedule_format = "Cron"`，并提供一个 6 字段的 cron 表达式（**必须包含秒字段**）：

```
second  minute  hour  day  month  day-of-week
```

示例：

| Expression | Meaning |
|---|---|
| `0 0 3 * * ?` | 每天 03:00:00 |
| `0 */5 * * * ?` | 每 5 分钟 |
| `0 0 0 1,15 * ?` | 每月 1 号和 15 号的午夜 |
| `0 0 9 ? * MON` | 每周一 09:00 |

## 查看调度

**ListSchedules** API 接口会返回所有已配置的调度及其状态，包括：

- 上次运行时间
- 下次计划运行时间
- 任何调度解析错误

## 告警

当启用 `schedule_alert` 时，Komodo 会在每次调度的过程或动作运行时，通过你配置的 [Alerters（告警器）](../resources) 发送告警。如果启用了 `failure_alert`，则在运行失败时还会额外发送一次告警。
