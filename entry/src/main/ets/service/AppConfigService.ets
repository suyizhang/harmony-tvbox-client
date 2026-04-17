import { preferences } from '@kit.ArkData';

/**
 * 应用配置管理服务
 */
export class AppConfigService {
  private static readonly CONFIG_KEY = 'app_config';
  private static defaultConfig: AppConfig = {
    version: '1.0.0',
    debugMode: false,
    autoCheckUpdate: true,
    performanceMonitoring: true,
    analyticsEnabled: true,
    crashReporting: true,
    maxCacheSize: 100,
    sessionTimeout: 30,
    networkTimeout: 10,
    defaultTheme: 'auto',
    language: 'zh-CN'
  };

  // 配置接口
  interface AppConfig {
    version: string;
    debugMode: boolean;
    autoCheckUpdate: boolean;
    performanceMonitoring: boolean;
    analyticsEnabled: boolean;
    crashReporting: boolean;
    maxCacheSize: number; // MB
    sessionTimeout: number; // 分钟
    networkTimeout: number; // 秒
    defaultTheme: 'light' | 'dark' | 'auto';
    language: string;
  }

  // 获取配置
  static async getConfig(): Promise<AppConfig> {
    try {
      const configStr = await preferences.getPreferencesValue('com.suyizhang.tvbox', AppConfigService.CONFIG_KEY, '');
      if (configStr) {
        return { ...AppConfigService.defaultConfig, ...JSON.parse(configStr as string) };
      }
      return AppConfigService.defaultConfig;
    } catch (error) {
      console.error('Get config failed:', error);
      return AppConfigService.defaultConfig;
    }
  }

  // 保存配置
  static async saveConfig(config: Partial<AppConfig>): Promise<boolean> {
    try {
      const currentConfig = await AppConfigService.getConfig();
      const newConfig = { ...currentConfig, ...config };
      
      await preferences.setPreferencesValue(
        'com.suyizhang.tvbox',
        AppConfigService.CONFIG_KEY,
        JSON.stringify(newConfig)
      );
      
      return true;
    } catch (error) {
      console.error('Save config failed:', error);
      return false;
    }
  }

  // 重置配置
  static async resetConfig(): Promise<boolean> {
    try {
      await preferences.setPreferencesValue(
        'com.suyizhang.tvbox',
        AppConfigService.CONFIG_KEY,
        JSON.stringify(AppConfigService.defaultConfig)
      );
      return true;
    } catch (error) {
      console.error('Reset config failed:', error);
      return false;
    }
  }

  // 获取配置项
  static async getConfigItem<K extends keyof AppConfig>(key: K): Promise<AppConfig[K]> {
    const config = await AppConfigService.getConfig();
    return config[key];
  }

  // 设置配置项
  static async setConfigItem<K extends keyof AppConfig>(key: K, value: AppConfig[K]): Promise<boolean> {
    return AppConfigService.saveConfig({ [key]: value });
  }

  // 导出配置
  static async exportConfig(): Promise<string> {
    try {
      const config = await AppConfigService.getConfig();
      return JSON.stringify(config, null, 2);
    } catch (error) {
      console.error('Export config failed:', error);
      return '{}';
    }
  }

  // 导入配置
  static async importConfig(configJson: string): Promise<{ success: boolean; error?: string }> {
    try {
      const config = JSON.parse(configJson);
      const success = await AppConfigService.saveConfig(config);
      return { success };
    } catch (error) {
      return { success: false, error: '配置格式错误' };
    }
  }

  // 验证配置
  static validateConfig(config: any): { valid: boolean; errors: string[] } {
    const errors: string[] = [];
    
    if (config.maxCacheSize && (config.maxCacheSize < 10 || config.maxCacheSize > 500)) {
      errors.push('缓存大小应在10-500MB之间');
    }
    
    if (config.sessionTimeout && (config.sessionTimeout < 5 || config.sessionTimeout > 120)) {
      errors.push('会话超时应在5-120分钟之间');
    }
    
    if (config.networkTimeout && (config.networkTimeout < 5 || config.networkTimeout > 60)) {
      errors.push('网络超时应在5-60秒之间');
    }
    
    return { valid: errors.length === 0, errors };
  }
}