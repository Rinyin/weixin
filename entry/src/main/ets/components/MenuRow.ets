import { TEXT_PRIMARY, TEXT_SECONDARY } from '../common/Theme';

@Component
export struct MenuRow {
  @Prop title: string = '';
  @Prop icon: Resource = $r('app.media.pengyouquan');
  @Prop color: string = '#07A854';
  @Prop rowId: string = '';
  @StorageLink('fontScale') fontScale: number = 1;
  onOpen: () => void = () => {};

  build() {
    Row({ space: 16 }) {
      Image(this.icon).width(25).height(25).fillColor(this.color)
      Text(this.title).fontSize(17 * this.fontScale).fontColor(TEXT_PRIMARY).layoutWeight(1)
      Text('›').fontSize(25).fontColor(TEXT_SECONDARY)
    }.id(this.rowId).width('100%').padding(20).constraintSize({ minHeight: 68 })
      .backgroundColor(Color.White).accessibilityGroup(true).accessibilityText(this.title)
      .onClick(() => this.onOpen())
  }
}
