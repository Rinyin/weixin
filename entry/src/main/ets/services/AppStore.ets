import { common } from '@kit.AbilityKit';
import { fileIo } from '@kit.CoreFileKit';
import { preferences } from '@kit.ArkData';
import { AppData, Contact } from '../model/Models';
import { seedData } from '../model/SeedData';

// 记录使用沙箱 JSON 原子替换；小型设置使用 Preferences，避免大 JSON 超过其单值限制。
export class AppStore {
  static data: AppData = seedData();
  static settings: preferences.Preferences;
  private static dataPath: string = '';
  private static writeQueue: Promise<void> = Promise.resolve();
  private static writable: boolean = false;

  static async initialize(context: common.UIAbilityContext): Promise<void> {
    AppStorage.setOrCreate('revision', 0);
    AppStorage.setOrCreate('fontScale', 1);
    AppStorage.setOrCreate('storeError', '');
    AppStore.dataPath = context.filesDir + '/weixin-data.json';
    try {
      AppStore.settings = await preferences.getPreferences(context, { name: 'weixin_settings' });
      const scale = AppStore.settings.getSync('fontScale', 1) as number;
      AppStorage.setOrCreate('fontScale', Math.min(1.4, Math.max(0.85, scale)));
      if (fileIo.accessSync(AppStore.dataPath)) {
        const saved = JSON.parse(fileIo.readTextSync(AppStore.dataPath)) as AppData;
        if (saved.version !== 1 || !Array.isArray(saved.contacts) || !Array.isArray(saved.messages) ||
          !Array.isArray(saved.moments) || !saved.profile) {
          throw new Error('数据格式不兼容');
        }
        AppStore.data = saved;
        AppStore.writable = true;
      } else {
        AppStore.writable = true;
        await AppStore.save();
      }
    } catch {
      AppStore.writable = false;
      AppStorage.setOrCreate('storeError', '本地数据读取失败，请检查设备存储后重启应用。');
    }
  }

  static contact(id: string): Contact | undefined {
    return AppStore.data.contacts.find((item: Contact) => item.id === id);
  }

  static changed(): void {
    AppStorage.setOrCreate('revision', (AppStorage.get<number>('revision') || 0) + 1);
  }

  static async save(): Promise<void> {
    if (!AppStore.writable) {
      throw new Error('本地数据未成功加载，已阻止覆盖原文件');
    }
    const content = JSON.stringify(AppStore.data);
    // 捕获调用时快照，写入串行化；失败保留原文件并将错误传给操作界面。
    const current = AppStore.writeQueue.then(() => {
      const temporary = AppStore.dataPath + '.tmp';
      const file = fileIo.openSync(temporary, fileIo.OpenMode.CREATE | fileIo.OpenMode.READ_WRITE | fileIo.OpenMode.TRUNC);
      try {
        fileIo.writeSync(file.fd, content);
        fileIo.fsyncSync(file.fd);
      } finally {
        fileIo.closeSync(file);
      }
      fileIo.renameSync(temporary, AppStore.dataPath);
      AppStorage.setOrCreate('storeError', '');
      AppStore.changed();
    });
    AppStore.writeQueue = current.catch(() => {
      AppStorage.setOrCreate('storeError', '保存失败，请检查设备剩余空间后重试。');
    });
    return current;
  }

  static id(prefix: string): string {
    return prefix + '-' + Date.now().toString(36) + '-' + Math.random().toString(36).slice(2, 8);
  }
}
