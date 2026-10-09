import { it } from "@ohos/hypium"
import { Contacts } from "./Contacts"
//索引
const  alphabets = ['#', 'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K',
  'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z'];
@Component
export struct  ContackList {
  @State selectedIndex: number = 0;
  private listScroller: Scroller = new Scroller();

  @State contacts: Contacts[] = [
    new Contacts($r('app.media.newFriends'), '新的朋友', '#fa9c3e'),
    new Contacts($r('app.media.xinxihuihuaxiaox11i'), '仅聊天的朋友', '#fa9c3e'),
    new Contacts($r('app.media.qunliao'), '群聊', '#08c05e'),
    new Contacts($r('app.media.label'), '标签', '#fa9c3e'),
    new Contacts($r('app.media.gongzhonghao'), '公众号', '#1584ef'),
    new Contacts($r('app.media.servicelist'), '服务号', '#1584ef'),
    new Contacts($r('app.media.qiyeweixin'), '企业微信联系人','#2781d7'),
  ]

  @State qiyeContacts: Contacts[] =[
    new Contacts($r('app.media.qiyeweixin'), '企业微信联系人','#2781d7')
  ]
  @State Acontacts : Contacts[]= [
    new Contacts($r('app.media.avatar2'), '敖炳')
  ]
  @State Bcontacts : Contacts[]= [
    new Contacts($r('app.media.avatar6'), '兵甲'),
    new Contacts($r('app.media.avatar6'), '兵乙')
  ]
  @State Hcontacts : Contacts[]= [
    new Contacts($r('app.media.avatar1'), '虎子')
  ]
  @State Tcontacts : Contacts[]= [
    new Contacts($r('app.media.avatar4'), '太乙真人')
  ]
  @State Ncontacts : Contacts[]= [
    new Contacts($r('app.media.avatar3'), '哪吒')
  ]
  @State Jcontacts : Contacts[]= [
    new Contacts($r('app.media.avatar5'), '结界兽甲'),
    new Contacts($r('app.media.avatar5'), '结界兽乙')
  ]
  @State Lcontacts : Contacts[]= [
    new Contacts($r('app.media.avatar6'), '李靖')
  ]
  @Builder
  createListItem(item: Contacts, setBgColor: boolean = false, bgColor?: string){
    Row() {
      Column() {
        if(!setBgColor){
          Image(item.getAvatar())
            .width(50)
            .height(50)
            .margin({ left: 10, right: 10 })
        } else {
          Row(){
            Image(item.getAvatar()).fillColor(Color.White)
              .width(36)
          }.width(50)
          .height(50)
          .justifyContent(FlexAlign.Center)
          .backgroundColor(item.getBgColor())
          .borderRadius(8)
        }
      }.margin({left: 20})

      Column() {
        Row() {
          Text(item.getNickName()).fontSize(18);
        }.width('100%')
        .height('100%')
        .alignItems(VerticalAlign.Center)
      }.width(260)
      .height(78)
      .margin({left: 10})
      Divider()
    }
    .backgroundColor(Color.White)
    .width('100%')
    .height(80)
  }

  @Builder itemHead(text: string) {
    // 列表分组的头部组件，对应联系人分组A、B等位置的组件
    Row(){
      Text(text)
        .fontSize(20)
        .width('100%')
        .padding(5)
        .margin({left: 20, top: 30})
    }.width('100%')

  }

  build() {
    //Text('今晚老地方见')
    Column() {
      //微信头
      //文字和按钮是叠放的
      Stack() {
        Row() {
          Text(`通讯录`).fontSize(20)
        }.width('85%')
        .height(50)
        .justifyContent(FlexAlign.Center)

        Row() {
          Button() {
            Image($r('app.media.addFriends')).width(26)
          }.margin({ right: 15 })
          .backgroundColor('#ededed')
        }.width('100%')
        .justifyContent(FlexAlign.End)
      }

      //搜索框
      Search({ placeholder: '搜索' }).width('90%')
        .margin({
          bottom: 15
        })
      //消息提示
      //聊天列表
      Stack({ alignContent: Alignment.End }) {
        List() {
          ForEach(this.contacts, (item: Contacts) => {
            ListItem() {
              this.createListItem(item, true, '#fa9c3e')
            }
          })
          ListItemGroup({ header: this.itemHead('我的企业') }) {
            ForEach(this.qiyeContacts, (item: Contacts) => {
              ListItem() {
                this.createListItem(item, true, '#fa9c3e')
              }
            })
          }

          ListItemGroup({ header: this.itemHead('A') }) {
            ForEach(this.Acontacts, (item: Contacts) => {
              ListItem() {
                this.createListItem(item, false)
              }
            })
          }

          ListItemGroup({ header: this.itemHead('B') }) {
            ForEach(this.Bcontacts, (item: Contacts) => {
              ListItem() {
                this.createListItem(item)
              }
            })
          }

          ListItemGroup({ header: this.itemHead('H') }) {
            ForEach(this.Hcontacts, (item: Contacts) => {
              ListItem() {
                this.createListItem(item)
              }
            })
          }

          ListItemGroup({ header: this.itemHead('L') }) {
            ForEach(this.Lcontacts, (item: Contacts) => {
              ListItem() {
                this.createListItem(item)
              }
            })
          }

          ListItemGroup({ header: this.itemHead('N') }) {
            ForEach(this.Ncontacts, (item: Contacts) => {
              ListItem() {
                this.createListItem(item)
              }
            })
          }

          ListItemGroup({ header: this.itemHead('T') }) {
            ForEach(this.Tcontacts, (item: Contacts) => {
              ListItem() {
                this.createListItem(item)
              }
            })
          }

        }.width('100%')
        .onScrollIndex((firstIndex: number) => {
          // 根据列表滚动到的索引值，重新计算对应联系人索引栏的位置this.selectedIndex
          if(firstIndex <= 3) {
            this.selectedIndex = 1
          } else if(firstIndex <= 4) {
            this.selectedIndex = 2
          } else if(firstIndex <= 5) {
            this.selectedIndex = 8
          } else if(firstIndex <= 6) {
            this.selectedIndex = 12
          } else if(firstIndex <= 7) {
            this.selectedIndex = 14
          } else if(firstIndex <= 9) {
            this.selectedIndex = 20
          }
        }).margin({
          bottom: 100
        })
        // 字母表索引组件
        AlphabetIndexer({ arrayValue: alphabets, selected: 0 })
          .selected(this.selectedIndex)
          .margin({right: 5})
      }.width('100%')
      .height('auto')
      .backgroundColor('#ededed')

    }
  }
}