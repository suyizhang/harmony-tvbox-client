import { AppSettings, SourceUiModel } from '../model/Models'
import { ConfigService } from '../service/ConfigService'
import { SettingsService } from '../service/SettingsService'
import { BackendApiService } from '../service/BackendApiService'
import { MockBackendService } from '../service/MockBackendService'

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
    if (this.settings.useMockBackend) {
      this.status = '正在加载 Mock 后端数据...'
      try {
        const mockBackend = new MockBackendService()
        const items = await mockBackend.fetchSources('http://mock.api.local')
        this.sources = mockBackend.mapBackendSources(items)
        this.filteredSources = this.sources
        this.overview = `Mock 后端模式: 开启\n数据源: ${this.sources.length} 个\n描述: 模拟后端API响应，便于开发和测试`
        this.status = `Mock 后端已加载 ${this.sources.length} 个源`
      } catch (err) {
        this.status = 'Mock 后端加载失败'
        this.overview = JSON.stringify(err)
      }
    } else if (this.settings.useBackendAdapter) {
      this.status = '正在加载后端聚合源...'
      try {
        const backend = new BackendApiService()
        const items = await backend.fetchSources(this.settings.apiBaseUrl)
        this.sources = backend.mapBackendSources(items)
        this.filteredSources = this.sources
        this.overview = `后端 API: ${this.settings.apiBaseUrl}\n后端模式: 开启\n推荐由后端处理 TVBox 兼容与播放解析。`
      } catch (err) {
        this.status = '后端加载失败'
        this.overview = JSON.stringify(err)
      }
    } else {
      this.status = '正在加载 TVBox 配置...'
      try {
        const service = new ConfigService()
        const config = await service.fetchConfig(this.settings.configUrl)
        this.sources = service.mapSources(config)
        this.filteredSources = this.sources
        this.overview = `spider: ${config.spider ?? '无'}\nwallpaper: ${config.wallpaper ?? '无'}\n后端模式: 关闭\n当前版本不执行外部 spider/jar/csp。`
      } catch (err) {
        this.status = '配置加载失败'
        this.overview = JSON.stringify(err)
      }
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
    
    // 如果是 mock 后端，预加载详情数据
    if (this.settings.useMockBackend && item.raw.key) {
      this.loadMockDetail(item.raw.key)
    }
  }

  async loadMockDetail(sourceId: string) {
    if (!this.settings.useMockBackend) return
    
    try {
      const mockBackend = new MockBackendService()
      const detail = await mockBackend.fetchDetail('http://mock.api.local', sourceId)
      console.log(`[AppState] Loaded mock detail for ${sourceId}: ${detail.title}`)
      // 可以在这里更新选中源的额外信息
    } catch (err) {
      console.error(`[AppState] Failed to load mock detail: ${err}`)
    }
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
