import { PageHeader } from '../components/PageHeader';
import { MessageEditor } from '../components/MessageEditor';
import { AppStore } from '../services/AppStore';
import { ChatMessage, Contact, ContactRoute } from '../model/Models';
import { ListDataSource } from '../common/ListDataSource';
import { avatarResource, BACKGROUND, GREEN, timeLabel } from '../common/Theme';

@Entry
@Component
struct Chat {
  @StorageLink('fontScale') fontScale: number = 1;
  @State contact: Contact | undefined = undefined;
  @State draft: string = '';
  @State emojiVisible: boolean = false;
  @State sending: boolean = false;
  @State messageCount: number = 0;
  private contactId: string = '';
  private scroller: Scroller = new Scroller();
  private source: ListDataSource<ChatMessage> = new ListDataSource<ChatMessage>();
  private scrollTimer: number = -1;
  // 与上一条消息间隔超过 5 分钟才显示时间，贴近微信的时间分隔方式。
  private timeIds: Set<string> = new Set<string>();
  private emojis: string[] = ['😀', '😊', '🥰', '😎', '🤔', '😂', '😭', '🥳', '👍', '👏', '❤️', '🌹', '☀️', '🎉', '🍀', '🏀',
    '😁', '😉', '😘', '😜', '😴', '😡', '😱', '🙏', '💪', '👌', '🤝', '🎂', '🌙', '⭐', '☕', '🍉'];
  private editor: CustomDialogController = new CustomDialogController({
    builder: MessageEditor({ text: $draft, onSend: () => { this.send(); } }),
    alignment: DialogAlignment.Center,
    autoCancel: true
  });

  aboutToAppear(): void {
    const params = this.getUIContext().getRouter().getParams() as ContactRoute;
    this.contactId = params?.contactId || '';
    this.contact = AppStore.contact(this.contactId);
    this.refresh();
  }

  aboutToDisappear(): void {
    if (this.scrollTimer !== -1) { clearTimeout(this.scrollTimer); }
    this.editor.close();
  }

  private refresh(): void {
    const messages = AppStore.data.messages.filter((item: ChatMessage) => item.contactId === this.contactId);
    const timeIds = new Set<string>();
    let last = 0;
    messages.forEach((item: ChatMessage) => {
      if (item.createdAt - last > 5 * 60 * 1000) { timeIds.add(item.id); }
      last = item.createdAt;
    });
    this.timeIds = timeIds;
    this.source.replace(messages);
    this.messageCount = messages.length;
    this.scrollToBottom();
  }

  private async send(): Promise<void> {
    const text = this.draft.trim();
    if (!this.contact || !text || this.sending) { return; }
    this.sending = true;
    const previous = AppStore.data.messages;
    const message: ChatMessage = {
      id: AppStore.id('message'), contactId: this.contactId, text: text.slice(0, 2000), mine: true, createdAt: Date.now()
    };
    AppStore.data.messages = previous.concat([message]);
    try {
      await AppStore.save();
      this.draft = '';
      this.refresh();
    } catch {
      AppStore.data.messages = previous;
      this.getUIContext().getPromptAction().showToast({ message: '消息保存失败，请重试' });
    } finally {
      this.sending = false;
    }
  }

  private hideInputs(): void {
    this.emojiVisible = false;
    this.getUIContext().getFocusController().clearFocus();
  }

  private toggleEmoji(): void {
    if (this.emojiVisible) {
      this.emojiVisible = false;
      return;
    }
    // 先收起键盘再展示表情面板，避免二者叠加。
    this.getUIContext().getFocusController().clearFocus();
    this.emojiVisible = true;
    this.scrollToBottom();
  }

  private scrollToBottom(): void {
    if (this.scrollTimer !== -1) { clearTimeout(this.scrollTimer); }
    this.scrollTimer = setTimeout(() => { this.scroller.scrollEdge(Edge.Bottom); }, 100);
  }

  @Builder
  messageBubble(item: ChatMessage) {
    Column({ space: 12 }) {
      if (this.timeIds.has(item.id)) {
        Text(timeLabel(item.createdAt)).fontSize(12 * this.fontScale).fontColor('#B2B2B2')
      }
      Row({ space: 10 }) {
        if (item.mine) { Blank() }
        if (!item.mine) {
          Image(avatarResource(this.contact?.avatar || '')).width(40).height(40).borderRadius(4)
        }
        Text(item.text).fontSize(17 * this.fontScale).fontColor('#191919')
          .padding({ left: 12, right: 12, top: 10, bottom: 10 })
          .backgroundColor(item.mine ? '#95EC69' : '#FFFFFF').borderRadius(4)
          .constraintSize({ maxWidth: '70%', minHeight: 40 }).copyOption(CopyOptions.LocalDevice)
        if (item.mine) {
          Image(avatarResource(AppStore.data.profile.avatar)).width(40).height(40).borderRadius(4)
        }
        if (!item.mine) { Blank() }
      }.width('100%').alignItems(VerticalAlign.Top)
    }.padding({ left: 12, right: 12, top: 8, bottom: 8 }).width('100%')
  }

  build() {
    Column() {
      PageHeader({ title: this.contact?.name || '聊天', action: this.contact ? '⋯' : '', actionLabel: '聊天信息',
        onAction: () => {
          this.getUIContext().getRouter().pushUrl({ url: 'pages/ContactDetail', params: { contactId: this.contactId } });
        } })
      Divider().strokeWidth(0.5).color('#DDDDDD')
      if (!this.contact) {
        Text('联系人不存在，请返回通讯录重新选择。').fontSize(16 * this.fontScale).padding(24)
      } else {
        List({ scroller: this.scroller }) {
          if (this.messageCount === 0) {
            ListItem() {
              Text('打个招呼吧').fontSize(14 * this.fontScale).fontColor('#B2B2B2').padding(32)
                .width('100%').textAlign(TextAlign.Center)
            }
          }
          LazyForEach(this.source, (item: ChatMessage) => {
            ListItem() { this.messageBubble(item) }
          }, (item: ChatMessage) => item.id)
        }.layoutWeight(1).width('100%').scrollBar(BarState.Off).padding({ top: 4, bottom: 4 })
        .onAreaChange(() => { this.scrollToBottom(); })
        .onClick(() => { this.hideInputs(); })
        Row({ space: 8 }) {
          TextInput({ text: this.draft, placeholder: '' }).fontSize(17 * this.fontScale)
            .constraintSize({ minHeight: 40 }).layoutWeight(1).borderRadius(4).backgroundColor(Color.White)
            .caretColor(GREEN).maxLength(2000).enterKeyType(EnterKeyType.Send).onSubmit(() => { this.send(); })
            .onFocus(() => { this.emojiVisible = false; })
            .onChange((value: string) => { this.draft = value; })
            .accessibilityText('输入消息')
          Text(this.emojiVisible ? '⌨' : '☺').fontSize(28).fontColor('#191919').width(36).height(40)
            .textAlign(TextAlign.Center).accessibilityText(this.emojiVisible ? '键盘' : '表情')
            .onClick(() => { this.toggleEmoji(); })
          if (this.draft.trim().length > 0) {
            Button(this.sending ? '…' : '发送', { type: ButtonType.Normal })
              .fontSize(15 * this.fontScale).height(34).padding({ left: 12, right: 12 })
              .backgroundColor(GREEN).borderRadius(4).enabled(!this.sending)
              .onClick(() => { this.send(); })
          } else {
            Text('⊕').fontSize(28).fontColor('#191919').width(36).height(40).textAlign(TextAlign.Center)
              .accessibilityText('展开输入框').onClick(() => { this.hideInputs(); this.editor.open(); })
          }
        }.width('100%').padding({ left: 10, right: 10, top: 8, bottom: 8 }).backgroundColor('#F7F7F7')
        .border({ width: { top: 0.5 }, color: '#DDDDDD' })
        if (this.emojiVisible) {
          Scroll() {
            Flex({ wrap: FlexWrap.Wrap }) {
              ForEach(this.emojis, (emoji: string) => {
                Text(emoji).fontSize(30).width('12.5%').height(52).textAlign(TextAlign.Center)
                  .accessibilityText('表情 ' + emoji).onClick(() => {
                    if (this.draft.length + emoji.length <= 2000) { this.draft += emoji; }
                  })
              }, (emoji: string) => emoji)
            }.padding({ left: 8, right: 8, top: 12, bottom: 12 })
          }.height(240).backgroundColor('#F7F7F7')
        }
      }
    }.width('100%').height('100%').backgroundColor(BACKGROUND)
  }
}
