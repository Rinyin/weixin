import { PageHeader } from '../components/PageHeader';
import { AppStore } from '../services/AppStore';
import { Contact } from '../model/Models';
import { avatarResource, BACKGROUND } from '../common/Theme';

@Entry
@Component
struct StartChat {
  @StorageLink('fontScale') fontScale: number = 1;
  @State query: string = '';

  build() {
    Column() {
      PageHeader({ title: '发起聊天' })
      Search({ value: this.query, placeholder: '搜索朋友' }).textFont({ size: 16 * this.fontScale })
        .placeholderFont({ size: 16 * this.fontScale })
        .margin({ left: 14, right: 14, bottom: 12 }).onChange((text: string) => { this.query = text; })
      List() {
        ForEach(AppStore.data.contacts.filter((item: Contact) => item.name.includes(this.query.trim()) ||
          item.account.includes(this.query.trim())), (item: Contact) => {
          ListItem() {
            Row({ space: 14 }) {
              Image(avatarResource(item.avatar)).width(46).height(46).borderRadius(7)
              Text(item.name).fontSize(17 * this.fontScale)
            }.padding(16).width('100%').backgroundColor(Color.White)
          }.onClick(() => {
            this.getUIContext().getRouter().replaceUrl({ url: 'pages/Chat', params: { contactId: item.id } });
          })
        }, (item: Contact) => item.id)
      }.layoutWeight(1).width('100%').divider({ strokeWidth: 0.5, color: '#EEEEEE', startMargin: 76 })
    }.width('100%').height('100%').backgroundColor(BACKGROUND)
  }
}
