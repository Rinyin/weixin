import { AppStore } from '../services/AppStore';
import { Contact, ChatMessage } from '../model/Models';
import { avatarResource, BACKGROUND, TEXT_SECONDARY, timeLabel } from '../common/Theme';
import { PageHeader } from './PageHeader';

interface Conversation {
  contact: Contact;
  lastMessage: ChatMessage;
}

@Component
export struct WeixinContainer {
  @StorageLink('revision') @Watch('refresh') revision: number = 0;
  @StorageLink('fontScale') fontScale: number = 1;
  @State query: string = '';
  @State conversations: Conversation[] = [];

  aboutToAppear(): void { this.refresh(); }

  refresh(): void {
    const items: Conversation[] = [];
    AppStore.data.contacts.forEach((contact: Contact) => {
      const messages = AppStore.data.messages.filter((message: ChatMessage) => message.contactId === contact.id);
      if (messages.length > 0) {
        items.push({ contact: contact, lastMessage: messages[messages.length - 1] });
      }
    });
    this.conversations = items.sort((a: Conversation, b: Conversation) => b.lastMessage.createdAt - a.lastMessage.createdAt);
  }

  filtered(): Conversation[] {
    const text = this.query.trim().toLowerCase();
    return this.conversations.filter((item: Conversation) =>
      item.contact.name.toLowerCase().includes(text) || AppStore.data.messages.some((message: ChatMessage) =>
        message.contactId === item.contact.id && message.text.toLowerCase().includes(text)));
  }

  build() {
    Column() {
      PageHeader({ title: '微信', back: false, action: '＋', onAction: () => {
        this.getUIContext().getRouter().pushUrl({ url: 'pages/StartChat' });
      } })
      Search({ value: this.query, placeholder: '搜索联系人或聊天内容' })
        .textFont({ size: 15 * this.fontScale }).placeholderFont({ size: 15 * this.fontScale })
        .height(40 * this.fontScale).margin({ left: 14, right: 14, bottom: 12 })
        .onChange((value: string) => { this.query = value; })
      List() {
        ForEach(this.filtered(), (item: Conversation) => {
          ListItem() {
            Row({ space: 12 }) {
              Image(avatarResource(item.contact.avatar)).width(52).height(52).borderRadius(8).objectFit(ImageFit.Cover)
              Column({ space: 7 }) {
                Row() {
                  Text(item.contact.name).fontSize(17 * this.fontScale).fontWeight(FontWeight.Medium)
                    .layoutWeight(1).maxLines(1).textOverflow({ overflow: TextOverflow.Ellipsis })
                  Text(timeLabel(item.lastMessage.createdAt)).fontSize(11 * this.fontScale).fontColor('#999999')
                }.width('100%')
                Text(item.lastMessage.text).fontSize(14 * this.fontScale).fontColor(TEXT_SECONDARY)
                  .width('100%').maxLines(1).textOverflow({ overflow: TextOverflow.Ellipsis })
              }.layoutWeight(1).alignItems(HorizontalAlign.Start)
            }.width('100%').padding({ left: 16, right: 16, top: 15, bottom: 15 })
            .backgroundColor(Color.White)
          }.onClick(() => {
            this.getUIContext().getRouter().pushUrl({ url: 'pages/Chat', params: { contactId: item.contact.id } });
          })
        }, (item: Conversation) => item.contact.id + item.lastMessage.id)
        if (this.filtered().length === 0) {
          ListItem() {
            Text(this.query ? '没有找到相关聊天' : '点击右上角 ＋，开始一段聊天')
              .fontSize(15 * this.fontScale).fontColor(TEXT_SECONDARY).padding(32).width('100%').textAlign(TextAlign.Center)
          }
        }
      }.divider({ strokeWidth: 0.5, color: '#EEEEEE', startMargin: 80 }).layoutWeight(1).width('100%')
    }.width('100%').height('100%').backgroundColor(BACKGROUND)
  }
}
