import { PageHeader } from '../components/PageHeader';
import { AppStore } from '../services/AppStore';
import { BACKGROUND, GREEN, TEXT_SECONDARY } from '../common/Theme';

@Entry
@Component
struct FontSettings {
  @StorageLink('fontScale') fontScale: number = 1;
  @State draftScale: number = AppStorage.get<number>('fontScale') || 1;
  @State saving: boolean = false;
  @State error: string = '';
  @State saved: boolean = false;

  private choose(value: number): void {
    this.draftScale = Math.round(value * 100) / 100;
    this.saved = false;
    this.error = '';
  }

  private async apply(): Promise<void> {
    if (this.saving) { return; }
    this.saving = true;
    this.error = '';
    try { await AppStore.setFontScale(this.draftScale); this.saved = true; }
    catch { this.error = '字体保存失败，请检查设备存储后重试'; }
    finally { this.saving = false; }
  }

  build() {
    Column() {
      PageHeader({ title: '字体大小' })
      Scroll() {
        Column({ space: 24 }) {
          Text('当前字号：' + Math.round(this.fontScale * 100).toString() + '%')
            .id('font-current').fontSize(17 * this.fontScale).fontWeight(FontWeight.Medium)
          Column({ space: 14 }) {
            Text('预览文字').fontSize(21 * this.draftScale).fontWeight(FontWeight.Medium)
            Text('聊天、通讯录和页面文字一起变化。选择适合你的阅读大小。')
              .fontSize(17 * this.draftScale).width('100%')
            Text('Hello HarmonyOS · 123456').fontSize(14 * this.draftScale).fontColor(TEXT_SECONDARY)
          }.padding(22).width('100%').backgroundColor(Color.White).borderRadius(12).alignItems(HorizontalAlign.Start)
          Text('预览比例 ' + Math.round(this.draftScale * 100).toString() + '%')
            .fontSize(15 * this.fontScale).fontColor(TEXT_SECONDARY)
          Slider({ value: this.draftScale, min: 0.85, max: 1.4, step: 0.05 })
            .id('font-slider').width('100%').selectedColor(GREEN).showSteps(true).enabled(!this.saving)
            .onChange((value: number) => { this.choose(value); })
          Row({ space: 10 }) {
            Button('标准').id('font-default').layoutWeight(1).fontSize(15 * this.fontScale)
              .backgroundColor(Color.White).fontColor('#333333').enabled(!this.saving).onClick(() => this.choose(1))
            Button('大').id('font-large').layoutWeight(1).fontSize(15 * this.fontScale)
              .backgroundColor(Color.White).fontColor('#333333').enabled(!this.saving).onClick(() => this.choose(1.2))
            Button('特大').id('font-largest').layoutWeight(1).fontSize(15 * this.fontScale)
              .backgroundColor(Color.White).fontColor('#333333').enabled(!this.saving).onClick(() => this.choose(1.4))
          }.width('100%')
          Button(this.saving ? '正在应用…' : '应用字体大小').id('font-apply').fontSize(17 * this.fontScale)
            .width('100%').height(48 * this.fontScale).backgroundColor(GREEN).enabled(!this.saving)
            .onClick(() => { this.apply(); })
          if (this.saved) { Text('已应用，将在下次启动时保留。').fontSize(14 * this.fontScale).fontColor(GREEN) }
          if (this.error) { Text(this.error).fontSize(14 * this.fontScale).fontColor('#C33B32') }
        }.padding(24).width('100%').alignItems(HorizontalAlign.Start)
      }.align(Alignment.TopStart).layoutWeight(1).width('100%')
    }.height('100%').width('100%').backgroundColor(BACKGROUND)
  }
}
