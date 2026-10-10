import { PageHeader } from '../components/PageHeader';
import { MenuRow } from '../components/MenuRow';
import { BACKGROUND, TEXT_SECONDARY } from '../common/Theme';
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
      List({ space: 12 }) {
        ListItem() {
          Column({ space: 12 }) {
            Text(this.sessionMode === SessionMode.Online ? '课程服务已登录' : '本地体验 · 未登录')
              .id('settings-session').fontSize(18 * this.fontScale).fontWeight(FontWeight.Medium)
            if (this.sessionMode === SessionMode.Online) {
              Row({ space: 12 }) {
                Image(!this.avatarFailed && /^https?:\/\//.test(this.onlineAvatar) ? this.onlineAvatar : $r('app.media.avatar7'))
                  .width(48).height(48).borderRadius(8).accessibilityText('联机账号头像')
                  .onError(() => { this.avatarFailed = true; })
                Text('联机昵称：' + this.onlineNickname).id('settings-online-name').layoutWeight(1)
                  .fontSize(16 * this.fontScale)
              }.width('100%')
            }
            Text('聊天、联系人、朋友圈和个人资料均保存在此设备，与联机账号资料分开。')
              .fontSize(14 * this.fontScale).fontColor(TEXT_SECONDARY)
          }.width('100%').alignItems(HorizontalAlign.Start).padding(20).backgroundColor(Color.White)
        }
        ListItem() {
          MenuRow({ title: '个人资料', rowId: 'settings-profile', icon: $r('app.media.me'), color: '#3F72C5', onOpen: () => {
            this.getUIContext().getRouter().pushUrl({ url: 'pages/EditProfile' });
          } })
        }
        ListItem() {
          MenuRow({ title: '字体大小', rowId: 'settings-font', icon: $r('app.media.setting'), color: '#3F72C5', onOpen: () => {
            this.getUIContext().getRouter().pushUrl({ url: 'pages/FontSettings' });
          } })
        }
        ListItem() {
          Button(this.sessionMode === SessionMode.Online ? '退出联机登录' : '返回登录页').id('settings-sign-out')
            .width('100%').height(52 * this.fontScale).fontSize(17 * this.fontScale)
            .backgroundColor(Color.White).fontColor('#B64236').enabled(!this.leaving)
            .onClick(() => { this.leaveSession(); })
        }
        if (this.error) {
          ListItem() { Text(this.error).fontSize(14 * this.fontScale).fontColor('#B64236').padding(16) }
        }
      }.width('100%').layoutWeight(1)
    }.height('100%').width('100%').backgroundColor(BACKGROUND)
  }
}
