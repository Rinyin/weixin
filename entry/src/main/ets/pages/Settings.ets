import { PageHeader } from '../components/PageHeader';
import { MenuRow } from '../components/MenuRow';
import { BACKGROUND, TEXT_SECONDARY } from '../common/Theme';

@Entry
@Component
struct Settings {
  @StorageLink('fontScale') fontScale: number = 1;

  build() {
    Column() {
      PageHeader({ title: '设置' })
      List({ space: 12 }) {
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
          Text('课程应用\n聊天、联系人、朋友圈与资料保存在此设备。').fontSize(14 * this.fontScale)
            .fontColor(TEXT_SECONDARY).textAlign(TextAlign.Center).width('100%').padding(24)
        }
      }.width('100%').layoutWeight(1)
    }.height('100%').width('100%').backgroundColor(BACKGROUND)
  }
}
