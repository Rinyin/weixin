interface ComPassItem {
  imgIcon: Resource; //图标
  itemTitle: string; //条目内容
  iconColor: string; //图标颜色
}
interface CompassItemGroup {
  groupTitle: string;
  items: ComPassItem[]

}
const compassItems : CompassItemGroup[] = [
  {
    groupTitle: '朋友圈',
    items: [
      {
        imgIcon: $r('app.media.pengyouquan'),
        itemTitle: '朋友圈',
        iconColor: '#21bbc1'
      }
    ]
  },
  {
    groupTitle: '视频号',
    items: [
      {
        imgIcon: $r('app.media.shipinhao'),
        itemTitle: '视频号',
        iconColor: '#f4a13c'
      },
      {
        imgIcon: $r('app.media.zhibo'),
        itemTitle: '直播',
        iconColor: '#ea7a69'
      }
    ]
  }
]
@Component
export struct CompassList{
  @Builder
  itemFooter() {
    Row(){

    }.height(20)
    .width('100%')
  }

  build() {
    Column() {
      //发现头
      Row() {
        Text(`发现`).fontSize(20)
      }.width('85%')
      .height(50)
      .justifyContent(FlexAlign.Center)

      //列表
      List(){
        ForEach(compassItems, (itemGroup: CompassItemGroup) => {
          ListItemGroup({footer: this.itemFooter()}){
            ForEach(itemGroup.items, (item: ComPassItem) => {
              ListItem(){
                Row() {
                  Column() {
                    Image(item.imgIcon).width(26).fillColor(item.iconColor)
                      .margin({left : 20, right: 10})
                  }.height(80)
                  .justifyContent(FlexAlign.Center)

                  Column() {
                    Stack(){
                      Text(item.itemTitle).fontSize(20)
                      Divider().margin({top: 79})
                    }.alignContent(Alignment.Start)

                  }.height(80)
                }.backgroundColor(Color.White)
                .width('100%')
              }
            })
          }
        })
      }

    }.height('100%')
    .width('100%')
  }
}