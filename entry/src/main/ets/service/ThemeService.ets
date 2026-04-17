import { preferences } from '@kit.ArkData';
import { Color } from '@ohos.arkui.ArkUI';

/**
 * 主题服务 - 提供个性化主题定制功能
 */
export class ThemeService {
  private static readonly THEME_KEY = 'app_theme';
  private static readonly CUSTOM_COLORS_KEY = 'custom_colors';

  // 预设主题
  static readonly themes = {
    light: {
      name: '浅色主题',
      colors: {
        primary: '#007AFF',
        secondary: '#34C759',
        background: '#FFFFFF',
        surface: '#F2F2F7',
        card: '#FFFFFF',
        text: '#000000',
        textSecondary: '#666666',
        border: '#E5E5EA',
        shadow: '#00000020'
      }
    },
    dark: {
      name: '深色主题',
      colors: {
        primary: '#0A84FF',
        secondary: '#30D158',
        background: '#000000',
        surface: '#1C1C1E',
        card: '#2C2C2E',
        text: '#FFFFFF',
        textSecondary: '#8E8E93',
        border: '#38383A',
        shadow: '#00000040'
      }
    },
    blue: {
      name: '海洋蓝',
      colors: {
        primary: '#007AFF',
        secondary: '#5856D6',
        background: '#F0F8FF',
        surface: '#E6F3FF',
        card: '#FFFFFF',
        text: '#1D1D1F',
        textSecondary: '#636366',
        border: '#B3D9FF',
        shadow: '#007AFF20'
      }
    },
    green: {
      name: '森林绿',
      colors: {
        primary: '#34C759',
        secondary: '#30D158',
        background: '#F0FFF4',
        surface: '#E6F7ED',
        card: '#FFFFFF',
        text: '#1D1D1F',
        textSecondary: '#636366',
        border: '#B3E5B3',
        shadow: '#34C75920'
      }
    },
    purple: {
      name: '优雅紫',
      colors: {
        primary: '#AF52DE',
        secondary: '#BF5AF2',
        background: '#FAF5FF',
        surface: '#F5EDFF',
        card: '#FFFFFF',
        text: '#1D1D1F',
        textSecondary: '#636366',
        border: '#D9CAFF',
        shadow: '#AF52DE20'
      }
    }
  };

  // 获取当前主题
  static async getCurrentTheme(): Promise<typeof ThemeService.themes.light> {
    try {
      const savedTheme = await preferences.getPreferencesValue('com.suyizhang.tvbox', this.THEME_KEY, 'light');
      return this.themes[savedTheme as keyof typeof this.themes] || this.themes.light;
    } catch (error) {
      console.error('Get current theme failed:', error);
      return this.themes.light;
    }
  }

  // 设置主题
  static async setTheme(themeName: keyof typeof ThemeService.themes): Promise<boolean> {
    try {
      await preferences.setPreferencesValue('com.suyizhang.tvbox', this.THEME_KEY, themeName);
      this.applyThemeToSystem(themeName);
      return true;
    } catch (error) {
      console.error('Set theme failed:', error);
      return false;
    }
  }

  // 获取自定义颜色
  static async getCustomColors(): Promise<Record<string, string>> {
    try {
      const colors = await preferences.getPreferencesValue('com.suyizhang.tvbox', this.CUSTOM_COLORS_KEY, '{}');
      return JSON.parse(colors as string);
    } catch (error) {
      return {};
    }
  }

  // 设置自定义颜色
  static async setCustomColor(colorKey: string, colorValue: string): Promise<boolean> {
    try {
      const currentColors = await this.getCustomColors();
      currentColors[colorKey] = colorValue;
      await preferences.setPreferencesValue('com.suyizhang.tvbox', this.CUSTOM_COLORS_KEY, JSON.stringify(currentColors));
      return true;
    } catch (error) {
      return false;
    }
  }

  // 重置为默认主题
  static async resetToDefault(): Promise<boolean> {
    try {
      await preferences.deletePreferences('com.suyizhang.tvbox', [this.THEME_KEY, this.CUSTOM_COLORS_KEY]);
      this.applyThemeToSystem('light');
      return true;
    } catch (error) {
      return false;
    }
  }

  // 应用主题到系统
  private static applyThemeToSystem(themeName: keyof typeof ThemeService.themes): void {
    const theme = this.themes[themeName];
    if (!theme) return;

    // 在实际项目中，这里会通过AppStorage或全局状态管理来应用主题
    console.log(`Applying theme: ${theme.name}`, theme.colors);
    
    // 发送主题变更事件
    AppStorage.SetOrCreate('currentTheme', theme);
  }

  // 获取主题列表
  static getAvailableThemes() {
    return Object.entries(this.themes).map(([key, theme]) => ({
      key,
      name: theme.name,
      preview: theme.colors.primary
    }));
  }

  // 创建渐变色
  static createGradient(startColor: string, endColor: string, direction: 'horizontal' | 'vertical' = 'horizontal'): string {
    return `linear-gradient(${direction === 'horizontal' ? '90deg' : '180deg'}, ${startColor}, ${endColor})`;
  }

  // 计算对比色
  static getContrastColor(hexColor: string): string {
    // 移除#号
    const hex = hexColor.replace('#', '');
    
    // 转换为RGB
    const r = parseInt(hex.substr(0, 2), 16);
    const g = parseInt(hex.substr(2, 2), 16);
    const b = parseInt(hex.substr(4, 2), 16);
    
    // 计算亮度（YIQ公式）
    const brightness = (r * 299 + g * 587 + b * 114) / 1000;
    
    return brightness > 128 ? '#000000' : '#FFFFFF';
  }
}