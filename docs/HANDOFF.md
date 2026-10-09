# 新对话接手入口

本文件是跨对话的固定入口；状态和测试证据分别引用 `PROGRESS.md` 与 `TEST_REPORT.md`，不要重新从头实现。

## 给新对话的提示词

```text
先阅读 AGENTS.md、docs/HANDOFF.md 和 docs/PROGRESS.md，核对 git status 后，
从接续点继续完成实验任务；逐功能实现并在现有模拟器验证，不重复已通过的无关测试。
```

## 原始任务与用户修订

- 原始要求来自仓库相邻目录 `../鸿蒙微信应用/微信小程序开发实验报告.md`，已完整阅读，功能拆分见 [进度表](PROGRESS.md)。
- 用户要求随时可中断，因此每项完成后记录证据并独立提交。不要大量测试或创建不必要备份。
- 用户后续明确仓库应为**公开 GitHub + AGPL-3.0**，README 明示课程作业；仓库地址见 [README](../README.md) 及 Git remote。
- 用户确认本机已启动 `word-api`，已通过本机在线 Swagger 核对契约；不要继续尝试报告中过期的私网地址。
- 当前任务持续进行中，用户提出“如何让新对话接手”不表示取消原来的全部开发任务。

## 接续点（2026-10-09）

本轮按用户要求于北京时间 23:50 左右收尾暂停（用户需关机，最迟不得超过 23:58）。下次用户要求继续即恢复，不要把已过期的当日截止时间当成新的限制。

F0、F1 已验证并提交；F2 已构建、安装并验证主要流程：新增“小陈”（`course_friend_01`）、资料页发消息、字母索引跳转、强制停止重启后联系人及消息保留、按微信号搜索。**仅重复添加错误提示尚待补验**：最后点击“添加到通讯录”后 HDC UITest dumpLayout 连续超时，未获得提示截图；不要把它记成通过，也不要未经检查就判定应用崩溃。

下次先确认 DevEco、模拟器、word-api 是否重新启动，补验重复账号提示；随后继续 F3。当前代码已经编译并通过上述主要流程，无需重复开发或整套重测 F0/F1。发现和我仍为原始静态页面；朋友圈、视频号、个人设置、登录和汇报材料未完成。

F2 最新构建与安装输出在 `.local/build-F2.log`、`.local/install-F2.log`；截图 `docs/screenshots/f2-*.png`。Git 哈希查 `git log -3 --oneline`。

先运行 `git status --short --branch`，检查是否有用户在上一轮之后新增的修改。工作区代码优先于本段描述；功能最新完成情况以 [PROGRESS.md](PROGRESS.md) 和 Git 历史为准。

## 已确认的运行通道

- DevEco 已打开本工程，安装目录为 `C:/Program Files/Huawei/DevEco Studio`；同目录 SDK、Node、Hvigor 可用。
- Git Bash：`bash tools/build.sh > .local/build-F1.log 2>&1`。构建通常 8–15 秒，不需重装环境。
- HDC：`C:/Program Files/Huawei/DevEco Studio/sdk/default/openharmony/toolchains/hdc.exe`；当前目标 `127.0.0.1:5555`。先 `list targets` 检查新会话时是否仍在线。
- `hdc install -r entry/build/default/outputs/default/entry-default-unsigned.hap` 在当前模拟器已成功，不必为它额外配置签名。
- `python tools/device.py launch|snapshot|tap x y|text x y 文本|back|stop` 控制真实模拟器并输出布局；`--shot 名称` 保存实际截图到 `docs/screenshots/`。图片用 FastCtx 查看。
- 本轮缺少 computer-use 的 `node_repl` 入口，不是应用失败；通过 DevEco 配套 Hvigor + HDC 实际编译/安装/交互。如果新对话拥有原生窗口工具，可直接使用已运行窗口。
- 本轮曾执行 `hdc rport tcp:3000 tcp:3000`；关机重启后需重新检查/建立转发，F6 尚须在应用中验证。避免重启无关服务。

## 后端契约与实现提醒

Swagger `http://127.0.0.1:3000/doc/swagger-api`，OpenAPI 为同路径加 `-json`。

- `GET /word/user/code?phone=<string>` → `{ code: 200, data: "验证码", message: "成功" }`。直接回包，不发短信；有效 10 分钟；实际可为 4–8 位，必须保留字符串及前导零。
- `POST /word/user/login`，JSON `{ phone: string, code: string }` → `data` 为 JWT。首次登录创建本机课程用户。
- `GET /word/user/info` 请求头为 `token: <原始 JWT>` → `data: { nickname, avatarUrl }`。
- HTTP 200 也可能业务失败，检查 `code === 200`；201 未登录、202 未填验证码、203 过期、204 错误、205 未填手机号、209 通用失败。
- 实际测试使用虚构的课程手机号。不要将会话 token 或验证码写入仓库；不要把离线体验写成真实登录通过。
- ArkTS 静态方法内部不可用 `this`，用类名；`Search` 字体使用 `textFont` / `placeholderFont`。
- AppStore 对初始化失败设置禁止写入，避免种子数据覆盖旧文件；后续保留该保护。

## 更新规则和技能

每项功能完成或外部阻塞变化时更新本文件“接续点”、进度表及真实测试记录，然后提交。代码与证据已有的细节通过链接引用，不复制整份聊天。

继续开发通常不需新技能；真实难复现 bug 才考虑 diagnose，制作报告要求的汇报 PPT 使用 presentations；再次整理接手文档可使用 handoff。技能规则仍服从本轮用户已明确的范围和授权。
