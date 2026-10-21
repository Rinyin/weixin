import { PageHeader } from './PageHeader';
import { MenuRow } from './MenuRow';
import { BACKGROUND, TEXT_SECONDARY } from '../common/Theme';

@Component
export struct CompassList {
  @StorageLink('fontScale') fontScale: number = 1;

  build() {
    Column() {
      PageHeader({ title: '发现', back: false })
      List({ space: 8 }) {
        ListItem() {
          MenuRow({ title: '朋友圈', onOpen: () => {
            this.getUIContext().getRouter().pushUrl({ url: 'pages/Moments', params: { mineOnly: false } });
          } })
        }
        ListItem() {
          MenuRow({ title: '视频号', icon: $r('app.media.shipinhao'), color: '#F4A13C', onOpen: () => {
            this.getUIContext().getRouter().pushUrl({ url: 'pages/VideoChannel' });
          } })
        }
      }.layoutWeight(1).width('100%')
    }.height('100%').width('100%').backgroundColor(BACKGROUND)
  }
}
