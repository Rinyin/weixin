import { PageHeader } from '../components/PageHeader';
import { BACKGROUND, GREEN, TEXT_SECONDARY } from '../common/Theme';
import { VideoClip, VIDEO_CLIPS, videoTime } from '../model/VideoData';

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
  private controller: VideoController = new VideoController();
  private activeId: string = VIDEO_CLIPS[0].id;
  private pageActive: boolean = false;
  private disposed: boolean = false;

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
    this.selected = (index + VIDEO_CLIPS.length) % VIDEO_CLIPS.length;
    this.activeId = VIDEO_CLIPS[this.selected].id;
    this.playing = false;
    this.prepared = false;
    this.finished = false;
    this.playbackSeconds = 0;
    this.duration = 0;
    this.status = '正在载入';
    this.error = '';
    // 新 ID 卸载旧 Video，让每段视频拥有独立控制器和资源生命周期。
    this.activeClips = [VIDEO_CLIPS[this.selected]];
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

  build() {
    Column() {
      PageHeader({ title: '视频号' })
      Scroll() {
        Column({ space: 18 }) {
          ForEach(this.activeClips, (clip: VideoClip) => {
            Video({ src: clip.source, controller: this.controller, previewUri: $r('app.media.shaoenpreview') })
              .id('course-video').width('100%').height(345).objectFit(ImageFit.Contain)
              .controls(false).autoPlay(false).loop(false).backgroundColor(Color.Black)
              .onPrepared((event: PreparedInfo) => {
                if (!this.current(clip)) { return; }
                this.duration = event.duration;
                this.prepared = true;
                this.status = '就绪';
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
                this.error = '视频暂时无法播放，请重新选择片段。';
              })
          }, (clip: VideoClip) => clip.id)
          Column({ space: 14 }) {
            Row() {
              Text(VIDEO_CLIPS[this.selected].title).fontSize(20 * this.fontScale).fontWeight(FontWeight.Medium).layoutWeight(1)
              Text((this.selected + 1).toString() + ' / ' + VIDEO_CLIPS.length.toString())
                .fontSize(14 * this.fontScale).fontColor(TEXT_SECONDARY)
            }.width('100%')
            Row() {
              Text(this.status).id('video-status').fontSize(14 * this.fontScale).fontColor(TEXT_SECONDARY).layoutWeight(1)
              Text(videoTime(this.playbackSeconds) + ' / ' + videoTime(this.duration)).id('video-progress')
                .fontSize(14 * this.fontScale).fontColor(TEXT_SECONDARY)
            }.width('100%')
            Progress({ value: this.playbackSeconds, total: this.duration || 1, type: ProgressType.Linear }).color(GREEN).width('100%')
            if (this.error) { Text(this.error).fontSize(14 * this.fontScale).fontColor('#C33B32') }
            Button(this.playing ? '暂停' : (this.finished ? '重新播放' : '播放')).id('video-play')
              .fontSize(18 * this.fontScale).height(48 * this.fontScale).width('100%').backgroundColor(GREEN)
              .enabled(this.prepared).onClick(() => this.toggle())
            Row({ space: 16 }) {
              Button('上一条').id('video-previous').fontSize(15 * this.fontScale).layoutWeight(1)
                .fontColor('#333333').backgroundColor(Color.White).onClick(() => this.select(this.selected - 1))
              Button('下一条').id('video-next').fontSize(15 * this.fontScale).layoutWeight(1)
                .fontColor('#333333').backgroundColor(Color.White).onClick(() => this.select(this.selected + 1))
            }.width('100%')
            Text('课程本地视频 · 离开页面自动暂停').fontSize(13 * this.fontScale).fontColor(TEXT_SECONDARY)
          }.padding({ left: 20, right: 20, bottom: 24 }).width('100%')
        }.width('100%')
      }.align(Alignment.TopStart).layoutWeight(1).width('100%')
    }.width('100%').height('100%').backgroundColor(BACKGROUND)
  }
}
