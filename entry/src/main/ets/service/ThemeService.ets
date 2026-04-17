import { preferences } from '@kit.ArkData';

/**
 * 主题模式
 */
export enum ThemeMode {
  LIGHT = 'light',
  DARK = 'dark',
  AUTO = 'auto'
}

/**
 * 主题配置
 */
export interface ThemeConfig {
  mode: ThemeMode;
  primaryColor: string;
  backgroundColor: string;
  surfaceColor: string;
  textColor: string;
  secondaryTextColor: string;
}

/**
 * 主题管理服务
 */
export class ThemeService {
  private static readonly THEME_KEY = 'app_theme';
  private static readonly DEFAULT_THEME = ThemeMode.AUTO;

  /**
   * 获取当前主题模式
   */
  static async getThemeMode(): Promise<ThemeMode> {
    try {
      const result = await preferences.getPreferencesValue(
        'com.suyizhang.tvbox',
        this.THEME_KEY,
        this.DEFAULT_THEME
      );
      return (result as string) as ThemeMode;
    } catch (error) {
      console.error('Failed to get theme mode:', error);
      return this.DEFAULT_THEME;
    }
  }

  /**
   * 设置主题模式
   */
  static async setThemeMode(mode: ThemeMode): Promise<boolean> {
    try {
      await preferences.setPreferencesValue(
        'com.suyizhang.tvbox',
        this.THEME_KEY,
        mode
      );
      return true;
    } catch (error) {
      console.error('Failed to set theme mode:', error);
      return false;
    }
  }

  /**
   * 获取主题配置
   */
  static getThemeConfig(mode: ThemeMode): ThemeConfig {
    const isDark = this.shouldUseDarkMode(mode);
    
    if (isDark) {
      return {
        mode,
        primaryColor: '#007AFF',
        backgroundColor: '#1C1C1E',
        surfaceColor: '#2C2C2E',
        textColor: '#FFFFFF',
        secondaryTextColor: '#8E8E93'
      };
    } else {
      return {
        mode,
        primaryColor: '#007AFF',
        backgroundColor: '#FFFFFF',
        surfaceColor: '#F2F2F7',
        textColor: '#000000',
        secondaryTextColor: '#8E8E93'
      };
    }
  }

  /**
   * 判断是否应该使用深色模式
   */
  private static shouldUseDarkMode(mode: ThemeMode): boolean {
    if (mode === ThemeMode.DARK) {
      return true;
    } else if (mode === ThemeMode.LIGHT) {
      return false;
    } else {
      // AUTO模式 - 根据系统时间判断
      const hour = new Date().getHours();
      return hour < 6 || hour >= 18; // 晚6点到早6点使用深色
    }
  }

  /**
   * 获取主题图标
   */
  static getThemeIcon(mode: ThemeMode): string {
    switch (mode) {
      case ThemeMode.LIGHT: return '☀️';
      case ThemeMode.DARK: return '🌙';
      case ThemeMode.AUTO: return '🔄';
      default: return '🔄';
    }
  }

  /**
   * 获取主题名称
   */
  static getThemeName(mode: ThemeMode): string {
    switch (mode) {
      case ThemeMode.LIGHT: return '浅色';
      case ThemeMode.DARK: return '深色';
      case ThemeMode.AUTO: return '自动';
      default: return '自动';
    }
  }
}