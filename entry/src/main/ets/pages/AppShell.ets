import { appState } from '../common/AppState'
import { SourceUiModel } from '../model/Models'

@Component
export struct AppShell {
  build() {
    Column({ space: 12 }) {
      Text('Harmony TVBox Client')
        .fontSize(24)
        .fontWeight(FontWeight.Bold)

      Text(appState.status)
        .fontSize(16)
        .fontWeight(FontWeight.Medium)

      Text(appState.overview)
        .fontSize(12)

      if (appState.currentPage === 'home') {
        Column({ space: 12 }) {
          Row({ space: 8 }) {
            Button('重新加载')
              .layoutWeight(1)
              .onClick(() => {
                appState.loadConfig()
              })
            Button('搜索')
              .layoutWeight(1)
              .onClick(() => {
                appState.openSearch()
              })
            Button('设置')
              .layoutWeight(1)
              .onClick(() => {
                appState.openSettings()
              })
          }

          List() {
            ForEach(appState.filteredSources, (item: SourceUiModel) => {
              ListItem() {
                Column({ space: 4 }) {
                  Text(item.title)
                    .fontSize(18)
                    .fontWeight(FontWeight.Medium)
                  Text(item.subtitle)
                    .fontSize(12)
                  Text(item.supportsSearch ? '可搜索' : '仅展示')
                    .fontSize(12)
                    .fontColor(item.supportsSearch ? Color.Green : Color.Gray)
                }
                .alignItems(HorizontalAlign.Start)
                .padding(12)
              }
              .onClick(() => {
                appState.openDetail(item)
              })
            })
          }
          .divider({ strokeWidth: 1, color: '#eeeeee' })
          .layoutWeight(1)
        }
      }

      if (appState.currentPage === 'search') {
        SearchPanel()
      }

      if (appState.currentPage === 'detail') {
        DetailPanel()
      }

      if (appState.currentPage === 'player') {
        PlayerPanel()
      }

      if (appState.currentPage === 'settings') {
        SettingsPanel()
      }
    }
    .padding(16)
    .width('100%')
    .height('100%')
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

      Text('下一阶段接 HarmonyOS 播放组件；当前先完成页面串联。')
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
