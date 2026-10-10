# 鸿蒙微信 · 课程作业

**本仓库为课程作业**：使用 HarmonyOS、ArkTS 和 ArkUI 实现微信风格的原生应用，用于学习页面组件化、路由、数据持久化与网络请求。与微信及腾讯无隶属关系。

开发工具为 DevEco Studio，目标 SDK 为 HarmonyOS 6.0.2 (API 22)，兼容 API 20；在鸿蒙模拟器中验证。

实现范围与实际验证进度见 [功能进度](docs/PROGRESS.md)，协作和编写规范见 [AGENTS.md](AGENTS.md)。功能按独立 Git 提交推进，便于中断后继续。

重开对话时，使用固定的 [接手入口与提示词](docs/HANDOFF.md) 继续任务。

当前已可运行：四个 Tabs、聊天列表/历史内容搜索、持久化文本及表情消息、展开输入弹窗、添加联系人、联系人资料和发消息、朋友圈图文发表/点赞/评论及我的朋友圈。其余模块仍在开发，准确状态见进度表。真实设备证据见 [测试记录](docs/TEST_REPORT.md)。

## 运行

使用 DevEco Studio 打开本项目，等待依赖同步，选择已启动的 HarmonyOS 模拟器并运行 `entry`。签名、本机 SDK 配置和私有凭据不入库。

也可在 Git Bash 中运行 `bash tools/build.sh`，使用 DevEco 配套的 Hvigor 构建（非默认安装位置请设置 `DEVECO_HOME`）。`python tools/device.py` 为 HDC 手动验收辅助工具，支持启动、点击、输入、返回和保存真实设备截图。

验证码登录服务依据课程报告中的 `word-api`；聊天和社交数据属于本地教学演示，联机配置与验收结果将随对应功能补充。

## 许可证与素材

源代码采用 [GNU Affero General Public License v3.0](LICENSE)（AGPL-3.0-only）。本项目原有头像、插图、音视频来自课程提供的工程素材，保留其原有权利归属；代码许可证不表示对第三方素材拥有额外授权。
