import { PageHeader } from '../components/PageHeader';
import { Contact } from '../model/Models';
import { AppStore } from '../services/AppStore';
import { avatarResource, BACKGROUND, GREEN, TEXT_SECONDARY } from '../common/Theme';

@Entry
@Component
struct AddFriend {
  @StorageLink('fontScale') fontScale: number = 1;
  @State name: string = '';
  @State account: string = '';
  @State region: string = '';
  @State avatar: string = 'avatar1';
  @State error: string = '';
  @State saving: boolean = false;
  private avatars: string[] = ['avatar1', 'avatar2', 'avatar3', 'avatar4'];

  private async add(): Promise<void> {
    if (this.saving) { return; }
    const name = this.name.trim();
    const account = this.account.trim();
    if (!name) { this.error = '请填写朋友的昵称'; return; }
    if (!/^[a-zA-Z0-9][a-zA-Z0-9_-]{2,31}$/.test(account)) {
      this.error = '微信号需为 3–32 位字母、数字、下划线或短横线'; return;
    }
    if (account.toLowerCase() === AppStore.data.profile.account.toLowerCase()) {
      this.error = '这是你自己的微信号'; return;
    }
    if (AppStore.data.contacts.some((contact: Contact) => contact.account.toLowerCase() === account.toLowerCase())) {
      this.error = '该微信号已在通讯录中，请勿重复添加'; return;
    }
    const first = name.charAt(0).toUpperCase();
    const contact: Contact = {
      id: AppStore.id('friend'), name: name, account: account, avatar: this.avatar,
      region: this.region.trim() || '中国', signature: '很高兴认识你。', initial: /^[A-Z]$/.test(first) ? first : '#'
    };
    const previous = AppStore.data.contacts;
    this.saving = true;
    this.error = '';
    AppStore.data.contacts = previous.concat([contact]);
    try {
      await AppStore.save();
      this.getUIContext().getRouter().replaceUrl({ url: 'pages/ContactDetail', params: { contactId: contact.id } });
    } catch {
      AppStore.data.contacts = previous;
      this.error = '保存失败，请检查存储空间后重试';
    } finally { this.saving = false; }
  }

  build() {
    Column() {
      PageHeader({ title: '添加朋友' })
      Scroll() {
        Column({ space: 18 }) {
          Text('认识新朋友，从一句你好开始').fontSize(16 * this.fontScale).fontColor(TEXT_SECONDARY)
          Row({ space: 15 }) {
            ForEach(this.avatars, (avatar: string) => {
              Image(avatarResource(avatar)).width(58).height(58).borderRadius(10)
                .border({ width: this.avatar === avatar ? 3 : 0, color: GREEN })
                .onClick(() => { this.avatar = avatar; })
            }, (avatar: string) => avatar)
          }.justifyContent(FlexAlign.Center).width('100%')
          TextInput({ text: this.name, placeholder: '昵称（必填）' }).id('friend-name').fontSize(17 * this.fontScale)
            .height(52 * this.fontScale).maxLength(20).onChange((value: string) => { this.name = value; })
          TextInput({ text: this.account, placeholder: '微信号或手机号（必填）' }).id('friend-account')
            .fontSize(17 * this.fontScale).height(52 * this.fontScale).maxLength(32)
            .onChange((value: string) => { this.account = value; })
          TextInput({ text: this.region, placeholder: '地区（选填）' }).id('friend-region')
            .fontSize(17 * this.fontScale).height(52 * this.fontScale).maxLength(30)
            .onChange((value: string) => { this.region = value; })
          if (this.error) { Text(this.error).fontSize(14 * this.fontScale).fontColor('#C33B32').width('100%') }
          Button(this.saving ? '正在保存…' : '添加到通讯录').id('friend-save')
            .fontSize(17 * this.fontScale).height(48 * this.fontScale).width('100%').backgroundColor(GREEN)
            .enabled(!this.saving).onClick(() => { this.add(); })
        }.padding(24).width('100%')
      }.layoutWeight(1).width('100%')
    }.width('100%').height('100%').backgroundColor(BACKGROUND)
  }
}
