import { AppSettings } from '../model/Models'
import { ConfigService } from './ConfigService'

const KEY_CONFIG_URL: string = 'configUrl'
const KEY_API_BASE_URL: string = 'apiBaseUrl'
const KEY_USE_BACKEND: string = 'useBackendAdapter'

export class SettingsService {
  load(): AppSettings {
    const configUrl = AppStorage.Get<string>(KEY_CONFIG_URL) ?? ConfigService.DEFAULT_CONFIG_URL
    const apiBaseUrl = AppStorage.Get<string>(KEY_API_BASE_URL) ?? ConfigService.DEFAULT_API_BASE_URL
    const useBackendAdapter = AppStorage.Get<boolean>(KEY_USE_BACKEND) ?? false
    return {
      configUrl,
      apiBaseUrl,
      useBackendAdapter
    }
  }

  save(settings: AppSettings): void {
    AppStorage.SetOrCreate(KEY_CONFIG_URL, settings.configUrl)
    AppStorage.SetOrCreate(KEY_API_BASE_URL, settings.apiBaseUrl)
    AppStorage.SetOrCreate(KEY_USE_BACKEND, settings.useBackendAdapter)
  }
}
