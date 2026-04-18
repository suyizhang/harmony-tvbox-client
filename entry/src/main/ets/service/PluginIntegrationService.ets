import { PluginManager } from './PluginManager';
import { DownloadManagerPlugin } from '../plugins/DownloadManagerPlugin';
import { SocialSharePlugin } from '../plugins/SocialSharePlugin';
import { SamplePlugin } from '../plugins/SamplePlugin';
import { appState } from '../common/AppState';

/**
 * 插件集成服务 - 负责插件的统一管理和系统集成
 */
export class PluginIntegrationService {
  private static initialized = false;

  // 初始化所有插件
  static async initializePluginSystem(): Promise<void> {
    if (this.initialized) return;
    
    try {
      console.log('🔌 开始初始化插件系统...');
      
      // 注册内置插件
      await this.registerBuiltinPlugins();
      
      // 加载用户插件配置
      await this.loadPluginConfigurations();
      
      // 启用默认插件
      await this.enableDefaultPlugins();
      
      this.initialized = true;
      console.log('✅ 插件系统初始化完成');
      appState.status = '插件系统已就绪';
      
    } catch (error) {
      console.error('❌ 插件系统初始化失败:', error);
      appState.setError('插件系统初始化失败');
    }
  }

  // 注册内置插件
  private static async registerBuiltinPlugins(): Promise<void> {
    const builtinPlugins = [
      SamplePlugin.pluginInfo,
      DownloadManagerPlugin.pluginInfo,
      SocialSharePlugin.pluginInfo
    ];
    
    for (const plugin of builtinPlugins) {
      const exists = PluginManager.isPluginInstalled(plugin.id);
      if (!exists) {
        const success = await PluginManager.registerPlugin(plugin);
        if (success) {
          console.log(`📦 注册插件: ${plugin.name}`);
        }
      }
    }
  }

  // 加载插件配置
  private static async loadPluginConfigurations(): Promise<void> {
    try {
      // 从本地存储加载用户插件设置
      const userPluginSettings = await this.getUserPluginSettings();
      
      for (const [pluginId, settings] of Object.entries(userPluginSettings)) {
        if (settings.enabled) {
          await PluginManager.enablePlugin(pluginId);
        }
      }
      
    } catch (error) {
      console.error('加载插件配置失败:', error);
    }
  }

  // 启用默认插件
  private static async enableDefaultPlugins(): Promise<void> {
    const defaultPlugins = ['sample_plugin_v1']; // 默认启用的插件
    
    for (const pluginId of defaultPlugins) {
      if (PluginManager.isPluginInstalled(pluginId) && !PluginManager.isPluginEnabled(pluginId)) {
        await PluginManager.enablePlugin(pluginId);
      }
    }
  }

  // 获取用户插件设置
  private static async getUserPluginSettings(): Promise<Record<string, any>> {
    // 模拟从本地存储读取配置
    return {
      sample_plugin_v1: { enabled: true },
      download_manager_v1: { enabled: false },
      social_share_v1: { enabled: true }
    };
  }

  // 获取插件市场数据
  static async getPluginMarketData(): Promise<{
    featured: any[];
    categories: any[];
    recommended: any[];
  }> {
    return {
      featured: [
        {
          id: 'download_manager_v1',
          name: '下载管理器',
          description: '提供视频下载、离线缓存功能',
          rating: 4.8,
          downloads: 1250,
          icon: '📥'
        },
        {
          id: 'social_share_v1',
          name: '社交分享',
          description: '分享内容到各大社交平台',
          rating: 4.6,
          downloads: 980,
          icon: '📤'
        }
      ],
      categories: [
        { id: 'utilities', name: '实用工具', count: 8 },
        { id: 'social', name: '社交互动', count: 5 },
        { id: 'media', name: '媒体处理', count: 12 },
        { id: 'productivity', name: '效率提升', count: 6 }
      ],
      recommended: [
        {
          id: 'subtitle_manager',
          name: '字幕管理器',
          description: '管理视频字幕文件，支持多语言切换',
          rating: 4.9,
          price: '免费'
        }
      ]
    };
  }

  // 搜索插件
  static async searchPlugins(query: string): Promise<any[]> {
    const allPlugins = PluginManager.getAllPlugins();
    return allPlugins
      .filter(({ plugin }) => 
        plugin.name.toLowerCase().includes(query.toLowerCase()) ||
        plugin.description.toLowerCase().includes(query.toLowerCase())
      )
      .map(({ plugin, state }) => ({
        ...plugin,
        installed: true,
        enabled: state === PluginManager.PluginState.ENABLED
      }));
  }

  // 创建插件快捷方式
  static createPluginShortcut(pluginId: string): void {
    const plugin = PluginManager.getAllPlugins().find(p => p.plugin.id === pluginId)?.plugin;
    if (plugin) {
      appState.addQuickAction({
        id: `plugin_${pluginId}`,
        title: plugin.name,
        icon: '🔌',
        action: () => appState.navigateTo(`/plugin/${pluginId}`)
      });
    }
  }

  // 获取插件统计信息
  static getPluginStatistics(): {
    totalPlugins: number;
    enabledPlugins: number;
    categories: string[];
    recentActivity: any[];
  } {
    const allPlugins = PluginManager.getAllPlugins();
    const enabledPlugins = PluginManager.getEnabledPlugins();
    
    return {
      totalPlugins: allPlugins.length,
      enabledPlugins: enabledPlugins.length,
      categories: ['实用工具', '社交互动', '媒体处理', '效率提升'],
      recentActivity: [
        { type: 'install', pluginName: '下载管理器', time: '2小时前' },
        { type: 'enable', pluginName: '社交分享', time: '1天前' }
      ]
    };
  }

  // 备份插件配置
  static async backupPluginConfig(): Promise<string> {
    const config = {
      timestamp: Date.now(),
      plugins: PluginManager.getAllPlugins(),
      settings: await this.getUserPluginSettings()
    };
    
    const configStr = JSON.stringify(config, null, 2);
    // 在实际项目中，这里会保存到云端或本地文件
    console.log('📋 插件配置已备份');
    return configStr;
  }

  // 恢复插件配置
  static async restorePluginConfig(configStr: string): Promise<boolean> {
    try {
      const config = JSON.parse(configStr);
      // 在实际项目中，这里会从备份恢复插件状态
      console.log('📥 插件配置已恢复');
      return true;
    } catch (error) {
      console.error('恢复插件配置失败:', error);
      return false;
    }
  }
}