import { AppSettings, SourceUiModel, TvBoxConfig } from '../model/Models'

export class ConfigService {
  static readonly DEFAULT_CONFIG_URL: string = 'https://pandown.pro/tvbox/tvbox.json'
  static readonly DEFAULT_API_BASE_URL: string = 'https://your-backend.example.com/api'

  async fetchConfig(url: string): Promise<TvBoxConfig> {
    const response = await fetch(url)
    return await response.json() as TvBoxConfig
  }

  mapSources(config: TvBoxConfig): SourceUiModel[] {
    const sites = config.sites ?? []
    return sites.map((site, index) => ({
      id: site.key ?? `site_${index}`,
      title: site.name ?? site.key ?? 'Unnamed source',
      subtitle: `api=${site.api ?? 'unknown'} · type=${site.type ?? -1} · playerType=${site.playerType ?? -1}`,
      supportsSearch: (site.searchable ?? 0) === 1 || (site.quickSearch ?? 0) === 1,
      raw: site
    }))
  }

  createDefaultSettings(): AppSettings {
    return {
      configUrl: ConfigService.DEFAULT_CONFIG_URL,
      apiBaseUrl: ConfigService.DEFAULT_API_BASE_URL,
      useBackendAdapter: false
    }
  }
}
