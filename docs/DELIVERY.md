# v1.0.1 课程作业交付

状态：2026-10-10 已公开发布并完成远端核对。全部 6 个附件的 GitHub SHA-256 摘要及大小与本地文件一致，版本标签与已验证的构建源码一致。

本交付为 HarmonyOS 原生 ArkTS 微信风格课程应用，不是微信官方客户端或小程序。功能与实际证据见 [进度](PROGRESS.md) 和 [测试记录](TEST_REPORT.md)。

## 产物

| 项目 | 内容 |
| --- | --- |
| 发布入口 | [v1.0.1 Release](https://github.com/Rinyin/weixin/releases/tag/v1.0.1) |
| 安装包 | [weixin-1.0.1-emulator-unsigned.hap](https://github.com/Rinyin/weixin/releases/download/v1.0.1/weixin-1.0.1-emulator-unsigned.hap) |
| 文件大小 | 50,029,903 字节 |
| 构建源码 | [`7ec73b638b4d0a93d6ac79429bfeebbe34257f9d`](https://github.com/Rinyin/weixin/commit/7ec73b638b4d0a93d6ac79429bfeebbe34257f9d) |
| Bundle / 版本 | `com.example.weixin` / `1.0.1`（1000001） |
| SDK | 兼容 API 20，目标 API 22，编译 SDK 6.0.2.130 |
| 包类型 | 未签名调试 HAP，debug=true |
| 已验证设备 | 当前 HarmonyOS 模拟器 `127.0.0.1:5557`，2026-10-10 |

HAP 的 SHA-256：

```text
caad2ec7d926f767302615738d7500920e871e7604f445dc45c2af9b5f956d8b
```

工作区交付副本位于忽略目录 `artifacts/v1.0.1/`；原始构建输出为 `entry/build/default/outputs/default/entry-default-unsigned.hap`。交付直接复用 F8 构建、安装和桌面/系统启动画面验收过的同一字节内容，后续交付文档不影响该二进制。

## 源码与许可

Release 的版本标签指向上表构建源码，并提供该标签的完整源码 ZIP / tar.gz。随 HAP 分发 `BUILD_INFO.json`、`SHA256SUMS`、项目 `LICENSE`、`THIRD_PARTY_NOTICES.md` 和 `axios-LICENSE.txt`。本仓库代码采用 AGPL-3.0-only；Axios 使用其 MIT 许可，完整正文亦内嵌于 HAP 的 rawfile。桌面和启动页图标由用户提供，其余素材来自课程原工程，均保留原权利归属。

将 Release 的全部附件下载到同一目录后，可以在 Git Bash 中执行 `sha256sum -c SHA256SUMS`。仅核对 HAP 时，运行 `sha256sum weixin-1.0.1-emulator-unsigned.hap` 并与上方摘要比较。构建及安装命令见 [README](../README.md)。这个 unsigned 包已在当前模拟器验证，真机签名和商店发布没有进行验证。

## 验收范围

F0–F5 沿用既有通过证据；F6 实际完成取码与倒计时、错误码拒绝、login/info、资料显示、退出、连接失败、本地体验、等待中取消和迟到响应、140% 字号与冷启动。F8 仅更换图标、应用名称和版本，实际完成必要构建、覆盖安装、中文桌面图标/名称检查、系统启动画面抓取及进入登录页；未重复无关功能测试。

v1.0.1 的 66 个 ZIP 条目 CRC 全部通过，无重复条目；包内 `app_icon.png` 与用户提供的 PNG 及两份源资源逐字节一致，应用、入口和启动窗口三处图标引用一致，默认/zh_CN/en_US 名称均为“微信”。许可与联机权限沿用既有配置；详细构建/设备日志仅保留本机 `.local/`。桌面证据只裁剪本应用图标和名称，系统启动截图保留实际抓取画面。

联机使用另行运行的本机课程 word-api，默认反向转发 3000 端口；验证码直接回包、不发短信。后端不属于本次源码交付。本地体验无需服务，聊天、联系人、朋友圈和资料始终为本地教学数据。生产认证、真实微信连接、真机及压力测试不在已验证范围内。

历史版本 [v1.0.0](https://github.com/Rinyin/weixin/releases/tag/v1.0.0) 保留原 HAP、源码标签和对应校验文件；本次交付使用 v1.0.1。
