import { CompassList } from '../components/CompassList';
import { ContackList } from '../components/ContackList';
import { Profile } from '../components/Profile';
import { WeixinContainer } from '../components/WeixinContainer';
import { BACKGROUND, GREEN } from '../common/Theme';
import { SessionMode } from '../model/AuthModels';
import { SessionStore } from '../services/SessionStore';

@Entry
@Component
struct Index {
  @State currentIndex: number = 0;
  @StorageLink('fontScale') fontScale: number = 1;
  @StorageLink('storeError') storeError: string = '';
  @StorageLink('sessionMode') sessionMode: SessionMode = SessionMode.SignedOut;

  onPageShow(): void {
    if (SessionStore.mode === SessionMode.SignedOut) { this.returnToLogin(); }
  }

  private async returnToLogin(): Promise<void> {
    try {
      await this.getUIContext().getRouter().replaceUrl({ url: 'pages/Login' });
    } catch {
      this.storeError = '登录页打开失败，请重启应用';
    }
  }
  @Builder
  createTabBar(ImgR: Resource, title: string, index: number) {
    Column({ space: 3 }) {
      Image(ImgR).width(25).height(25).fillColor(this.currentIndex === index ? GREEN : '#555555')
      Text(title).fontSize(11 * this.fontScale).fontColor(this.currentIndex === index ? GREEN : '#555555')
    }.width('100%').height('100%').justifyContent(FlexAlign.Center)
  }
  build() {
    Column() {
      Text(this.sessionMode === SessionMode.Online ? '课程服务已登录 · 社交数据为本地教学数据' : '本地体验 · 未登录课程服务')
        .id('session-status').fontSize(12 * this.fontScale).fontColor('#576B75')
        .padding(8).width('100%').backgroundColor('#E5F0EA')
      if (this.storeError) {
        Text(this.storeError).fontSize(13 * this.fontScale).fontColor('#B64236')
          .padding(10).width('100%').backgroundColor('#FFF0E9')
      }
    Tabs({ barPosition: BarPosition.End , index: this.currentIndex}) {
      TabContent() {
        WeixinContainer()
      }.tabBar(this.createTabBar($r('app.media.weixin'), '微信', 0))

      TabContent() {
        ContackList()
      }.tabBar(this.createTabBar($r('app.media.contactlist'), '通讯录', 1))

      TabContent() {
        CompassList()
      }.tabBar(this.createTabBar($r('app.media.compass'), '发现', 2))

      TabContent() {
        Profile()
      }.tabBar(this.createTabBar($r('app.media.me'), '我', 3))
    }.onChange((index: number) => {this.currentIndex = index})
    .backgroundColor(BACKGROUND)
    .barWidth('100%').barHeight(58 * this.fontScale)
    .divider({ strokeWidth: 0.5, color: '#D8D8D8' }).scrollable(false).layoutWeight(1)
    }.width('100%').height('100%').backgroundColor(BACKGROUND)
  }
}
