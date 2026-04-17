import { appState } from '../common/AppState'
import { SourceUiModel } from '../model/Models'
import { AppStyles, Card, PrimaryButton, StatusBadge } from '../components/Styles'
import { SearchPage } from './SearchPage'
import { DetailPage } from './DetailPage'
import { PlayerPage } from './PlayerPage'
import { SettingsPage } from './SettingsPage'
import { FavoritesPage } from './FavoritesPage'

@Component
export struct AppShell {
  build() {
    Column({ space: AppStyles.Spacing.M }) {
      // 头部
      this.buildHeader()
      
      // 主要内容区域
      if (appState.currentPage === 'home') {
        this.buildHomePage()
      } else if (appState.currentPage === 'search') {
        SearchPage()
      } else if (appState.currentPage === 'detail') {
        DetailPage()
      } else if (appState.currentPage === 'player') {
        PlayerPage()
      } else if (appState.currentPage === 'settings') {
        SettingsPage({ settings: appState.settings })
      } else if (appState.currentPage === 'favorites') {
        FavoritesPage()
      }
    }
    .padding(AppStyles.Spacing.M)
    .width('100%')
    .height('100%')
    .backgroundColor(AppStyles.Colors.LightGray)
  }

  @Builder buildHeader() {
    Card() {
      Column({ space: AppStyles.Spacing.S }) {
        Row() {
          Text('📺 Harmony TVBox Client')
            .fontSize(AppStyles.FontSizes.Title1)
            .fontWeight(FontWeight.Bold)
            .layoutWeight(1)
          
          if (appState.settings.useMockBackend) {
            StatusBadge({ text: '🎭 Mock', type: 'info' })
          } else if (appState.settings.useBackendAdapter) {
            StatusBadge({ text: '🔗 API', type: 'success' })
          } else {
            StatusBadge({ text: '📁 本地', type: 'warning' })
          }
        }
        
        Text(appState.status)
          .fontSize(AppStyles.FontSizes.Callout)
          .fontColor(AppStyles.Colors.Gray)
        
        if (appState.overview) {
          Text(appState.overview)
            .fontSize(AppStyles.FontSizes.Footnote)
            .fontColor(AppStyles.Colors.Gray)
            .maxLines(2)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
        }
      }
    }
  }

  @Builder buildHomePage() {
    Column({ space: AppStyles.Spacing.M }) {
      // 操作按钮栏
      Row({ space: AppStyles.Spacing.S }) {
        PrimaryButton({
          text: '🔄 刷新',
          onClick: () => appState.loadConfig()
        })
        .layoutWeight(1)
        
        PrimaryButton({
          text: '🔍 搜索',
          onClick: () => appState.openSearch()
        })
        .layoutWeight(1)
        
        PrimaryButton({
          text: '⭐ 收藏',
          onClick: () => appState.openFavorites()
        })
        .layoutWeight(1)
        
        PrimaryButton({
          text: '⚙️ 设置',
          onClick: () => appState.openSettings()
        })
        .layoutWeight(1)
      }

      // 数据源列表
      if (appState.sources.length > 0) {
        Card() {
          Column({ space: AppStyles.Spacing.S }) {
            Row() {
              Text(`数据源 (${appState.sources.length})`)
                .fontSize(AppStyles.FontSizes.Title3)
                .fontWeight(FontWeight.Bold)
                .layoutWeight(1)
              StatusBadge({ 
                text: `${appState.filteredSources.length} 可用`, 
                type: 'success' 
              })
            }
            
            List() {
              ForEach(appState.filteredSources, (item: SourceUiModel) => {
                ListItem() {
                  Card() {
                    Row() {
                      Column({ space: 4 }) {
                        Text(item.title)
                          .fontSize(AppStyles.FontSizes.Body)
                          .fontWeight(FontWeight.Medium)
                        Text(item.subtitle)
                          .fontSize(AppStyles.FontSizes.Caption1)
                          .fontColor(AppStyles.Colors.Gray)
                      }
                      .layoutWeight(1)
                      
                      Column({ space: 2 }) {
                        StatusBadge({ 
                          text: item.supportsSearch ? '🔍' : '👁️', 
                          type: item.supportsSearch ? 'success' : 'warning' 
                        })
                        if (appState.settings.useMockBackend) {
                          StatusBadge({ text: '🎭', type: 'info' })
                        }
                      }
                    }
                  }
                }
                .onClick(() => appState.openDetail(item))
              }, (item: SourceUiModel) => item.id)
            }
            .divider({ strokeWidth: 1, color: AppStyles.Colors.LightGray })
            .height('60%')
          }
        }
      } else {
        // 空状态或有数据时都显示收藏入口
        Card() {
          Column({ space: AppStyles.Spacing.M }) {
            if (appState.favorites.length > 0) {
              // 收藏统计
              Row() {
                Text('⭐')
                  .fontSize(24)
                  .fontColor(AppStyles.Colors.Orange)
                Text(`我的收藏 (${appState.favorites.length})`)
                  .fontSize(AppStyles.FontSizes.Headline)
                  .fontWeight(FontWeight.Medium)
                  .margin({ left: 8 })
              }
              
              Text('快速访问您收藏的内容')
                .fontSize(AppStyles.FontSizes.Caption1)
                .fontColor(AppStyles.Colors.Gray)
              
              PrimaryButton({
                text: '查看收藏',
                onClick: () => appState.openFavorites()
              })
              
              Divider()
                .strokeWidth(1)
                .color(AppStyles.Colors.LightGray)
                .margin({ top: 8, bottom: 8 })
            }

            if (appState.sources.length === 0) {
              Text('😕')
                .fontSize(48)
              Text('暂无数据源')
                .fontSize(AppStyles.FontSizes.Headline)
                .fontColor(AppStyles.Colors.Gray)
              Text('请检查配置或切换到 Mock 模式进行测试')
                .fontSize(AppStyles.FontSizes.Caption1)
                .fontColor(AppStyles.Colors.Gray)
              
              PrimaryButton({
                text: '🔄 重新加载',
                onClick: () => appState.loadConfig()
              })
            } else {
              Text(`发现 ${appState.sources.length} 个数据源`)
                .fontSize(AppStyles.FontSizes.Caption1)
                .fontColor(AppStyles.Colors.Gray)
            }
          }
          .alignItems(HorizontalAlign.Center)
        }
      }
    }
  }
}

@Component
struct SearchPanel {
  build() {
    Column({ space: 12 }) {
      Text('搜索页')
        .fontSize(20)
        .fontWeight(FontWeight.Bold)

      TextInput({ placeholder: '搜索源名 / api', text: appState.searchKeyword })
        .onChange((value: string) => {
          appState.searchKeyword = value
        })

      Row({ space: 8 }) {
        Button('执行搜索')
          .layoutWeight(1)
          .onClick(() => {
            appState.filterSources()
            appState.openHome()
          })
        Button('返回')
          .layoutWeight(1)
          .onClick(() => {
            appState.openHome()
          })
      }
    }
    .padding(12)
    .backgroundColor('#F7F8FA')
  }
}

@Component
struct DetailPanel {
  build() {
    const item = appState.selectedSource
    Column({ space: 12 }) {
      Text(item?.title ?? '详情页')
        .fontSize(20)
        .fontWeight(FontWeight.Bold)

      Text(item?.subtitle ?? '暂无详情')
        .fontSize(12)

      Text(`api: ${item?.raw.api ?? 'unknown'}\nplayerType: ${item?.raw.playerType ?? -1}\next: ${item?.raw.ext ?? '无'}`)
        .fontSize(12)

      Text('当前版本不执行 spider/jar/csp，建议由后端适配层提供可播放地址。')
        .fontSize(12)

      Row({ space: 8 }) {
        Button('进入播放页')
          .layoutWeight(1)
          .onClick(() => {
            appState.openPlayer()
          })
        Button('返回首页')
          .layoutWeight(1)
          .onClick(() => {
            appState.openHome()
          })
      }
    }
    .padding(12)
    .backgroundColor('#F7F8FA')
  }
}

@Component
struct PlayerPanel {
  build() {
    Column({ space: 12 }) {
      Text('播放页')
        .fontSize(20)
        .fontWeight(FontWeight.Bold)

      Text(`当前播放地址：${appState.playUrl || '未设置'}`)
        .fontSize(12)

      Text(appState.settings.useBackendAdapter
        ? '当前为后端适配模式：后续由 /play 接口返回可播地址。'
        : '当前为本地配置模式：后续支持直链或测试地址播放。')
        .fontSize(12)

      Button('返回详情')
        .onClick(() => {
          appState.currentPage = 'detail'
        })
    }
    .padding(12)
    .backgroundColor('#F7F8FA')
  }
}

@Component
struct SettingsPanel {
  build() {
    Column({ space: 12 }) {
      Text('设置页')
        .fontSize(20)
        .fontWeight(FontWeight.Bold)

      TextInput({ placeholder: '配置 URL', text: appState.settings.configUrl })
        .onChange((value: string) => {
          appState.settings.configUrl = value
        })

      TextInput({ placeholder: '后端 API Base URL', text: appState.settings.apiBaseUrl })
        .onChange((value: string) => {
          appState.settings.apiBaseUrl = value
        })

      Row({ space: 8 }) {
        Button(appState.settings.useBackendAdapter ? '后端模式：开' : '后端模式：关')
          .layoutWeight(1)
          .onClick(() => {
            appState.settings.useBackendAdapter = !appState.settings.useBackendAdapter
          })
        Button('保存并返回')
          .layoutWeight(1)
          .onClick(() => {
            appState.saveSettings()
            appState.openHome()
            appState.loadConfig()
          })
      }
    }
    .padding(12)
    .backgroundColor('#F7F8FA')
  }
}
