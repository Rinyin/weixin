import { ListDataSource } from '../common/ListDataSource';
import { avatarResource, BACKGROUND, GREEN, LINK_COLOR, momentImage, TEXT_PRIMARY, timeLabel } from '../common/Theme';
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
  @State menuFor: string = '';
  @State solidHeader: boolean = false;
  private scroller: Scroller = new Scroller();
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

  private authorName(author: string): string {
    return author === 'self' ? AppStore.data.profile.name : author;
  }

  @Builder
  card(view: MomentView) {
    Row({ space: 10 }) {
      Image(avatarResource(view.avatar)).width(42).height(42).borderRadius(4)
      Column({ space: 8 }) {
        Text(view.name).fontSize(16 * this.fontScale).fontColor(LINK_COLOR).fontWeight(FontWeight.Medium)
        Text(view.moment.text).fontSize(16 * this.fontScale).fontColor(TEXT_PRIMARY).width('100%')
          .lineHeight(23 * this.fontScale).copyOption(CopyOptions.LocalDevice)
        if (view.moment.image) {
          Image(momentImage(view.moment.image)).width('62%').aspectRatio(1).objectFit(ImageFit.Cover)
            .accessibilityText('朋友圈配图')
        }
        Row() {
          Text(timeLabel(view.moment.createdAt)).fontSize(12 * this.fontScale).fontColor('#B2B2B2').layoutWeight(1)
          if (this.menuFor === view.moment.id) {
            Row() {
              Text(view.moment.liked ? '♥ 取消' : '♡ 赞').fontSize(14 * this.fontScale).fontColor(Color.White)
                .padding({ left: 16, right: 16, top: 8, bottom: 8 })
                .onClick(() => { this.menuFor = ''; this.like(view.moment.id); })
              Divider().vertical(true).height(18).color('#3E3E3E')
              Text('💬 评论').fontSize(14 * this.fontScale).fontColor(Color.White)
                .padding({ left: 16, right: 16, top: 8, bottom: 8 })
                .onClick(() => { this.menuFor = ''; this.commentFor = view.moment.id; this.commentDraft = ''; })
            }.backgroundColor('#4C4C4C').borderRadius(4).margin({ right: 8 }).enabled(!this.busy)
          }
          Text('··').fontSize(18).fontWeight(FontWeight.Bold).fontColor(LINK_COLOR)
            .width(32).height(22).textAlign(TextAlign.Center).borderRadius(3).backgroundColor('#F7F7F7')
            .accessibilityText('赞或评论')
            .onClick(() => { this.menuFor = this.menuFor === view.moment.id ? '' : view.moment.id; })
        }.width('100%')
        if (view.moment.liked || view.moment.comments.length > 0) {
          Column({ space: 4 }) {
            if (view.moment.liked) {
              Text('♡ ' + AppStore.data.profile.name).fontSize(14 * this.fontScale).fontColor(LINK_COLOR)
                .width('100%').padding({ bottom: view.moment.comments.length > 0 ? 6 : 0 })
            }
            if (view.moment.liked && view.moment.comments.length > 0) {
              Divider().strokeWidth(0.5).color('#E5E5E5')
            }
            ForEach(view.moment.comments, (comment: MomentComment) => {
              Text() {
                Span(this.authorName(comment.author)).fontColor(LINK_COLOR).fontWeight(FontWeight.Medium)
                Span('：' + comment.text).fontColor(TEXT_PRIMARY)
              }.fontSize(14 * this.fontScale).width('100%')
            }, (comment: MomentComment) => comment.id)
          }.padding({ left: 10, right: 10, top: 6, bottom: 6 }).width('100%').backgroundColor('#F7F7F7')
          .borderRadius(2).alignItems(HorizontalAlign.Start)
        }
      }.layoutWeight(1).alignItems(HorizontalAlign.Start)
    }.alignItems(VerticalAlign.Top).padding({ left: 12, right: 16, top: 16, bottom: 16 }).width('100%')
    .backgroundColor(Color.White)
  }

  @Builder
  cover() {
    Stack({ alignContent: Alignment.BottomEnd }) {
      Column() {
        Image(momentImage('img1')).width('100%').height(300).objectFit(ImageFit.Cover)
      }.width('100%').height(330).alignItems(HorizontalAlign.Start)
      Row({ space: 14 }) {
        Text(this.profile.name).fontSize(19 * this.fontScale).fontWeight(FontWeight.Medium).fontColor(Color.White)
          .textShadow({ radius: 4, color: '#80000000', offsetX: 0, offsetY: 1 }).margin({ bottom: 40 })
        Image(avatarResource(this.profile.avatar)).width(72).height(72).borderRadius(8)
          .border({ width: 2, color: Color.White })
      }.padding({ right: 16 })
    }.width('100%').backgroundColor(Color.White)
  }

  build() {
    Stack({ alignContent: Alignment.Top }) {
      Column() {
        List({ scroller: this.scroller }) {
          ListItem() { this.cover() }
          if (this.count === 0) {
            ListItem() {
              Text(this.mineOnly ? '还没有发表过朋友圈' : '暂时没有朋友圈动态').fontSize(15 * this.fontScale)
                .fontColor('#B2B2B2').padding(40).width('100%').textAlign(TextAlign.Center)
            }
          }
          LazyForEach(this.source, (view: MomentView) => {
            ListItem() { this.card(view) }
          }, (view: MomentView) => view.key)
        }.layoutWeight(1).width('100%').scrollBar(BarState.Off).edgeEffect(EdgeEffect.Spring)
        .divider({ strokeWidth: 0.5, color: '#EDEDED' })
        .onDidScroll(() => { this.solidHeader = this.scroller.currentOffset().yOffset > 220; })
        .onClick(() => { this.menuFor = ''; })
        if (this.error) {
          Text(this.error).fontSize(14 * this.fontScale).fontColor('#FA5151').padding(10).width('100%')
            .backgroundColor(Color.White)
        }
        if (this.commentFor) {
          Row({ space: 8 }) {
            TextInput({ text: this.commentDraft, placeholder: '评论' }).fontSize(16 * this.fontScale)
              .constraintSize({ minHeight: 38 }).layoutWeight(1).maxLength(200).borderRadius(4)
              .backgroundColor(Color.White).caretColor(GREEN).defaultFocus(true)
              .enterKeyType(EnterKeyType.Send).onSubmit(() => { this.sendComment(); })
              .onChange((value: string) => { this.commentDraft = value; })
            Button('发送', { type: ButtonType.Normal }).fontSize(15 * this.fontScale).height(34)
              .padding({ left: 12, right: 12 }).borderRadius(4)
              .backgroundColor(this.commentDraft.trim().length > 0 ? GREEN : '#E1E1E1')
              .fontColor(this.commentDraft.trim().length > 0 ? Color.White : '#B2B2B2')
              .enabled(!this.busy && this.commentDraft.trim().length > 0).onClick(() => { this.sendComment(); })
            Text('取消').fontSize(15 * this.fontScale).fontColor(TEXT_PRIMARY).padding(4)
              .onClick(() => { this.commentFor = ''; this.commentDraft = ''; })
          }.padding({ left: 10, right: 10, top: 8, bottom: 8 }).width('100%').backgroundColor('#F7F7F7')
          .border({ width: { top: 0.5 }, color: '#DDDDDD' })
        }
      }.width('100%').height('100%')
      Row() {
        Text('‹').fontSize(36).width(48).height(48).textAlign(TextAlign.Center)
          .fontColor(this.solidHeader ? TEXT_PRIMARY : Color.White).accessibilityText('返回')
          .onClick(() => { this.getUIContext().getRouter().back(); })
        Text(this.solidHeader ? (this.mineOnly ? '我的朋友圈' : '朋友圈') : '').fontSize(17 * this.fontScale)
          .fontWeight(FontWeight.Medium).fontColor(TEXT_PRIMARY).layoutWeight(1).textAlign(TextAlign.Center)
        Text('📷').fontSize(22).width(48).height(48).textAlign(TextAlign.Center).accessibilityText('发表朋友圈')
          .onClick(() => { this.getUIContext().getRouter().pushUrl({ url: 'pages/PublishMoment' }); })
      }.width('100%').height(56).backgroundColor(this.solidHeader ? BACKGROUND : Color.Transparent)
    }.height('100%').width('100%').backgroundColor(Color.White)
  }
}
