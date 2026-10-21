import { AbortController } from '@ohos/axios';
import { GREEN, LINK_COLOR, TEXT_PRIMARY } from '../common/Theme';
import { OnlineProfile } from '../model/AuthModels';
import { AuthFailure, AuthService } from '../services/AuthService';
import { SessionStore } from '../services/SessionStore';

@Entry
@Component
struct Login {
  @StorageLink('fontScale') fontScale: number = 1;
  @StorageLink('storeError') storeError: string = '';
  @State phone: string = '';
  @State code: string = '';
  @State error: string = '';
  @State busy: boolean = false;
  @State signingIn: boolean = false;
  @State countdown: number = 0;
  private issuedPhone: string = '';
  private cooldownUntil: number = 0;
  private timer: number = -1;
  private controller: AbortController | undefined = undefined;
  private requestId: number = 0;
  private active: boolean = true;
  private navigating: boolean = false;

  onPageShow(): void {
    this.active = true;
    this.resumeCountdown();
  }

  onPageHide(): void { this.stopWork(); }
  aboutToDisappear(): void {
    this.stopWork();
    this.code = '';
  }

  private stopTimer(): void {
    if (this.timer !== -1) { clearInterval(this.timer); this.timer = -1; }
  }

  private resumeCountdown(): void {
    this.stopTimer();
    this.countdown = Math.max(0, Math.ceil((this.cooldownUntil - Date.now()) / 1000));
    if (this.countdown > 0 && this.active) {
      this.timer = setInterval(() => {
        this.countdown = Math.max(0, Math.ceil((this.cooldownUntil - Date.now()) / 1000));
        if (this.countdown === 0) { this.stopTimer(); }
      }, 1000);
    }
  }

  private stopWork(): void {
    this.active = false;
    this.requestId++;
    this.controller?.abort();
    this.controller = undefined;
    this.busy = false;
    this.signingIn = false;
    this.stopTimer();
  }

  private isCurrent(id: number): boolean { return this.active && !this.navigating && id === this.requestId; }

  private async requestCode(): Promise<void> {
    if (this.busy || this.navigating || this.countdown > 0) { return; }
    if (!AuthService.validPhone(this.phone)) { this.error = '手机号应为 1 开头的 11 位数字'; return; }
    this.busy = true;
    this.error = '';
    this.code = '';
    const phone = this.phone.trim();
    const controller = new AbortController();
    this.controller = controller;
    const id = ++this.requestId;
    try {
      const code = await AuthService.requestCode(phone, controller);
      if (!this.isCurrent(id)) { return; }
      // 服务端直接返回验证码，模拟系统短信验证码自动填充。
      this.code = code;
      this.getUIContext().getPromptAction().showToast({ message: '验证码已发送' });
      this.issuedPhone = phone;
      this.cooldownUntil = Date.now() + 60000;
      this.resumeCountdown();
    } catch (error) {
      if (this.isCurrent(id)) {
        this.error = error instanceof AuthFailure ? error.message : '获取验证码失败，请重试';
      }
    } finally {
      if (this.isCurrent(id)) { this.busy = false; this.controller = undefined; }
    }
  }

  private async signIn(): Promise<void> {
    if (this.busy || this.navigating) { return; }
    if (!AuthService.validPhone(this.phone)) { this.error = '手机号应为 1 开头的 11 位数字'; return; }
    if (!AuthService.validCode(this.code)) { this.error = '验证码应为 4–8 位数字'; return; }
    this.busy = true;
    this.signingIn = true;
    this.error = '';
    const controller = new AbortController();
    this.controller = controller;
    const id = ++this.requestId;
    try {
      const profile = await AuthService.signIn(this.phone, this.code, controller);
      if (this.isCurrent(id)) { await this.enterApp(profile); }
    } catch (error) {
      if (this.isCurrent(id)) {
        this.error = error instanceof AuthFailure ? error.message : '登录失败，请重试';
      }
    } finally {
      if (this.isCurrent(id)) { this.busy = false; this.signingIn = false; this.controller = undefined; }
    }
  }

  private async enterApp(profile?: OnlineProfile): Promise<void> {
    if (this.navigating) { return; }
    this.navigating = true;
    this.stopWork();
    this.code = '';
    if (profile) { SessionStore.enterOnline(profile); } else { SessionStore.enterLocal(); }
    try {
      const router = this.getUIContext().getRouter();
      await router.replaceUrl({ url: 'pages/Index' });
      router.clear();
    } catch {
      SessionStore.reset();
      this.navigating = false;
      this.active = true;
      this.resumeCountdown();
      this.error = '页面打开失败，请重试';
    }
  }

  @Builder
  fieldRow(label: string) {
    Text(label).fontSize(17 * this.fontScale).fontColor(TEXT_PRIMARY).width(96 * this.fontScale)
  }

  @Builder
  lineDivider() {
    Divider().strokeWidth(0.5).color('#E5E5E5')
  }

  private canSubmit(): boolean {
    return !this.busy && this.phone.length > 0 && this.code.length > 0;
  }

  build() {
    Column() {
      Scroll() {
        Column() {
          Text('手机号登录').fontSize(26 * this.fontScale).fontWeight(FontWeight.Medium).fontColor(TEXT_PRIMARY)
            .width('100%').margin({ top: 72, bottom: 40 })
          Row() {
            this.fieldRow('国家/地区')
            Text('中国大陆（+86）').fontSize(17 * this.fontScale).fontColor(TEXT_PRIMARY).layoutWeight(1)
          }.width('100%').constraintSize({ minHeight: 56 })
          this.lineDivider()
          Row() {
            this.fieldRow('手机号')
            TextInput({ text: this.phone, placeholder: '请填写手机号' })
              .type(InputType.PhoneNumber).maxLength(11).layoutWeight(1).height(56)
              .fontSize(17 * this.fontScale).placeholderFont({ size: 17 * this.fontScale })
              .backgroundColor(Color.Transparent).padding(0).borderRadius(0).caretColor(GREEN)
              .enabled(!this.busy).onChange((value: string) => {
                this.phone = value.trim();
                this.error = '';
                if (this.phone !== this.issuedPhone) { this.code = ''; }
              })
          }.width('100%').constraintSize({ minHeight: 56 })
          this.lineDivider()
          Row() {
            this.fieldRow('验证码')
            TextInput({ text: this.code, placeholder: '请填写验证码' })
              .type(InputType.Number).maxLength(8).layoutWeight(1).height(56)
              .fontSize(17 * this.fontScale).placeholderFont({ size: 17 * this.fontScale })
              .backgroundColor(Color.Transparent).padding(0).borderRadius(0).caretColor(GREEN)
              .enabled(!this.busy).onChange((value: string) => { this.code = value.trim(); this.error = ''; })
            Text(this.countdown > 0 ? this.countdown + '秒后重发' : (this.busy && !this.signingIn ? '获取中…' : '获取验证码'))
              .fontSize(15 * this.fontScale)
              .fontColor(this.busy || this.countdown > 0 ? '#B2B2B2' : LINK_COLOR)
              .padding({ left: 12, top: 8, bottom: 8 })
              .accessibilityText('获取验证码')
              .onClick(() => { this.requestCode(); })
          }.width('100%').constraintSize({ minHeight: 56 })
          this.lineDivider()
          if (this.error) {
            Text(this.error).fontSize(14 * this.fontScale).fontColor('#FA5151').width('100%').margin({ top: 12 })
          }
          if (this.storeError) {
            Text(this.storeError).fontSize(14 * this.fontScale).fontColor('#FA5151').width('100%').margin({ top: 12 })
          }
          Button(this.signingIn ? '正在登录…' : '同意并继续', { type: ButtonType.Normal })
            .width(184).height(48).borderRadius(8).margin({ top: 72 })
            .fontSize(17 * this.fontScale).fontWeight(FontWeight.Medium)
            .fontColor(this.canSubmit() ? Color.White : '#B2B2B2')
            .backgroundColor(this.canSubmit() ? GREEN : '#E1E1E1')
            .enabled(this.canSubmit()).onClick(() => { this.signIn(); })
          Text() {
            Span('登录即表示同意')
            Span('《软件许可及服务协议》').fontColor(LINK_COLOR)
            Span('和')
            Span('《隐私保护指引》').fontColor(LINK_COLOR)
          }.fontSize(13 * this.fontScale).fontColor('#B2B2B2').textAlign(TextAlign.Center)
          .width('100%').margin({ top: 16 })
        }.padding({ left: 32, right: 32, bottom: 24 }).width('100%')
      }.align(Alignment.TopStart).layoutWeight(1).width('100%').scrollBar(BarState.Off)
      Row() {
        Text('找回密码').fontSize(14 * this.fontScale).fontColor(LINK_COLOR)
          .onClick(() => {
            this.getUIContext().getPromptAction().showToast({ message: '请使用验证码登录' });
          })
        Divider().vertical(true).height(12).color('#D8D8D8').margin({ left: 14, right: 14 })
        Text('更多选项').fontSize(14 * this.fontScale).fontColor(LINK_COLOR)
          .bindMenu([{ value: '游客模式（暂不登录）', action: () => { this.enterApp(); } }])
      }.justifyContent(FlexAlign.Center).width('100%').padding({ top: 12, bottom: 28 })
    }.height('100%').width('100%').backgroundColor(Color.White)
  }
}
