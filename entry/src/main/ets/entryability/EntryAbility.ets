import UIAbility from '@ohos.app.ability.UIAbility';
import window from '@ohos.window';

export default class EntryAbility extends UIAbility {
  onWindowStageCreate(windowStage: window.WindowStage): void {
    windowStage.loadContent('pages/HomePage', (err) => {
      if (err.code) {
        console.error('Failed to load the content. Cause:', JSON.stringify(err));
        return;
      }
      console.info('Succeeded in loading the content.');
    });
  }
}
