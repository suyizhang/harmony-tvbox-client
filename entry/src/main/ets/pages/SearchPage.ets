import { appState } from '../common/AppState'
import { SearchService, SearchFilter, SearchResult, SearchSuggestion } from '../service/SearchService'
import { BackendApiService } from '../service/BackendApiService'
import { UnifiedLoading, ErrorState, EmptyState } from '../components/LoadingStates'
import { SearchFilterPanel } from '../components/SearchFilterPanel'
import { ForEach, List, ListItem } from '@kit.ArkUI'
import { ButtonType } from '@kit.ArkUI'
import { Color } from '@kit.ArkUI'
import { FontWeight } from '@kit.ArkUI'
import { Slider } from '@kit.ArkUI'
import { FlexAlign } from '@kit.ArkUI'
import { router } from '@kit.ArkUI'
import { preferences } from '@kit.ArkData'

// 使用别名避免命名冲突
import * as SearchComponents from './SearchPage'

@Component
struct SearchSuggestionItem {
  private suggestion: SearchSuggestion
  private onClick: () => void

  build() {
    Row() {
      Text(this.suggestion.text)
        .fontSize(14)
        .layoutWeight(1)
      Text(this.getSuggestionTypeText(this.suggestion.type))
        .fontSize(10)
        .fontColor('#999999')
    }
    .padding(8)
    .width('100%')
    .backgroundColor('#f5f5f5')
    .borderRadius(4)
    .onClick(() => this.onClick())
  }

  private getSuggestionTypeText(type: string): string {
    switch (type) {
      case 'autocomplete': return '自动补全'
      case 'popular': return '热门搜索'
      case 'history': return '搜索历史'
      case 'keyword': return '关键词'
      default: return ''
    }
  }

  private getFilterDescription(): string {
    const parts: string[] = []
    if (this.searchFilter.type) {
      parts.push(`类型: ${this.searchFilter.type.join(', ')}`)
    }
    if (this.searchFilter.category) {
      parts.push(`分类: ${this.searchFilter.category.join(', ')}`)
    }
    if (this.searchFilter.year) {
      parts.push(`年份: ${this.searchFilter.year.min || '不限'}-${this.searchFilter.year.max || '不限'}`)
    }
    return parts.join(' | ')
  }
}

@Component
export struct SearchPage {
  @State keyword: string = ''
  @State searchResults: SearchResult[] = []
  @State searchSuggestions: SearchSuggestion[] = []
  @State searching: boolean = false
  @State error: string = ''
  @State showSuggestions: boolean = false
  @State searchFilter: SearchFilter = {}
  @State hotKeywords: string[] = []
  @State showFilterPanel: boolean = false

  build() {
    Column({ space: 12 }) {
      // 返回按钮
      Button('← 返回', { type: ButtonType.Normal })
        .onClick(() => appState.openHome())
        .margin({ bottom: 16 })

      Text('搜索页')
        .fontSize(22)
        .fontWeight(FontWeight.Bold)

      // 搜索框和过滤器
      Column({ space: 8 }) {
        Row({ space: 8 }) {
          TextInput({ placeholder: '搜索影片、剧集', text: this.keyword })
            .layoutWeight(1)
            .onChange(async (value: string) => {
              this.keyword = value
              // 延迟加载建议
              if (value.trim()) {
                setTimeout(() => this.loadSuggestions(), 300)
              } else {
                this.showSuggestions = false
              }
            })
          
          Button(appState.settings.useMockBackend ? '🎭 搜索' : '搜索', { type: ButtonType.Normal })
            .onClick(() => this.performSearch())
            .disabled(this.searching)
          
          Button('🔍', { type: ButtonType.Normal })
            .onClick(() => this.showFilterPanel = !this.showFilterPanel)
        }
        
        // 搜索建议
        if (this.showSuggestions && this.searchSuggestions.length > 0) {
          Column({ space: 4 }) {
            ForEach(this.searchSuggestions, (suggestion: SearchSuggestion) => {
              Row() {
                Text(suggestion.text)
                  .fontSize(14)
                  .layoutWeight(1)
                Text(this.getSuggestionTypeText(suggestion.type))
                  .fontSize(10)
                  .fontColor('#999999')
              }
              .padding(8)
              .width('100%')
              .backgroundColor('#f5f5f5')
              .borderRadius(4)
              .onClick(async () => {
                this.keyword = suggestion.text
                this.showSuggestions = false
                await this.performSearch()
              })
            })
          }
          .width('100%')
        }
        
        // 过滤器面板
        SearchFilterPanel({
          filter: $searchFilter,
          showPanel: $showFilterPanel,
          onFilterChange: () => {
            if (this.keyword.trim()) {
              this.performSearch()
            }
          }
        })
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
          ForEach(this.searchResults, (item: SearchResult) => {
            Column() {
              Row() {
                Text(item.title)
                  .fontSize(16)
                  .fontWeight(FontWeight.Medium)
                  .layoutWeight(1)
                
                // 评分徽章
                if (item.rating) {
                  Text(`${item.rating}分`)
                    .fontSize(12)
                    .fontColor('#FF6B35')
                    .backgroundColor('#FFF2E8')
                    .padding({ left: 6, right: 6, top: 2, bottom: 2 })
                    .borderRadius(4)
                }
              }
              
              if (item.subtitle) {
                Text(item.subtitle)
                  .fontSize(12)
                  .fontColor(Color.Gray)
                  .maxLines(1)
                  .textOverflow({ overflow: TextOverflow.Ellipsis })
              }
              
              if (item.description) {
                Text(item.description)
                  .fontSize(11)
                  .fontColor(Color.Gray)
                  .maxLines(2)
                  .textOverflow({ overflow: TextOverflow.Ellipsis })
                  .margin({ top: 2 })
              }
              
              // 元信息行
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
                if (item.duration) {
                  Text(`⏱️ ${Math.floor(item.duration/60)}分钟`)
                    .fontSize(10)
                    .fontColor(Color.Gray)
                    .margin({ left: 8 })
                }
                if (item.category) {
                  Text(`📂 ${item.category}`)
                    .fontSize(10)
                    .fontColor(Color.Gray)
                    .margin({ left: 8 })
                }
              }
              .margin({ top: 4 })
              
              // 标签
              if (item.tags.length > 0) {
                Row({ space: 4 }) {
                  ForEach(item.tags.slice(0, 3), (tag: string) => {
                    Text(`#${tag}`)
                      .fontSize(9)
                      .fontColor('#007AFF')
                      .backgroundColor('#F0F8FF')
                      .padding({ left: 4, right: 4, top: 1, bottom: 1 })
                      .borderRadius(2)
                  })
                }
                .margin({ top: 4 })
              }
            }
            .padding(12)
            .width('100%')
            .backgroundColor('#f9f9f9')
            .borderRadius(8)
            .margin({ bottom: 8 })
            .onClick(() => {
              // 点击搜索结果，打开详情页
              appState.selectedSource = {
                id: item.id,
                title: item.title,
                subtitle: item.subtitle || '',
                supportsSearch: true,
                raw: { key: item.id, name: item.title, ext: '' }
              }
              appState.openDetail(appState.selectedSource)
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
        // 默认页面 - 显示热门搜索和过滤器
        Column({ space: 16 }) {
          // 热门搜索
          if (this.hotKeywords.length > 0) {
            Column({ space: 8 }) {
              Text('🔥 热门搜索')
                .fontSize(16)
                .fontWeight(FontWeight.Medium)
              
              Row({ space: 8 }) {
                ForEach(this.hotKeywords.slice(0, 6), (keyword: string) => {
                  Button(keyword, { type: ButtonType.Normal })
                    .fontSize(12)
                    .padding({ left: 12, right: 12, top: 6, bottom: 6 })
                    .backgroundColor('#f0f0f0')
                    .onClick(async () => {
                      this.keyword = keyword
                      await this.performSearch()
                    })
                })
              }
            }
          }
          
          // 当前过滤器显示
          if (Object.keys(this.searchFilter).length > 0) {
            Row() {
              Text('当前过滤: ' + this.getFilterDescription())
                .fontSize(12)
                .fontColor(Color.Gray)
              Button('清除', { type: ButtonType.Normal })
                .fontSize(10)
                .margin({ left: 8 })
                .onClick(() => this.clearFilters())
            }
            .padding(8)
            .backgroundColor('#f5f5f5')
            .borderRadius(4)
          }
          
          // 搜索提示
          EmptyState({
            icon: '💡',
            title: '搜索提示',
            description: '支持关键词搜索、类型过滤、时间筛选等高级功能',
            showAction: false
          })
        }
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
    this.showSuggestions = false
    
    try {
      // 保存搜索历史
      await SearchService.saveSearchHistory(this.keyword)
      
      // 使用新的搜索服务
      const { results, suggestions } = await SearchService.smartSearch(
        this.keyword,
        this.searchFilter,
        20
      )
      
      this.searchResults = results
      this.searchSuggestions = suggestions
      
    } catch (err) {
      this.error = `搜索失败: ${err}`
      console.error('SearchPage performSearch error:', err)
      this.searchResults = []
    } finally {
      this.searching = false
    }
  }

  async loadSuggestions() {
    if (this.keyword.trim().length === 0) {
      this.searchSuggestions = []
      this.showSuggestions = false
      return
    }
    
    try {
      const { suggestions } = await SearchService.smartSearch(this.keyword, {}, 5)
      this.searchSuggestions = suggestions
      this.showSuggestions = this.searchSuggestions.length > 0
    } catch (error) {
      console.error('Failed to load suggestions:', error)
      this.searchSuggestions = []
      this.showSuggestions = false
    }
  }

  async applyFilter(filter: SearchFilter) {
    this.searchFilter = { ...this.searchFilter, ...filter }
    if (this.keyword.trim()) {
      await this.performSearch()
    }
  }

  clearFilters() {
    this.searchFilter = {}
    if (this.keyword.trim()) {
      this.performSearch()
    }
  }
}
