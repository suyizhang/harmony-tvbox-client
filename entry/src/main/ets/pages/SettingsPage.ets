import { AppSettings } from '../model/Models'
import { ConfigService } from '../service/ConfigService'

@Component
export struct SettingsPage {
  @State settings: AppSettings = new ConfigService().createDefaultSettings()

  build() {
    Column({ space: 12 }) {
      Text('设置页')
        .fontSize(22)
        .fontWeight(FontWeight.Bold)

      TextInput({ placeholder: '配置 URL', text: this.settings.configUrl })
      TextInput({ placeholder: '后端 API Base URL', text: this.settings.apiBaseUrl })
      Text(`后端模式：${this.settings.useBackendAdapter ? '开启' : '关闭'}`)
      Text('这里后续接入 Preferences / AppStorage 保存配置。')
        .fontSize(12)
    }
    .padding(16)
    .width('100%')
    .height('100%')
  }
}
