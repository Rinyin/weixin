import { GREEN } from '../common/Theme';

@CustomDialog
export struct MessageEditor {
  controller: CustomDialogController;
  @Link text: string;
  @StorageLink('fontScale') fontScale: number = 1;
  onSend: () => void = () => {};

  build() {
    Column({ space: 16 }) {
      Text('编辑消息').fontSize(19 * this.fontScale).fontWeight(FontWeight.Medium)
      TextArea({ text: this.text, placeholder: '写下想说的话…' }).height(160)
        .fontSize(17 * this.fontScale).maxLength(2000).onChange((value: string) => { this.text = value; })
      Row({ space: 12 }) {
        Button('收起').layoutWeight(1).fontSize(16 * this.fontScale).fontColor('#444444')
          .backgroundColor('#EEEEEE').onClick(() => this.controller.close())
        Button('发送').layoutWeight(1).fontSize(16 * this.fontScale).backgroundColor(GREEN)
          .enabled(this.text.trim().length > 0).onClick(() => { this.controller.close(); this.onSend(); })
      }
    }.padding(24).borderRadius(18).backgroundColor(Color.White)
  }
}
