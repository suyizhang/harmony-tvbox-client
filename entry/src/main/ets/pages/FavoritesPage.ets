import { appState } from '../common/AppState'
import { FavoriteService, FavoriteItem, FavoriteCategory } from '../service/FavoriteService'
import { FavoriteImportExportService } from '../service/FavoriteImportExportService'
import { AppStyles, Card, PrimaryButton, StatusBadge } from '../components/Styles'
import { UnifiedLoading, ErrorState, EmptyState } from '../components/LoadingStates'
import { Column, Row, Text, Button, List, ListItem, Dialog, Input, Checkbox, Select } from '@ohos.arkui.ArkUI'

@Component
export struct FavoritesPage {
  @State categories: FavoriteCategory[] = Object.values(FavoriteCategory)
  @State selectedCategory: FavoriteCategory = FavoriteCategory.MOVIE
  @State favorites: FavoriteItem[] = []
  @State loading: boolean = true
  @State showImportDialog: boolean = false
  @State importData: string = ''
  @State importMode: 'merge' | 'replace' = 'merge'
  @State exportResult: string = ''
  @State operationStatus: string = ''

  async aboutToAppear() {
    await this.loadFavorites()
  }

  // 批量选择切换
  toggleSelect(id: string) {
    if (this.selectedIds.has(id)) {
      this.selectedIds.delete(id)
    } else {
      this.selectedIds.add(id)
    }
  }

  // 全选/取消全选
  toggleSelectAll() {
    if (this.selectedIds.size === appState.favorites.length) {
      this.selectedIds.clear()
    } else {
      appState.favorites.forEach(item => this.selectedIds.add(item.id))
    }
  }

  // 批量删除
  async batchDelete() {
    if (this.selectedIds.size === 0) return
    
    try {
      const ids = Array.from(this.selectedIds)
      const result = await FavoriteService.batchDeleteFavorites(ids)
      this.operationStatus = `✅ 批量删除完成：成功 ${result.success} 个，失败 ${result.failed} 个`
      this.selectedIds.clear()
      await this.loadFavorites()
    } catch (error) {
      this.operationStatus = `❌ 批量删除失败：${error}`
    }
    
    setTimeout(() => this.operationStatus = '', 5000)
  }

  // 批量更新分类
  async batchUpdateCategory() {
    if (this.selectedIds.size === 0) return
    
    try {
      const ids = Array.from(this.selectedIds)
      const result = await FavoriteService.batchUpdateCategory(ids, this.batchCategory)
      this.operationStatus = `✅ 批量更新分类完成：成功 ${result.success} 个，失败 ${result.failed} 个`
      this.selectedIds.clear()
      await this.loadFavorites()
    } catch (error) {
      this.operationStatus = `❌ 批量更新分类失败：${error}`
    }
    
    setTimeout(() => this.operationStatus = '', 5000)
  }

  // 批量添加标签
  async batchAddTags() {
    if (this.selectedIds.size === 0 || !this.batchTags.trim()) return
    
    try {
      const ids = Array.from(this.selectedIds)
      const tags = this.batchTags.split(',').map(tag => tag.trim()).filter(tag => tag)
      const result = await FavoriteService.batchAddTags(ids, tags)
      this.operationStatus = `✅ 批量添加标签完成：成功 ${result.success} 个，失败 ${result.failed} 个`
      this.selectedIds.clear()
      this.batchTags = ''
      await this.loadFavorites()
    } catch (error) {
      this.operationStatus = `❌ 批量添加标签失败：${error}`
    }
    
    setTimeout(() => this.operationStatus = '', 5000)
  }

  async loadFavorites() {
    this.loading = true
    try {
      this.favorites = await FavoriteService.getFavorites()
    } catch (error) {
      console.error('Failed to load favorites:', error)
    } finally {
      this.loading = false
    }
  }

  getCategoryIcon(category: FavoriteCategory): string {
    switch (category) {
      case FavoriteCategory.MOVIE: return '🎬'
      case FavoriteCategory.TV_SHOW: return '📺'
      case FavoriteCategory.ANIME: return '🎌'
      case FavoriteCategory.VARIETY: return '🎪'
      case FavoriteCategory.DOCUMENTARY: return '📽️'
      default: return '⭐'
    }
  }

  getCategoryName(category: FavoriteCategory): string {
    switch (category) {
      case FavoriteCategory.MOVIE: return '电影'
      case FavoriteCategory.TV_SHOW: return '电视剧'
      case FavoriteCategory.ANIME: return '动漫'
      case FavoriteCategory.VARIETY: return '综艺'
      case FavoriteCategory.DOCUMENTARY: return '纪录片'
      default: return '其他'
    }
  }

  // 导出收藏功能
  async exportFavorites() {
    try {
      const jsonData = await FavoriteImportExportService.exportFavorites(appState)
      if (jsonData) {
        this.operationStatus = `✅ 导出成功！共导出 ${appState.favorites.length} 个收藏项目`
        console.log('Export data:', jsonData)
        // 在实际环境中，这里会将数据保存到文件或复制到剪贴板
      } else {
        this.operationStatus = '❌ 导出失败'
      }
    } catch (error) {
      this.operationStatus = `❌ 导出出错: ${error}`
    }
    
    // 5秒后清除状态
    setTimeout(() => {
      this.operationStatus = ''
    }, 5000)
  }

  // 处理导入功能
  async handleImport() {
    if (!this.importData.trim()) {
      this.operationStatus = '❌ 请输入导入数据'
      return
    }

    try {
      const result = await FavoriteImportExportService.importFavoritesFromJson(
        this.importData,
        appState,
        this.importMode
      )
      
      if (result.success) {
        this.operationStatus = `✅ 导入成功！新增 ${result.imported} 个，跳过 ${result.skipped} 个`
        await this.loadFavorites()
        this.showImportDialog = false
        this.importData = ''
      } else {
        this.operationStatus = `❌ 导入失败: ${result.errors.join(', ')}`
      }
    } catch (error) {
      this.operationStatus = `❌ 导入出错: ${error}`
    }
    
    setTimeout(() => {
      this.operationStatus = ''
    }, 5000)
  }

  build() {
    Column({ space: AppStyles.Spacing.M }) {
      // 返回按钮
      Button('← 返回', { type: ButtonType.Normal })
        .onClick(() => appState.openHome())
        .margin({ bottom: 16 })

      // 标题
      Text('我的收藏')
        .fontSize(AppStyles.FontSizes.Title1)
        .fontWeight(FontWeight.Bold)

      // 统计信息
      if (Object.keys(appState.favoriteStats).length > 0) {
        Row() {
          ForEach(Object.entries(appState.favoriteStats), ([category, count]) => {
            Card() {
              Column({ space: 4 }) {
                Text(this.getCategoryIcon(category as FavoriteCategory))
                  .fontSize(20)
                Text(count.toString())
                  .fontSize(AppStyles.FontSizes.Caption1)
                  .fontColor(AppStyles.Colors.Primary)
                Text(this.getCategoryName(category as FavoriteCategory))
                  .fontSize(AppStyles.FontSizes.Caption2)
                  .fontColor(AppStyles.Colors.Gray)
              }
            }
            .padding(8)
          })
        }
      }

      // 收藏列表
      if (this.loading) {
        UnifiedLoading({
          message: '加载收藏中...',
          showProgress: true,
          size: 'medium'
        })
      } else if (appState.favorites.length === 0) {
        // 空状态
        EmptyState({
          icon: '💔',
          title: '暂无收藏',
          description: '在详情页点击❤️按钮收藏喜欢的内容',
          showAction: true,
          actionText: '返回首页',
          onAction: () => appState.openHome()
        })
      } else {
        // 收藏列表
        List() {
          ForEach(appState.favorites, (item: FavoriteItem) => {
            ListItem() {
              Card() {
                Row() {
                  // 图标
                  Column() {
                    Text(this.getCategoryIcon(item.category || FavoriteCategory.OTHER))
                      .fontSize(32)
                  }
                  .width(60)
                  .alignItems(HorizontalAlign.Center)
                  .justifyContent(FlexAlign.Center)

                  // 内容
                  Column({ space: 4 }) {
                    Text(item.title)
                      .fontSize(AppStyles.FontSizes.Body)
                      .fontWeight(FontWeight.Medium)
                    if (item.subtitle) {
                      Text(item.subtitle)
                        .fontSize(AppStyles.FontSizes.Caption1)
                        .fontColor(AppStyles.Colors.Gray)
                        .maxLines(1)
                        .textOverflow({ overflow: TextOverflow.Ellipsis })
                    }
                    Row() {
                      Text(this.getCategoryName(item.category || FavoriteCategory.OTHER))
                        .fontSize(AppStyles.FontSizes.Caption2)
                        .padding({ left: 6, right: 6, top: 2, bottom: 2 })
                        .backgroundColor(AppStyles.Colors.LightGray)
                        .borderRadius(AppStyles.Radius.Small)
                      Text(new Date(item.createdAt).toLocaleDateString())
                        .fontSize(AppStyles.FontSizes.Caption2)
                        .fontColor(AppStyles.Colors.Gray)
                    }
                  }
                  .layoutWeight(1)

                  // 操作按钮
                  Column() {
                    Button('❤️', { type: ButtonType.Normal })
                      .width(32)
                      .height(32)
                      .backgroundColor('transparent')
                      .fontSize(16)
                      .onClick(async () => {
                        await appState.toggleFavorite({
                          id: item.sourceId,
                          title: item.title,
                          subtitle: item.subtitle,
                          supportsSearch: false,
                          raw: { key: item.sourceId, name: item.title, ext: '' }
                        })
                        await appState.loadFavorites()
                      })
                  }
                }
              }
            }
            .onClick(() => {
              // 点击收藏项，跳转到详情
              appState.selectedSource = {
                id: item.sourceId,
                title: item.title,
                subtitle: item.subtitle,
                supportsSearch: false,
                raw: { key: item.sourceId, name: item.title, ext: '' }
              }
              appState.openDetail(appState.selectedSource)
            })
          }, (item: FavoriteItem) => item.id)
        }
        .divider({ strokeWidth: 1, color: AppStyles.Colors.LightGray })
      }

      // 操作按钮区域
      Column({ space: AppStyles.Spacing.S }) {
        // 批量操作模式切换
        if (appState.favorites.length > 0) {
          Row({ space: AppStyles.Spacing.S }) {
            Button(this.batchMode ? '退出批量模式' : '批量操作', { type: ButtonType.Normal })
              .layoutWeight(1)
              .backgroundColor(this.batchMode ? AppStyles.Colors.Orange : AppStyles.Colors.Primary)
              .onClick(() => {
                this.batchMode = !this.batchMode
                if (!this.batchMode) this.selectedIds.clear()
              })
            
            if (this.batchMode && this.selectedIds.size > 0) {
              Button(`已选 ${this.selectedIds.size} 项`, { type: ButtonType.Normal })
                .layoutWeight(1)
                .backgroundColor(AppStyles.Colors.Green)
            }
          }
        }
        
        // 批量操作工具栏
        if (this.batchMode && this.selectedIds.size > 0) {
          Card() {
            Column({ space: AppStyles.Spacing.S }) {
              Text(`已选择 ${this.selectedIds.size} 个项目`)
                .fontSize(AppStyles.FontSizes.Caption1)
                .fontColor(AppStyles.Colors.Primary)
              
              // 批量分类操作
              Row({ space: AppStyles.Spacing.S }) {
                Select([
                  { value: FavoriteCategory.MOVIE, label: '电影' },
                  { value: FavoriteCategory.TV_SHOW, label: '电视剧' },
                  { value: FavoriteCategory.ANIME, label: '动漫' },
                  { value: FavoriteCategory.VARIETY, label: '综艺' },
                  { value: FavoriteCategory.DOCUMENTARY, label: '纪录片' },
                  { value: FavoriteCategory.OTHER, label: '其他' }
                ])
                .value(this.batchCategory)
                .onSelect((value: FavoriteCategory) => {
                  this.batchCategory = value
                })
                .layoutWeight(1)
                
                Button('批量分类', { type: ButtonType.Normal })
                  .onClick(() => this.batchUpdateCategory())
              }
              
              // 批量标签操作
              Row({ space: AppStyles.Spacing.S }) {
                Input({ placeholder: '标签(逗号分隔)', text: this.batchTags })
                  .layoutWeight(1)
                  .onChange((value: string) => {
                    this.batchTags = value
                  })
                
                Button('批量加标签', { type: ButtonType.Normal })
                  .onClick(() => this.batchAddTags())
              }
              
              // 批量删除
              Button('🗑️ 批量删除', { type: ButtonType.Normal })
                .width('100%')
                .height(36)
                .backgroundColor(AppStyles.Colors.Red)
                .onClick(() => this.batchDelete())
            }
          }
        }
        
        // 常规操作按钮
        Row({ space: AppStyles.Spacing.S }) {
          Button('📤 导出收藏', { type: ButtonType.Normal })
            .layoutWeight(1)
            .onClick(() => this.exportFavorites())
          
          Button('📥 导入收藏', { type: ButtonType.Normal })
            .layoutWeight(1)
            .onClick(() => {
              this.showImportDialog = true
            })
        }
        
        // 清空收藏按钮
        if (appState.favorites.length > 0 && !this.batchMode) {
          PrimaryButton({
            text: '🗑️ 清空收藏',
            onClick: async () => {
              await FavoriteService.clearFavorites()
              await appState.loadFavorites()
            },
            disabled: false
          })
          .layoutWeight(1)
          .backgroundColor(AppStyles.Colors.Red)
        }
      }
      
      // 导入对话框
      if (this.showImportDialog) {
        Dialog.show({
          title: '导入收藏',
          message: '请输入JSON格式的收藏数据，或从文件导入',
          primaryButton: {
            value: '取消',
            action: () => {
              this.showImportDialog = false
              this.importData = ''
            }
          },
          secondaryButton: {
            value: '导入',
            action: () => {
              this.handleImport()
            }
          },
          autoCancel: true
        })
        
        Column({ space: AppStyles.Spacing.M }) {
          TextArea({ placeholder: '粘贴收藏JSON数据 here...', text: this.importData })
            .width('100%')
            .height(120)
            .onChange((value: string) => {
              this.importData = value
            })
          
          Row({ space: AppStyles.Spacing.S }) {
            Checkbox()
              .select(this.importMode === 'merge')
              .onChange((checked: boolean) => {
                this.importMode = checked ? 'merge' : 'replace'
              })
            Text(this.importMode === 'merge' ? '合并模式（保留现有）' : '替换模式（覆盖现有）')
              .fontSize(AppStyles.FontSizes.Caption1)
          }
        }
        .padding(16)
      }
      
      // 操作状态提示
      if (this.operationStatus) {
        Text(this.operationStatus)
          .fontSize(AppStyles.FontSizes.Caption1)
          .fontColor(this.operationStatus.includes('成功') ? AppStyles.Colors.Green : AppStyles.Colors.Red)
          .margin({ top: 8 })
      }
    }
    .padding(AppStyles.Spacing.M)
    .width('100%')
    .height('100%')
    .backgroundColor(AppStyles.Colors.LightGray)
  }
}