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

构建详细输出保存在本机忽略目录 `.local/`。每项仅进行必要构建和相关功能操作；未运行与改动无关的压力测试或测试模板。

F1 的必要修正：Search 使用当前 SDK 支持的 `textFont`；静态存储方法使用类名访问；表情按钮清除默认内边距以避免图案裁切。只读审查发现初始化失败可能覆盖旧数据，已增加写入保护；该故障保护经过代码审查，未伪称做过破坏数据的设备测试。
