import { hilog } from '@kit.PerformanceAnalysisKit';
import { UIAbility, ConfigurationConstant } from '@kit.AbilityKit';
import { window } from '@kit.ArkUI';
import { AppStore } from '../services/AppStore';

export default class EntryAbility extends UIAbility {
  onCreate(): void {
    this.context.getApplicationContext().setColorMode(ConfigurationConstant.ColorMode.COLOR_MODE_LIGHT);
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    AppStore.initialize(this.context).then(() => {
      windowStage.loadContent('pages/Index', (error) => {
        if (error.code) {
          hilog.error(0x0000, 'Weixin', 'Page load failed: %{public}d', error.code);
        }
      });
    });
  }
}
