import { Chatter } from "./Chatter"

@Component

export struct  WeixinContainer{
  @State chatters : Chatter[]= [
    new Chatter($r('app.media.avatar1'), '虎子', '一起找老大踢毽子', '上午 12：05'),
    new Chatter($r('app.media.avatar2'), '敖炳', '我要去练武了，勿扰', '00：00'),
  new Chatter($r('app.media.avatar3'), '哪吒', '一起踢毽子', '上午 10：00'),
  new Chatter($r('app.media.avatar4'), '太乙真人', '中午有啥好吃的？', '上午 9：05'),
  new Chatter($r('app.media.avatar5'), '结界兽甲', '你知道结界兽乙去哪里偷懒了吗？', '23：40'),
    new Chatter($r('app.media.avatar6'), '李靖', '下午你值守城门你', '8：00'),
    new Chatter($r('app.media.avatar5'), '结界兽乙', '结界兽甲找你打听我了吗？', '23：50'),
    new Chatter($r('app.media.avatar6'), '兵甲', '看我的新头像，帅不帅？', '23：50'),
  ]
  @Builder
  createListItem(item: Chatter){
    Row() {
      Column() {
        Image(item.getAvatar())
          .width(50)
          .height(50)
          .margin({ left: 10, right: 10 })
      }

      Column() {
        Row() {
          Text(item.getNickName()).fontSize(18);
          Blank()
          Text(item.getLastTime()).fontSize(12).fontColor(Color.Gray);
        }.width('100%')
        .margin({ top: 16 }) //昵称和最后聊天时间
        Row() {
          Text(item.getLastWords()).fontSize(16).fontColor(Color.Gray);
        }.justifyContent(FlexAlign.Start)
        .margin({ top: 5 })
        .width('100%')
        Blank()
        Divider()
        //最后的聊天内容
      }.width(260)
      .height(80)
    }
    .backgroundColor(Color.White)
    .width('100%')
    .height(80)
  }

  build() {
    //Text('今晚老地方见')
    Column() {
      //微信头
      //文字和按钮是叠放的
      Stack() {
        Row() {
          Text(`微信(520)`).fontSize(20)
        }.width('85%')
        .height(50)
        .justifyContent(FlexAlign.Center)

        Row() {
          Button() {
            Image($r('app.media.plus')).width(26)
          }.margin({ right: 15 })
          .backgroundColor('#ededed')
        }.width('100%')
        .justifyContent(FlexAlign.End)
      }.height(50)

      //搜索框
      Search({ placeholder: '搜索' }).width('90%')
        .margin({
          bottom: 15
        })
        .height(40)
      //消息提示
      //聊天列表
      List() {
        ForEach(this.chatters, (item: Chatter)=>{
          ListItem() {
            this.createListItem(item)
          }
        })
      }.width('100%')
      .layoutWeight(1)
    }.width('100%')
    .height('100%')
    .backgroundColor('#ededed')
  }
}