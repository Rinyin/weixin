import { BACKGROUND, GREEN, TEXT_PRIMARY } from '../common/Theme';

@Component
export struct PageHeader {
  @Prop title: string = '';
  @Prop back: boolean = true;
  @Prop action: string = '';
  @Prop actionLabel: string = '';
  @Prop primary: boolean = false;
  @Prop actionEnabled: boolean = true;
  @StorageLink('fontScale') fontScale: number = 1;
  onAction: () => void = () => {};

  build() {
    Row() {
      if (this.back) {
        Text('‹').fontSize(36).fontColor(TEXT_PRIMARY).width(48).height(48).textAlign(TextAlign.Center)
          .accessibilityText('返回').onClick(() => this.getUIContext().getRouter().back())
      } else {
        Blank().width(48)
      }
      Text(this.title).fontSize(17 * this.fontScale).fontWeight(FontWeight.Medium)
        .fontColor(TEXT_PRIMARY).layoutWeight(1).textAlign(TextAlign.Center).maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
      if (this.primary) {
        Button(this.action, { type: ButtonType.Normal }).fontSize(15 * this.fontScale).height(32)
          .padding({ left: 14, right: 14 }).borderRadius(4).margin({ right: 16 })
          .backgroundColor(this.actionEnabled ? GREEN : '#E1E1E1').fontColor(this.actionEnabled ? Color.White : '#B2B2B2')
          .enabled(this.actionEnabled).onClick(() => this.onAction())
      } else {
        Text(this.action).fontSize(this.action.length <= 1 ? 24 : 16 * this.fontScale).fontColor(TEXT_PRIMARY)
          .constraintSize({ minWidth: 48, minHeight: 48 }).textAlign(TextAlign.Center).padding({ left: 4, right: 8 })
          .accessibilityText(this.actionLabel || this.action)
          .visibility(this.action ? Visibility.Visible : Visibility.Hidden)
          .onClick(() => this.onAction())
      }
    }.width('100%').height(56).backgroundColor(BACKGROUND)
  }
}
