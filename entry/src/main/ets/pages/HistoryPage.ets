import { appState } from '../common/AppState'
import { HistoryService, HistoryItem } from '../service/HistoryService'
import { AppStyles, Card, PrimaryButton, StatusBadge } from '../components/Styles'

@Component
export struct HistoryPage {
  @State history: HistoryItem[] = []
  @State loading: boolean = true

  async aboutToAppear() {
    await this.loadHistory()
  }

  async loadHistory() {
    this.loading = true
    try {
      this.history = await HistoryService.getHistory()
    } catch (error) {
      console.error('Failed to load history:', error)
    } finally {
      this.loading = false
    }
  }

  formatDuration(seconds?: number): string {
    if (!seconds) return '未知时长'
    const hours = Math.floor(seconds / 3600)
    const minutes = Math.floor((seconds % 3600) / 60)
    if (hours > 0) {
      return `${hours}小时${minutes}分钟`
    } else {
      return `${minutes}分钟`
    }
  }

  formatDate(timestamp: number): string {
    return new Date(timestamp).toLocaleString('zh-CN')
  }

  build() {
    Column({ space: AppStyles.Spacing.M }) {
      // 返回按钮
      Button('← 返回', { type: ButtonType.Normal })
        .onClick(() => appState.openHome())
        .margin({ bottom: 16 })

      // 标题
      Text('播放历史')
        .fontSize(AppStyles.FontSizes.Title1)
        .fontWeight(FontWeight.Bold)

      // 历史记录列表
      if (this.loading) {
        Column() {
          LoadingProgress.create()
            .width(30)
            .height(30)
          Text('加载历史记录中...')
            .fontSize(AppStyles.FontSizes.Caption1)
            .fontColor(AppStyles.Colors.Gray)
        }
        .alignItems(HorizontalAlign.Center)
        .width('100%')
        .margin({ top: 40 })
      } else if (this.history.length === 0) {
        // 空状态
        Card() {
          Column({ space: AppStyles.Spacing.M }) {
            Text('📺')
              .fontSize(48)
            Text('暂无播放历史')
              .fontSize(AppStyles.FontSizes.Headline)
              .fontColor(AppStyles.Colors.Gray)
            Text('观看视频后，播放记录会显示在这里')
              .fontSize(AppStyles.FontSizes.Caption1)
              .fontColor(AppStyles.Colors.Gray)
          }
          .alignItems(HorizontalAlign.Center)
        }
      } else {
        // 历史记录列表
        List() {
          ForEach(this.history, (item: HistoryItem) => {
            ListItem() {
              Card() {
                Row() {
                  // 缩略图占位
                  Column() {
                    Text('🎬')
                      .fontSize(32)
                  }
                  .width(60)
                  .alignItems(HorizontalAlign.Center)
                  .justifyContent(FlexAlign.Center)
                  .backgroundColor(AppStyles.Colors.LightGray)

                  // 内容
                  Column({ space: 4 }) {
                    Text(item.title)
                      .fontSize(AppStyles.FontSizes.Body)
                      .fontWeight(FontWeight.Medium)
                      .maxLines(1)
                      .textOverflow({ overflow: TextOverflow.Ellipsis })
                    
                    if (item.subtitle) {
                      Text(item.subtitle)
                        .fontSize(AppStyles.FontSizes.Caption1)
                        .fontColor(AppStyles.Colors.Gray)
                        .maxLines(1)
                        .textOverflow({ overflow: TextOverflow.Ellipsis })
                    }

                    Row() {
                      Text(this.formatDate(item.timestamp))
                        .fontSize(AppStyles.FontSizes.Caption2)
                        .fontColor(AppStyles.Colors.Gray)
                      if (item.duration) {
                        Text(`⏱️ ${this.formatDuration(item.duration)}`)
                          .fontSize(AppStyles.FontSizes.Caption2)
                          .fontColor(AppStyles.Colors.Gray)
                          .margin({ left: 8 })
                      }
                    }
                  }
                  .layoutWeight(1)

                  // 播放按钮
                  Button('▶', { type: ButtonType.Normal })
                    .width(32)
                    .height(32)
                    .backgroundColor(AppStyles.Colors.Primary)
                    .onClick(() => {
                      appState.playUrl = item.playUrl
                      appState.openPlayer()
                    })
                }
              }
            }
            .onClick(() => {
              // 点击跳转到详情（如果有sourceId）
              if (item.id) {
                appState.selectedSource = {
                  id: item.id,
                  title: item.title,
                  subtitle: item.subtitle,
                  supportsSearch: false,
                  raw: { key: item.id, name: item.title, ext: item.playUrl }
                }
                appState.openDetail(appState.selectedSource)
              }
            })
          }, (item: HistoryItem) => item.id)
        }
        .divider({ strokeWidth: 1, color: AppStyles.Colors.LightGray })
      }

      // 底部操作按钮
      if (this.history.length > 0) {
        Row({ space: AppStyles.Spacing.S }) {
          PrimaryButton({
            text: '🗑️ 清空历史',
            onClick: async () => {
              await HistoryService.clearHistory()
              await this.loadHistory()
            },
            disabled: false
          })
          .layoutWeight(1)
          .backgroundColor(AppStyles.Colors.Red)
        }
      }
    }
    .padding(AppStyles.Spacing.M)
    .width('100%')
    .height('100%')
    .backgroundColor(AppStyles.Colors.LightGray)
  }
}