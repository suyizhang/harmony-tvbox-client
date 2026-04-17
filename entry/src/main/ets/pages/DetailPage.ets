import { appState } from '../common/AppState'
import { MockBackendService } from '../service/MockBackendService'
import { BackendApiService } from '../service/BackendApiService'
import { BackendDetail } from '../model/ApiModels'

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
        Text('未选择源')
          .fontSize(18)
          .fontColor(Color.Red)
      } else if (this.loading) {
        Column() {
          LoadingProgress.create()
            .width(50)
            .height(50)
          Text('正在加载详情...')
            .fontSize(14)
            .fontColor(Color.Gray)
        }
        .alignItems(HorizontalAlign.Center)
      } else if (this.error) {
        Column() {
          Text('加载出错')
            .fontSize(18)
            .fontColor(Color.Red)
          Text(this.error)
            .fontSize(12)
            .fontColor(Color.Gray)
          Button('重试', { type: ButtonType.Normal })
            .onClick(() => this.loadDetail(appState.selectedSource!.raw.key))
        }
      } else if (this.detail) {
        // 详情内容
        Column({ space: 16 }) {
          // 标题区域
          Column() {
            Text(this.detail.title)
              .fontSize(24)
              .fontWeight(FontWeight.Bold)
            if (this.detail.description) {
              Text(this.detail.description)
                .fontSize(14)
                .fontColor(Color.Gray)
                .maxLines(3)
                .textOverflow({ overflow: TextOverflow.Ellipsis })
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

          // 播放按钮
          Button('▶ 播放', { type: ButtonType.Normal, stateEffect: true })
            .width('100%')
            .height(48)
            .backgroundColor('#007AFF')
            .onClick(() => {
              if (appState.settings.useMockBackend && this.detail) {
                // Mock 模式下直接构造播放URL
                appState.playUrl = this.detail.playUrl || 'https://mock-stream.example.com/default.mp4'
                appState.openPlayer()
              } else {
                appState.openPlayer()
              }
            })

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
