import { PluginManager } from '../service/PluginManager';
import { DownloadService } from '../service/DownloadService';
import { appState } from '../common/AppState';
import { Card, PrimaryButton } from '../components/Styles';
import { Column, Row, Text, Button, List, ListItem, Progress } from '@ohos.arkui.ArkUI';
import { ButtonType } from '@ohos.arkui.ArkUI';
import { FontWeight } from '@ohos.arkui.ArkUI';

/**
 * 下载管理器插件 - 提供视频下载和离线缓存功能
 */
export class DownloadManagerPlugin {
  static readonly pluginInfo: PluginManager.Plugin = {
    id: 'download_manager_v1',
    name: '下载管理器',
    version: '1.0.0',
    description: '提供视频下载、离线缓存、批量管理等实用功能',
    author: 'SuYiZhang',
    permissions: ['storage.write', 'network.download', 'file.management'],
    dependencies: [],
    
    async onInstall(): Promise<boolean> {
      console.log('DownloadManagerPlugin: 安装下载管理器...');
      await DownloadService.initialize();
      return true;
    },
    
    async onEnable(): Promise<boolean> {
      console.log('DownloadManagerPlugin: 启用下载管理器...');
      return true;
    },
    
    async onDisable(): Promise<boolean> {
      console.log('DownloadManagerPlugin: 禁用下载管理器...');
      return true;
    },
    
    async onUninstall(): Promise<boolean> {
      console.log('DownloadManagerPlugin: 卸载下载管理器...');
      return true;
    },
    
    getComponents(): PluginManager.PluginComponent[] {
      return [
        {
          type: 'page',
          name: '下载管理页面',
          component: 'DownloadManagerPage',
          route: '/plugin/downloads',
          position: 'settings'
        },
        {
          type: 'widget',
          name: '下载状态小组件',
          component: 'DownloadStatusWidget',
          position: 'home'
        }
      ];
    },
    
    getServices(): PluginManager.PluginService[] {
      return [
        {
          name: 'downloadManager',
          methods: ['startDownload', 'pauseDownload', 'resumeDownload', 'cancelDownload', 'getDownloads']
        }
      ];
    },
    
    getSettings(): PluginManager.PluginSetting[] {
      return [
        {
          key: 'autoDownload',
          type: 'toggle',
          label: 'WiFi下自动下载',
          description: '仅在WiFi环境下自动下载收藏内容',
          defaultValue: false
        },
        {
          key: 'maxConcurrent',
          type: 'select',
          label: '最大并发数',
          description: '同时下载的视频数量',
          defaultValue: 2,
          options: [
            { label: '1个', value: 1 },
            { label: '2个', value: 2 },
            { label: '3个', value: 3 },
            { label: '5个', value: 5 }
          ]
        },
        {
          key: 'downloadQuality',
          type: 'select',
          label: '下载画质',
          description: '默认下载的视频画质',
          defaultValue: '720p',
          options: [
            { label: '标清 480p', value: '480p' },
            { label: '高清 720p', value: '720p' },
            { label: '超清 1080p', value: '1080p' }
          ]
        }
      ];
    }
  };

  // 下载管理服务（模拟实现）
  static async startDownload(videoInfo: any, quality: string = '720p'): Promise<string> {
    const downloadId = 'dl_' + Date.now();
    console.log(`开始下载: ${videoInfo.title} (${quality})`);
    
    // 模拟下载进度
    setTimeout(() => {
      appState.status = `下载完成: ${videoInfo.title}`;
    }, 5000);
    
    return downloadId;
  }
}

// 下载管理页面组件
@Component
export struct DownloadManagerPage {
  @State downloads: Array<{
    id: string;
    title: string;
    progress: number;
    status: 'downloading' | 'paused' | 'completed' | 'failed';
    size: string;
    speed: string;
  }> = [];
  
  @State totalDownloads: number = 0;
  @State completedDownloads: number = 0;

  async aboutToAppear() {
    await this.loadDownloads();
  }

  async loadDownloads() {
    // 模拟下载数据
    this.downloads = [
      {
        id: 'dl_001',
        title: '示例视频1.mp4',
        progress: 65,
        status: 'downloading',
        size: '245MB',
        speed: '1.2MB/s'
      },
      {
        id: 'dl_002',
        title: '示例视频2.mp4',
        progress: 100,
        status: 'completed',
        size: '189MB',
        speed: '0MB/s'
      }
    ];
    
    this.totalDownloads = this.downloads.length;
    this.completedDownloads = this.downloads.filter(d => d.status === 'completed').length;
  }

  build() {
    Column({ space: 16 }) {
      Text('📥 下载管理器')
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
      
      // 下载统计
      Card() {
        Row({ space: 20 }) {
          Column() {
            Text(this.totalDownloads.toString())
              .fontSize(24)
              .fontColor('#007AFF')
            Text('总任务')
              .fontSize(12)
              .fontColor('#666666')
          }
          
          Column() {
            Text(this.completedDownloads.toString())
              .fontSize(24)
              .fontColor('#34C759')
            Text('已完成')
              .fontSize(12)
              .fontColor('#666666')
          }
          
          Column() {
            Text((this.totalDownloads - this.completedDownloads).toString())
              .fontSize(24)
              .fontColor('#FF9500')
            Text('进行中')
              .fontSize(12)
              .fontColor('#666666')
          }
        }
      }
      
      // 下载列表
      List() {
        ForEach(this.downloads, (item) => {
          ListItem() {
            Card() {
              Column({ space: 8 }) {
                Row() {
                  Text(item.title)
                    .fontSize(16)
                    .fontWeight(FontWeight.Medium)
                    .layoutWeight(1)
                  
                  Text(item.size)
                    .fontSize(12)
                    .fontColor('#666666')
                }
                
                if (item.status === 'downloading') {
                  Column({ space: 4 }) {
                    Progress({ value: item.progress, total: 100 })
                      .width('100%')
                    
                    Row() {
                      Text(`${item.progress}%`)
                        .fontSize(12)
                        .fontColor('#007AFF')
                      Text(item.speed)
                        .fontSize(12)
                        .fontColor('#34C759')
                        .margin({ left: 8 })
                      
                      Button('暂停', { type: ButtonType.Normal })
                        .height(24)
                        .margin({ left: 8 })
                    }
                  }
                } else {
                  Row() {
                    Text(item.status === 'completed' ? '✅ 下载完成' : item.status === 'failed' ? '❌ 下载失败' : '⏸️ 已暂停')
                      .fontSize(12)
                      .fontColor(item.status === 'completed' ? '#34C759' : item.status === 'failed' ? '#FF3B30' : '#FF9500')
                    
                    if (item.status === 'completed') {
                      Button('播放', { type: ButtonType.Normal })
                        .height(24)
                        .margin({ left: 8 })
                    }
                  }
                }
              }
            }
          }
        })
      }
      
      // 操作按钮
      Row({ space: 12 }) {
        PrimaryButton({
          text: '➕ 添加下载',
          onClick: () => {
            appState.status = '添加下载功能开发中...';
          }
        })
        
        Button('🗑️ 清理完成', { type: ButtonType.Normal })
          .onClick(() => {
            this.downloads = this.downloads.filter(d => d.status !== 'completed');
          })
      }
    }
    .padding(16)
    .width('100%')
    .height('100%')
  }
}

// 下载状态小组件
@Component
export struct DownloadStatusWidget {
  @State activeDownloads: number = 2;
  
  build() {
    Card() {
      Row({ space: 8 }) {
        Text('📥')
          .fontSize(20)
        Column() {
          Text('下载管理器')
            .fontSize(14)
            .fontWeight(FontWeight.Medium)
          Text(`${this.activeDownloads} 个任务进行中`)
            .fontSize(12)
            .fontColor('#666666')
        }
        .layoutWeight(1)
        Button('查看', { type: ButtonType.Normal })
          .height(28)
      }
    }
    .padding(12)
  }
}

// 下载服务（基础实现）
export class DownloadService {
  static async initialize(): Promise<void> {
    console.log('DownloadService: 初始化下载服务...');
    // 创建下载目录等初始化工作
  }
}