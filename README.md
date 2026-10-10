# 鸿蒙微信 · 课程作业

**本仓库为课程作业**：使用 HarmonyOS、ArkTS 和 ArkUI 实现微信风格的原生应用，用于学习页面组件化、路由、数据持久化与网络请求。与微信及腾讯无隶属关系。

开发工具为 DevEco Studio，目标 SDK 为 HarmonyOS 6.0.2 (API 22)，兼容 API 20；在鸿蒙模拟器中验证。

实现范围与实际验证进度见 [功能进度](docs/PROGRESS.md)，协作和编写规范见 [AGENTS.md](AGENTS.md)。功能按独立 Git 提交推进，便于中断后继续。

重开对话时，使用固定的 [接手入口与提示词](docs/HANDOFF.md) 继续任务。

当前已可运行：四个 Tabs、聊天与搜索、输入弹窗及表情、通讯录与资料、朋友圈发表/互动、我的朋友圈、本地视频号、个人资料编辑、设置及全局字体大小，以及 Axios 验证码登录和独立本地体验。真实模拟器证据见 [测试记录](docs/TEST_REPORT.md)。

## 运行

使用 DevEco Studio 打开本项目，等待依赖同步，选择已启动的 HarmonyOS 模拟器并运行 `entry`。签名、本机 SDK 配置和私有凭据不入库。

也可在 Git Bash 中运行 `bash tools/build.sh`，使用 DevEco 配套的 Hvigor 构建（非默认安装位置请设置 `DEVECO_HOME`）。`python tools/device.py` 为 HDC 手动验收辅助工具，支持启动、点击、输入、返回和保存真实设备截图。

验证码登录使用本机 `word-api`，直接返回验证码，不发送短信；仅登录及联机账号资料联网。聊天、社交和个人资料属于本地教学演示；连接失败不会自动登录。接口、配置与会话行为见 [课程登录接口](docs/AUTH_API.md)。

## 许可证与素材

源代码采用 [GNU Affero General Public License v3.0](LICENSE)（AGPL-3.0-only）。本项目原有头像、插图、音视频来自课程提供的工程素材，保留其原有权利归属；代码许可证不表示对第三方素材拥有额外授权。

Axios 等依赖及随 HAP 分发的许可说明见 [第三方声明](THIRD_PARTY_NOTICES.md)。
