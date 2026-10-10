import { PageHeader } from '../components/PageHeader';
import { ListDataSource } from '../common/ListDataSource';
import { avatarResource, BACKGROUND, GREEN, LINK_COLOR, momentImage, TEXT_SECONDARY, timeLabel } from '../common/Theme';
import { MomentComment, MomentsRoute, UserProfile } from '../model/Models';
import { AppStore } from '../services/AppStore';
import { MomentsService, MomentView } from '../services/MomentsService';

@Entry
@Component
struct Moments {
  @StorageLink('fontScale') fontScale: number = 1;
  @StorageLink('revision') @Watch('refresh') revision: number = 0;
  @State mineOnly: boolean = false;
  @State profile: UserProfile = AppStore.data.profile;
  @State count: number = 0;
  @State busy: boolean = false;
  @State error: string = '';
  @State commentFor: string = '';
  @State commentDraft: string = '';
  private source: ListDataSource<MomentView> = new ListDataSource<MomentView>();

  aboutToAppear(): void {
    const params = this.getUIContext().getRouter().getParams() as MomentsRoute;
    this.mineOnly = params?.mineOnly || false;
    this.refresh();
  }

  onPageShow(): void { this.refresh(); }

  refresh(): void {
    this.profile = AppStore.data.profile;
    const items = MomentsService.list(this.mineOnly);
    this.count = items.length;
    this.source.replace(items);
  }

  private async like(id: string): Promise<void> {
    if (this.busy) { return; }
    this.busy = true;
    this.error = '';
    try { await MomentsService.like(id); }
    catch { this.error = '点赞保存失败，请稍后重试'; }
    finally { this.busy = false; }
  }

  private async sendComment(): Promise<void> {
    if (this.busy || !this.commentFor || !this.commentDraft.trim()) { return; }
    this.busy = true;
    this.error = '';
    try {
      await MomentsService.comment(this.commentFor, this.commentDraft);
      this.commentDraft = '';
      this.commentFor = '';
    } catch { this.error = '评论保存失败，请稍后重试'; }
    finally { this.busy = false; }
  }

  @Builder
  card(view: MomentView) {
    Row({ space: 12 }) {
      Image(avatarResource(view.avatar)).width(42).height(42).borderRadius(7)
      Column({ space: 10 }) {
        Text(view.name).fontSize(17 * this.fontScale).fontColor(LINK_COLOR).fontWeight(FontWeight.Medium)
        Text(view.moment.text).fontSize(16 * this.fontScale).width('100%')
        if (view.moment.image) {
          Image(momentImage(view.moment.image)).width('80%').height(205).objectFit(ImageFit.Cover).borderRadius(4)
            .accessibilityText('朋友圈配图')
        }
        Row({ space: 8 }) {
          Text(timeLabel(view.moment.createdAt)).fontSize(12 * this.fontScale).fontColor(TEXT_SECONDARY).layoutWeight(1)
          Button(view.moment.liked ? '已赞 ♥' : '赞 ♡', { type: ButtonType.Normal }).id('like-' + view.moment.id)
            .fontSize(13 * this.fontScale).fontColor(LINK_COLOR).backgroundColor('#F3F3F3').padding(8)
            .enabled(!this.busy).onClick(() => { this.like(view.moment.id); })
          Button('评论', { type: ButtonType.Normal }).id('comment-' + view.moment.id)
            .fontSize(13 * this.fontScale).fontColor(LINK_COLOR).backgroundColor('#F3F3F3').padding(8)
            .enabled(!this.busy).onClick(() => { this.commentFor = view.moment.id; this.commentDraft = ''; })
        }.width('100%')
        if (view.moment.liked || view.moment.comments.length > 0) {
          Column({ space: 6 }) {
            if (view.moment.liked) {
              Text('♥ ' + AppStore.data.profile.name).fontSize(14 * this.fontScale).fontColor(LINK_COLOR)
            }
            ForEach(view.moment.comments, (comment: MomentComment) => {
              Text((comment.author === 'self' ? AppStore.data.profile.name : comment.author) + '：' + comment.text)
                .fontSize(14 * this.fontScale).fontColor(LINK_COLOR).width('100%')
            }, (comment: MomentComment) => comment.id)
          }.padding(10).width('100%').backgroundColor('#F5F5F5').alignItems(HorizontalAlign.Start)
        }
      }.layoutWeight(1).alignItems(HorizontalAlign.Start)
    }.alignItems(VerticalAlign.Top).padding(18).width('100%').backgroundColor(Color.White)
  }

  build() {
    Column() {
      PageHeader({ title: this.mineOnly ? '我的朋友圈' : '朋友圈', action: '发表', onAction: () => {
        this.getUIContext().getRouter().pushUrl({ url: 'pages/PublishMoment' });
      } })
      List({ space: 1 }) {
        ListItem() {
          Column({ space: 12 }) {
            Image(momentImage('img1')).width('100%').height(155).objectFit(ImageFit.Cover)
            Row({ space: 12 }) {
              Text(this.profile.name).fontSize(21 * this.fontScale).fontWeight(FontWeight.Bold).layoutWeight(1)
              Image(avatarResource(this.profile.avatar)).width(52).height(52).borderRadius(8)
            }.width('100%').padding({ left: 20, right: 20 })
            Text(this.mineOnly ? '只展示我发表的内容' : '朋友们的生活片刻')
              .fontSize(13 * this.fontScale).fontColor(TEXT_SECONDARY).padding({ bottom: 16 })
          }.width('100%').backgroundColor(Color.White)
        }
        if (this.count === 0) {
          ListItem() {
            Text('还没有动态，点击右上角发表第一条吧。').fontSize(16 * this.fontScale).fontColor(TEXT_SECONDARY).padding(28)
          }
        }
        LazyForEach(this.source, (view: MomentView) => {
          ListItem() { this.card(view) }
        }, (view: MomentView) => view.key)
        ListItem() {
          Text('本地课程数据 · 仅保存在此设备').fontSize(12 * this.fontScale).fontColor(TEXT_SECONDARY)
            .width('100%').textAlign(TextAlign.Center).padding(24)
        }
      }.layoutWeight(1).width('100%').scrollBar(BarState.Off)
      if (this.error) { Text(this.error).fontSize(14 * this.fontScale).fontColor('#C33B32').padding(10) }
      if (this.commentFor) {
        Column({ space: 8 }) {
          Row() {
            Text('写评论').fontSize(14 * this.fontScale).layoutWeight(1)
            Button('取消', { type: ButtonType.Normal }).fontSize(13 * this.fontScale).fontColor(TEXT_SECONDARY)
              .backgroundColor(Color.Transparent).onClick(() => { this.commentFor = ''; this.commentDraft = ''; })
          }.width('100%')
          Row({ space: 8 }) {
            TextInput({ text: this.commentDraft, placeholder: '评论内容（最多 200 字）' }).id('moment-comment')
              .fontSize(16 * this.fontScale).height(46 * this.fontScale).layoutWeight(1).maxLength(200)
              .onChange((value: string) => { this.commentDraft = value; })
            Button('发送').id('moment-comment-send').fontSize(15 * this.fontScale).backgroundColor(GREEN)
              .enabled(!this.busy && this.commentDraft.trim().length > 0).onClick(() => { this.sendComment(); })
          }.width('100%')
        }.padding(12).width('100%').backgroundColor(Color.White)
      }
    }.height('100%').width('100%').backgroundColor(BACKGROUND)
  }
}
