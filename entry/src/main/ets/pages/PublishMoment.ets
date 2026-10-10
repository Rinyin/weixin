import { PageHeader } from '../components/PageHeader';
import { BACKGROUND, GREEN, momentImage, TEXT_SECONDARY } from '../common/Theme';
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
      PageHeader({ title: '发表朋友圈' })
      Scroll() {
        Column({ space: 20 }) {
          TextArea({ text: this.text, placeholder: '这一刻的想法…' }).id('moment-draft')
            .fontSize(18 * this.fontScale).height(190 * this.fontScale).maxLength(1000).backgroundColor(Color.White)
            .onChange((value: string) => { this.text = value; })
          Text('添加配图（可选，点击取消选择）').fontSize(14 * this.fontScale).fontColor(TEXT_SECONDARY)
          Row({ space: 12 }) {
            ForEach(this.images, (name: string) => {
              Image(momentImage(name)).id('moment-image-' + name).width('29%').aspectRatio(1).objectFit(ImageFit.Cover)
                .borderRadius(6).border({ width: this.image === name ? 3 : 0, color: GREEN })
                .accessibilityText('选择课程配图 ' + name)
                .onClick(() => { this.image = this.image === name ? '' : name; })
            }, (name: string) => name)
          }.width('100%')
          Text('内容仅保存在本机，用于课程展示。').fontSize(13 * this.fontScale).fontColor(TEXT_SECONDARY)
          if (this.error) { Text(this.error).fontSize(14 * this.fontScale).fontColor('#C33B32') }
          Button(this.saving ? '正在发表…' : '发表').id('moment-publish').fontSize(17 * this.fontScale)
            .width('100%').height(48 * this.fontScale).backgroundColor(GREEN)
            .enabled(!this.saving && this.text.trim().length > 0).onClick(() => { this.publish(); })
        }.padding(20).width('100%').alignItems(HorizontalAlign.Start)
      }.align(Alignment.TopStart).layoutWeight(1).width('100%')
    }.height('100%').width('100%').backgroundColor(BACKGROUND)
  }
}
