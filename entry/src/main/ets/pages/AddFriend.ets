import { PageHeader } from '../components/PageHeader';
import { Contact } from '../model/Models';
import { AppStore } from '../services/AppStore';
import { avatarResource, BACKGROUND, DIVIDER_COLOR, GREEN, TEXT_PRIMARY, TEXT_SECONDARY } from '../common/Theme';

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

  @Builder
  inputRow(label: string, value: string, placeholder: string, maxLength: number, onInput: (value: string) => void) {
    Row() {
      Text(label).fontSize(17 * this.fontScale).fontColor(TEXT_PRIMARY).width(80 * this.fontScale)
      TextInput({ text: value, placeholder: placeholder }).layoutWeight(1).height(54)
        .fontSize(17 * this.fontScale).placeholderFont({ size: 17 * this.fontScale }).placeholderColor('#B2B2B2')
        .backgroundColor(Color.Transparent).padding(0).borderRadius(0).caretColor(GREEN).maxLength(maxLength)
        .onChange((text: string) => { onInput(text); this.error = ''; })
    }.width('100%').padding({ left: 16, right: 16 }).constraintSize({ minHeight: 54 })
  }

  build() {
    Column() {
      PageHeader({ title: '添加朋友' })
      Scroll() {
        Column() {
          Row({ space: 8 }) {
            Text('🔍').fontSize(15)
            TextInput({ text: this.account, placeholder: '微信号/手机号' }).layoutWeight(1).height(40)
              .fontSize(16 * this.fontScale).placeholderFont({ size: 16 * this.fontScale }).placeholderColor('#B2B2B2')
              .backgroundColor(Color.Transparent).padding(0).borderRadius(0).caretColor(GREEN).maxLength(32)
              .onChange((value: string) => { this.account = value; this.error = ''; })
          }.padding({ left: 12, right: 12 }).margin({ left: 8, right: 8, top: 4 }).height(40)
          .backgroundColor(Color.White).borderRadius(6)
          Text('我的微信号：' + AppStore.data.profile.account).fontSize(14 * this.fontScale).fontColor(TEXT_SECONDARY)
            .margin({ top: 14, bottom: 22 })
          Text('朋友资料').fontSize(14 * this.fontScale).fontColor(TEXT_SECONDARY).width('100%')
            .padding({ left: 16, bottom: 8 })
          Column() {
            Row() {
              Text('头像').fontSize(17 * this.fontScale).fontColor(TEXT_PRIMARY).width(80 * this.fontScale)
              Row({ space: 10 }) {
                ForEach(this.avatars, (avatar: string) => {
                  Image(avatarResource(avatar)).width(44).height(44).borderRadius(4)
                    .border({ width: this.avatar === avatar ? 2 : 0, color: GREEN })
                    .opacity(this.avatar === avatar ? 1 : 0.6)
                    .accessibilityText('选择头像 ' + avatar).onClick(() => { this.avatar = avatar; })
                }, (avatar: string) => avatar)
              }.layoutWeight(1)
            }.width('100%').padding({ left: 16, right: 16, top: 10, bottom: 10 })
            Divider().strokeWidth(0.5).color(DIVIDER_COLOR).margin({ left: 16 })
            this.inputRow('昵称', this.name, '必填', 20, (value: string) => { this.name = value; })
            Divider().strokeWidth(0.5).color(DIVIDER_COLOR).margin({ left: 16 })
            this.inputRow('地区', this.region, '选填', 30, (value: string) => { this.region = value; })
          }.backgroundColor(Color.White).width('100%')
          if (this.error) {
            Text(this.error).fontSize(14 * this.fontScale).fontColor('#FA5151').width('100%')
              .padding({ left: 16, right: 16, top: 12 })
          }
          Button(this.saving ? '正在添加…' : '添加到通讯录', { type: ButtonType.Normal })
            .width(184).height(48).borderRadius(8).margin({ top: 40 })
            .fontSize(17 * this.fontScale).fontWeight(FontWeight.Medium)
            .backgroundColor(GREEN).fontColor(Color.White).enabled(!this.saving).onClick(() => { this.add(); })
        }.width('100%').padding({ bottom: 32 })
      }.align(Alignment.TopStart).layoutWeight(1).width('100%')
    }.width('100%').height('100%').backgroundColor(BACKGROUND)
  }
}
