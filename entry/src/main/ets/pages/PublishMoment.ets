import { GREEN, momentImage, TEXT_PRIMARY } from '../common/Theme';
import { MomentsService } from '../services/MomentsService';

@Entry
@Component
struct PublishMoment {
  @StorageLink('fontScale') fontScale: number = 1;
  @State text: string = '';
  @State image: string = '';
  @State saving: boolean = false;
  @State error: string = '';
  private images: string[] = ['img1', 'cherry', 'dog'];

  private async publish(): Promise<void> {
    if (this.saving || !this.text.trim()) { return; }
    this.saving = true;
    this.error = '';
    try {
      await MomentsService.publish(this.text, this.image);
      this.getUIContext().getRouter().back();
    } catch { this.error = '发表失败，请检查设备存储后重试'; }
    finally { this.saving = false; }
  }

  build() {
    Column() {
      Row() {
        Text('取消').fontSize(16 * this.fontScale).fontColor(TEXT_PRIMARY).padding({ left: 16, right: 16 })
          .height(56).onClick(() => { this.getUIContext().getRouter().back(); })
        Blank()
        Button(this.saving ? '发表中' : '发表', { type: ButtonType.Normal }).fontSize(15 * this.fontScale)
          .height(32).padding({ left: 14, right: 14 }).borderRadius(4).margin({ right: 16 })
          .backgroundColor(this.text.trim().length > 0 ? GREEN : '#E1E1E1')
          .fontColor(this.text.trim().length > 0 ? Color.White : '#B2B2B2')
          .enabled(!this.saving && this.text.trim().length > 0).onClick(() => { this.publish(); })
      }.width('100%').height(56)
      Scroll() {
        Column({ space: 16 }) {
          TextArea({ text: this.text, placeholder: '这一刻的想法...' })
            .fontSize(17 * this.fontScale).placeholderColor('#B2B2B2').constraintSize({ minHeight: 120 * this.fontScale })
            .maxLength(1000).backgroundColor(Color.Transparent).padding(0).borderRadius(0).caretColor(GREEN)
            .onChange((value: string) => { this.text = value; })
          Row({ space: 6 }) {
            ForEach(this.images, (name: string) => {
              Stack({ alignContent: Alignment.TopEnd }) {
                Image(momentImage(name)).width('100%').aspectRatio(1).objectFit(ImageFit.Cover)
                  .opacity(this.image && this.image !== name ? 0.45 : 1)
                Text(this.image === name ? '✓' : '').fontSize(14).fontColor(Color.White).width(22).height(22)
                  .textAlign(TextAlign.Center).borderRadius(11).margin(4)
                  .backgroundColor(this.image === name ? GREEN : '#66000000').border({ width: 1, color: Color.White })
              }.width('31%').accessibilityText('选择配图 ' + name)
              .onClick(() => { this.image = this.image === name ? '' : name; })
            }, (name: string) => name)
          }.width('100%')
          Divider().strokeWidth(0.5).color('#E5E5E5').margin({ top: 24 })
          Row() {
            Text('谁可以看').fontSize(16 * this.fontScale).fontColor(TEXT_PRIMARY).layoutWeight(1)
            Text('公开 ›').fontSize(15 * this.fontScale).fontColor('#B2B2B2')
          }.width('100%').height(52)
          Divider().strokeWidth(0.5).color('#E5E5E5')
          if (this.error) { Text(this.error).fontSize(14 * this.fontScale).fontColor('#FA5151') }
        }.padding({ left: 24, right: 24, top: 8, bottom: 24 }).width('100%').alignItems(HorizontalAlign.Start)
      }.align(Alignment.TopStart).layoutWeight(1).width('100%')
    }.height('100%').width('100%').backgroundColor(Color.White)
  }
}
