import { PageHeader } from '../components/PageHeader';
import { AppStore } from '../services/AppStore';
import { ProfileService } from '../services/ProfileService';
import { avatarResource, BACKGROUND, GREEN, TEXT_SECONDARY } from '../common/Theme';

@Entry
@Component
struct EditProfile {
  @StorageLink('fontScale') fontScale: number = 1;
  @State name: string = AppStore.data.profile.name;
  @State avatar: string = AppStore.data.profile.avatar;
  @State region: string = AppStore.data.profile.region;
  @State signature: string = AppStore.data.profile.signature;
  @State saving: boolean = false;
  @State error: string = '';
  private avatars: string[] = ['avatar1', 'avatar2', 'avatar3', 'avatar4', 'avatar5', 'avatar6', 'avatar7'];
  private active: boolean = true;

  aboutToDisappear(): void { this.active = false; }

  private async save(): Promise<void> {
    if (this.saving) { return; }
    if (!this.name.trim()) { this.error = '昵称不能为空'; return; }
    this.saving = true;
    this.error = '';
    try {
      await ProfileService.save({ name: this.name, account: AppStore.data.profile.account,
        avatar: this.avatar, region: this.region, signature: this.signature });
      if (this.active) { this.getUIContext().getRouter().back(); }
    } catch {
      if (this.active) { this.error = '资料保存失败，请检查设备存储后重试'; }
    } finally { if (this.active) { this.saving = false; } }
  }

  build() {
    Column() {
      PageHeader({ title: '个人资料' })
      Scroll() {
        Column({ space: 16 }) {
          Text('选择头像').fontSize(16 * this.fontScale)
          Flex({ wrap: FlexWrap.Wrap }) {
            ForEach(this.avatars, (avatar: string) => {
              Image(avatarResource(avatar)).id('profile-avatar-' + avatar).width(58).height(58).margin(6)
                .borderRadius(10).border({ width: this.avatar === avatar ? 3 : 0, color: GREEN })
                .accessibilityText('选择头像 ' + avatar).onClick(() => { this.avatar = avatar; })
            }, (avatar: string) => avatar)
          }.width('100%')
          Text('昵称').fontSize(15 * this.fontScale).fontColor(TEXT_SECONDARY)
          TextInput({ text: this.name, placeholder: '填写昵称' }).id('profile-name').maxLength(20)
            .height(48 * this.fontScale).fontSize(17 * this.fontScale).onChange((value: string) => { this.name = value; })
          Text('微信号：' + AppStore.data.profile.account).fontSize(14 * this.fontScale).fontColor(TEXT_SECONDARY)
          Text('地区').fontSize(15 * this.fontScale).fontColor(TEXT_SECONDARY)
          TextInput({ text: this.region, placeholder: '填写地区' }).id('profile-region').maxLength(30)
            .height(48 * this.fontScale).fontSize(17 * this.fontScale).onChange((value: string) => { this.region = value; })
          Text('个性签名').fontSize(15 * this.fontScale).fontColor(TEXT_SECONDARY)
          TextArea({ text: this.signature, placeholder: '写下你的个性签名' }).id('profile-signature').maxLength(80)
            .height(100 * this.fontScale).fontSize(17 * this.fontScale).onChange((value: string) => { this.signature = value; })
          if (this.error) { Text(this.error).fontSize(14 * this.fontScale).fontColor('#C33B32') }
          Button(this.saving ? '正在保存…' : '保存资料').id('profile-save').width('100%').height(48 * this.fontScale)
            .fontSize(17 * this.fontScale).backgroundColor(GREEN).enabled(!this.saving).onClick(() => { this.save(); })
        }.padding(20).width('100%').alignItems(HorizontalAlign.Start)
      }.align(Alignment.TopStart).layoutWeight(1).width('100%')
    }.height('100%').width('100%').backgroundColor(BACKGROUND)
  }
}
