import { AbortController } from '@ohos/axios';
import { BACKGROUND, GREEN, TEXT_PRIMARY, TEXT_SECONDARY } from '../common/Theme';
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
  @State deliveredCode: string = '';
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
    this.deliveredCode = '';
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
    this.deliveredCode = '';
    this.code = '';
    const phone = this.phone.trim();
    const controller = new AbortController();
    this.controller = controller;
    const id = ++this.requestId;
    try {
      const code = await AuthService.requestCode(phone, controller);
      if (!this.isCurrent(id)) { return; }
      this.deliveredCode = code;
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
    this.deliveredCode = '';
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

  build() {
    Scroll() {
      Column({ space: 18 }) {
        Image($r('app.media.weixin')).width(64).height(64).fillColor(GREEN).margin({ top: 28, bottom: 8 })
        Text('鸿蒙微信 · 课程作业').fontSize(26 * this.fontScale).fontWeight(FontWeight.Bold)
          .fontColor(TEXT_PRIMARY).textAlign(TextAlign.Center).width('100%')
        Text('登录本机课程服务').fontSize(18 * this.fontScale).fontColor(TEXT_PRIMARY)
        Text('验证码由课程服务直接返回，不发送短信。聊天、联系人和朋友圈使用本地教学数据。')
          .fontSize(14 * this.fontScale).fontColor(TEXT_SECONDARY).width('100%').lineHeight(22 * this.fontScale)
        Text('手机号').fontSize(16 * this.fontScale).alignSelf(ItemAlign.Start)
        TextInput({ text: this.phone, placeholder: '输入 11 位课程手机号' }).id('login-phone')
          .type(InputType.PhoneNumber).maxLength(11).height(50 * this.fontScale).fontSize(17 * this.fontScale)
          .enabled(!this.busy).onChange((value: string) => {
            this.phone = value.trim();
            this.error = '';
            if (this.phone !== this.issuedPhone) { this.deliveredCode = ''; this.code = ''; }
          })
        Button(this.countdown > 0 ? this.countdown + ' 秒后重新获取' : (this.busy && !this.signingIn ? '正在获取…' : '获取验证码'))
          .id('login-get-code').width('100%').height(48 * this.fontScale).fontSize(16 * this.fontScale)
          .fontColor(GREEN).backgroundColor('#E0F2E7').enabled(!this.busy && this.countdown === 0)
          .onClick(() => { this.requestCode(); })
        Text('验证码').fontSize(16 * this.fontScale).alignSelf(ItemAlign.Start)
        TextInput({ text: this.code, placeholder: '输入 4–8 位验证码' }).id('login-code')
          .type(InputType.NUMBER_PASSWORD).showPasswordIcon(false).maxLength(8)
          .height(50 * this.fontScale).fontSize(17 * this.fontScale).enabled(!this.busy)
          .onChange((value: string) => { this.code = value.trim(); this.error = ''; })
        if (this.deliveredCode) {
          Text('已取得课程验证码，有效期 10 分钟。可点击下方按钮填入。')
            .fontSize(14 * this.fontScale).fontColor(TEXT_SECONDARY).width('100%')
          Button('填入课程验证码').id('login-fill-code').fontSize(15 * this.fontScale)
            .width('100%').height(44 * this.fontScale).backgroundColor(Color.White).fontColor(GREEN)
            .enabled(!this.busy).onClick(() => { this.code = this.deliveredCode; this.error = ''; })
        }
        if (this.error) {
          Text(this.error).id('login-error').fontSize(14 * this.fontScale).fontColor('#B64236').width('100%')
        }
        if (this.storeError) {
          Text(this.storeError).fontSize(14 * this.fontScale).fontColor('#B64236').width('100%')
        }
        Button(this.signingIn ? '正在登录…' : '登录课程服务').id('login-submit')
          .width('100%').height(50 * this.fontScale).fontSize(18 * this.fontScale).backgroundColor(GREEN)
          .enabled(!this.busy).onClick(() => { this.signIn(); })
        Button('进入本地体验').id('login-local').width('100%').height(48 * this.fontScale)
          .fontSize(17 * this.fontScale).fontColor(TEXT_PRIMARY).backgroundColor(Color.White)
          .onClick(() => { this.enterApp(); })
        Text('本地体验无需登录；联机登录仅在本次运行有效。').fontSize(13 * this.fontScale)
          .fontColor(TEXT_SECONDARY).textAlign(TextAlign.Center).width('100%')
      }.padding({ left: 24, right: 24, top: 16, bottom: 32 }).width('100%')
    }.id('login-scroll').align(Alignment.TopStart).height('100%').width('100%').backgroundColor(BACKGROUND)
  }
}
