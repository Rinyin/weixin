import { hilog } from '@kit.PerformanceAnalysisKit';
import { UIAbility, ConfigurationConstant } from '@kit.AbilityKit';
import { KeyboardAvoidMode, window } from '@kit.ArkUI';
import { SessionMode } from '../model/AuthModels';
import { AppStore } from '../services/AppStore';
import { SessionStore } from '../services/SessionStore';

export default class EntryAbility extends UIAbility {
  onCreate(): void {
    this.context.getApplicationContext().setColorMode(ConfigurationConstant.ColorMode.COLOR_MODE_LIGHT);
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    AppStore.initialize(this.context).then(() => {
      // 已登录（或已选择游客模式）时直接进入主页，无需每次重新登录。
      SessionStore.restore();
      const page = SessionStore.mode === SessionMode.SignedOut ? 'pages/Login' : 'pages/Index';
      windowStage.loadContent(page, (error) => {
        if (error.code) {
          hilog.error(0x0000, 'Weixin', 'Page load failed: %{public}d', error.code);
          return;
        }
        // 键盘弹出时压缩页面而不是整体上移，保证标题栏始终可见。
        try {
          windowStage.getMainWindowSync().getUIContext().setKeyboardAvoidMode(KeyboardAvoidMode.RESIZE);
        } catch {
          hilog.warn(0x0000, 'Weixin', 'Keyboard avoid mode unavailable');
        }
      });
    });
  }
}
