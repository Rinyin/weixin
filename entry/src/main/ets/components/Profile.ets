import { AppStore } from '../services/AppStore';
import { UserProfile } from '../model/Models';
import { MenuRow } from './MenuRow';
import { avatarResource, BACKGROUND, TEXT_SECONDARY } from '../common/Theme';

@Component
export struct Profile {
  @StorageLink('fontScale') fontScale: number = 1;
  @StorageLink('revision') @Watch('refresh') revision: number = 0;
  @State profile: UserProfile = AppStore.data.profile;

  aboutToAppear(): void { this.refresh(); }
  refresh(): void { this.profile = AppStore.data.profile; }

  build() {
    List({ space: 8 }) {
      ListItem() {
        Row({ space: 16 }) {
          Image(avatarResource(this.profile.avatar)).width(64).height(64).borderRadius(8)
          Column({ space: 8 }) {
            Text(this.profile.name).fontSize(22 * this.fontScale).fontWeight(FontWeight.Medium)
            Text('微信号：' + this.profile.account).fontSize(14 * this.fontScale).fontColor(TEXT_SECONDARY)
            Text(this.profile.signature).fontSize(14 * this.fontScale).fontColor('#B2B2B2')
              .maxLines(1).textOverflow({ overflow: TextOverflow.Ellipsis })
          }.layoutWeight(1).alignItems(HorizontalAlign.Start)
          Text('›').fontSize(24).fontColor('#B2B2B2')
        }.width('100%').padding({ left: 24, right: 16, top: 64, bottom: 36 }).backgroundColor(Color.White)
          .accessibilityText('编辑个人资料').onClick(() => {
            this.getUIContext().getRouter().pushUrl({ url: 'pages/EditProfile' });
          })
      }
      ListItem() {
        MenuRow({ title: '朋友圈', icon: $r('app.media.pic'), color: '#4374C1', onOpen: () => {
          this.getUIContext().getRouter().pushUrl({ url: 'pages/Moments', params: { mineOnly: true } });
        } })
      }
      ListItem() {
        MenuRow({ title: '视频号', icon: $r('app.media.shipinhao'), color: '#F4A13C', onOpen: () => {
          this.getUIContext().getRouter().pushUrl({ url: 'pages/VideoChannel' });
        } })
      }
      ListItem() {
        MenuRow({ title: '设置', icon: $r('app.media.setting'), color: '#3F72C5', onOpen: () => {
          this.getUIContext().getRouter().pushUrl({ url: 'pages/Settings' });
        } })
      }
    }.height('100%').width('100%').backgroundColor(BACKGROUND)
  }
}
