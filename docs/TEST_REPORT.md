# 实际验证记录

环境：2026-10-09，Windows，已启动 DevEco Studio 6.0.2，HarmonyOS 模拟器 `127.0.0.1:5555`（1316 × 2832）。使用 IDE 自带 Hvigor/SDK 构建，并通过 HDC 在该模拟器中安装、启动和操作；未使用浏览器预览替代运行验证。

| 功能 | 实际操作 | 结果 | 证据 |
| --- | --- | --- | --- |
| F0 主框架 | 编译 HAP → `hdc install -r` → 启动 → 依次点微信、通讯录、发现、我 | 通过；四个页签可切换，默认微信页，无定位授权弹窗 | [截图](screenshots/f0-framework.png) |
| F1 聊天 | 打开虎子会话 → 中文消息“周末一起去海边吧” → 表情面板选择 😊 → 展开弹窗发送 → 强制停止并重启 → 搜索旧关键词“周末” → ＋选择虎子 | 通过；空消息禁用；两条消息均保留，列表预览刷新，旧关键词仍可搜索；弹窗/表情可用 | [会话列表](screenshots/f1-chats.png)、[消息](screenshots/f1-chat-message.png)、[表情与重启后消息](screenshots/f1-emoji-panel.png)、[输入弹窗](screenshots/f1-message-editor.png) |
| F2 通讯录主流程 | 通讯录 T 索引 → 添加“小陈 / course_friend_01” → 查看资料 → 发消息“你好，很高兴认识你！” → 强制停止重启 → 按微信号搜索 | 通过；联系人和消息保留，详情进入对应会话，索引能滚动到目标组 | [列表](screenshots/f2-contacts.png)、[新增](screenshots/f2-add-friend.png)、[详情](screenshots/f2-contact-detail.png)、[新会话](screenshots/f2-new-chat.png)、[重启搜索](screenshots/f2-search-persisted.png) |
| F2 重复添加提示 | 2026-10-10，在现有模拟器 `127.0.0.1:5557` 再次填写“小陈 / course_friend_01”，收起键盘后点击添加 | 通过；明确提示“该微信号已在通讯录中，请勿重复添加”，停留当前页 | [重复提示](screenshots/f2-duplicate-contact.png) |

构建详细输出保存在本机忽略目录 `.local/`。每项仅进行必要构建和相关功能操作；未运行与改动无关的压力测试或测试模板。

F1 的必要修正：Search 使用当前 SDK 支持的 `textFont`；静态存储方法使用类名访问；表情按钮清除默认内边距以避免图案裁切。只读审查发现初始化失败可能覆盖旧数据，已增加写入保护；该故障保护经过代码审查，未伪称做过破坏数据的设备测试。
