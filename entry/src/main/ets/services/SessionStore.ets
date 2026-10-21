import { OnlineProfile, SessionMode } from '../model/AuthModels';
import { AppStore } from './AppStore';

// 登录状态与联机资料保存在 Preferences，应用重启后无需重新登录；本地资料继续由 AppStore 管理。
// 不保存 token 和验证码。
export class SessionStore {
  static mode: SessionMode = SessionMode.SignedOut;

  private static apply(mode: SessionMode, nickname: string, avatar: string): void {
    SessionStore.mode = mode;
    AppStorage.setOrCreate('onlineNickname', nickname);
    AppStorage.setOrCreate('onlineAvatar', avatar);
    AppStorage.setOrCreate('sessionMode', mode);
  }

  /** 启动时读取上次的登录状态；读取失败视为未登录。 */
  static restore(): void {
    const saved = AppStore.readSetting('sessionMode', '');
    if (saved === 'online') {
      SessionStore.apply(SessionMode.Online, AppStore.readSetting('onlineNickname', '微信用户'),
        AppStore.readSetting('onlineAvatar', ''));
    } else if (saved === 'local') {
      SessionStore.apply(SessionMode.Local, '', '');
    } else {
      SessionStore.apply(SessionMode.SignedOut, '', '');
    }
  }

  private static persist(): void {
    AppStore.saveSettings([
      { key: 'sessionMode', value: SessionStore.mode.toString() },
      { key: 'onlineNickname', value: AppStorage.get<string>('onlineNickname') || '' },
      { key: 'onlineAvatar', value: AppStorage.get<string>('onlineAvatar') || '' }
    ]).catch(() => {
      AppStorage.setOrCreate('storeError', '登录状态保存失败，下次打开可能需要重新登录。');
    });
  }

  static reset(): void {
    SessionStore.apply(SessionMode.SignedOut, '', '');
    SessionStore.persist();
  }

  static enterLocal(): void {
    SessionStore.apply(SessionMode.Local, '', '');
    SessionStore.persist();
  }

  static enterOnline(profile: OnlineProfile): void {
    SessionStore.apply(SessionMode.Online, profile.nickname || '微信用户', profile.avatarUrl);
    SessionStore.persist();
  }
}
