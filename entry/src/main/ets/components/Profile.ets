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
    groupTitle: '服务',
    items: [
      {
        imgIcon: $r('app.media.service'),
        itemTitle: '服务',
        iconColor: '#21bbc1'
      }
    ]
  },
  {
    groupTitle: '收藏',
    items: [
      {
        imgIcon: $r('app.media.shoucang'),
        itemTitle: '收藏',
        iconColor: '#ffc84d'
      },
      {
        imgIcon: $r('app.media.pic'),
        itemTitle: '朋友圈',
        iconColor: '#4374c1'
      },
      {
        imgIcon: $r('app.media.cardbag'),
        itemTitle: '卡包',
        iconColor: '#1e8de6'
      },
      {
        imgIcon: $r('app.media.face'),
        itemTitle: '表情',
        iconColor: '#ebc41f'
      }
    ]
  },
  {
    groupTitle: '设置',
    items: [
      {
        imgIcon: $r('app.media.setting'),
        itemTitle: '设置',
        iconColor: '#3f72c5'
      }
    ]
  }
]


@Component

export struct Profile {
  @Builder
  itemFooter() {
    Row(){

    }.height(15)
    .width('100%')
  }

  build() {
    Column(){
      Row(){
        Column(){
          Image($r('app.media.avatar7'))
            .width(100)
            .height(100)
            .borderRadius(8)
            .margin({
              left: 20,
              right: 15
            })
        }
        Column(){
          Row(){
            Text('yy').fontSize(24).fontWeight(FontWeight.Bold)
              .margin({bottom: 15})
          }
          Row(){
            Text('微信号：yy1').fontSize(20).margin({bottom: 15}).fontColor(Color.Gray)
          }
          Row(){
            Button(){
              Row(){
                Image($r('app.media.add')).width(20)
                Text('状态').fontColor(Color.Gray)
              }.width(80)
              .justifyContent(FlexAlign.Center)
              .height(30)
              .backgroundColor(Color.White)
              .border({
                width: 1,
                color: '#ededed',
                radius: 15
              })
            }
          }
        }.width(200)
        .alignItems(HorizontalAlign.Start)
      }.height(220)
      .width('100%')
      .backgroundColor(Color.White)
      .margin({bottom :15 })
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
      .width('100%')
      .height(430)
    }
    .width('100%')
    .height('100%')
  }
}