import { appState } from '../common/AppState'
import { BackendPlayResponse } from '../model/ApiModels'
import { MockBackendService } from '../service/MockBackendService'
import { BackendApiService } from '../service/BackendApiService'
import { FavoriteService } from '../service/FavoriteService'
import { VideoPlayerService } from '../service/VideoPlayerService'
import { AppStyles, PrimaryButton, StatusBadge } from '../components/Styles'
import { UnifiedLoading, ErrorState } from '../components/LoadingStates'
import { Slider, SliderStyle } from '@kit.ArkUI'
import { Picker } from '@kit.ArkUI'
import { ButtonType } from '@kit.ArkUI'
import { FlexAlign } from '@kit.ArkUI'
import { Color } from '@kit.ArkUI'

@Component
export struct PlayerPage {
  @State playInfo: BackendPlayResponse | null = null
  @State loading: boolean = true
  @State error: string = ''
  @State mockPlaying: boolean = false
  @State isRealPlaying: boolean = false
  private playerService: VideoPlayerService = new VideoPlayerService()

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
        UnifiedLoading({
          message: '正在准备播放...',
          showProgress: true,
          size: 'medium'
        })
      } else if (this.error) {
        ErrorState({
          title: '播放出错',
          message: this.error,
          showRetry: true,
          onRetry: () => {
            if (appState.selectedSource) {
              this.loadPlayUrl(appState.selectedSource.raw.key)
            }
          }
        })
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

          // 视频播放区域
          Card() {
            if (appState.settings.useMockBackend && !this.isRealPlaying) {
              // Mock 播放器界面
              Stack() {
                // 背景渐变
                Column()
                  .width('100%')
                  .height('100%')
                  .linearGradient({
                    angle: 135,
                    colors: [['#1e3c72', 0.0], ['#2a5298', 1.0]]
                  })
                
                Column({ space: 12 }) {
                  Text('🎬')
                    .fontSize(64)
                    .fontColor('#FFFFFF')
                  Text(appState.selectedSource?.title || 'Mock 视频')
                    .fontSize(20)
                    .fontWeight(FontWeight.Bold)
                    .fontColor('#FFFFFF')
                  Row() {
                    Text('⏱️ 02:30:45')
                      .fontSize(14)
                      .fontColor('#FFFFFF')
                      .opacity(0.8)
                    Text('📺 1920×1080')
                      .fontSize(14)
                      .fontColor('#FFFFFF')
                      .opacity(0.8)
                      .margin({ left: 16 })
                  }
                  Row() {
                    Text('🔊 立体声')
                      .fontSize(14)
                      .fontColor('#FFFFFF')
                      .opacity(0.8)
                    Text('🎞️ MP4')
                      .fontSize(14)
                      .fontColor('#FFFFFF')
                      .opacity(0.8)
                      .margin({ left: 16 })
                  }
                }
                .padding(32)
                .width('100%')
                .height(240)
                .justifyContent(FlexAlign.Center)
                .alignItems(HorizontalAlign.Center)
              }
            } else {
              // 真实视频播放区域
              Column() {
                if (this.isRealPlaying) {
                  // 真实播放器界面
                  Stack() {
                    // 视频播放区域
                    Column()
                      .width('100%')
                      .height('100%')
                      .backgroundColor('#000000')
                      .onClick(() => {
                        // 点击切换播放/暂停
                        if (this.playerService.isPlaying()) {
                          this.playerService.pause()
                        } else {
                          this.playerService.resume()
                        }
                      })
                    
                    // 播放状态叠加层
                    if (!this.playerService.isPlaying() && !this.playerService.isPaused()) {
                      Column() {
                        Text('▶')
                          .fontSize(64)
                          .fontColor('#FFFFFF')
                          .opacity(0.8)
                      }
                      .width('100%')
                      .height('100%')
                      .justifyContent(FlexAlign.Center)
                      .alignItems(HorizontalAlign.Center)
                    }
                  }
                  .width('100%')
                  .height(240)
                  
                  // 播放控制栏
                  Column({ space: 8 }) {
                    // 进度条
                    Slider({
                      value: this.playerService.getProgress(),
                      min: 0,
                      max: 100,
                      style: SliderStyle.OutSet
                    })
                    .width('100%')
                    .onChange(async (value: number) => {
                      const duration = this.playerService.getDuration()
                      const seekTime = (value / 100) * duration
                      await this.playerService.seekTo(seekTime)
                    })
                    
                    // 时间和控制按钮
                    Row({ space: 12 }) {
                      Text(`${Math.floor(this.playerService.getCurrentTime())}s`)
                        .fontSize(12)
                        .fontColor('#666666')
                      
                      // 播放/暂停按钮
                      Button(this.playerService.isPlaying() ? '⏸️' : '▶️', { type: ButtonType.Circle })
                        .width(40)
                        .height(40)
                        .onClick(async () => {
                          if (this.playerService.isPlaying()) {
                            await this.playerService.pause()
                          } else {
                            await this.playerService.resume()
                          }
                        })
                      
                      // 停止按钮
                      Button('⏹️', { type: ButtonType.Circle })
                        .width(40)
                        .height(40)
                        .onClick(async () => {
                          await this.playerService.stop()
                          this.isRealPlaying = false
                        })
                      
                      Text(`${Math.floor(this.playerService.getDuration())}s`)
                        .fontSize(12)
                        .fontColor('#666666')
                    }
                    .width('100%')
                    .justifyContent(FlexAlign.SpaceBetween)
                    
                    // 音量和速度控制
                    Row({ space: 12 }) {
                      // 音量控制
                      Row({ space: 4 }) {
                        Text('🔊')
                          .fontSize(14)
                        Slider({
                          value: 70, // 默认音量70%
                          min: 0,
                          max: 100
                        })
                        .width(80)
                        .onChange(async (value: number) => {
                          await this.playerService.setVolume(value / 100)
                        })
                      }
                      
                      // 播放速度
                      Picker()
                        .selected(2) // 默认1.0x
                        .onChange((index: number) => {
                          const speeds = this.playerService.getSupportedSpeeds()
                          this.playerService.setPlaybackSpeed(speeds[index])
                        })
                        .child(
                          Text(`${this.playerService.getSupportedSpeeds()[2]}x`)
                            .fontSize(12)
                        )
                    }
                    .width('100%')
                  }
                  .padding(12)
                  .backgroundColor('#f8f9fa')
                  .borderRadius(8)
                } else {
                  // 播放前界面
                  Column() {
                    Text('🎥')
                      .fontSize(48)
                      .fontColor('#007AFF')
                    Text('真实播放模式')
                      .fontSize(16)
                      .fontColor('#333333')
                    Text(appState.playUrl || '播放地址')
                      .fontSize(10)
                      .fontColor('#666666')
                      .maxLines(1)
                  }
                  .padding(32)
                  .width('100%')
                  .height(240)
                  .justifyContent(FlexAlign.Center)
                  .alignItems(HorizontalAlign.Center)
                  .backgroundColor('#f8f9fa')
                  .onClick(async () => {
                    if (appState.playUrl && !this.isRealPlaying) {
                      this.isRealPlaying = true
                      const success = await this.playerService.play(appState.playUrl)
                      if (!success) {
                        this.error = '播放失败，请检查网络连接'
                        this.loading = false
                      }
                    }
                  })
                }
              }
            }
          }
          .width('100%')
          .height(240)
          .borderRadius(AppStyles.Radius.Large)

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
          Column({ space: AppStyles.Spacing.S }) {
            if (this.isRealPlaying) {
              // 真实播放模式控制
              Row({ space: AppStyles.Spacing.S }) {
                Button('⏸️ 暂停', { type: ButtonType.Normal })
                  .flexGrow(1)
                  .onClick(async () => {
                    await this.playerService.pause()
                  })
                
                Button('⏹️ 停止', { type: ButtonType.Normal })
                  .flexGrow(1)
                  .onClick(async () => {
                    await this.playerService.stop()
                    this.isRealPlaying = false
                  })
              }
            } else {
              // Mock模式控制
              Row({ space: AppStyles.Spacing.S }) {
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
                
                Button('▶️ 播放', { type: ButtonType.Normal })
                  .flexGrow(1)
                  .onClick(async () => {
                    if (appState.playUrl) {
                      this.isRealPlaying = true
                      await this.playerService.play(appState.playUrl)
                    }
                  })
              }
            }
            
            // 收藏按钮
            if (appState.selectedSource) {
              Button(appState.favorites.some(f => f.id === appState.selectedSource?.id) ? '❤️ 已收藏' : '🤍 收藏', { type: ButtonType.Normal })
                .width('100%')
                .height(40)
                .backgroundColor(appState.favorites.some(f => f.id === appState.selectedSource?.id) ? AppStyles.Colors.Red : AppStyles.Colors.Gray)
                .onClick(async () => {
                  if (appState.selectedSource) {
                    await appState.toggleFavorite(appState.selectedSource)
                  }
                })
            }
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
