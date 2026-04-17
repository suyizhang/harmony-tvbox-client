import { appState } from '../common/AppState'
import { FavoriteService, FavoriteItem, FavoriteCategory } from '../service/FavoriteService'
import { AppStyles, Card, PrimaryButton, StatusBadge } from '../components/Styles'
import { Column, Row, Text, Button, List, ListItem, Tabs, TabContent } from '@ohos.arkui.ArkUI'

@Component
export struct FavoritesPage {
  @State categories: FavoriteCategory[] = Object.values(FavoriteCategory)
  @State selectedCategory: FavoriteCategory = FavoriteCategory.MOVIE
  @State favorites: FavoriteItem[] = []
  @State loading: boolean = true

  async aboutToAppear() {
    await this.loadFavorites()
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
        Column() {
          LoadingProgress.create()
            .width(30)
            .height(30)
          Text('加载收藏中...')
            .fontSize(AppStyles.FontSizes.Caption1)
            .fontColor(AppStyles.Colors.Gray)
        }
        .alignItems(HorizontalAlign.Center)
        .width('100%')
        .margin({ top: 40 })
      } else if (appState.favorites.length === 0) {
        // 空状态
        Card() {
          Column({ space: AppStyles.Spacing.M }) {
            Text('💔')
              .fontSize(48)
            Text('暂无收藏')
              .fontSize(AppStyles.FontSizes.Headline)
              .fontColor(AppStyles.Colors.Gray)
            Text('在详情页点击❤️按钮收藏喜欢的内容')
              .fontSize(AppStyles.FontSizes.Caption1)
              .fontColor(AppStyles.Colors.Gray)
          }
          .alignItems(HorizontalAlign.Center)
        }
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

      // 底部操作按钮
      if (appState.favorites.length > 0) {
        Row({ space: AppStyles.Spacing.S }) {
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
    }
    .padding(AppStyles.Spacing.M)
    .width('100%')
    .height('100%')
    .backgroundColor(AppStyles.Colors.LightGray)
  }
}