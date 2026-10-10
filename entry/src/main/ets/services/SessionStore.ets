import { OnlineProfile, SessionMode } from '../model/AuthModels';

// 仅保留当前进程的体验模式和联机资料；本地课程资料继续由 AppStore 管理。
export class SessionStore {
  static mode: SessionMode = SessionMode.SignedOut;

  static reset(): void {
    SessionStore.mode = SessionMode.SignedOut;
    AppStorage.setOrCreate('sessionMode', SessionMode.SignedOut);
    AppStorage.setOrCreate('onlineNickname', '');
    AppStorage.setOrCreate('onlineAvatar', '');
  }

  static enterLocal(): void {
    SessionStore.reset();
    SessionStore.mode = SessionMode.Local;
    AppStorage.setOrCreate('sessionMode', SessionMode.Local);
  }

  static enterOnline(profile: OnlineProfile): void {
    SessionStore.reset();
    SessionStore.mode = SessionMode.Online;
    AppStorage.setOrCreate('onlineNickname', profile.nickname || '课程用户');
    AppStorage.setOrCreate('onlineAvatar', profile.avatarUrl);
    AppStorage.setOrCreate('sessionMode', SessionMode.Online);
  }
}
