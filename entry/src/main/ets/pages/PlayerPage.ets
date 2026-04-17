import { appState } from '../common/AppState'
import { BackendPlayResponse } from '../model/ApiModels'
import { MockBackendService } from '../service/MockBackendService'
import { BackendApiService } from '../service/BackendApiService'

@Component
export struct PlayerPage {
  @State playInfo: BackendPlayResponse | null = null
  @State loading: boolean = true
  @State error: string = ''
  @State mockPlaying: boolean = false

  async aboutToAppear() {
    if (appState.selectedSource && appState.selectedSource.raw.key) {
      if (appState.settings.useMockBackend) {
        // Mock 模式直接使用预设的播放URL
        this.loading = false
        this.mockPlaying = true
        appState.playUrl = appState.playUrl || 'https://mock-stream.example.com/default.mp4'
      } else {
        await this.loadPlayUrl(appState.selectedSource.raw.key)
      }
    } else if (appState.playUrl) {
      // 直接使用现有的播放URL
      this.loading = false
    } else {
      this.error = '未找到播放源'
      this.loading = false
    }
  }

  async loadPlayUrl(sourceId: string) {
    this.loading = true
    this.error = ''
    
    try {
      if (appState.settings.useMockBackend) {
        // Mock 模式下模拟API调用
        await new Promise(resolve => setTimeout(resolve, 500))
        this.playInfo = {
          id: sourceId,
          url: 'https://mock-stream.example.com/' + sourceId + '.mp4',
          type: 'mp4'
        }
        appState.playUrl = this.playInfo.url
      } else if (appState.settings.useBackendAdapter) {
        // 使用真实后端
        const backend = new BackendApiService()
        this.playInfo = await backend.fetchPlay(appState.settings.apiBaseUrl, sourceId)
        appState.playUrl = this.playInfo.url
      } else {
        // 本地模式，使用预设URL
        appState.playUrl = appState.playUrl || 'https://example.com/local-stream.mp4'
      }
    } catch (err) {
      this.error = `播放地址获取失败: ${err}`
      console.error('PlayerPage loadPlayUrl error:', err)
    } finally {
      this.loading = false
    }
  }

  build() {
    Column({ space: 16 }) {
      // 返回按钮
      Button('← 返回', { type: ButtonType.Normal })
        .onClick(() => appState.openDetail(appState.selectedSource!))
        .margin({ bottom: 16 })

      if (this.loading) {
        Column() {
          LoadingProgress.create()
            .width(50)
            .height(50)
          Text('正在准备播放...')
            .fontSize(14)
            .fontColor(Color.Gray)
        }
        .alignItems(HorizontalAlign.Center)
        .width('100%')
      } else if (this.error) {
        Column() {
          Text('播放出错')
            .fontSize(18)
            .fontColor(Color.Red)
          Text(this.error)
            .fontSize(12)
            .fontColor(Color.Gray)
          Button('重试', { type: ButtonType.Normal })
            .onClick(() => {
              if (appState.selectedSource) {
                this.loadPlayUrl(appState.selectedSource.raw.key)
              }
            })
        }
        .alignItems(HorizontalAlign.Center)
      } else {
        // 播放器界面
        Column({ space: 12 }) {
          // Mock 模式标识
          if (appState.settings.useMockBackend) {
            Row() {
              Text('🎭 Mock 播放模式')
                .fontSize(12)
                .fontColor(Color.Orange)
              if (this.mockPlaying) {
                Text('▶ 播放中')
                  .fontSize(12)
                  .fontColor(Color.Green)
                  .margin({ left: 8 })
              }
            }
            .margin({ bottom: 8 })
          }

          // 视频播放区域（模拟）
          Column() {
            if (appState.settings.useMockBackend) {
              // Mock 播放器界面
              Column() {
                Text('🎬')
                  .fontSize(48)
                Text(appState.selectedSource?.title || 'Mock 视频')
                  .fontSize(16)
                  .fontWeight(FontWeight.Medium)
                Text('时长: 02:30:45')
                  .fontSize(12)
                  .fontColor(Color.Gray)
                Text('分辨率: 1920x1080')
                  .fontSize(12)
                  .fontColor(Color.Gray)
              }
              .padding(32)
              .backgroundColor('#000000')
              .width('100%')
              .height(240)
              .justifyContent(FlexAlign.Center)
              .alignItems(HorizontalAlign.Center)
            } else {
              // 真实播放器占位
              Text('📺 视频播放器')
                .fontSize(18)
                .fontColor(Color.Gray)
                .width('100%')
                .height(240)
                .backgroundColor('#f0f0f0')
                .justifyContent(FlexAlign.Center)
                .alignItems(HorizontalAlign.Center)
            }
          }
          .width('100%')
          .height(240)
          .backgroundColor('#000000')
          .borderRadius(8)

          // 播放URL信息
          if (appState.playUrl) {
            Column() {
              Text('播放地址')
                .fontSize(14)
                .fontWeight(FontWeight.Medium)
              Text(appState.playUrl)
                .fontSize(10)
                .fontColor(Color.Gray)
                .maxLines(2)
                .textOverflow({ overflow: TextOverflow.Ellipsis })
            }
            .padding(12)
            .backgroundColor('#f5f5f5')
            .borderRadius(8)
            .width('100%')
          }

          // 控制按钮
          Row({ space: 12 }) {
            Button(appState.settings.useMockBackend ? '🔄 换片' : '重新加载', { type: ButtonType.Normal })
              .flexGrow(1)
              .onClick(() => {
                if (appState.settings.useMockBackend && appState.selectedSource) {
                  const mockBackend = new MockBackendService()
                  const ids = mockBackend.getAvailableIds()
                  const randomId = ids[Math.floor(Math.random() * ids.length)]
                  appState.selectedSource = { ...appState.selectedSource!, raw: { ...appState.selectedSource!.raw, key: randomId } }
                  this.loadPlayUrl(randomId)
                } else if (appState.selectedSource) {
                  this.loadPlayUrl(appState.selectedSource.raw.key)
                }
              })
            
            Button('⏹ 停止', { type: ButtonType.Normal })
              .flexGrow(1)
              .onClick(() => {
                this.mockPlaying = false
                appState.playUrl = ''
              })
          }
          .width('100%')
        }
      }
    }
    .padding(16)
    .width('100%')
    .height('100%')
    .alignItems(HorizontalAlign.Start)
  }
}
