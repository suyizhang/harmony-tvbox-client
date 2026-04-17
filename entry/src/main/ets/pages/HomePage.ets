import { appState } from '../common/AppState'
import { AppShell } from './AppShell'

@Entry
@Component
struct HomePage {
  async aboutToAppear() {
    if (appState.sources.length === 0) {
      await appState.loadConfig()
    }
  }

  build() {
    AppShell()
  }
}
