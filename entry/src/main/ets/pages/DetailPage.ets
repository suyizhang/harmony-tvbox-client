import { appState } from '../common/AppState'
import { MockBackendService } from '../service/MockBackendService'
import { BackendApiService } from '../service/BackendApiService'
import { BackendDetail } from '../model/ApiModels'
import { FavoriteService, FavoriteCategory } from '../service/FavoriteService'
import { AppStyles, PrimaryButton, StatusBadge } from '../components/Styles'
import { UnifiedLoading, ErrorState } from '../components/LoadingStates'

@Component
export struct DetailPage {
  @State detail: BackendDetail | null = null
  @State loading: boolean = true
  @State error: string = ''

  async aboutToAppear() {
    if (appState.selectedSource) {
      await this.loadDetail(appState.selectedSource.raw.key)
    }
  }

  async loadDetail(sourceId: string) {
    this.loading = true
    this.error = ''
    
    try {
      if (appState.settings.useMockBackend) {
        // 使用 Mock 后端
        const mockBackend = new MockBackendService()
        this.detail = await mockBackend.fetchDetail('http://mock.api.local', sourceId)
      } else if (appState.settings.useBackendAdapter) {
        // 使用真实后端
        const backend = new BackendApiService()
        this.detail = await backend.fetchDetail(appState.settings.apiBaseUrl, sourceId)
      } else {
        // 本地模式，显示基本信息
        this.detail = {
          id: sourceId,
          title: appState.selectedSource?.title || '未知标题',
          description: appState.selectedSource?.subtitle || '暂无描述'
        }
      }
    } catch (err) {
      this.error = `加载失败: ${err}`
      console.error('DetailPage loadDetail error:', err)
    } finally {
      this.loading = false
    }
  }

  build() {
    Column({ space: 12 }) {
      // 返回按钮
      Button('← 返回', { type: ButtonType.Normal })
        .onClick(() => appState.openHome())
        .margin({ bottom: 16 })

      if (!appState.selectedSource) {
        EmptyState({
          icon: '⚠️',
          title: '未选择源',
          description: '请先选择一个数据源',
          showAction: true,
          actionText: '返回首页',
          onAction: () => appState.openHome()
        })
      } else if (this.loading) {
        UnifiedLoading({
          message: '正在加载详情...',
          showProgress: true,
          size: 'medium'
        })
      } else if (this.error) {
        ErrorState({
          title: '加载出错',
          message: this.error,
          showRetry: true,
          onRetry: () => this.loadDetail(appState.selectedSource!.raw.key)
        })
      } else if (this.detail) {
        // 详情内容
        Column({ space: 16 }) {
          // 标题区域
          Card() {
            Column({ space: 12 }) {
              Row() {
                Text(this.detail.title)
                  .fontSize(AppStyles.FontSizes.Title2)
                  .fontWeight(FontWeight.Bold)
                  .layoutWeight(1)
                if (appState.settings.useMockBackend) {
                  StatusBadge({ text: '🎭 Mock', type: 'info' })
                }
              }
              
              if (this.detail.description) {
                Text(this.detail.description)
                  .fontSize(AppStyles.FontSizes.Body)
                  .fontColor(AppStyles.Colors.Gray)
                  .maxLines(3)
                  .textOverflow({ overflow: TextOverflow.Ellipsis })
              }
              
              // Mock 模式特殊信息
              if (appState.settings.useMockBackend) {
                Row() {
                  Text('🎲 随机推荐')
                    .fontSize(AppStyles.FontSizes.Caption1)
                    .fontColor(AppStyles.Colors.Orange)
                  Button('换一个', { type: ButtonType.Normal, stateEffect: true })
                    .fontSize(10)
                    .margin({ left: 8 })
                    .onClick(() => {
                      const mockBackend = new MockBackendService()
                      const ids = mockBackend.getAvailableIds()
                      const randomId = ids[Math.floor(Math.random() * ids.length)]
                      appState.selectedSource = { ...appState.selectedSource!, raw: { ...appState.selectedSource!.raw, key: randomId } }
                      this.loadDetail(randomId)
                    })
                }
              }
            }
          }

          // Mock 模式特殊信息
          if (appState.settings.useMockBackend) {
            Row() {
              Text('🎭 Mock 数据')
                .fontSize(12)
                .fontColor(Color.Orange)
              Button('换一个', { type: ButtonType.Normal, stateEffect: true })
                .fontSize(10)
                .margin({ left: 8 })
                .onClick(() => {
                  const mockBackend = new MockBackendService()
                  const ids = mockBackend.getAvailableIds()
                  const randomId = ids[Math.floor(Math.random() * ids.length)]
                  appState.selectedSource = { ...appState.selectedSource!, raw: { ...appState.selectedSource!.raw, key: randomId } }
                  this.loadDetail(randomId)
                })
            }
          }

          // 操作按钮区域
          Row({ space: AppStyles.Spacing.S }) {
            // 播放按钮
            Button(appState.settings.useMockBackend ? '🎭 模拟播放' : '▶ 播放', { type: ButtonType.Normal, stateEffect: true })
              .layoutWeight(2)
              .height(48)
              .backgroundColor('#007AFF')
              .onClick(() => {
                if (appState.settings.useMockBackend && this.detail) {
                  appState.playUrl = this.detail.playUrl || 'https://mock-stream.example.com/default.mp4'
                  appState.openPlayer()
                } else {
                  appState.openPlayer()
                }
              })
            
            // 收藏按钮
            Button(appState.favorites.some(f => f.id === appState.selectedSource?.id) ? '❤️' : '🤍', { type: ButtonType.Normal, stateEffect: true })
              .layoutWeight(1)
              .height(48)
              .backgroundColor(appState.favorites.some(f => f.id === appState.selectedSource?.id) ? '#FF3B30' : '#8E8E93')
              .onClick(async () => {
                if (appState.selectedSource) {
                  await appState.toggleFavorite(appState.selectedSource)
                }
              })
          }
          .width('100%')

          // 源信息
          if (appState.selectedSource) {
            Column() {
              Text('源信息')
                .fontSize(16)
                .fontWeight(FontWeight.Medium)
              Text(`ID: ${appState.selectedSource.id}`)
                .fontSize(12)
                .fontColor(Color.Gray)
              Text(`支持搜索: ${appState.selectedSource.supportsSearch ? '是' : '否'}`)
                .fontSize(12)
                .fontColor(Color.Gray)
            }
            .padding(12)
            .backgroundColor('#f5f5f5')
            .borderRadius(8)
          }
        }
      }
    }
    .padding(16)
    .width('100%')
    .height('100%')
    .alignItems(HorizontalAlign.Start)
  }
}
