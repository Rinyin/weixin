import { VideoClip, VIDEO_CLIPS, videoTime } from '../model/VideoData';
import { AppStore } from '../services/AppStore';

@Entry
@Component
struct VideoChannel {
  @StorageLink('fontScale') fontScale: number = 1;
  @State selected: number = 0;
  @State activeClips: VideoClip[] = [VIDEO_CLIPS[0]];
  @State prepared: boolean = false;
  @State playing: boolean = false;
  @State finished: boolean = false;
  @State duration: number = 0;
  @State playbackSeconds: number = 0;
  @State status: string = '正在载入';
  @State error: string = '';
  @State likedIds: string[] = [];
  // 0 关注、1 朋友、2 推荐；关注与喜欢保存在 Preferences，重启后保留。
  @State tab: number = 2;
  @State playlist: VideoClip[] = VIDEO_CLIPS;
  @State followed: string[] = [];
  private controller: VideoController = new VideoController();
  private activeId: string = VIDEO_CLIPS[0].id;
  private pageActive: boolean = false;
  private disposed: boolean = false;

  aboutToAppear(): void {
    this.likedIds = VideoChannel.readList('videoLiked');
    this.followed = VideoChannel.readList('videoFollowed');
  }

  private static readList(key: string): string[] {
    try {
      const value = JSON.parse(AppStore.readSetting(key, '[]')) as string[];
      return Array.isArray(value) ? value.filter((item: string) => typeof item === 'string') : [];
    } catch {
      // 设置内容损坏时按未关注 / 未喜欢处理，不影响播放。
      return [];
    }
  }

  private persist(): void {
    AppStore.saveSettings([
      { key: 'videoLiked', value: JSON.stringify(this.likedIds) },
      { key: 'videoFollowed', value: JSON.stringify(this.followed) }
    ]).catch(() => {
      this.getUIContext().getPromptAction().showToast({ message: '保存失败，请检查设备存储后重试' });
    });
  }

  onPageShow(): void { this.pageActive = true; }

  onPageHide(): void {
    this.pageActive = false;
    if (this.playing) { this.controller.pause(); }
  }

  aboutToDisappear(): void {
    this.disposed = true;
    // VideoController 不提供 release；停止后，ArkUI 随 Video 组件销毁播放器资源。
    this.controller.stop();
  }

  private current(clip: VideoClip): boolean { return !this.disposed && clip.id === this.activeId; }

  private select(index: number): void {
    this.controller.stop();
    this.controller = new VideoController();
    const count = this.playlist.length;
    this.selected = count > 0 ? (index + count) % count : 0;
    this.activeId = count > 0 ? this.playlist[this.selected].id : '';
    this.playing = false;
    this.prepared = false;
    this.finished = false;
    this.playbackSeconds = 0;
    this.duration = 0;
    this.status = '正在载入';
    this.error = '';
    // 新 ID 卸载旧 Video，让每段视频拥有独立控制器和资源生命周期。
    this.activeClips = count > 0 ? [this.playlist[this.selected]] : [];
  }

  private clipsFor(tab: number): VideoClip[] {
    if (tab === 0) { return VIDEO_CLIPS.filter((clip: VideoClip) => this.followed.includes(clip.author)); }
    if (tab === 1) { return VIDEO_CLIPS.filter((clip: VideoClip) => clip.friendLikes.length > 0); }
    return VIDEO_CLIPS;
  }

  private switchTab(tab: number): void {
    if (tab === this.tab) { return; }
    this.tab = tab;
    this.playlist = this.clipsFor(tab);
    this.select(0);
  }

  private toggleFollow(author: string): void {
    this.followed = this.followed.includes(author) ?
      this.followed.filter((item: string) => item !== author) : this.followed.concat([author]);
    this.persist();
    if (this.tab === 0) {
      // 在“关注”页取消关注后，列表随之更新。
      this.playlist = this.clipsFor(0);
      this.select(0);
    }
  }

  @Builder
  tabItem(title: string, index: number) {
    Column({ space: 4 }) {
      Text(title).fontSize((this.tab === index ? 17 : 16) * this.fontScale)
        .fontColor(this.tab === index ? Color.White : '#B3FFFFFF')
        .fontWeight(this.tab === index ? FontWeight.Medium : FontWeight.Normal)
      Divider().strokeWidth(2).color(this.tab === index ? Color.White : Color.Transparent).width(18)
    }.padding({ left: 4, right: 4, top: 6 }).accessibilityText(title).onClick(() => { this.switchTab(index); })
  }

  private toggle(): void {
    if (!this.prepared || !this.pageActive) { return; }
    if (this.playing) {
      this.controller.pause();
    } else {
      if (this.finished) { this.controller.setCurrentTime(0); this.finished = false; }
      this.controller.start();
    }
  }

  private toggleLike(id: string): void {
    this.likedIds = this.likedIds.includes(id) ? this.likedIds.filter((item: string) => item !== id) : this.likedIds.concat([id]);
    this.persist();
  }

  @Builder
  sideAction(icon: string, label: string, color: ResourceColor, action: () => void) {
    Column({ space: 2 }) {
      Text(icon).fontSize(30).fontColor(color)
      Text(label).fontSize(12 * this.fontScale).fontColor(Color.White)
    }.accessibilityGroup(true).accessibilityText(label).onClick(action)
  }

  build() {
    Stack({ alignContent: Alignment.Bottom }) {
      Stack() {
        ForEach(this.activeClips, (clip: VideoClip) => {
          Video({ src: clip.source, controller: this.controller, previewUri: $r('app.media.shaoenpreview') })
            .width('100%').height('100%').objectFit(ImageFit.Contain)
            .controls(false).autoPlay(false).loop(false).backgroundColor(Color.Black)
            .onPrepared((event: PreparedInfo) => {
              if (!this.current(clip)) { return; }
              this.duration = event.duration;
              this.prepared = true;
              this.status = '就绪';
              // 与视频号一致，进入或切换后自动播放；页面不可见时不播放。
              if (this.pageActive) { this.controller.start(); }
            })
            .onStart(() => {
              if (!this.current(clip)) { return; }
              if (!this.pageActive) { this.controller.pause(); return; }
              this.playing = true;
              this.status = '播放中';
            })
            .onPause(() => {
              if (!this.current(clip)) { return; }
              this.playing = false;
              this.status = '已暂停';
            })
            .onUpdate((event: PlaybackInfo) => {
              if (this.current(clip)) { this.playbackSeconds = event.time; }
            })
            .onFinish(() => {
              if (!this.current(clip)) { return; }
              this.playing = false;
              this.finished = true;
              this.playbackSeconds = this.duration;
              this.status = '播放完毕';
            })
            .onError(() => {
              if (!this.current(clip)) { return; }
              this.prepared = false;
              this.playing = false;
              this.status = '加载失败';
              this.error = '视频暂时无法播放，请上下滑动切换。';
            })
        }, (clip: VideoClip) => clip.id)
        if (this.prepared && !this.playing) {
          Text('▶').fontSize(72).fontColor('#CCFFFFFF').accessibilityText('播放')
        }
        if (this.playlist.length === 0) {
          Text(this.tab === 0 ? '还没有关注的作者\n在“推荐”中点击作者旁的“关注”' : '暂无朋友赞过的视频')
            .fontSize(15 * this.fontScale).fontColor('#B3FFFFFF').textAlign(TextAlign.Center)
            .lineHeight(24 * this.fontScale)
        }
        if (this.error) {
          Text(this.error).fontSize(15 * this.fontScale).fontColor(Color.White).padding(16)
        }
      }.width('100%').height('100%').accessibilityText(this.playing ? '点击暂停' : '点击播放')
      .onClick(() => this.toggle())
      .gesture(PanGesture({ direction: PanDirection.Vertical, distance: 20 }).onActionEnd((event: GestureEvent) => {
        if (event.offsetY < -60) { this.select(this.selected + 1); }
        else if (event.offsetY > 60) { this.select(this.selected - 1); }
      }))

      Row() {
        Text('‹').fontSize(36).fontColor(Color.White).width(48).height(48).textAlign(TextAlign.Center)
          .accessibilityText('返回').onClick(() => this.getUIContext().getRouter().back())
        Row({ space: 24 }) {
          this.tabItem('关注', 0)
          this.tabItem('朋友', 1)
          this.tabItem('推荐', 2)
        }.layoutWeight(1).justifyContent(FlexAlign.Center)
        Blank().width(48)
      }.width('100%').height(56).position({ x: 0, y: 0 })

      if (this.playlist.length > 0) {
      Column() {
        Row() {
          Column({ space: 10 }) {
            Row({ space: 8 }) {
              Image(this.playlist[this.selected].avatar).width(36).height(36).borderRadius(18)
                .border({ width: 1, color: Color.White })
              Text(this.playlist[this.selected].author).fontSize(16 * this.fontScale).fontColor(Color.White)
                .fontWeight(FontWeight.Medium)
              Text(this.followed.includes(this.playlist[this.selected].author) ? '已关注' : '关注')
                .fontSize(13 * this.fontScale).fontColor(Color.White).borderRadius(4)
                .padding({ left: 10, right: 10, top: 3, bottom: 3 })
                .backgroundColor(this.followed.includes(this.playlist[this.selected].author) ? '#4DFFFFFF' : '#FA5151')
                .onClick(() => { this.toggleFollow(this.playlist[this.selected].author); })
            }
            if (this.tab === 1 && this.playlist[this.selected].friendLikes.length > 0) {
              Text('♥ ' + this.playlist[this.selected].friendLikes.join('、') + ' 赞过')
                .fontSize(13 * this.fontScale).fontColor('#FFD24C')
            }
            Text(this.playlist[this.selected].title).fontSize(15 * this.fontScale).fontColor(Color.White)
              .maxLines(2).textOverflow({ overflow: TextOverflow.Ellipsis })
            Text(videoTime(this.playbackSeconds) + ' / ' + videoTime(this.duration) + '  ·  上下滑动切换')
              .fontSize(12 * this.fontScale).fontColor('#B3FFFFFF')
          }.layoutWeight(1).alignItems(HorizontalAlign.Start)
          Column({ space: 22 }) {
            this.sideAction(this.likedIds.includes(this.playlist[this.selected].id) ? '♥' : '♡', '喜欢',
              this.likedIds.includes(this.playlist[this.selected].id) ? '#FA5151' : Color.White,
              () => { this.toggleLike(this.playlist[this.selected].id); })
          }.margin({ left: 12 })
        }.width('100%').alignItems(VerticalAlign.Bottom).padding({ left: 16, right: 14, bottom: 14 })
        Progress({ value: this.playbackSeconds, total: this.duration || 1, type: ProgressType.Linear })
          .color('#E6FFFFFF').backgroundColor('#4DFFFFFF').width('100%').height(2)
          .style({ strokeWidth: 2 }).margin({ bottom: 12 })
      }.width('100%')
      }
    }.width('100%').height('100%').backgroundColor(Color.Black)
  }
}
