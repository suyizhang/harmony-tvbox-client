import { AppSettings, SourceUiModel } from '../model/Models'
import { ConfigService } from '../service/ConfigService'
import { SettingsService } from '../service/SettingsService'
import { BackendApiService } from '../service/BackendApiService'

@Observed
export class AppState {
  currentPage: string = 'home'
  settings: AppSettings = new SettingsService().load()
  status: string = '准备就绪'
  overview: string = ''
  searchKeyword: string = ''
  sources: SourceUiModel[] = []
  filteredSources: SourceUiModel[] = []
  selectedSource?: SourceUiModel = undefined
  playUrl: string = ''

  saveSettings() {
    new SettingsService().save(this.settings)
  }

  async loadConfig() {
    this.status = this.settings.useBackendAdapter ? '正在加载后端聚合源...' : '正在加载 TVBox 配置...'
    try {
      if (this.settings.useBackendAdapter) {
        const backend = new BackendApiService()
        const items = await backend.fetchSources(this.settings.apiBaseUrl)
        this.sources = backend.mapBackendSources(items)
        this.filteredSources = this.sources
        this.overview = `后端 API: ${this.settings.apiBaseUrl}\n后端模式: 开启\n推荐由后端处理 TVBox 兼容与播放解析。`
      } else {
        const service = new ConfigService()
        const config = await service.fetchConfig(this.settings.configUrl)
        this.sources = service.mapSources(config)
        this.filteredSources = this.sources
        this.overview = `spider: ${config.spider ?? '无'}\nwallpaper: ${config.wallpaper ?? '无'}\n后端模式: 关闭\n当前版本不执行外部 spider/jar/csp。`
      }
      this.status = `已加载 ${this.sources.length} 个源`
    } catch (err) {
      this.status = '加载失败'
      this.overview = JSON.stringify(err)
    }
  }

  filterSources() {
    const keyword = this.searchKeyword.trim().toLowerCase()
    if (!keyword) {
      this.filteredSources = this.sources
      return
    }
    this.filteredSources = this.sources.filter(item =>
      item.title.toLowerCase().includes(keyword) || item.subtitle.toLowerCase().includes(keyword)
    )
  }

  openDetail(item: SourceUiModel) {
    this.selectedSource = item
    this.playUrl = item.raw.ext ?? ''
    this.currentPage = 'detail'
  }

  openPlayer() {
    this.currentPage = 'player'
  }

  openSearch() {
    this.currentPage = 'search'
  }

  openSettings() {
    this.currentPage = 'settings'
  }

  openHome() {
    this.currentPage = 'home'
  }
}

export const appState: AppState = new AppState()
