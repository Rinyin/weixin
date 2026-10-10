# 实际验证记录

环境：2026-10-09，Windows，已启动 DevEco Studio 6.0.2，HarmonyOS 模拟器 `127.0.0.1:5555`（1316 × 2832）。使用 IDE 自带 Hvigor/SDK 构建，并通过 HDC 在该模拟器中安装、启动和操作；未使用浏览器预览替代运行验证。

| 功能 | 实际操作 | 结果 | 证据 |
| --- | --- | --- | --- |
| F0 主框架 | 编译 HAP → `hdc install -r` → 启动 → 依次点微信、通讯录、发现、我 | 通过；四个页签可切换，默认微信页，无定位授权弹窗 | [截图](screenshots/f0-framework.png) |
| F1 聊天 | 打开虎子会话 → 中文消息“周末一起去海边吧” → 表情面板选择 😊 → 展开弹窗发送 → 强制停止并重启 → 搜索旧关键词“周末” → ＋选择虎子 | 通过；空消息禁用；两条消息均保留，列表预览刷新，旧关键词仍可搜索；弹窗/表情可用 | [会话列表](screenshots/f1-chats.png)、[消息](screenshots/f1-chat-message.png)、[表情与重启后消息](screenshots/f1-emoji-panel.png)、[输入弹窗](screenshots/f1-message-editor.png) |
| F2 通讯录主流程 | 通讯录 T 索引 → 添加“小陈 / course_friend_01” → 查看资料 → 发消息“你好，很高兴认识你！” → 强制停止重启 → 按微信号搜索 | 通过；联系人和消息保留，详情进入对应会话，索引能滚动到目标组 | [列表](screenshots/f2-contacts.png)、[新增](screenshots/f2-add-friend.png)、[详情](screenshots/f2-contact-detail.png)、[新会话](screenshots/f2-new-chat.png)、[重启搜索](screenshots/f2-search-persisted.png) |
| F2 重复添加提示 | 2026-10-10，在现有模拟器 `127.0.0.1:5557` 再次填写“小陈 / course_friend_01”，收起键盘后点击添加 | 通过；明确提示“该微信号已在通讯录中，请勿重复添加”，停留当前页 | [重复提示](screenshots/f2-duplicate-contact.png) |
| F3 朋友圈 | 2026-10-10 构建安装 → 发现/朋友圈浏览两条种子动态 → 点赞敖丙动态并评论“今天也要开心” → 发表文字及猫咪配图 → 我/我的朋友圈 | 通过；旧联系人和消息仍在；点赞评论即时更新；发表返回列表首项；我的朋友圈仅展示自己的动态；空发表和空评论发送按钮禁用 | [浏览](screenshots/f3-moments-feed.png)、[互动](screenshots/f3-interaction.png)、[发表](screenshots/f3-publish.png)、[我的朋友圈](screenshots/f3-my-moments.png) |
| F3 重启保留 | 强制停止并重新启动应用 → 发现/朋友圈 → 下滑查看原动态 | 通过；新发表的图文、敖丙动态的点赞和评论均保留 | [发表保留](screenshots/f3-restart-published.png)、[互动保留](screenshots/f3-restart-interaction.png) |
| F4 播放与切换 | 2026-10-10 构建安装 → 发现/视频号 → 播放首段 → 暂停 → 下一条并播放 → 再切第三条 | 通过；真实画面变化、进度从 00:01 增至 00:47；暂停后两次读取均为 00:49；三个源均能播放 | [播放](screenshots/f4-video-playing.png)、[暂停](screenshots/f4-video-paused.png)、[第二段](screenshots/f4-video-second.png)、[第三段](screenshots/f4-video-third.png) |
| F4 生命周期与入口 | 播放时回到桌面 → 重新进入 → 返回发现 → 我/视频号；退出前后读取系统播放器服务 | 通过；后台恢复为已暂停；返回正常；“我”入口从 00:00 就绪；退出前 PlayerServer 有 1 个实例，退出后为 0 个 | [后台暂停](screenshots/f4-background-paused.png)、[返回](screenshots/f4-return-discover.png)、[我的入口](screenshots/f4-profile-entry.png)；系统取证留本机 `.local/`，未开展压力或内存泄漏测试 |
| F5 个人资料 | 2026-10-10 编辑昵称/头像/地区/签名；空昵称保存；修改成功后打开我的朋友圈；强制停止重启 | 通过；空昵称明确拒绝；“我”和朋友圈同步昵称/头像；重启后全部字段保留 | [保存](screenshots/f5-profile-saved.png)、[朋友圈同步](screenshots/f5-moments-font.png)、[重启资料](screenshots/f5-profile-persisted.png) |
| F5 全局字体 | 设置中应用 140%；检查四 Tabs、联系人详情、聊天、弹窗与键盘、朋友圈及视频页；重启后进入字体设置；验后恢复 100% | 通过；字号同步、关键按钮可达、无观察到的文字遮挡；重启仍显示 140%，恢复标准字号成功 | [大字号](screenshots/f5-font-largest.png)、[通讯录](screenshots/f5-contacts-font.png)、[详情](screenshots/f5-contact-detail-font.png)、[聊天](screenshots/f5-chat-font.png)、[键盘弹窗](screenshots/f5-editor-keyboard.png)、[发现](screenshots/f5-discover-font.png)、[视频](screenshots/f5-video-font.png)、[重启字号](screenshots/f5-restart-font.png) |
| F6 构建与取码 | 2026-10-10，现有模拟器 `127.0.0.1:5557`；Hvigor 构建、HDC 覆盖安装并冷启动；空手机号取码；虚构课程号码取码；回桌面后重新打开 | 通过；登录页为空手机号给出格式提示；真实服务取码后按钮倒计时且禁用重复请求，倒计时结束恢复；后台恢复由 59 秒变为 57 秒，保留当前输入 | [输入校验](screenshots/f6-login-validation.png)、[取码](screenshots/f6-code-countdown.png)、[后台恢复](screenshots/f6-countdown-resume.png)；本机 `.local/build-F6.log`、`.local/install-F6.log` |
| F6 业务登录与资料 | 输入错误验证码提交；再填入本次课程验证码登录；我/设置查看联机资料；退出登录 | 通过；错误码明确提示并停留登录页；真实 login 和 info 成功后才进入联机主页；设置显示服务返回的昵称与头像，本地“小林同学”资料保持独立；退出回到清空表单的登录页 | [错误验证码](screenshots/f6-wrong-code.png)、[联机主页](screenshots/f6-online.png)、[联机资料](screenshots/f6-online-profile.png)、[退出](screenshots/f6-sign-out.png) |
| F6 连接失败 | 暂时移除本应用使用的 3000 反向转发，点击取码；取证后恢复同一转发，未停止后端服务 | 通过；显示“无法连接课程服务”，仍在登录页，可重试或主动进入本地体验；网络失败未被标为登录成功 | [失败提示](screenshots/f6-network-failure.png) |
| F6 取消与迟到响应 | 本机临时代理转发真实 login/info，将成功的 info 响应延迟 8 秒；“正在登录”时点击本地体验，再等待 9 秒 | 通过；等待中表单与重复提交禁用，本地体验按钮仍可用；迟到响应释放后仍显示“本地体验 · 未登录课程服务”；设置亦显示未登录。代理随后关闭，原转发已恢复 | [等待状态](screenshots/f6-login-pending.png)、[进入本地](screenshots/f6-local.png)、[等待后仍为本地](screenshots/f6-cancelled-stays-local.png)、[本地设置](screenshots/f6-local-settings.png)；无凭据代理日志留本机 `.local/f6-delayed-proxy.log` |
| F6 新页面字号与冷启动 | 对新登录/设置内容应用 140%；滚动登录页并完成取码、填入和真实登录；联机状态强制停止、重新打开；进入本地体验后恢复 100% | 通过；新内容换行正常，输入框和按钮可滚动到达，登录成功；冷启动清空登录表单，未恢复联机会话；本地联系人、消息与“小林同学”资料仍在。验后恢复标准字号 | [设置大字号](screenshots/f6-settings-font.png)、[登录页顶部](screenshots/f6-login-font-top.png)、[登录操作区](screenshots/f6-login-font-bottom.png)、[大字号登录成功](screenshots/f6-online-font.png)、[冷启动](screenshots/f6-cold-start.png) |
| F7 产物交付 | 复用 F6 同一 HAP；检查 ZIP、版本、权限和许可，生成交付副本及校验文件；发布 v1.0.0；比对全部远端附件与源码标签 | 通过；65 个 ZIP 条目 CRC 全过，无重复/越界路径；HAP 为 49,993,097 字节，仅 INTERNET；6 个公开附件的 GitHub SHA-256 摘要和大小均与本地一致，源码标签为 `515be15`。未为仅改文档重跑无关测试 | [交付说明](DELIVERY.md)、[Release](https://github.com/Rinyin/weixin/releases/tag/v1.0.0)；本机 `.local/release-verification.json` |

构建详细输出保存在本机忽略目录 `.local/`。每项仅进行必要构建和相关功能操作；未运行与改动无关的压力测试或测试模板。

F1 的必要修正：Search 使用当前 SDK 支持的 `textFont`；静态存储方法使用类名访问；表情按钮清除默认内边距以避免图案裁切。只读审查发现初始化失败可能覆盖旧数据，已增加写入保护；该故障保护经过代码审查，未伪称做过破坏数据的设备测试。

F6 使用虚构课程手机号，验证码输入控件遮蔽显示，辅助工具也隐藏验证码日志。业务仅连接本机 word-api；没有调用真实短信或微信服务。实际响应中 login 的 HTTP 状态为 201、业务 code 为 200，info 为 HTTP 200、业务 code 为 200。未逐一模拟验证码过期、服务端畸形数据、10 秒超时或所有业务错误码；这些分支仅做实现及只读审查。构建仍有原工程图标基础资源、可能抛异常调用及未配置签名提示，构建成功与设备安装运行分别以上述证据为准。
