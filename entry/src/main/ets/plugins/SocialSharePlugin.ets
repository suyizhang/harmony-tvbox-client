import { PluginManager } from '../service/PluginManager';
import { appState } from '../common/AppState';
import { Card } from '../components/Styles';
import { Column, Row, Text, Button, List, ListItem, Image } from '@ohos.arkui.ArkUI';
import { ButtonType } from '@ohos.arkui.ArkUI';
import { FontWeight } from '@ohos.arkui.ArkUI';

/**
 * 社交分享插件 - 提供内容分享到社交媒体功能
 */
export class SocialSharePlugin {
  static readonly pluginInfo: PluginManager.Plugin = {
    id: 'social_share_v1',
    name: '社交分享',
    version: '1.0.0',
    description: '将喜欢的视频内容分享到微信、QQ、微博等社交平台',
    author: 'SuYiZhang',
    permissions: ['network.share', 'ui.sharing'],
    dependencies: [],
    
    async onInstall(): Promise<boolean> {
      console.log('SocialSharePlugin: 安装社交分享插件...');
      return true;
    },
    
    async onEnable(): Promise<boolean> {
      console.log('SocialSharePlugin: 启用社交分享插件...');
      return true;
    },
    
    async onDisable(): Promise<boolean> {
      console.log('SocialSharePlugin: 禁用社交分享插件...');
      return true;
    },
    
    async onUninstall(): Promise<boolean> {
      console.log('SocialSharePlugin: 卸载社交分享插件...');
      return true;
    },
    
    getComponents(): PluginManager.PluginComponent[] {
      return [
        {
          type: 'page',
          name: '分享管理页面',
          component: 'ShareManagerPage',
          route: '/plugin/share',
          position: 'settings'
        }
      ];
    },
    
    getServices(): PluginManager.PluginService[] {
      return [
        {
          name: 'socialShare',
          methods: ['shareToWechat', 'shareToQQ', 'shareToWeibo', 'shareToFriends']
        }
      ];
    },
    
    getSettings(): PluginManager.PluginSetting[] {
      return [
        {
          key: 'defaultSharePlatform',
          type: 'select',
          label: '默认分享平台',
          description: '优先使用的分享渠道',
          defaultValue: 'wechat',
          options: [
            { label: '微信好友', value: 'wechat' },
            { label: 'QQ好友', value: 'qq' },
            { label: '新浪微博', value: 'weibo' },
            { label: '复制链接', value: 'link' }
          ]
        },
        {
          key: 'includeWatermark',
          type: 'toggle',
          label: '添加水印',
          description: '分享时自动添加应用水印',
          defaultValue: true
        },
        {
          key: 'shareTemplate',
          type: 'select',
          label: '分享模板',
          description: '分享内容的展示样式',
          defaultValue: 'card',
          options: [
            { label: '卡片样式', value: 'card' },
            { label: '简洁文字', value: 'text' },
            { label: '海报样式', value: 'poster' }
          ]
        }
      ];
    }
  };

  // 分享功能实现
  static async shareToPlatform(content: any, platform: string): Promise<boolean> {
    console.log(`分享到${platform}: ${content.title}`);
    
    // 模拟分享过程
    appState.status = `正在分享到${this.getPlatformName(platform)}...`;
    
    setTimeout(() => {
      appState.status = `成功分享到${this.getPlatformName(platform)}: ${content.title}`;
    }, 2000);
    
    return true;
  }
  
  private static getPlatformName(platform: string): string {
    const names = {
      wechat: '微信',
      qq: 'QQ',
      weibo: '微博',
      link: '链接'
    };
    return names[platform] || platform;
  }
}

// 分享管理页面组件
@Component
export struct ShareManagerPage {
  @State shareHistory: Array<{
    id: string;
    contentTitle: string;
    platform: string;
    shareTime: string;
    status: 'success' | 'failed';
  }> = [];
  
  @State popularPlatforms: Array<{
    id: string;
    name: string;
    icon: string;
    color: string;
  }> = [];

  async aboutToAppear() {
    await this.loadShareData();
  }

  async loadShareData() {
    // 模拟分享历史
    this.shareHistory = [
      {
        id: 'share_001',
        contentTitle: '流浪地球2 - 精彩片段',
        platform: 'wechat',
        shareTime: '2026-04-18 09:30',
        status: 'success'
      },
      {
        id: 'share_002',
        contentTitle: '狂飙 - 第15集预告',
        platform: 'weibo',
        shareTime: '2026-04-18 08:15',
        status: 'success'
      }
    ];
    
    // 平台配置
    this.popularPlatforms = [
      { id: 'wechat', name: '微信', icon: '💬', color: '#07C160' },
      { id: 'qq', name: 'QQ', icon: '🐧', color: '#12B7F5' },
      { id: 'weibo', name: '微博', icon: '🌐', color: '#E6162D' },
      { id: 'link', name: '复制链接', icon: '🔗', color: '#666666' }
    ];
  }

  build() {
    Column({ space: 16 }) {
      Text('📤 社交分享')
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
      
      // 快速分享
      Card() {
        Column({ space: 12 }) {
          Text('快速分享')
            .fontSize(18)
            .fontWeight(FontWeight.Medium)
          
          Text('选择分享平台')
            .fontSize(14)
            .fontColor('#666666')
          
          Grid() {
            ForEach(this.popularPlatforms, (platform) => {
              GridItem() {
                Button(platform.icon + ' ' + platform.name)
                  .width(80)
                  .height(60)
                  .fontSize(12)
                  .backgroundColor(platform.color + '20')
                  .fontColor(platform.color)
                  .onClick(() => this.quickShare(platform.id))
              }
            })
          }
          .columnsTemplate('1fr 1fr')
          .rowsGap(8)
          .columnsGap(8)
        }
      }
      
      // 分享历史
      Card() {
        Column({ space: 12 }) {
          Row() {
            Text('分享历史')
              .fontSize(18)
              .fontWeight(FontWeight.Medium)
              .layoutWeight(1)
            Button('清空历史', { type: ButtonType.Normal })
              .height(28)
          }
          
          List() {
            ForEach(this.shareHistory, (item) => {
              ListItem() {
                Row({ space: 12 }) {
                  Text(this.getPlatformIcon(item.platform))
                    .fontSize(20)
                  
                  Column({ space: 2 }) {
                    Text(item.contentTitle)
                      .fontSize(14)
                      .fontWeight(FontWeight.Medium)
                      .layoutWeight(1)
                    Text(`${this.getPlatformName(item.platform)} · ${item.shareTime}`)
                      .fontSize(12)
                      .fontColor('#666666')
                  }
                  
                  Text(item.status === 'success' ? '✅' : '❌')
                    .fontSize(16)
                }
                .padding(8)
              }
            })
          }
        }
      }
      
      // 分享统计
      Card() {
        Column({ space: 8 }) {
          Text('📊 分享统计')
            .fontSize(18)
            .fontWeight(FontWeight.Medium)
          
          Row({ space: 20 }) {
            Column() {
              Text('28')
                .fontSize(20)
                .fontColor('#007AFF')
              Text('总分享')
                .fontSize(12)
                .fontColor('#666666')
            }
            
            Column() {
              Text('25')
                .fontSize(20)
                .fontColor('#34C759')
              Text('成功')
                .fontSize(12)
                .fontColor('#666666')
            }
            
            Column() {
              Text('3')
                .fontSize(20)
                .fontColor('#FF3B30')
              Text('失败')
                .fontSize(12)
                .fontColor('#666666')
            }
          }
        }
      }
    }
    .padding(16)
    .width('100%')
    .height('100%')
  }

  private quickShare(platformId: string) {
    const mockContent = {
      title: '精彩视频内容',
      description: '来自HarmonyTVBox的推荐',
      url: 'https://tvbox.example.com/video/123'
    };
    
    SocialSharePlugin.shareToPlatform(mockContent, platformId);
  }
  
  private getPlatformIcon(platform: string): string {
    const icons = {
      wechat: '💬',
      qq: '🐧',
      weibo: '🌐',
      link: '🔗'
    };
    return icons[platform] || '📤';
  }
  
  private getPlatformName(platform: string): string {
    const names = {
      wechat: '微信',
      qq: 'QQ',
      weibo: '微博',
      link: '链接'
    };
    return names[platform] || platform;
  }
}