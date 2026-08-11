# Terminals

Komodo 为服务器和容器提供基于浏览器的终端会话。会话是持久化的，支持多个同时连接，并且命令可以脚本化和计划调度。

## 服务器终端（Server Terminals）

直接在已连接的服务器上打开一个 shell。默认命令是 `bash`，可通过每个 Periphery 的 `default_terminal_command` 进行配置。

## 容器终端（Container Terminals）

以两种模式连接到运行中的容器：

- **Exec**（默认）—— 在容器内运行一个新命令（`docker exec`）。通常用于交互式 shell。
- **Attach** —— 附加到容器的主进程（`docker attach`）。适用于直接与主进程交互。

容器终端可用于 **部署（Deployments）**、**堆栈服务（Stack services）**，以及服务器上任何可见的容器。

## 多会话

你可以在同一资源上创建多个命名的终端会话。每个会话都有其独立的 PTY 进程和输出历史。

- 终端名称在一个目标内必须唯一（例如，两个名为 "debug" 的终端可以存在于不同的服务器上）。
- 多个用户可以同时连接到同一个终端会话 —— 输出会广播给所有已连接的客户端。
- 会话会一直保留，直到被显式删除或 Periphery 重启。

## 终端历史

每个终端维护一个滚动的 1 MiB 输出缓冲区。当你重新连接到已有会话时，历史记录会被重放，以便你看到之前的输出。

## CLI

终端会话也可以通过命令行使用 [Komodo CLI](./ecosystem/cli.mdx#terminals) 访问。

- `km ssh <server>` —— 在服务器上打开一个 shell
- `km exec <container> <shell>` —— exec 进入容器
- `km attach <container>` —— 附加到容器的主进程

在任何 CLI 终端会话中按 **Alt+Q** 可断开连接，而会话本身仍保持运行。

## Execute Terminal

`execute_terminal` API 方法允许你在终端上运行命令，并将输出通过 HTTP 流式传回。这在以下场景很有用：

- **动作（Actions）** —— TypeScript 脚本可以在 Komodo 客户端上调用 `execute_terminal`，在任意服务器或容器上运行命令并以编程方式处理输出。
- **自动化（Automation）** —— 通过 REST API 将终端命令执行集成到外部工具中。

TypeScript 客户端为每种目标类型提供了便捷方法。所有方法都接受可选的 `callbacks`，其中包含 `onLine`（每行输出时调用）和 `onFinish`（附带退出码调用）。

```typescript
// Server terminal
await komodo.execute_server_terminal({
  server: "my-server",
  terminal: "automation",
  command: "df -h",
  init: { command: "bash", recreate: "DifferentCommand" },
}, {
  onLine: (line) => console.log(line),
  onFinish: (code) => console.log("Exit code:", code),
});

// Container terminal
await komodo.execute_container_terminal({
  server: "my-server",
  container: "my-container",
  terminal: "debug",
  command: "cat /var/log/errors.log",
  init: { command: "sh", mode: "Exec", recreate: "Never" },
});

// Stack service terminal
await komodo.execute_stack_service_terminal({
  stack: "my-stack",
  service: "web",
  terminal: "debug",
  command: "nginx -t",
  init: { command: "sh" },
});

// Deployment terminal
await komodo.execute_deployment_terminal({
  deployment: "my-deployment",
  terminal: "check",
  command: "node --version",
  init: { command: "sh", recreate: "Always" },
});
```

## Periphery 配置

终端行为可以在 Periphery 配置文件中进行配置：

| Setting | Description | Default |
|---|---|---|
| `default_terminal_command` | 新服务器终端的默认 shell 命令。 | `bash` |
| `disable_terminals` | 禁用服务器终端会话。 | `false` |
| `disable_container_terminals` | 禁用容器终端会话。 | `false` |
