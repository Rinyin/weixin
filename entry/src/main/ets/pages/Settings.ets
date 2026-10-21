import { PageHeader } from '../components/PageHeader';
import { MenuRow } from '../components/MenuRow';
import { BACKGROUND, GREEN, TEXT_PRIMARY, TEXT_SECONDARY } from '../common/Theme';
import { SessionMode } from '../model/AuthModels';
import { SessionStore } from '../services/SessionStore';

@Entry
@Component
struct Settings {
  @StorageLink('fontScale') fontScale: number = 1;
  @StorageLink('sessionMode') sessionMode: SessionMode = SessionMode.SignedOut;
  @StorageLink('onlineNickname') onlineNickname: string = '';
  @StorageLink('onlineAvatar') onlineAvatar: string = '';
  @State avatarFailed: boolean = false;
  @State leaving: boolean = false;
  @State error: string = '';

  private async leaveSession(): Promise<void> {
    if (this.leaving) { return; }
    this.leaving = true;
    SessionStore.reset();
    try {
      const router = this.getUIContext().getRouter();
      await router.replaceUrl({ url: 'pages/Login' });
      router.clear();
    } catch {
      this.leaving = false;
      this.error = '登录页打开失败，请重试';
    }
  }

  build() {
    Column() {
      PageHeader({ title: '设置' })
      List({ space: 8 }) {
        ListItem() {
          Row({ space: 12 }) {
            Text('账号与安全').fontSize(17 * this.fontScale).fontColor(TEXT_PRIMARY).layoutWeight(1)
            if (this.sessionMode === SessionMode.Online) {
              Text(this.onlineNickname).fontSize(15 * this.fontScale).fontColor(TEXT_SECONDARY)
                .maxLines(1).textOverflow({ overflow: TextOverflow.Ellipsis }).constraintSize({ maxWidth: '50%' })
              Image(!this.avatarFailed && /^https?:\/\//.test(this.onlineAvatar) ? this.onlineAvatar : $r('app.media.avatar7'))
                .width(32).height(32).borderRadius(4).accessibilityText('账号头像')
                .onError(() => { this.avatarFailed = true; })
            } else {
              Text('游客模式').fontSize(15 * this.fontScale).fontColor(TEXT_SECONDARY)
            }
          }.width('100%').padding({ left: 16, right: 16, top: 14, bottom: 14 }).constraintSize({ minHeight: 56 })
          .backgroundColor(Color.White)
        }
        ListItem() {
          MenuRow({ title: '个人资料', icon: $r('app.media.me'), color: '#3F72C5', onOpen: () => {
            this.getUIContext().getRouter().pushUrl({ url: 'pages/EditProfile' });
          } })
        }
        ListItem() {
          MenuRow({ title: '字体大小', icon: $r('app.media.setting'), color: '#3F72C5', onOpen: () => {
            this.getUIContext().getRouter().pushUrl({ url: 'pages/FontSettings' });
          } })
        }
        ListItem() {
          Column() {
            Text(this.sessionMode === SessionMode.Online ? '退出登录' : '登录微信')
              .fontSize(17 * this.fontScale).fontColor(this.sessionMode === SessionMode.Online ? TEXT_PRIMARY : GREEN)
              .width('100%').textAlign(TextAlign.Center).padding(16)
          }.backgroundColor(Color.White).margin({ top: 16 }).enabled(!this.leaving)
          .accessibilityGroup(true).onClick(() => { this.leaveSession(); })
        }
        if (this.error) {
          ListItem() { Text(this.error).fontSize(14 * this.fontScale).fontColor('#FA5151').padding(16) }
        }
      }.width('100%').layoutWeight(1)
    }.height('100%').width('100%').backgroundColor(BACKGROUND)
  }
}
