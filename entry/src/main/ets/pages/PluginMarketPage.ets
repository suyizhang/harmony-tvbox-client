import { PluginManager } from '../service/PluginManager';
import { SamplePlugin } from '../plugins/SamplePlugin';
import { DownloadManagerPlugin } from '../plugins/DownloadManagerPlugin';
import { SocialSharePlugin } from '../plugins/SocialSharePlugin';
import { appState } from '../common/AppState';
import { Card, PrimaryButton, StatusBadge } from '../components/Styles';
import { Column, Row, Text, Button, List, ListItem, Image } from '@ohos.arkui.ArkUI';
import { ButtonType } from '@ohos.arkui.ArkUI';
import { FontWeight } from '@ohos.arkui.ArkUI';

@Component
export struct PluginMarketPage {
  @State availablePlugins: Array<{
    plugin: PluginManager.Plugin;
    installed: boolean;
    enabled: boolean;
    state: string;
  }> = [];
  
  @State pluginStats: {
    total: number;
    installed: number;
    enabled: number;
  } = { total: 0, installed: 0, enabled: 0 };

  async aboutToAppear() {
    await this.loadPluginData();
  }

  async loadPluginData() {
    // 注册内置插件
    await PluginManager.registerPlugin(SamplePlugin.pluginInfo);
    await PluginManager.registerPlugin(DownloadManagerPlugin.pluginInfo);
    await PluginManager.registerPlugin(SocialSharePlugin.pluginInfo);
    
    // 启用示例插件
    await PluginManager.enablePlugin('sample_plugin_v1');
    
    const allPlugins = PluginManager.getAllPlugins();
    const enabledPlugins = PluginManager.getEnabledPlugins();
    
    this.availablePlugins = allPlugins.map(({ plugin, state }) => ({
      plugin,
      installed: true,
      enabled: state === PluginManager.PluginState.ENABLED,
      state
    }));
    
    this.pluginStats = {
      total: allPlugins.length,
      installed: allPlugins.length,
      enabled: enabledPlugins.length
    };
  }

  async togglePlugin(pluginId: string, enable: boolean) {
    if (enable) {
      const success = await PluginManager.enablePlugin(pluginId);
      if (success) {
        appState.status = '插件已启用';
        await this.loadPluginData();
      }
    } else {
      const success = await PluginManager.disablePlugin(pluginId);
      if (success) {
        appState.status = '插件已禁用';
        await this.loadPluginData();
      }
    }
  }

  async installPlugin(plugin: PluginManager.Plugin) {
    const success = await PluginManager.registerPlugin(plugin);
    if (success) {
      appState.status = `插件"${plugin.name}"安装成功`;
      await this.loadPluginData();
    }
  }

  async uninstallPlugin(pluginId: string) {
    const success = await PluginManager.uninstallPlugin(pluginId);
    if (success) {
      appState.status = '插件已卸载';
      await this.loadPluginData();
    }
  }

  build() {
    Column({ space: 16 }) {
      // 返回按钮
      Button('← 返回', { type: ButtonType.Normal })
        .onClick(() => appState.openSettings())
        .margin({ bottom: 16 })

      // 标题
      Text('🔌 插件市场')
        .fontSize(24)
        .fontWeight(FontWeight.Bold)

      // 插件统计
      Card() {
        Row({ space: 20 }) {
          Column() {
            Text(this.pluginStats.total.toString())
              .fontSize(24)
              .fontColor('#007AFF')
            Text('总插件')
              .fontSize(12)
              .fontColor('#666666')
          }
          
          Column() {
            Text(this.pluginStats.installed.toString())
              .fontSize(24)
              .fontColor('#34C759')
            Text('已安装')
              .fontSize(12)
              .fontColor('#666666')
          }
          
          Column() {
            Text(this.pluginStats.enabled.toString())
              .fontSize(24)
              .fontColor('#FF9500')
            Text('已启用')
              .fontSize(12)
              .fontColor('#666666')
          }
        }
      }

      // 插件列表
      Text('已安装插件')
        .fontSize(18)
        .fontWeight(FontWeight.Medium)
        .width('100%')
        .margin({ top: 16 })
      
      List() {
        ForEach(this.availablePlugins, (item) => {
          ListItem() {
            Card() {
              Column({ space: 12 }) {
                // 插件头部信息
                Row() {
                  // 插件图标/标识
                  Column()
                    .width(50)
                    .height(50)
                    .backgroundColor('#007AFF20')
                    .borderRadius(8)
                    .overlay(
                      Text(item.plugin.name.charAt(0))
                        .fontSize(20)
                        .fontColor('#007AFF')
                    )
                  
                  // 插件详细信息
                  Column({ space: 4 }) {
                    Row() {
                      Text(item.plugin.name)
                        .fontSize(16)
                        .fontWeight(FontWeight.Medium)
                        .layoutWeight(1)
                      
                      StatusBadge({
                        status: item.enabled ? 'enabled' : 'disabled',
                        text: item.enabled ? '已启用' : '已禁用'
                      })
                    }
                    
                    Text(`版本 ${item.plugin.version}`)
                      .fontSize(12)
                      .fontColor('#666666')
                    
                    Text(item.plugin.description)
                      .fontSize(12)
                      .fontColor('#666666')
                      .maxLines(2)
                      .textOverflow({ overflow: TextOverflow.Ellipsis })
                    
                    Row() {
                      Text(`作者: ${item.plugin.author}`)
                        .fontSize(10)
                        .fontColor('#999999')
                      Text(`• ${item.plugin.permissions.length} 权限`)
                        .fontSize(10)
                        .fontColor('#999999')
                        .margin({ left: 8 })
                    }
                  }
                }

                // 插件操作按钮
                Row({ space: 8 }) {
                  if (item.enabled) {
                    Button('禁用', { type: ButtonType.Normal })
                      .onClick(() => this.togglePlugin(item.plugin.id, false))
                  } else {
                    Button('启用', { type: ButtonType.Normal })
                      .onClick(() => this.togglePlugin(item.plugin.id, true))
                  }
                  
                  Button('设置', { type: ButtonType.Normal })
                    .onClick(() => appState.status = '插件设置功能开发中...')
                  
                  Button('卸载', { type: ButtonType.Normal })
                    .backgroundColor('#FF3B30')
                    .fontColor('#FFFFFF')
                    .onClick(() => this.uninstallPlugin(item.plugin.id))
                }
              }
            }
          }
        })
      }

      // 可用插件推荐
      Card() {
        Column({ space: 12 }) {
          Text('🔍 发现更多插件')
            .fontSize(18)
            .fontWeight(FontWeight.Medium)
          
          Text('插件市场正在建设中，敬请期待更多精彩插件！')
            .fontSize(14)
            .fontColor('#666666')
            .textAlign(TextAlign.Center)
          
          PrimaryButton({
            text: '检查更新',
            onClick: () => {
              appState.status = '正在检查插件更新...';
              setTimeout(() => {
                appState.status = '所有插件都是最新版本';
              }, 2000);
            }
          })
        }
      }
    }
    .padding(16)
    .width('100%')
    .height('100%')
    .backgroundColor('#F2F2F7')
  }
}