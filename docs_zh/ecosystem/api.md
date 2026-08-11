# API 和客户端

Komodo Core 公开了一个类似 RPC 的 HTTP API，用于读取数据、写入配置和执行操作。
提供了类型安全客户端：
[**Rust**](/docs/ecosystem/api#rust-client) 和 [**Typescript**](/docs/ecosystem/api#typescript-client)。

完整的 API 文档可在[**此处**](https://docs.rs/komodo_client/latest/komodo_client/api/index.html)获取。

## Rust 客户端 {#rust-client}

Rust 客户端发布在 crates.io 上，名为 [komodo_client](https://crates.io/crates/komodo_client)。

```rust
let komodo = KomodoClient::new("https://demo.komo.do", "your_key", "your_secret")
  .with_healthcheck()
  .await?;

let stacks = komodo.read(ListStacks::default()).await?;

let update = komodo
  .execute(DeployStack {
    stack: stacks[0].name.clone(),
    stop_time: None
  })
  .await?;
```

## Typescript 客户端 {#typescript-client}

Typescript 客户端发布在 NPM 上，名为 [komodo_client](https://www.npmjs.com/package/komodo_client)。

```ts
import { KomodoClient, Types } from "komodo_client";

const komodo = KomodoClient("https://demo.komo.do", {
  type: "api-key",
  params: {
    key: "your_key",
    secret: "your secret",
  },
});

// 推断为 Types.StackListItem[]
const stacks = await komodo.read("ListStacks", {});

// 推断为 Types.Update
const update = await komodo.execute("DeployStack", {
  stack: stacks[0].name,
});
```