import { SourceUiModel } from '../model/Models'
import { ConfigService } from '../service/ConfigService'

@Entry
@Component
struct HomePage {
  private service: ConfigService = new ConfigService()

  @State status: string = '准备加载配置'
  @State overview: string = ''
  @State sources: SourceUiModel[] = []

  async aboutToAppear() {
    await this.loadConfig()
  }

  async loadConfig() {
    this.status = '正在加载 TVBox 配置...'
    try {
      const config = await this.service.fetchConfig(ConfigService.DEFAULT_CONFIG_URL)
      this.sources = this.service.mapSources(config)
      this.status = `已加载 ${this.sources.length} 个源`
      this.overview = `spider: ${config.spider ?? '无'}\nwallpaper: ${config.wallpaper ?? '无'}\n当前版本只读取展示配置，不执行外部 spider/jar/csp 逻辑。`
    } catch (err) {
      this.status = '加载失败'
      this.overview = JSON.stringify(err)
    }
  }

  build() {
    Column({ space: 12 }) {
      Text('Harmony TVBox Client')
        .fontSize(24)
        .fontWeight(FontWeight.Bold)

      Text(this.status)
        .fontSize(16)
        .fontWeight(FontWeight.Medium)

      Text(this.overview)
        .fontSize(12)

      Button('重新加载配置')
        .onClick(() => {
          this.loadConfig()
        })

      List() {
        ForEach(this.sources, (item: SourceUiModel) => {
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
        })
      }
      .divider({ strokeWidth: 1, color: '#eeeeee' })
      .layoutWeight(1)
    }
    .padding(16)
    .width('100%')
    .height('100%')
  }
}
