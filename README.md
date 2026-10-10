# 鸿蒙微信 · 课程作业

**本仓库为课程作业**：使用 HarmonyOS、ArkTS 和 ArkUI 实现微信风格的原生应用，用于学习页面组件化、路由、数据持久化与网络请求。与微信及腾讯无隶属关系。

开发工具为 DevEco Studio 6.0.2，目标 SDK 为 HarmonyOS 6.0.2 (API 22)，兼容 API 20；在鸿蒙模拟器中验证。公开仓库为 [Rinyin/weixin](https://github.com/Rinyin/weixin)。

实现范围与实际验证进度见 [功能进度](docs/PROGRESS.md)，协作和编写规范见 [AGENTS.md](AGENTS.md)。功能按独立 Git 提交推进，便于中断后继续。

重开对话时，使用固定的 [接手入口与提示词](docs/HANDOFF.md) 继续任务。

当前已可运行：四个 Tabs、聊天与搜索、输入弹窗及表情、通讯录与资料、朋友圈发表/互动、我的朋友圈、本地视频号、个人资料编辑、设置及全局字体大小，以及 Axios 验证码登录和独立本地体验。真实模拟器证据见 [测试记录](docs/TEST_REPORT.md)。

## 下载与运行

[下载 v1.0.0 HAP](https://github.com/Rinyin/weixin/releases/download/v1.0.0/weixin-1.0.0-emulator-unsigned.hap)；[Release](https://github.com/Rinyin/weixin/releases/tag/v1.0.0) 同时提供源码、校验文件与许可证，完整信息见 [交付说明](docs/DELIVERY.md)。安装包为 `weixin-1.0.0-emulator-unsigned.hap`，已在本项目当前模拟器安装运行；它是未签名调试包，不代表真机免签可装。真机安装需在 DevEco 配置自己的签名。

使用 DevEco Studio 打开本项目，等待依赖同步，选择已启动的 HarmonyOS 模拟器并运行 `entry`。签名、本机 SDK 配置和私有凭据不入库。也可在 Windows Git Bash 中使用 IDE 自带的 Node、OHPM、Hvigor：

```bash
# 非默认安装位置请先设置 DEVECO_HOME。
deveco_root="${DEVECO_HOME:-C:/Program Files/Huawei/DevEco Studio}"
"$deveco_root/tools/node/node.exe" "$deveco_root/tools/ohpm/bin/pm-cli.js" install
bash tools/build.sh

hdc_bin="$deveco_root/sdk/default/openharmony/toolchains/hdc.exe"
"$hdc_bin" list targets
"$hdc_bin" install -r entry/build/default/outputs/default/entry-default-unsigned.hap
"$hdc_bin" shell aa start -a EntryAbility -b com.example.weixin
```

安装已下载的 HAP 时，将 `install -r` 后的路径换成下载文件路径。多个设备在线时，HDC 命令需加 `-t <目标设备>`。`python tools/device.py` 为手动验收辅助工具，支持启动、点击、输入、返回和保存实际模拟器截图。

## 联机与本地体验

验证码登录使用本机 `word-api`，直接返回验证码，不发送短信；仅登录及联机账号资料联网。聊天、社交和个人资料属于本地教学演示；连接失败不会自动登录。接口、配置与会话行为见 [课程登录接口](docs/AUTH_API.md)。

本地体验不依赖后端。联机验收需另行运行课程提供的 `word-api`（服务源码不在本仓库），确保主机 `http://127.0.0.1:3000/doc/swagger-api` 可访问，再执行：

```bash
"$hdc_bin" rport tcp:3000 tcp:3000
"$hdc_bin" fport ls
```

如果已存在相同 `[Reverse]` 转发，无需重复创建。登录页输入虚构课程号码（例如 `10000000001`），点击获取验证码、填入课程验证码，再登录；设置页可查看独立的联机资料或退出。联机会话不持久化，冷启动重新选择登录或本地体验；原有课程数据会保留。

## 许可证与素材

源代码采用 [GNU Affero General Public License v3.0](LICENSE)（AGPL-3.0-only）。本项目原有头像、插图、音视频来自课程提供的工程素材，保留其原有权利归属；代码许可证不表示对第三方素材拥有额外授权。

Axios 等依赖及随 HAP 分发的许可说明见 [第三方声明](THIRD_PARTY_NOTICES.md)。
