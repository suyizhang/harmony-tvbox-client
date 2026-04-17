import { AnalyticsService } from '../service/AnalyticsService';
import { AppStyles, Card, PrimaryButton, StatusBadge } from '../components/Styles';
import { UnifiedLoading, ErrorState, EmptyState } from '../components/LoadingStates';
import { appState } from '../common/AppState';
import { Column, Row, Text, Button, List, ListItem, Stack } from '@ohos.arkui.ArkUI';
import { ButtonType } from '@ohos.arkui.ArkUI';
import { FontWeight } from '@ohos.arkui.ArkUI';
import { Picker } from '@ohos.arkui.ArkUI';
import { preferences } from '@kit.ArkData';

@Component
export struct AnalyticsPage {
  @State stats: any = null;
  @State trends: any[] = [];
  @State recommendations: any[] = [];
  @State loading: boolean = true;
  @State error: string = '';
  @State selectedTab: 'overview' | 'trends' | 'recommendations' = 'overview';
  @State selectedTimeRange: string = '7d';
  @State chartType: string = 'bar';
  @State showDetails: boolean = false;
  
  // 时间范围选项
  private timeRanges: Array<{label: string, value: string}> = [
    { label: '最近7天', value: '7d' },
    { label: '最近30天', value: '30d' },
    { label: '最近90天', value: '90d' },
    { label: '今年', value: 'year' }
  ];
  
  // 图表类型选项
  private chartTypes: Array<{label: string, value: string}> = [
    { label: '柱状图', value: 'bar' },
    { label: '折线图', value: 'line' },
    { label: '饼图', value: 'pie' }
  ];

  async aboutToAppear() {
    await this.loadAnalytics();
  }

  async loadAnalytics() {
    this.loading = true;
    this.error = '';
    
    try {
      this.stats = await AnalyticsService.getUsageStats();
      this.trends = await AnalyticsService.getWatchTrends(
        this.selectedTimeRange === '7d' ? 7 : 
        this.selectedTimeRange === '30d' ? 30 : 
        this.selectedTimeRange === '90d' ? 90 : 365
      );
      this.recommendations = await AnalyticsService.getRecommendations();
    } catch (err) {
      this.error = `加载分析数据失败: ${err}`;
      console.error('AnalyticsPage loadAnalytics error:', err);
    } finally {
      this.loading = false;
    }
  }

  async refreshData() {
    await this.loadAnalytics();
  }

  changeTimeRange(range: string) {
    this.selectedTimeRange = range;
    this.loadAnalytics();
  }

  changeChartType(type: string) {
    this.chartType = type;
  }

  formatDuration(minutes: number): string {
    const hours = Math.floor(minutes / 60);
    const mins = minutes % 60;
    return hours > 0 ? `${hours}小时${mins}分钟` : `${mins}分钟`;
  }

  getTopGenres(): Array<{name: string, count: number}> {
    if (!this.stats?.genreStats) return [];
    return Object.entries(this.stats.genreStats)
      .map(([name, count]) => ({ name, count: count as number }))
      .sort((a, b) => b.count - a.count)
      .slice(0, 5);
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

      // 控制面板
      Row({ space: 12 }) {
        // 时间范围选择
        Picker()
          .value(this.selectedTimeRange)
          .onChange((value: string) => this.changeTimeRange(value))
          .child(
            Text(this.timeRanges.find(t => t.value === this.selectedTimeRange)?.label || '7天')
              .fontSize(12)
          )
        
        // 图表类型选择
        Picker()
          .value(this.chartType)
          .onChange((value: string) => this.changeChartType(value))
          .child(
            Text(this.chartTypes.find(t => t.value === this.chartType)?.label || '柱状图')
              .fontSize(12)
          )
        
        // 刷新按钮
        Button('🔄', { type: ButtonType.Normal })
          .width(40)
          .height(32)
          .onClick(() => this.refreshData())
        
        // 详情切换
        Button(this.showDetails ? '简化' : '详细', { type: ButtonType.Normal })
          .width(48)
          .height(32)
          .onClick(() => this.showDetails = !this.showDetails)
      }
      .margin({ bottom: 16 })
      
      // 标签页切换
      Row({ space: 8 }) {
        ForEach([
          { key: 'overview', label: '概览' },
          { key: 'trends', label: '趋势' },
          { key: 'recommendations', label: '推荐' }
        ], (tab: any) => {
          Button(tab.label)
            .fontSize(12)
            .padding({ left: 16, right: 16, top: 8, bottom: 8 })
            .backgroundColor(this.selectedTab === tab.key ? '#007AFF' : '#f0f0f0')
            .fontColor(this.selectedTab === tab.key ? '#FFFFFF' : '#000000')
            .onClick(() => { this.selectedTab = tab.key; })
        })
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
              
              Column() {
                Text(Math.round(this.stats.overview.totalWatchTime / 60).toString())
                  .fontSize(24)
                  .fontColor(AppStyles.Colors.Purple)
                Text('小时')
                  .fontSize(AppStyles.FontSizes.Caption1)
                  .fontColor(AppStyles.Colors.Gray)
              }
            }
          }
        }
      }

      // 分类分布图表
      if (this.stats?.favoritesByCategory && this.showDetails) {
        Card() {
          Column({ space: AppStyles.Spacing.S }) {
            Text('🏷️ 收藏分类分布')
              .fontSize(AppStyles.FontSizes.Title3)
              .fontWeight(FontWeight.Bold)
            
            // 简化的柱状图表示
            Row({ space: 4 }) {
              ForEach(Object.entries(this.stats.favoritesByCategory), ([category, count]) => {
                Column() {
                  Column()
                    .width(20)
                    .height(60 * (count as number) / Math.max(...Object.values(this.stats.favoritesByCategory)))
                    .backgroundColor('#007AFF')
                    .borderRadius(2)
                  Text(this.getCategoryName(category))
                    .fontSize(10)
                    .fontColor(AppStyles.Colors.Gray)
                    .margin({ top: 4 })
                }
              })
            }
            .margin({ top: 8 })
          }
        }
      }

      // 热门类型
      if (this.stats?.genreStats) {
        Card() {
          Column({ space: AppStyles.Spacing.S }) {
            Text('🔥 热门类型TOP5')
              .fontSize(AppStyles.FontSizes.Title3)
              .fontWeight(FontWeight.Bold)
            
            ForEach(this.getTopGenres(), (genre: any, index: number) => {
              Row() {
                Text(`#${index + 1}`)
                  .fontSize(12)
                  .fontColor(AppStyles.Colors.Gray)
                  .width(30)
                Text(genre.name)
                  .fontSize(AppStyles.FontSizes.Body)
                  .layoutWeight(1)
                Text(`${genre.count}次`)
                  .fontSize(AppStyles.FontSizes.Caption1)
                  .fontColor(AppStyles.Colors.Gray)
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
      Row() {
        Text('📈 观看趋势分析')
          .fontSize(AppStyles.FontSizes.Title3)
          .fontWeight(FontWeight.Bold)
          .layoutWeight(1)
        Button(this.chartType === 'line' ? '📊 列表' : '📈 图表', { type: ButtonType.Normal })
          .onClick(() => this.changeChartType(this.chartType === 'line' ? 'list' : 'line'))
      }
      
      if (this.trends.length > 0) {
        if (this.chartType === 'line' && this.showDetails) {
          // 趋势图表视图
          Card() {
            Column() {
              Text('最近7天播放次数趋势')
                .fontSize(14)
                .fontColor(AppStyles.Colors.Gray)
                .margin({ bottom: 8 })
              
              // 简化的趋势线图
              Stack() {
                // 背景网格
                ForEach([0, 1, 2, 3], (i) => {
                  Row()
                    .width('100%')
                    .height(1)
                    .backgroundColor('#f0f0f0')
                    .margin({ top: 30 + i * 30 })
                })
                
                // 趋势线
                Row() {
                  ForEach(this.trends, (trend, index) => {
                    Column() {
                      Column()
                        .width(30)
                        .height(20 + trend.count * 15)
                        .backgroundColor('#007AFF')
                        .borderRadius(2)
                        .margin({ bottom: 4 })
                      Text(trend.date.split('-').slice(1).join('/'))
                        .fontSize(10)
                        .fontColor(AppStyles.Colors.Gray)
                    }
                    .margin({ right: 2 })
                  })
                }
                .margin({ top: 10 })
              }
              .width('100%')
              .height(120)
            }
          }
        } else {
          // 列表视图
          ForEach(this.trends, (trend) => {
            Card() {
              Row() {
                Column({ space: 2 }) {
                  Text(trend.date)
                    .fontSize(AppStyles.FontSizes.Caption1)
                  Text(`${trend.count} 次播放`)
                    .fontSize(AppStyles.FontSizes.Body)
                    .fontColor(AppStyles.Colors.Primary)
                  if (this.showDetails) {
                    Text(`总时长: ${this.formatDuration(trend.totalDuration)}`)
                      .fontSize(AppStyles.FontSizes.Caption2)
                      .fontColor(AppStyles.Colors.Gray)
                    Text(`平均时长: ${this.formatDuration(trend.totalDuration / trend.count)}`)
                      .fontSize(AppStyles.FontSizes.Caption2)
                      .fontColor(AppStyles.Colors.Gray)
                  }
                }
                .layoutWeight(1)
                
                Column() {
                  Text(this.getTrendIcon(trend.count))
                    .fontSize(24)
                  if (this.showDetails && trend.topCategory) {
                    Text(`主要: ${this.getCategoryName(trend.topCategory)}`)
                      .fontSize(10)
                      .fontColor(AppStyles.Colors.Gray)
                      .margin({ top: 4 })
                  }
                }
              }
            }
          })
        }
        
        // 趋势统计摘要
        if (this.showDetails) {
          Card() {
            Column({ space: AppStyles.Spacing.S }) {
              Text('📊 趋势统计')
                .fontSize(AppStyles.FontSizes.Title3)
                .fontWeight(FontWeight.Bold)
              
              Row({ space: AppStyles.Spacing.M }) {
                Column() {
                  Text(Math.round(this.trends.reduce((sum, t) => sum + t.count, 0) / this.trends.length).toString())
                    .fontSize(20)
                    .fontColor(AppStyles.Colors.Primary)
                  Text('日均播放')
                    .fontSize(AppStyles.FontSizes.Caption1)
                    .fontColor(AppStyles.Colors.Gray)
                }
                
                Column() {
                  Text(Math.max(...this.trends.map(t => t.count)).toString())
                    .fontSize(20)
                    .fontColor(AppStyles.Colors.Green)
                  Text('最高单日')
                    .fontSize(AppStyles.FontSizes.Caption1)
                    .fontColor(AppStyles.Colors.Gray)
                }
                
                Column() {
                  Text(this.trends.filter(t => t.count > 0).length.toString())
                    .fontSize(20)
                    .fontColor(AppStyles.Colors.Orange)
                  Text('活跃天数')
                    .fontSize(AppStyles.FontSizes.Caption1)
                    .fontColor(AppStyles.Colors.Gray)
                }
              }
            }
          }
        }
      } else {
        EmptyState({
          icon: '📈',
          title: '暂无趋势数据',
          description: '开始观看内容后，这里将显示您的观看趋势',
          showAction: true,
          actionText: '去观看',
          onAction: () => appState.openHome()
        })
      }
    }
  }

  @Builder
  buildRecommendationsTab() {
    Column({ space: AppStyles.Spacing.M }) {
      Row() {
        Text('💡 个性化推荐')
          .fontSize(AppStyles.FontSizes.Title3)
          .fontWeight(FontWeight.Bold)
          .layoutWeight(1)
        Button('🔄 换一批', { type: ButtonType.Normal })
          .onClick(() => this.loadAnalytics())
      }
      
      if (this.recommendations.length > 0) {
        // 推荐统计
        if (this.showDetails) {
          Card() {
            Column({ space: AppStyles.Spacing.S }) {
              Text('🎯 推荐依据')
                .fontSize(AppStyles.FontSizes.Title3)
                .fontWeight(FontWeight.Bold)
              
              Row({ space: AppStyles.Spacing.M }) {
                Column() {
                  Text(this.recommendations.length.toString())
                    .fontSize(20)
                    .fontColor(AppStyles.Colors.Primary)
                  Text('推荐数量')
                    .fontSize(AppStyles.FontSizes.Caption1)
                    .fontColor(AppStyles.Colors.Gray)
                }
                
                Column() {
                  Text(new Set(this.recommendations.map(r => r.category)).size.toString())
                    .fontSize(20)
                    .fontColor(AppStyles.Colors.Green)
                  Text('涉及分类')
                    .fontSize(AppStyles.FontSizes.Caption1)
                    .fontColor(AppStyles.Colors.Gray)
                }
                
                Column() {
                  Text(Math.round(this.recommendations.reduce((sum, r) => sum + (r.score || 0), 0) / this.recommendations.length * 100) / 100).toString())
                    .fontSize(20)
                    .fontColor(AppStyles.Colors.Orange)
                  Text('平均评分')
                    .fontSize(AppStyles.FontSizes.Caption1)
                    .fontColor(AppStyles.Colors.Gray)
                }
              }
            }
          }
        }
        
        // 推荐列表
        List() {
          ForEach(this.recommendations, (item, index) => {
            ListItem() {
              Card() {
                Row() {
                  // 排名标识
                  if (this.showDetails) {
                    Column() {
                      Text(`#${index + 1}`)
                        .fontSize(16)
                        .fontColor('#FF6B35')
                        .fontWeight(FontWeight.Bold)
                      Text('推荐')
                        .fontSize(10)
                        .fontColor(AppStyles.Colors.Gray)
                    }
                    .margin({ right: 8 })
                  }
                  
                  // 内容图标
                  Text(this.getCategoryIcon(item.category))
                    .fontSize(this.showDetails ? 40 : 32)
                    .margin({ right: 12 })
                  
                  // 内容信息
                  Column({ space: 4 }) {
                    Row() {
                      Text(item.title)
                        .fontSize(AppStyles.FontSizes.Body)
                        .fontWeight(FontWeight.Medium)
                        .layoutWeight(1)
                      
                      if (item.year) {
                        Text(item.year.toString())
                          .fontSize(12)
                          .fontColor(AppStyles.Colors.Gray)
                          .backgroundColor('#f0f0f0')
                          .padding({ left: 6, right: 6, top: 2, bottom: 2 })
                          .borderRadius(4)
                      }
                    }
                    
                    Text(item.reason)
                      .fontSize(AppStyles.FontSizes.Caption1)
                      .fontColor(AppStyles.Colors.Gray)
                      .maxLines(2)
                      .textOverflow({ overflow: TextOverflow.Ellipsis })
                    
                    if (this.showDetails && item.tags) {
                      Row({ space: 4 }) {
                        ForEach(item.tags.slice(0, 3), (tag: string) => {
                          Text(`#${tag}`)
                            .fontSize(10)
                            .fontColor('#007AFF')
                            .backgroundColor('#F0F8FF')
                            .padding({ left: 4, right: 4, top: 1, bottom: 1 })
                            .borderRadius(2)
                        })
                      }
                      .margin({ top: 4 })
                    }
                  }
                  .layoutWeight(1)
                  
                  // 操作按钮
                  Column({ space: 4 }) {
                    Button('➕', { type: ButtonType.Normal })
                      .width(32)
                      .height(32)
                      .fontSize(14)
                      .onClick(() => this.addToFavorites(item))
                    
                    if (this.showDetails) {
                      Button('👁️', { type: ButtonType.Normal })
                        .width(32)
                        .height(32)
                        .fontSize(14)
                        .onClick(() => this.previewItem(item))
                    }
                  }
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
          showAction: true,
          actionText: '浏览收藏',
          onAction: () => appState.openFavorites()
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