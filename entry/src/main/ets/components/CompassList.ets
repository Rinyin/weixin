import { PageHeader } from './PageHeader';
import { MenuRow } from './MenuRow';
import { BACKGROUND, TEXT_SECONDARY } from '../common/Theme';

@Component
export struct CompassList {
  @StorageLink('fontScale') fontScale: number = 1;

  build() {
    Column() {
      PageHeader({ title: '发现', back: false })
      List({ space: 12 }) {
        ListItem() {
          MenuRow({ title: '朋友圈', rowId: 'discover-moments', onOpen: () => {
            this.getUIContext().getRouter().pushUrl({ url: 'pages/Moments', params: { mineOnly: false } });
          } })
        }
        ListItem() {
          Text('本地课程数据 · 分享生活中的小美好').fontSize(13 * this.fontScale)
            .fontColor(TEXT_SECONDARY).padding(20).width('100%').textAlign(TextAlign.Center)
        }
      }.layoutWeight(1).width('100%')
    }.height('100%').width('100%').backgroundColor(BACKGROUND)
  }
}
