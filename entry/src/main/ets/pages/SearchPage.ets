import { appState } from '../common/AppState'
import { MockBackendService } from '../service/MockBackendService'
import { BackendApiService } from '../service/BackendApiService'
import { UnifiedLoading, ErrorState, EmptyState } from '../components/LoadingStates'

@Component
export struct SearchPage {
  @State keyword: string = ''
  @State searchResults: any[] = []
  @State searching: boolean = false
  @State error: string = ''

  build() {
    Column({ space: 12 }) {
      // 返回按钮
      Button('← 返回', { type: ButtonType.Normal })
        .onClick(() => appState.openHome())
        .margin({ bottom: 16 })

      Text('搜索页')
        .fontSize(22)
        .fontWeight(FontWeight.Bold)

      // 搜索框
      Row({ space: 8 }) {
        TextInput({ placeholder: '搜索影片、剧集', text: this.keyword })
          .layoutWeight(1)
          .onChange((value: string) => {
            this.keyword = value
          })
        
        Button(appState.settings.useMockBackend ? '🎭 Mock搜索' : '搜索', { type: ButtonType.Normal })
          .onClick(() => this.performSearch())
          .disabled(this.searching)
      }

      // 搜索结果
      if (this.searching) {
        UnifiedLoading({
          message: '搜索中...',
          showProgress: true,
          size: 'small'
        })
      } else if (this.error) {
        ErrorState({
          title: '搜索出错',
          message: this.error,
          showRetry: true,
          onRetry: () => this.performSearch()
        })
      } else if (this.searchResults.length > 0) {
        Column() {
          Text(`找到 ${this.searchResults.length} 个结果`)
            .fontSize(14)
            .fontColor(Color.Gray)
            .margin({ bottom: 8 })
          
          // 搜索结果列表
          ForEach(this.searchResults, (item: any) => {
            Column() {
              Text(item.title || item.name || '未知标题')
                .fontSize(16)
                .fontWeight(FontWeight.Medium)
              if (item.description) {
                Text(item.description)
                  .fontSize(12)
                  .fontColor(Color.Gray)
                  .maxLines(2)
                  .textOverflow({ overflow: TextOverflow.Ellipsis })
              }
              if (item.year || item.type) {
                Row() {
                  if (item.year) {
                    Text(`📅 ${item.year}`)
                      .fontSize(10)
                      .fontColor(Color.Gray)
                  }
                  if (item.type) {
                    Text(`🏷️ ${item.type}`)
                      .fontSize(10)
                      .fontColor(Color.Gray)
                      .margin({ left: 8 })
                  }
                }
              }
            }
            .padding(12)
            .width('100%')
            .backgroundColor('#f9f9f9')
            .borderRadius(6)
            .margin({ bottom: 6 })
            .onClick(() => {
              // 点击搜索结果，打开详情页
              if (item.id) {
                appState.selectedSource = {
                  id: item.id,
                  title: item.title || item.name || '未知标题',
                  subtitle: item.description || '',
                  supportsSearch: true,
                  raw: { key: item.id, name: item.title || item.name || 'unknown', ext: '' }
                }
                appState.openDetail(appState.selectedSource)
              }
            })
          })
        }
        .width('100%')
      } else if (this.keyword.trim()) {
        EmptyState({
          icon: '🔍',
          title: '暂无搜索结果',
          description: `没有找到包含 "${this.keyword}" 的内容`,
          showAction: true,
          actionText: '清空搜索',
          onAction: () => { this.keyword = '' }
        })
      } else {
        // 默认提示
        EmptyState({
          icon: '🎭',
          title: 'Mock 搜索模式',
          description: '输入关键词搜索模拟数据',
          showAction: false
        })
            
            // Mock搜索建议
            Column({ space: 4 }) {
              Text('💡 试试搜索：').fontSize(12).fontColor(Color.Blue)
              ForEach(['电影', '电视剧', '动漫', '综艺'], (keyword: string) => {
                Button(keyword, { type: ButtonType.Normal, stateEffect: true })
                  .fontSize(10)
                  .padding({ left: 8, right: 8, top: 4, bottom: 4 })
                  .backgroundColor('#e3f2fd')
                  .onClick(() => {
                    this.keyword = keyword
                    this.performSearch()
                  })
              })
            }
            .margin({ top: 12 })
          } else {
            
          }
        }
        .alignItems(HorizontalAlign.Center)
        .width('100%')
        .margin({ top: 20 })
      }
    }
    .padding(16)
    .width('100%')
    .height('100%')
    .alignItems(HorizontalAlign.Start)
  }

  async performSearch() {
    if (!this.keyword.trim()) return
    
    this.searching = true
    this.error = ''
    this.searchResults = []
    
    try {
      if (appState.settings.useMockBackend) {
        // Mock 搜索
        await new Promise(resolve => setTimeout(resolve, 800))
        this.searchResults = this.generateMockSearchResults(this.keyword)
      } else if (appState.settings.useBackendAdapter) {
        // 真实后端搜索
        const backend = new BackendApiService()
        const response = await fetch(`${appState.settings.apiBaseUrl}/search?q=${encodeURIComponent(this.keyword)}`)
        this.searchResults = await response.json()
      } else {
        // 本地模式，模拟搜索
        await new Promise(resolve => setTimeout(resolve, 300))
        this.searchResults = this.generateLocalSearchResults(this.keyword)
      }
    } catch (err) {
      this.error = `搜索失败: ${err}`
      console.error('SearchPage performSearch error:', err)
    } finally {
      this.searching = false
    }
  }

  generateMockSearchResults(keyword: string): any[] {
    const mockData = [
      { id: 'movie_001', title: '流浪地球2', description: '太阳即将毁灭，人类建造推进器寻找新家园', year: '2023', type: '科幻' },
      { id: 'movie_002', title: '满江红', description: '南宋绍兴年间，秦桧率兵与金国会谈的阴谋故事', year: '2023', type: '悬疑' },
      { id: 'tv_001', title: '狂飙', description: '京海市一线刑警安欣与黑恶势力的斗争', year: '2023', type: '犯罪' },
      { id: 'movie_003', title: '阿凡达：水之道', description: '杰克·萨利一家在潘多拉星球的冒险', year: '2022', type: '科幻' },
      { id: 'tv_002', title: '三体', description: '地球文明与三体文明的宇宙史诗', year: '2023', type: '科幻' }
    ]
    
    return mockData.filter(item => 
      item.title.toLowerCase().includes(keyword.toLowerCase()) ||
      item.description.toLowerCase().includes(keyword.toLowerCase())
    )
  }

  generateLocalSearchResults(keyword: string): any[] {
    // 简单的本地搜索模拟
    return []
  }
}
