import { hilog } from '@kit.PerformanceAnalysisKit';
import { UIAbility, ConfigurationConstant } from '@kit.AbilityKit';
import { window } from '@kit.ArkUI';
import { AppStore } from '../services/AppStore';
import { SessionStore } from '../services/SessionStore';

export default class EntryAbility extends UIAbility {
  onCreate(): void {
    this.context.getApplicationContext().setColorMode(ConfigurationConstant.ColorMode.COLOR_MODE_LIGHT);
    SessionStore.reset();
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    AppStore.initialize(this.context).then(() => {
      windowStage.loadContent('pages/Login', (error) => {
        if (error.code) {
          hilog.error(0x0000, 'Weixin', 'Page load failed: %{public}d', error.code);
        }
      });
    });
  }
}
