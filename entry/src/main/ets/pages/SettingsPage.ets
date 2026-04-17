import { AppSettings } from '../model/Models'
import { ConfigService } from '../service/ConfigService'
import { UserService } from '../service/UserService'
import { appState } from '../common/AppState'
import { ThemeService, ThemeMode } from '../service/ThemeService'

@Component
export struct SettingsPage {
  @Link settings: AppSettings
  @State mockBackendEnabled: boolean = appState.settings.useMockBackend

  build() {
    Column({ space: 12 }) {
      Text('设置页')
        .fontSize(22)
        .fontWeight(FontWeight.Bold)

      // 配置 URL
      TextInput({ placeholder: 'TVBox 配置 URL', text: this.settings.configUrl })
        .onChange((value: string) => {
          this.settings.configUrl = value
        })

      // 后端 API URL
      TextInput({ placeholder: '后端 API Base URL', text: this.settings.apiBaseUrl })
        .onChange((value: string) => {
          this.settings.apiBaseUrl = value
        })

      // 本地配置模式
      Row() {
        Text('本地配置模式')
        Toggle({ type: ToggleType.Switch, isOn: !this.settings.useBackendAdapter && !this.settings.useMockBackend })
          .onChange((isOn: boolean) => {
            if (isOn) {
              this.settings.useBackendAdapter = false
              this.settings.useMockBackend = false
            }
          })
      }

      // 后端适配模式
      Row() {
        Text('后端适配模式')
        Toggle({ type: ToggleType.Switch, isOn: this.settings.useBackendAdapter })
          .onChange((isOn: boolean) => {
            if (isOn) {
              this.settings.useBackendAdapter = true
              this.settings.useMockBackend = false
            }
          })
      }

      // Mock 后端模式
      Row() {
        Text('Mock 后端模式')
        Toggle({ type: ToggleType.Switch, isOn: this.settings.useMockBackend })
          .onChange((isOn: boolean) => {
            if (isOn) {
              this.settings.useMockBackend = true
              this.settings.useBackendAdapter = false
            }
          })
      }

      Button('保存设置', { type: ButtonType.Normal, stateEffect: true })
        .onClick(() => {
          appState.settings = this.settings
          appState.saveSettings()
          appState.loadConfig()
        })

      Text(`当前状态: ${appState.status}`)
        .fontSize(12)
        .fontColor(Color.Gray)
      
      Text(`数据源数量: ${appState.sources.length}`)
        .fontSize(12)
        .fontColor(Color.Gray)
      
      // 主题设置
      Card() {
        Column({ space: 12 }) {
          Text('🎨 主题设置')
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
          
          // 当前主题显示
          Row() {
            Text('当前主题:')
              .fontSize(14)
            Text(ThemeService.getThemeName(appState.themeMode))
              .fontSize(14)
              .fontColor(Color.Blue)
            Button(ThemeService.getThemeIcon(appState.themeMode))
              .width(32)
              .height(32)
              .backgroundColor('transparent')
              .onClick(async () => {
                await appState.toggleTheme()
              })
          }
          
          // 主题说明
          Text('点击主题图标切换：浅色☀️ → 深色🌙 → 自动🔄')
            .fontSize(12)
            .fontColor(Color.Gray)
        }
        .padding(12)
        .width('100%')
      }
      
      // 用户账户设置
      Card() {
        Column({ space: 12 }) {
          Text(appState.isLoggedIn ? `👤 用户: ${appState.currentUser?.username || '未知'}` : '👤 用户账户')
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
          
          if (appState.isLoggedIn) {
            // 已登录状态
            Text(`邮箱: ${appState.currentUser?.email || '未设置'}`)
              .fontSize(14)
              .fontColor(Color.Gray)
            
            Text(`注册时间: ${new Date(appState.currentUser?.createdAt || 0).toLocaleDateString()}`)
              .fontSize(12)
              .fontColor(Color.Gray)
            
            Text(`最后登录: ${new Date(appState.currentUser?.lastLoginAt || 0).toLocaleDateString()}`)
              .fontSize(12)
              .fontColor(Color.Gray)
            
            Row({ space: 8 }) {
              Button('🔄 同步收藏', { type: ButtonType.Normal })
                .onClick(async () => {
                  await appState.syncFavorites()
                })
              
              Button('🚪 退出登录', { type: ButtonType.Normal })
                .backgroundColor(Color.Red)
                .onClick(async () => {
                  await appState.logout()
                })
            }
          } else {
            // 未登录状态
            Text('登录以使用云同步功能')
              .fontSize(14)
              .fontColor(Color.Gray)
            
            Button('🔑 登录账户', { type: ButtonType.Normal })
              .onClick(() => appState.openLogin())
            
            Text('演示账号: demo / 123456')
              .fontSize(12)
              .fontColor(Color.Gray)
              .margin({ top: 8 })
          }
        }
        .padding(12)
        .width('100%')
      }
      
      // 数据分析设置
      Card() {
        Column({ space: 12 }) {
          Text('📊 数据分析')
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
          
          Button('📈 查看分析', { type: ButtonType.Normal })
            .onClick(() => appState.openAnalytics())
          
          Button('📋 导出报告', { type: ButtonType.Normal })
            .onClick(async () => {
              // 触发分析页面导出功能
              appState.status = '请在数据分析页面导出详细报告'
            })
        }
        .padding(12)
        .width('100%')
      }
    }
    .padding(16)
    .width('100%')
    .height('100%')
  }
}
