import { PluginManager } from '../service/PluginManager';
import { Card } from '../components/Styles';
import { Column, Row, Text, Button } from '@ohos.arkui.ArkUI';

/**
 * 示例插件 - 演示插件系统的完整功能
 */
export class SamplePlugin {
  static readonly pluginInfo: PluginManager.Plugin = {
    id: 'sample_plugin_v1',
    name: '示例插件',
    version: '1.0.0',
    description: '演示插件系统功能的示例插件，提供额外的数据统计和工具',
    author: 'SuYiZhang',
    permissions: ['analytics.read', 'storage.write', 'ui.components'],
    dependencies: [],
    
    // 生命周期钩子
    async onInstall(): Promise<boolean> {
      console.log('SamplePlugin: 安装中...');
      // 执行初始化逻辑
      await new Promise(resolve => setTimeout(resolve, 1000));
      return true;
    },
    
    async onEnable(): Promise<boolean> {
      console.log('SamplePlugin: 启用中...');
      // 注册服务和组件
      return true;
    },
    
    async onDisable(): Promise<boolean> {
      console.log('SamplePlugin: 禁用中...');
      return true;
    },
    
    async onUninstall(): Promise<boolean> {
      console.log('SamplePlugin: 卸载中...');
      return true;
    },
    
    // 提供组件
    getComponents(): PluginManager.PluginComponent[] {
      return [
        {
          type: 'page',
          name: '插件统计页面',
          component: 'SampleStatsPage',
          route: '/plugin/stats',
          position: 'settings'
        },
        {
          type: 'widget',
          name: '快速工具小组件',
          component: 'QuickToolsWidget',
          position: 'home'
        }
      ];
    },
    
    // 提供服务
    getServices(): PluginManager.PluginService[] {
      return [
        {
          name: 'advancedAnalytics',
          methods: ['getAdvancedStats', 'generateReport', 'exportData']
        },
        {
          name: 'utilityTools',
          methods: ['formatTime', 'calculateRating', 'generateQRCode']
        }
      ];
    },
    
    // 提供设置项
    getSettings(): PluginManager.PluginSetting[] {
      return [
        {
          key: 'enableAdvancedStats',
          type: 'toggle',
          label: '启用高级统计',
          description: '开启更详细的数据分析功能',
          defaultValue: true
        },
        {
          key: 'dataRetentionDays',
          type: 'slider',
          label: '数据保留天数',
          description: '设置插件数据的保留期限',
          defaultValue: 30,
          min: 7,
          max: 90
        },
        {
          key: 'reportFormat',
          type: 'select',
          label: '报告格式',
          description: '选择导出的报告格式',
          defaultValue: 'pdf',
          options: [
            { label: 'PDF文档', value: 'pdf' },
            { label: 'Excel表格', value: 'excel' },
            { label: 'JSON数据', value: 'json' }
          ]
        }
      ];
    }
  };

  // 插件提供的额外功能
  static calculateAdvancedMetrics(data: any[]) {
    if (!data || data.length === 0) return null;
    
    const sorted = [...data].sort((a, b) => b.count - a.count);
    const total = data.reduce((sum, item) => sum + item.count, 0);
    
    return {
      totalItems: data.length,
      averageCount: total / data.length,
      medianCount: sorted[Math.floor(sorted.length / 2)]?.count || 0,
      topPerformer: sorted[0],
      growthRate: this.calculateGrowthRate(data)
    };
  }
  
  private static calculateGrowthRate(data: any[]) {
    if (data.length < 2) return 0;
    const recent = data.slice(0, Math.floor(data.length / 2));
    const older = data.slice(Math.floor(data.length / 2));
    
    const recentAvg = recent.reduce((sum, item) => sum + item.count, 0) / recent.length;
    const olderAvg = older.reduce((sum, item) => sum + item.count, 0) / older.length;
    
    return olderAvg > 0 ? ((recentAvg - olderAvg) / olderAvg) * 100 : 0;
  }
}

// 插件统计页面组件
@Component
export struct SampleStatsPage {
  @State sampleData: any = null;
  
  async aboutToAppear() {
    // 模拟加载插件数据
    this.sampleData = {
      efficiency: 87.5,
      optimizations: 12,
      insights: [
        '用户活跃度提升了15%',
        '收藏转化率提高了8%',
        '播放流畅度改善明显'
      ]
    };
  }
  
  build() {
    Column({ space: 16 }) {
      Text('📊 插件统计')
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
      
      Card() {
        Column({ space: 12 }) {
          Text('性能指标')
            .fontSize(18)
            .fontWeight(FontWeight.Medium)
          
          Row({ space: 16 }) {
            Column() {
              Text(this.sampleData?.efficiency?.toString() || '0')
                .fontSize(32)
                .fontColor('#34C759')
              Text('效率指数')
                .fontSize(12)
                .fontColor('#666666')
            }
            
            Column() {
              Text(this.sampleData?.optimizations?.toString() || '0')
                .fontSize(32)
                .fontColor('#007AFF')
              Text('优化项目')
                .fontSize(12)
                .fontColor('#666666')
            }
          }
        }
      }
      
      Card() {
        Column({ space: 12 }) {
          Text('AI洞察')
            .fontSize(18)
            .fontWeight(FontWeight.Medium)
          
          ForEach(this.sampleData?.insights || [], (insight: string) => {
            Row() {
              Text('💡')
                .margin({ right: 8 })
              Text(insight)
                .fontSize(14)
            }
          })
        }
      }
    }
    .padding(16)
    .width('100%')
    .height('100%')
  }
}

// 快速工具小组件
@Component
export struct QuickToolsWidget {
  build() {
    Card() {
      Column({ space: 8 }) {
        Text('🔧 快速工具')
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
        
        Row({ space: 8 }) {
          Button('清理缓存', { type: ButtonType.Normal })
            .height(32)
            .onClick(() => console.log('清理缓存'))
          
          Button('生成报告', { type: ButtonType.Normal })
            .height(32)
            .onClick(() => console.log('生成报告'))
        }
      }
    }
    .padding(12)
  }
}