# 新对话接手入口

本文件是跨对话的固定入口；状态和测试证据分别引用 `PROGRESS.md` 与 `TEST_REPORT.md`，不要重新从头实现。

## 给新对话的提示词

```text
先阅读 AGENTS.md、docs/HANDOFF.md 和 docs/PROGRESS.md，核对 git status 后，
从接续点继续完成实验任务；逐功能实现并在现有模拟器验证，不重复已通过的无关测试。
```

## 任务范围

- 实现 HarmonyOS 原生 ArkTS 课程应用；功能拆分见 [进度表](PROGRESS.md)，交付代码和可安装 HAP。
- 用户要求随时可中断，因此每项完成后记录证据并独立提交。不要大量测试或创建不必要备份。
- 用户后续明确仓库应为**公开 GitHub + AGPL-3.0**，README 明示课程作业；仓库地址见 [README](../README.md) 及 Git remote。
- 本机已启动 `word-api`，已通过在线 Swagger 核对契约；使用本机服务地址。
- 一次推进一项功能：实现、必要构建、现有模拟器验证、更新记录、独立提交。

## 接续点（2026-10-10）

本轮已从 F5 检查点继续，**F6 已完成并通过必要构建和现有模拟器验证**；下一项 F7 为最终交付。不要重复 F0–F6 已通过的无关测试。

F0–F2 已验证。F2 本轮补验：再次添加“小陈 / course_friend_01”，页面显示“该微信号已在通讯录中，请勿重复添加”；证据 `docs/screenshots/f2-duplicate-contact.png`。不重复已通过的主流程测试。

F3 已完成：`Moments`、`PublishMoment`、`MomentsService`、`MenuRow`；发现/我已接入朋友圈，version 1 → 2 迁移保留旧联系人、消息和资料。实际通过图文浏览、发表、点赞评论、我的朋友圈筛选及强制停止重启保留，截图 `f3-*`，构建输出 `.local/build-F3.log`。当前存有一条“小林”发布的课程动态及敖丙动态上的点赞评论。

F4 已完成：`VideoChannel`、`VideoData` 和发现/我入口；三个 MP4 均实际播放，暂停、切换、后台恢复保持暂停通过。退出前后 `PlayerDistributedService` 取证显示播放器实例 1 → 0，本机日志 `.local/f4-player-{active,exited}.txt`，截图 `f4-*`。构建 `.local/build-F4.log`，SDK 的 `VideoController` 无 release 方法，资源随组件销毁管理。

F5 已完成：`ProfileService`、`EditProfile`、`Settings`、`FontSettings`；资料及字号持久化、空昵称校验、资料跨页同步通过。140% 字号下四 Tabs、联系人详情、聊天/弹窗及键盘、朋友圈、视频布局检查通过；重启资料和字号保留。截图 `f5-*`，构建 `.local/build-F5.log`。已恢复标准字号；本机课程资料为“小林同学 / 湖北 · 武汉 / 认真学习，记录生活。”及 avatar2。`device.py replace-text-id` 可替换已有字段；原 `text-id` 会追加文本。

F6 已完成：Axios 2.2.15、`AuthModels`、`AuthService`、`SessionStore`、`Login`；入口改为登录页，Index 显示会话模式，设置显示独立联机资料并可退出；INTERNET 权限已简化。真实取码、倒计时、错误码拒绝、login/info、连接失败、请求中退出到本地、140% 字号及联机状态冷启动均通过，截图 `f6-*`。契约见 `docs/AUTH_API.md`，详细证据见测试报告。token 不持久化，验证码控件与工具输出均遮蔽。Axios MIT 许可已放入 rawfile 随 HAP 打包。

当前可安装产物为 F6 构建：`entry/build/default/outputs/default/entry-default-unsigned.hap`，已在现有模拟器安装通过。构建/安装输出为 `.local/build-F6.log`、`.local/install-F6.log`。F7 应复用这个已验证二进制，整理产物与校验信息，不因仅改文档重复构建。历史提交：F2 补验 `6a83e55`、F3 `4781846`、F4 `7b4b23e`、F5 `5fbf752`；后续提交以 Git 历史为准，验收详情见 [实际验证记录](TEST_REPORT.md)。

先运行 `git status --short --branch`，检查是否有用户在上一轮之后新增的修改。工作区代码优先于本段描述；功能最新完成情况以 [PROGRESS.md](PROGRESS.md) 和 Git 历史为准。

## 已确认的运行通道

- DevEco 已打开本工程，安装目录为 `C:/Program Files/Huawei/DevEco Studio`；同目录 SDK、Node、Hvigor 可用。
- Git Bash：`bash tools/build.sh > .local/build-F6.log 2>&1`。构建通常 8–15 秒，不需重装环境。
- HDC：`C:/Program Files/Huawei/DevEco Studio/sdk/default/openharmony/toolchains/hdc.exe`；2026-10-10 当前目标 `127.0.0.1:5557`。先 `list targets` 检查新会话时是否仍在线。
- `hdc install -r entry/build/default/outputs/default/entry-default-unsigned.hap` 在当前模拟器已成功，不必为它额外配置签名。
- `python tools/device.py launch|snapshot|tap x y|text x y 文本|back|stop` 控制真实模拟器并输出布局；支持 `click-id`、`click-text`、`replace-text-id`，`--shot 名称` 保存实际截图到 `docs/screenshots/`。冷启动后需等页面稳定再查节点；不要把短暂的桌面布局当作应用崩溃。
- 已通过 DevEco 配套 Hvigor + HDC 实际编译/安装/交互，无需依赖浏览器或原生窗口工具。
- 2026-10-10 已确认 DevEco、模拟器及本机 Swagger 在线，`hdc fport ls` 可检查 `tcp:3000 tcp:3000 [Reverse]`。F6 已实际登录；故障验证只调整本应用转发，现已恢复，临时延迟代理已关闭。避免重启无关服务。

## 后端契约与实现提醒

Swagger `http://127.0.0.1:3000/doc/swagger-api`，OpenAPI 为同路径加 `-json`。

- `GET /word/user/code?phone=<string>` → `{ code: 200, data: "验证码", message: "成功" }`。直接回包，不发短信；有效 10 分钟；实际可为 4–8 位，必须保留字符串及前导零。
- `POST /word/user/login`，JSON `{ phone: string, code: string }` → `data` 为 JWT。首次登录创建本机课程用户。
- `GET /word/user/info` 请求头为 `token: <原始 JWT>` → `data: { nickname, avatarUrl }`。
- HTTP 200 也可能业务失败，检查 `code === 200`；201 未登录、202 未填验证码、203 过期、204 错误、205 未填手机号、209 通用失败。
- 实际测试使用虚构的课程手机号。不要将会话 token 或验证码写入仓库；不要把离线体验写成真实登录通过。
- ArkTS 静态方法内部不可用 `this`，用类名；`Search` 字体使用 `textFont` / `placeholderFont`。
- AppStore 对初始化失败设置禁止写入，避免种子数据覆盖旧文件；后续保留该保护。
- Axios 2.2.15 已只读核对：从库导入 `AbortController` 并传 signal，鸿蒙不支持 CancelToken；同时配置 `timeout`、`connectTimeout`（如各 10000ms）。页面退出取消请求、清理倒计时，并防止迟到响应导航。不启用请求复用或 API 23/26 的额外选项。
- token 建议仅保存在会话内存，单独传给 info 请求；联机资料与本地课程资料分开。不要打印 Axios 错误对象、请求体、验证码或 token；截图使用虚构数据并遮蔽凭据。登录失败不能自动冒充成功。

## 更新规则和技能

每项功能完成或外部阻塞变化时更新本文件“接续点”、进度表及真实测试记录，然后提交。代码与证据已有的细节通过链接引用，不复制整份聊天。

继续开发通常不需新技能；真实难复现 bug 才考虑 diagnose；再次整理接手文档可使用 handoff。技能规则仍服从本轮用户已明确的范围和授权。
