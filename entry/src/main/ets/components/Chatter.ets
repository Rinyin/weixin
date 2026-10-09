export class Chatter {
  private avatar: Resource; //头像
  private nickName: string; //昵称
  private lastWords: string; //最后一句聊天内容
  private lastTime: string; //最后聊天时间

  constructor(avtar: Resource,  nickName: string, lastWords: string, lastTime: string) {
    this.avatar = avtar;
    this.nickName = nickName;
    this.lastWords = lastWords;
    this.lastTime = lastTime
  }

  getAvatar(): Resource{
    return this.avatar;
  }

  getNickName(): string {
    return this.nickName;
  }

  getLastWords(): string {
    return this.lastWords;
  }

  getLastTime() : string {
    return this.lastTime;
  }
}