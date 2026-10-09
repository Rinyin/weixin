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
  private emojis: string[] = ['😀', '😊', '🥰', '😎', '🤔', '😂', '😭', '🥳', '👍', '👏', '❤️', '🌹', '☀️', '🎉', '🍀', '🏀'];
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
    this.source.replace(messages);
    this.messageCount = messages.length;
    if (this.scrollTimer !== -1) { clearTimeout(this.scrollTimer); }
    this.scrollTimer = setTimeout(() => { this.scroller.scrollEdge(Edge.Bottom); }, 100);
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

  @Builder
  messageBubble(item: ChatMessage) {
    Column({ space: 10 }) {
      Text(timeLabel(item.createdAt)).fontSize(11 * this.fontScale).fontColor('#999999')
      Row({ space: 10 }) {
        if (item.mine) { Blank() }
        if (!item.mine) {
          Image(avatarResource(this.contact?.avatar || '')).width(40).height(40).borderRadius(6)
        }
        Text(item.text).fontSize(17 * this.fontScale).fontColor('#191919').padding(12)
          .backgroundColor(item.mine ? '#95EC69' : '#FFFFFF').borderRadius(8)
          .constraintSize({ maxWidth: '72%' }).copyOption(CopyOptions.LocalDevice)
        if (item.mine) {
          Image(avatarResource(AppStore.data.profile.avatar)).width(40).height(40).borderRadius(6)
        }
        if (!item.mine) { Blank() }
      }.width('100%').alignItems(VerticalAlign.Top)
    }.padding({ left: 14, right: 14, top: 12, bottom: 10 }).width('100%')
  }

  build() {
    Column() {
      PageHeader({ title: this.contact?.name || '聊天' })
      if (!this.contact) {
        Text('联系人不存在，请返回通讯录重新选择。').fontSize(16 * this.fontScale).padding(24)
      } else {
        List({ scroller: this.scroller, space: 4 }) {
          if (this.messageCount === 0) {
            ListItem() {
              Text('打个招呼吧').fontSize(14 * this.fontScale).fontColor('#999999').padding(32)
                .width('100%').textAlign(TextAlign.Center)
            }
          }
          LazyForEach(this.source, (item: ChatMessage) => {
            ListItem() { this.messageBubble(item) }
          }, (item: ChatMessage) => item.id)
        }.layoutWeight(1).width('100%').scrollBar(BarState.Off)
        Row({ space: 7 }) {
          Button(this.emojiVisible ? '键盘' : '表情', { type: ButtonType.Normal })
            .fontSize(13 * this.fontScale).fontColor('#333333').backgroundColor(Color.Transparent)
            .padding(5).height(44).onClick(() => { this.emojiVisible = !this.emojiVisible; })
          TextInput({ text: this.draft, placeholder: '发消息…' }).id('chat-input').fontSize(16 * this.fontScale)
            .height(44 * this.fontScale).layoutWeight(1).borderRadius(6).backgroundColor(Color.White)
            .maxLength(2000).enterKeyType(EnterKeyType.Send).onSubmit(() => { this.send(); })
            .onChange((value: string) => { this.draft = value; })
          Button('展开', { type: ButtonType.Normal }).fontSize(12 * this.fontScale)
            .fontColor('#555555').backgroundColor(Color.Transparent).padding(3).height(44)
            .onClick(() => this.editor.open())
          Button(this.sending ? '…' : '发送', { type: ButtonType.Normal }).id('chat-send')
            .fontSize(14 * this.fontScale).height(40 * this.fontScale).padding({ left: 11, right: 11 })
            .backgroundColor(GREEN).borderRadius(6).enabled(this.draft.trim().length > 0 && !this.sending)
            .onClick(() => { this.send(); })
        }.width('100%').padding(10).backgroundColor('#F6F6F6')
        if (this.emojiVisible) {
          Flex({ wrap: FlexWrap.Wrap }) {
            ForEach(this.emojis, (emoji: string) => {
              Button(emoji, { type: ButtonType.Normal }).fontSize(27).width('12.5%').height(56).padding(0)
                .backgroundColor(Color.Transparent).onClick(() => {
                  if (this.draft.length + emoji.length <= 2000) { this.draft += emoji; }
                })
            }, (emoji: string) => emoji)
          }.padding(10).backgroundColor('#F6F6F6')
        }
      }
    }.width('100%').height('100%').backgroundColor(BACKGROUND)
  }
}
