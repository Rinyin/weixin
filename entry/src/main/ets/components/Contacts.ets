export class Contacts {
  private avatar: Resource; //头像
  private nickName: string; //昵称
  private bgColor: string; //填充背景色

  constructor(avtar: Resource,  nickName: string, bgColor: string = '#fa9c3e') {
    this.avatar = avtar;
    this.nickName = nickName;
    this.bgColor = bgColor;
  }

  getAvatar(): Resource{
    return this.avatar;
  }

  getNickName(): string {
    return this.nickName;
  }

  getBgColor(): string {
    return this.bgColor;
  }
}