import { PageHeader } from '../components/PageHeader';
import { AppStore } from '../services/AppStore';
import { ProfileService } from '../services/ProfileService';
import { avatarResource, BACKGROUND, DIVIDER_COLOR, GREEN, TEXT_PRIMARY, TEXT_SECONDARY } from '../common/Theme';

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
  @State pickerVisible: boolean = false;
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

  @Builder
  editRow(label: string, value: string, placeholder: string, maxLength: number, onInput: (value: string) => void) {
    Row({ space: 12 }) {
      Text(label).fontSize(17 * this.fontScale).fontColor(TEXT_PRIMARY)
      TextInput({ text: value, placeholder: placeholder }).layoutWeight(1).height(56)
        .fontSize(16 * this.fontScale).fontColor(TEXT_SECONDARY).textAlign(TextAlign.End)
        .placeholderFont({ size: 16 * this.fontScale }).placeholderColor('#B2B2B2')
        .backgroundColor(Color.Transparent).padding(0).borderRadius(0).caretColor(GREEN).maxLength(maxLength)
        .onChange((text: string) => { onInput(text); this.error = ''; })
      Text('›').fontSize(22).fontColor('#B2B2B2')
    }.width('100%').padding({ left: 16, right: 16 }).constraintSize({ minHeight: 56 })
  }

  @Builder
  rowDivider() {
    Divider().strokeWidth(0.5).color(DIVIDER_COLOR).margin({ left: 16 })
  }

  build() {
    Column() {
      PageHeader({ title: '个人资料', action: this.saving ? '保存中' : '保存', primary: true,
        actionEnabled: !this.saving && this.name.trim().length > 0, onAction: () => { this.save(); } })
      Scroll() {
        Column() {
          Column() {
            Row() {
              Text('头像').fontSize(17 * this.fontScale).fontColor(TEXT_PRIMARY).layoutWeight(1)
              Image(avatarResource(this.avatar)).width(56).height(56).borderRadius(6)
              Text('›').fontSize(22).fontColor('#B2B2B2').margin({ left: 12 })
            }.width('100%').padding({ left: 16, right: 16, top: 14, bottom: 14 })
            .accessibilityText('更换头像').onClick(() => { this.pickerVisible = !this.pickerVisible; })
            if (this.pickerVisible) {
              Flex({ wrap: FlexWrap.Wrap }) {
                ForEach(this.avatars, (avatar: string) => {
                  Image(avatarResource(avatar)).width(52).height(52).margin(6).borderRadius(6)
                    .border({ width: this.avatar === avatar ? 2 : 0, color: GREEN })
                    .accessibilityText('选择头像 ' + avatar)
                    .onClick(() => { this.avatar = avatar; this.pickerVisible = false; })
                }, (avatar: string) => avatar)
              }.width('100%').padding({ left: 10, right: 10, bottom: 10 })
            }
            this.rowDivider()
            this.editRow('名字', this.name, '填写名字', 20, (value: string) => { this.name = value; })
            this.rowDivider()
            Row() {
              Text('微信号').fontSize(17 * this.fontScale).fontColor(TEXT_PRIMARY).layoutWeight(1)
              Text(AppStore.data.profile.account).fontSize(16 * this.fontScale).fontColor(TEXT_SECONDARY)
            }.width('100%').padding({ left: 16, right: 16 }).height(56)
          }.backgroundColor(Color.White).width('100%')
          Column() {
            this.editRow('地区', this.region, '未设置', 30, (value: string) => { this.region = value; })
            this.rowDivider()
            this.editRow('个性签名', this.signature, '未填写', 80, (value: string) => { this.signature = value; })
          }.backgroundColor(Color.White).width('100%').margin({ top: 8 })
          if (this.error) {
            Text(this.error).fontSize(14 * this.fontScale).fontColor('#FA5151').width('100%').padding(16)
          }
        }.width('100%')
      }.align(Alignment.TopStart).layoutWeight(1).width('100%')
    }.height('100%').width('100%').backgroundColor(BACKGROUND)
  }
}
