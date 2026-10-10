import { PageHeader } from '../components/PageHeader';
import { AppStore } from '../services/AppStore';
import { Contact, ContactRoute } from '../model/Models';
import { avatarResource, BACKGROUND, GREEN, TEXT_SECONDARY } from '../common/Theme';

@Entry
@Component
struct ContactDetail {
  @StorageLink('fontScale') fontScale: number = 1;
  @State contact: Contact | undefined = undefined;

  aboutToAppear(): void {
    const params = this.getUIContext().getRouter().getParams() as ContactRoute;
    this.contact = AppStore.contact(params?.contactId || '');
  }

  @Builder
  detail(label: string, value: string) {
    Row({ space: 20 }) {
      Text(label).fontSize(16 * this.fontScale).fontColor(TEXT_SECONDARY).width(80 * this.fontScale)
      Text(value).fontSize(16 * this.fontScale).layoutWeight(1)
    }.padding(20).width('100%').backgroundColor(Color.White)
  }

  build() {
    Column() {
      PageHeader({ title: '详细资料' })
      if (this.contact) {
        Scroll() {
          Column({ space: 12 }) {
            Row({ space: 18 }) {
              Image(avatarResource(this.contact.avatar)).width(74).height(74).borderRadius(12)
              Column({ space: 9 }) {
                Text(this.contact.name).fontSize(23 * this.fontScale).fontWeight(FontWeight.Bold)
                Text('微信号：' + this.contact.account).fontSize(14 * this.fontScale).fontColor(TEXT_SECONDARY)
              }.layoutWeight(1).alignItems(HorizontalAlign.Start)
            }.padding(24).width('100%').backgroundColor(Color.White)
            Column() {
              this.detail('地区', this.contact.region)
              Divider().color('#EEEEEE')
              this.detail('个性签名', this.contact.signature)
            }.width('100%')
            Button('发消息', { type: ButtonType.Normal }).id('contact-message')
              .fontSize(18 * this.fontScale).fontColor(GREEN).fontWeight(FontWeight.Medium)
              .width('100%').height(58 * this.fontScale).backgroundColor(Color.White)
              .onClick(() => this.getUIContext().getRouter().pushUrl({
                url: 'pages/Chat', params: { contactId: this.contact?.id || '' }
              }))
          }.width('100%')
        }.align(Alignment.TopStart).layoutWeight(1).width('100%')
      } else {
        Text('未找到联系人，请返回通讯录。').fontSize(16 * this.fontScale).padding(24)
      }
    }.width('100%').height('100%').backgroundColor(BACKGROUND)
  }
}
