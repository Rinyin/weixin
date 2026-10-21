import { CompassList } from '../components/CompassList';
import { ContackList } from '../components/ContackList';
import { Profile } from '../components/Profile';
import { WeixinContainer } from '../components/WeixinContainer';
import { BACKGROUND, BAR_BACKGROUND, GREEN } from '../common/Theme';
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
      Image(ImgR).width(26).height(26).fillColor(this.currentIndex === index ? GREEN : '#191919')
      Text(title).fontSize(11 * this.fontScale).fontColor(this.currentIndex === index ? GREEN : '#191919')
    }.width('100%').height('100%').justifyContent(FlexAlign.Center)
  }
  build() {
    Column() {
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
    .backgroundColor(BACKGROUND).barBackgroundColor(BAR_BACKGROUND)
    .barWidth('100%').barHeight(56 * this.fontScale)
    .divider({ strokeWidth: 0.5, color: '#E0E0E0' }).scrollable(false).layoutWeight(1)
    }.width('100%').height('100%').backgroundColor(BACKGROUND)
  }
}
