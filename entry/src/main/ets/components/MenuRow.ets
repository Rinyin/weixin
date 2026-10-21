import { TEXT_PRIMARY, TEXT_SECONDARY } from '../common/Theme';

@Component
export struct MenuRow {
  @Prop title: string = '';
  @Prop icon: Resource = $r('app.media.pengyouquan');
  @Prop color: string = '#07C160';
  @StorageLink('fontScale') fontScale: number = 1;
  onOpen: () => void = () => {};

  build() {
    Row({ space: 14 }) {
      Image(this.icon).width(24).height(24).fillColor(this.color)
      Text(this.title).fontSize(17 * this.fontScale).fontColor(TEXT_PRIMARY).layoutWeight(1)
      Text('›').fontSize(24).fontColor('#B2B2B2')
    }.width('100%').padding({ left: 16, right: 16, top: 14, bottom: 14 }).constraintSize({ minHeight: 56 })
      .backgroundColor(Color.White).accessibilityGroup(true).accessibilityText(this.title)
      .onClick(() => this.onOpen())
  }
}
