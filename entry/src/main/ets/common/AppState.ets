import { AppSettings, SourceUiModel } from '../model/Models'
import { ConfigService } from '../service/ConfigService'
import { SettingsService } from '../service/SettingsService'
import { BackendApiService } from '../service/BackendApiService'
import { MockBackendService } from '../service/MockBackendService'
import { HistoryService, HistoryItem } from '../service/HistoryService'
import { FavoriteService, FavoriteItem, FavoriteCategory } from '../service/FavoriteService'
import { ThemeService, ThemeMode, ThemeConfig } from '../service/ThemeService'

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
  playHistory: HistoryItem[] = []
  favorites: FavoriteItem[] = []
  favoriteStats: Record<string, number> = {}
  themeMode: ThemeMode = ThemeMode.AUTO
  themeConfig: ThemeConfig = ThemeService.getThemeConfig(ThemeMode.AUTO)

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

  // 收藏相关方法
  async toggleFavorite(item?: SourceUiModel) {
    if (!item) return
    
    const isFav = await FavoriteService.isFavorited(item.id)
    if (isFav) {
      await FavoriteService.removeFromFavorites(item.id)
    } else {
      const favoriteItem: Omit<FavoriteItem, 'createdAt' | 'updatedAt'> = {
        id: item.id,
        title: item.title,
        subtitle: item.subtitle,
        sourceId: item.id,
        category: this.guessCategory(item.title)
      }
      await FavoriteService.addToFavorites(favoriteItem)
    }
    await this.loadFavorites()
  }

  async loadFavorites() {
    this.favorites = await FavoriteService.getFavorites()
    this.favoriteStats = await FavoriteService.getStatistics()
  }

  private guessCategory(title: string): FavoriteCategory {
    const lower = title.toLowerCase()
    if (lower.includes('动漫') || lower.includes('动画')) return FavoriteCategory.ANIME
    if (lower.includes('综艺') || lower.includes('娱乐')) return FavoriteCategory.VARIETY
    if (lower.includes('纪录')) return FavoriteCategory.DOCUMENTARY
    if (lower.includes('第') && (lower.includes('季') || lower.includes('集'))) return FavoriteCategory.TV_SHOW
    return FavoriteCategory.MOVIE
  }

  async addToHistory(detail: BackendDetail, playUrl: string) {
    if (!this.selectedSource) return
    
    const historyItem: HistoryItem = {
      id: detail.id,
      title: detail.title,
      subtitle: detail.description || this.selectedSource.subtitle,
      playUrl: playUrl,
      timestamp: Date.now()
    }
    await HistoryService.addToHistory(historyItem)
  }

  // 主题相关方法
  async loadTheme() {
    this.themeMode = await ThemeService.getThemeMode()
    this.themeConfig = ThemeService.getThemeConfig(this.themeMode)
  }

  async toggleTheme() {
    const modes = [ThemeMode.LIGHT, ThemeMode.DARK, ThemeMode.AUTO]
    const currentIndex = modes.indexOf(this.themeMode)
    const nextIndex = (currentIndex + 1) % modes.length
    this.themeMode = modes[nextIndex]
    
    await ThemeService.setThemeMode(this.themeMode)
    this.themeConfig = ThemeService.getThemeConfig(this.themeMode)
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

  openFavorites() {
    this.currentPage = 'favorites'
    this.loadFavorites()
  }

  openHome() {
    this.currentPage = 'home'
  }
}

export const appState: AppState = new AppState()
