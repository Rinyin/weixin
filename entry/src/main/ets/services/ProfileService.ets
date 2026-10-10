import { UserProfile } from '../model/Models';
import { AppStore } from './AppStore';

export class ProfileService {
  private static saving: boolean = false;

  static async save(profile: UserProfile): Promise<void> {
    if (ProfileService.saving) { throw new Error('正在保存，请稍后重试'); }
    const name = profile.name.trim().slice(0, 20);
    if (!name) { throw new Error('昵称不能为空'); }
    const previous = AppStore.data.profile;
    const next: UserProfile = {
      name: name, account: previous.account,
      avatar: /^avatar[1-7]$/.test(profile.avatar) ? profile.avatar : previous.avatar,
      region: profile.region.trim().slice(0, 30) || '中国', signature: profile.signature.trim().slice(0, 80)
    };
    ProfileService.saving = true;
    AppStore.data.profile = next;
    try { await AppStore.save(); }
    catch {
      AppStore.data.profile = previous;
      throw new Error('资料保存失败，请稍后重试');
    } finally { ProfileService.saving = false; }
  }
}
