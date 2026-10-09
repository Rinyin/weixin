import { CompassList } from '../components/CompassList';
import { ContackList } from '../components/ContackList';
import { Profile } from '../components/Profile';
import {WeixinContainer} from '../components/WeixinContainer';

@Entry
@Component
struct Index {
  @State currentIndex: number = 2
  @Builder
  createTabBar(ImgR: Resource, title: string, index: number) {
    Column() {
      Row() {
        Image(ImgR).height(24)
          .fillColor(this.currentIndex == index ? Color.Green : Color.Gray)
      }
      Row() {
        Text(title).fontSize(12).fontColor(this.currentIndex == index ? Color.Green : Color.Gray)
      }.margin({ top: 5 })
    }
  }
  build() {
    Tabs({ barPosition: BarPosition.End , index: 2}) {
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
    .backgroundColor('#ededed')
    .barWidth('100%')  // 确保宽度设置正确
    .barHeight(50)     // 设置合适的高度
  }
}