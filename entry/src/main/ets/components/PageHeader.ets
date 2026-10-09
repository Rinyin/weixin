import { BACKGROUND, GREEN, TEXT_PRIMARY } from '../common/Theme';

@Component
export struct PageHeader {
  @Prop title: string = '';
  @Prop back: boolean = true;
  @Prop action: string = '';
  @StorageLink('fontScale') fontScale: number = 1;
  onAction: () => void = () => {};

  build() {
    Row() {
      if (this.back) {
        Button('‹', { type: ButtonType.Normal })
          .fontSize(34).fontColor(TEXT_PRIMARY).backgroundColor(Color.Transparent)
          .width(44).height(48).accessibilityText('返回')
          .onClick(() => this.getUIContext().getRouter().back())
      } else {
        Blank().width(44)
      }
      Text(this.title).fontSize(19 * this.fontScale).fontWeight(FontWeight.Medium)
        .fontColor(TEXT_PRIMARY).layoutWeight(1).textAlign(TextAlign.Center).maxLines(1)
      Button(this.action, { type: ButtonType.Normal })
        .fontSize(15 * this.fontScale).fontColor(GREEN).backgroundColor(Color.Transparent)
        .constraintSize({ minWidth: 44, minHeight: 48 }).padding({ left: 6, right: 10 })
        .visibility(this.action ? Visibility.Visible : Visibility.Hidden)
        .onClick(() => this.onAction())
    }.width('100%').constraintSize({ minHeight: 56 }).backgroundColor(BACKGROUND)
  }
}
