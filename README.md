# lrrry-updates

lrrry 自用版 CoA 服务端的**云编译配置仓库**（不放源码、不放产物）。

## 这里是干什么的

GitHub Actions 上编一版 `lrrry-coa-Repack` 的核心：

- 核心：`Conquest-of-AzerothCore/azerothcore-wotlk-coa@main`（js 官方主线）
- 机器人：`Zyth45/mod-playerbots@coa`
- 额外模块：`mod-ah-bot-plus`、`mod-dungeon-clear`（coa 分支）、`mod-npc-enchanter`
- 补丁：`ci/patches/*.patch`（playerbots 需要的 core 侧 companion loot 接口等）

产出 `lrrry-core-windows-rNN.zip`，下载后在本机用
`node tools\lrrry-cloud.mjs pack --zip <产物.zip>` 落地成更新包。

## 怎么跑

仓库页面 → **Actions** → 左侧 `Build lrrry (Windows)` → **Run workflow**：

| 输入 | 留空时的值 |
|---|---|
| `core_repo` | `Conquest-of-AzerothCore/azerothcore-wotlk-coa` |
| `core_ref` | `main` |
| `module_ref` | `coa` |
| `build_type` | `RelWithDebInfo` |

约 50 分钟（首次要装 Boost / MySQL 客户端 / OpenSSL，之后走缓存）。

跑完在运行页面底部 **Artifacts** 下载 `lrrry-core-windows-rNN`。

## 目录

```
.github/workflows/build-lrrry-windows.yml   工作流
ci/patches/                                  编译前要打的补丁（sparse-checkout 只取这个目录）
```

## 注意

- 不要把这个仓库设成私有后再关掉 Actions 额度，否则跑不了（公开仓库免费）。
- 产物里的 `RELEASE_ID.txt` 决定更新包版本号（`main-<core日期>-<core短hash>`），
  本机 `pack` 时校验它，缺了会报「产物里没有 release_id」。
