# 过程和操作

对于涉及多个资源和执行的编排，
Komodo 提供了 `Procedure` 和 `Action` 资源类型。

## 过程

`Procedures` 是许多执行的组合，例如 `RunBuild` 和 `DeployStack`。
执行被分组为一系列 `Stages`，其中每个 `Stage` 包含一个或多个执行
以 **_一次性全部_** 运行。过程将等到 `Stage` 中的所有执行都完成后再移动
到下一个阶段。简而言之，`Stage` 中的执行是 **_并行_** 运行的，而阶段本身是
**_顺序_** 执行的。

### 批量执行

许多执行都有一个 `Batch` 版本可供您选择，例如 [**BatchDeployStackIfChanged**](https://docs.rs/komodo_client/latest/komodo_client/api/execute/struct.BatchDeployStackIfChanged.html)。有了这个，您可以通过名称匹配多个堆栈
使用 [**通配符语法**](https://docs.rs/wildcard/latest/wildcard) 和 [**正则表达式**](https://docs.rs/regex/latest/regex)。

### TOML 示例

与所有资源一样，`Procedures` 具有 TOML 表示，并且可以在 `ResourceSyncs` 中进行管理。

```toml
[[procedure]]
name = "pull-deploy"
description = "拉取堆栈仓库，部署堆栈"

[[procedure.config.stage]]
name = "拉取仓库"
executions = [
  { execution.type = "PullRepo", execution.params.pattern = "stack-repo" },
]

[[procedure.config.stage]]
name = "如果已更改则部署"
executions = [
  # 使用批处理版本，它按模式匹配许多堆栈
  # 这一个匹配所有以 `foo-`（通配符）和 `bar-`（正则表达式）为前缀的堆栈。
  { execution.type = "BatchDeployStackIfChanged", execution.params.pattern = "foo-* , \\^bar-.*$\" },
]
```

## 操作

`Actions` 赋予用户使用 Typescript 编写对 Komodo API 的调用的能力。

例如，像这样的 `Action` 脚本将对齐许多 `Builds` 的版本和分支。

```ts
const VERSION = "1.16.5";
const BRANCH = "dev/" + VERSION;
const APPS = ["core", "periphery"];
const ARCHS = ["x86", "aarch64"];

await komodo.write("UpdateVariableValue", {
  name: "KOMODO_DEV_VERSION",
  value: VERSION,
});
console.log("已将 KOMODO_DEV_VERSION 更新为 " + VERSION);

for (const app of APPS) {
  for (const arch of ARCHS) {
    const name = `komodo-${app}-${arch}-dev`;
    await komodo.write("UpdateBuild", {
      id: name,
      config: {
        version: VERSION as any,
        branch: BRANCH,
      },
    });
    console.log(
      `已将构建 ${name} 更新为版本 ${VERSION} 和分支 ${BRANCH}`
    );
  }
}

for (const arch of ARCHS) {
  const name = `periphery-bin-${arch}-dev`;
  await komodo.write("UpdateRepo", {
    id: name,
    config: {
      branch: BRANCH,
    },
  });
  console.log(`已将仓库 ${name} 更新为分支 ${BRANCH}`);
}
```


---
*此文档尚未翻译。*