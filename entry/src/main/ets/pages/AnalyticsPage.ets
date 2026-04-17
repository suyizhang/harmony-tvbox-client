import { AnalyticsService } from '../service/AnalyticsService';
import { AppStyles, Card, PrimaryButton, StatusBadge } from '../components/Styles';
import { UnifiedLoading, ErrorState, EmptyState } from '../components/LoadingStates';
import { appState } from '../common/AppState';
import { Column, Row, Text, Button, List, ListItem, Chart } from '@ohos.arkui.ArkUI';

@Component
export struct AnalyticsPage {
  @State stats: any = null;
  @State trends: any[] = [];
  @State recommendations: any[] = [];
  @State loading: boolean = true;
  @State error: string = '';
  @State selectedTab: 'overview' | 'trends' | 'recommendations' = 'overview';

  async aboutToAppear() {
    await this.loadAnalytics();
  }

  async loadAnalytics() {
    this.loading = true;
    this.error = '';
    
    try {
      const [stats, trends, recommendations] = await Promise.all([
        AnalyticsService.getUsageStats(),
        AnalyticsService.getWatchTrends(7),
        AnalyticsService.getRecommendations()
      ]);
      
      this.stats = stats;
      this.trends = trends;
      this.recommendations = recommendations;
    } catch (err) {
      this.error = '加载分析数据失败';
      console.error('Load analytics failed:', err);
    } finally {
      this.loading = false;
    }
  }

  build() {
    Column({ space: AppStyles.Spacing.M }) {
      // 返回按钮
      Button('← 返回', { type: ButtonType.Normal })
        .onClick(() => appState.openHome())
        .margin({ bottom: 16 })

      // 标题
      Text('📊 数据分析')
        .fontSize(AppStyles.FontSizes.Title1)
        .fontWeight(FontWeight.Bold)

      // 标签页切换
      Row({ space: AppStyles.Spacing.S }) {
        Button('概览', { type: this.selectedTab === 'overview' ? ButtonType.Capsule : ButtonType.Normal })
          .onClick(() => this.selectedTab = 'overview')
        Button('趋势', { type: this.selectedTab === 'trends' ? ButtonType.Capsule : ButtonType.Normal })
          .onClick(() => this.selectedTab = 'trends')
        Button('推荐', { type: this.selectedTab === 'recommendations' ? ButtonType.Capsule : ButtonType.Normal })
          .onClick(() => this.selectedTab = 'recommendations')
      }
      .margin({ bottom: 16 })

      // 内容区域
      if (this.loading) {
        UnifiedLoading({
          message: '正在分析数据...',
          showProgress: true,
          size: 'medium'
        })
      } else if (this.error) {
        ErrorState({
          title: '加载失败',
          message: this.error,
          showRetry: true,
          onRetry: () => this.loadAnalytics()
        })
      } else {
        // 根据选择的标签页显示内容
        if (this.selectedTab === 'overview') {
          this.buildOverviewTab()
        } else if (this.selectedTab === 'trends') {
          this.buildTrendsTab()
        } else if (this.selectedTab === 'recommendations') {
          this.buildRecommendationsTab()
        }
      }
    }
    .padding(AppStyles.Spacing.M)
    .width('100%')
    .height('100%')
    .backgroundColor(AppStyles.Colors.LightGray)
  }

  @Builder
  buildOverviewTab() {
    Column({ space: AppStyles.Spacing.M }) {
      // 总体统计卡片
      if (this.stats?.overview) {
        Card() {
          Column({ space: AppStyles.Spacing.S }) {
            Text('📈 总体概况')
              .fontSize(AppStyles.FontSizes.Title3)
              .fontWeight(FontWeight.Bold)
            
            Row({ space: AppStyles.Spacing.M }) {
              Column() {
                Text(this.stats.overview.totalFavorites.toString())
                  .fontSize(24)
                  .fontColor(AppStyles.Colors.Primary)
                Text('收藏')
                  .fontSize(AppStyles.FontSizes.Caption1)
                  .fontColor(AppStyles.Colors.Gray)
              }
              
              Column() {
                Text(this.stats.overview.totalHistory.toString())
                  .fontSize(24)
                  .fontColor(AppStyles.Colors.Green)
                Text('播放')
                  .fontSize(AppStyles.FontSizes.Caption1)
                  .fontColor(AppStyles.Colors.Gray)
              }
              
              Column() {
                Text(this.stats.overview.activeSources.toString())
                  .fontSize(24)
                  .fontColor(AppStyles.Colors.Orange)
                Text('可用源')
                  .fontSize(AppStyles.FontSizes.Caption1)
                  .fontColor(AppStyles.Colors.Gray)
              }
            }
          }
        }
      }

      // 分类分布
      if (this.stats?.favoritesByCategory) {
        Card() {
          Column({ space: AppStyles.Spacing.S }) {
            Text('🏷️ 收藏分类')
              .fontSize(AppStyles.FontSizes.Title3)
              .fontWeight(FontWeight.Bold)
            
            ForEach(Object.entries(this.stats.favoritesByCategory), ([category, count]) => {
              Row() {
                Text(this.getCategoryIcon(category))
                  .fontSize(16)
                Text(this.getCategoryName(category))
                  .fontSize(AppStyles.FontSizes.Body)
                Text(`${count} 个`)
                  .fontSize(AppStyles.FontSizes.Caption1)
                  .fontColor(AppStyles.Colors.Gray)
                  .margin({ left: 8 })
                Button('查看', { type: ButtonType.Normal })
                  .height(24)
                  .fontSize(12)
                  .onClick(() => appState.openFavorites())
              }
              .width('100%')
              .margin({ bottom: 4 })
            })
          }
        }
      }

      // 导出报告按钮
      PrimaryButton({
        text: '📋 导出分析报告',
        onClick: () => this.exportReport()
      })
    }
  }

  @Builder
  buildTrendsTab() {
    Column({ space: AppStyles.Spacing.M }) {
      Text('📅 最近7天观看趋势')
        .fontSize(AppStyles.FontSizes.Title3)
        .fontWeight(FontWeight.Bold)
      
      if (this.trends.length > 0) {
        // 简化的趋势图表（实际项目中会用Chart组件）
        ForEach(this.trends, (trend) => {
          Card() {
            Row() {
              Column({ space: 2 }) {
                Text(trend.date)
                  .fontSize(AppStyles.FontSizes.Caption1)
                Text(`${trend.count} 次播放`)
                  .fontSize(AppStyles.FontSizes.Body)
                  .fontColor(AppStyles.Colors.Primary)
                Text(`总时长: ${Math.round(trend.totalDuration/60)}分钟`)
                  .fontSize(AppStyles.FontSizes.Caption2)
                  .fontColor(AppStyles.Colors.Gray)
              }
              .layoutWeight(1)
              
              Text(this.getTrendIcon(trend.count))
                .fontSize(24)
            }
          }
        })
      } else {
        EmptyState({
          icon: '📈',
          title: '暂无趋势数据',
          description: '开始观看内容后，这里将显示您的观看趋势',
          showAction: false
        })
      }
    }
  }

  @Builder
  buildRecommendationsTab() {
    Column({ space: AppStyles.Spacing.M }) {
      Text('💡 为您推荐')
        .fontSize(AppStyles.FontSizes.Title3)
        .fontWeight(FontWeight.Bold)
      
      if (this.recommendations.length > 0) {
        List() {
          ForEach(this.recommendations, (item) => {
            ListItem() {
              Card() {
                Row() {
                  Text(this.getCategoryIcon(item.category))
                    .fontSize(32)
                    .margin({ right: 12 })
                  
                  Column({ space: 4 }) {
                    Text(item.title)
                      .fontSize(AppStyles.FontSizes.Body)
                      .fontWeight(FontWeight.Medium)
                    Text(item.reason)
                      .fontSize(AppStyles.FontSizes.Caption1)
                      .fontColor(AppStyles.Colors.Gray)
                  }
                  .layoutWeight(1)
                  
                  Button('➕ 收藏', { type: ButtonType.Normal })
                    .height(32)
                    .fontSize(12)
                }
              }
            }
          }, (item) => item.id)
        }
      } else {
        EmptyState({
          icon: '💡',
          title: '暂无推荐内容',
          description: '继续使用和收藏内容，系统将为您提供更精准的推荐',
          showAction: false
        })
      }
    }
  }

  // 辅助方法
  private getCategoryIcon(category: string): string {
    switch (category) {
      case 'movie': return '🎬';
      case 'tv_show': return '📺';
      case 'anime': return '🎌';
      case 'variety': return '🎪';
      case 'documentary': return '📽️';
      default: return '⭐';
    }
  }

  private getCategoryName(category: string): string {
    switch (category) {
      case 'movie': return '电影';
      case 'tv_show': return '电视剧';
      case 'anime': return '动漫';
      case 'variety': return '综艺';
      case 'documentary': return '纪录片';
      default: return '其他';
    }
  }

  private getTrendIcon(count: number): string {
    if (count === 0) return '📉';
    if (count <= 2) return '📊';
    if (count <= 5) return '📈';
    return '🚀';
  }

  private async exportReport() {
    try {
      const report = await AnalyticsService.exportAnalyticsReport();
      // 在实际环境中，这里会保存到文件或分享
      console.log('Analytics report:', report);
      appState.status = '分析报告已生成（查看控制台输出）';
    } catch (error) {
      appState.setError('导出报告失败');
    }
  }
}