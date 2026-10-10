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
    List({ space: 12 }) {
      ListItem() {
        Row({ space: 18 }) {
          Image(avatarResource(this.profile.avatar)).width(70).height(70).borderRadius(12)
          Column({ space: 10 }) {
            Text(this.profile.name).fontSize(24 * this.fontScale).fontWeight(FontWeight.Bold)
            Text('微信号：' + this.profile.account).fontSize(14 * this.fontScale).fontColor(TEXT_SECONDARY)
            Text(this.profile.signature).fontSize(14 * this.fontScale).fontColor(TEXT_SECONDARY)
          }.layoutWeight(1).alignItems(HorizontalAlign.Start)
        }.width('100%').padding({ left: 24, right: 24, top: 44, bottom: 32 }).backgroundColor(Color.White)
      }
      ListItem() {
        MenuRow({ title: '我的朋友圈', rowId: 'profile-moments', icon: $r('app.media.pic'), color: '#4374C1', onOpen: () => {
          this.getUIContext().getRouter().pushUrl({ url: 'pages/Moments', params: { mineOnly: true } });
        } })
      }
    }.height('100%').width('100%').backgroundColor(BACKGROUND)
  }
}
