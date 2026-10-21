# v1.1.0 课程作业交付

状态：2026-10-21 已公开发布。全部 6 个附件的 GitHub SHA-256 摘要及大小与本地文件一致，版本标签 `v1.1.0` 指向包含版本号更新的源码提交。

本交付为 HarmonyOS 原生 ArkTS 微信风格课程应用，不是微信官方客户端或小程序。功能与实际证据见 [进度](PROGRESS.md) 和 [测试记录](TEST_REPORT.md)。

## 产物

| 项目 | 内容 |
| --- | --- |
| 发布入口 | [v1.1.0 Release](https://github.com/Rinyin/weixin/releases/tag/v1.1.0) |
| 安装包 | [weixin-1.1.0-emulator-unsigned.hap](https://github.com/Rinyin/weixin/releases/download/v1.1.0/weixin-1.1.0-emulator-unsigned.hap) |
| 文件大小 | 50,114,919 字节 |
| 构建源码 | 标签 [`v1.1.0`](https://github.com/Rinyin/weixin/tree/v1.1.0)（`BUILD_INFO.json` 记录完整提交号） |
| Bundle / 版本 | `com.example.weixin` / `1.1.0`（1001000） |
| SDK | 兼容 API 20，目标 API 22，编译 SDK 6.0.2.130 |
| 包类型 | 未签名调试 HAP，debug=true |
| 已验证设备 | 当前 HarmonyOS 模拟器 `127.0.0.1:5555`，2026-10-21 |

HAP 的 SHA-256：

```text
faa9d2c3aa0a93ddc9286f4794adf75a942d7b76c340691f1671d7a44debf840
```

工作区交付副本位于忽略目录 `artifacts/v1.1.0/`；原始构建输出为 `entry/build/default/outputs/default/entry-default-unsigned.hap`。

## 源码与许可

Release 的版本标签指向构建源码，并提供该标签的完整源码 ZIP / tar.gz。随 HAP 分发 `BUILD_INFO.json`、`SHA256SUMS`、项目 `LICENSE`、`THIRD_PARTY_NOTICES.md` 和 `axios-LICENSE.txt`。本仓库代码采用 AGPL-3.0-only；Axios 使用其 MIT 许可，完整正文亦内嵌于 HAP 的 rawfile。桌面和启动页图标由用户提供，其余素材来自课程原工程，均保留原权利归属。

将 Release 的全部附件下载到同一目录后，可以在 Git Bash 中执行 `sha256sum -c SHA256SUMS`。仅核对 HAP 时，运行 `sha256sum weixin-1.1.0-emulator-unsigned.hap` 并与上方摘要比较。构建及安装命令见 [README](../README.md)。这个 unsigned 包已在当前模拟器验证，真机签名和商店发布没有进行验证。

## 验收范围

F0–F9 沿用既有通过证据。F10–F14 为本版本改动：去除测试标识并按微信样式调整各页面、登录状态保持、聊天键盘不顶出标题栏、朋友圈/视频号/添加朋友/个人资料重做、视频号标签切换及关注/喜欢持久化，均在模拟器实际操作验证（见测试记录 F10–F14）。F15 仅将版本号改为 1.1.0（1001000），完成构建、ZIP 完整性检查（66 个条目 CRC 通过、无重复）、覆盖安装（`bm dump` 显示 versionName 1.1.0 / versionCode 1001000）与启动，升级后保持已登录并直接进入主页；未重复其他功能测试。

联机使用另行运行的本机课程 word-api，默认反向转发 3000 端口；验证码直接回包、不发短信，取码后自动填入。后端不属于本次源码交付。游客模式（登录页“更多选项”）无需服务；聊天、联系人、朋友圈、视频号互动和资料始终为本地数据。生产认证、真实微信连接、真机及压力测试不在已验证范围内。

## 历史版本

[v1.0.0](https://github.com/Rinyin/weixin/releases/tag/v1.0.0)、[v1.0.1](https://github.com/Rinyin/weixin/releases/tag/v1.0.1) 保留原 HAP、源码标签和对应校验文件；本次交付使用 v1.1.0。
