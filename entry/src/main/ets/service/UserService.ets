import { preferences } from '@kit.ArkData';

/**
 * 用户账户服务
 */
export class UserService {
  private static readonly USER_KEY = 'user_account';
  private static readonly TOKEN_KEY = 'auth_token';

  // 用户信息接口
  export interface UserInfo {
    id: string;
    username: string;
    email: string;
    avatar?: string;
    createdAt: number;
    lastLoginAt: number;
    preferences: UserPreferences;
  }

  // 用户偏好设置
  export interface UserPreferences {
    themeMode: 'light' | 'dark' | 'auto';
    language: string;
    autoPlay: boolean;
    defaultCategory: string;
    notifications: boolean;
    syncCollections: boolean;
  }

  // 登录状态
  static async isLoggedIn(): Promise<boolean> {
    try {
      const token = await preferences.getPreferencesValue('com.suyizhang.tvbox', this.TOKEN_KEY, '');
      return !!token;
    } catch (error) {
      return false;
    }
  }

  // 获取当前用户
  static async getCurrentUser(): Promise<UserInfo | null> {
    try {
      const userStr = await preferences.getPreferencesValue('com.suyizhang.tvbox', this.USER_KEY, '');
      return userStr ? JSON.parse(userStr as string) : null;
    } catch (error) {
      console.error('Get current user failed:', error);
      return null;
    }
  }

  // 模拟登录
  static async login(username: string, password: string): Promise<{ success: boolean; user?: UserInfo; error?: string }> {
    try {
      // 模拟API调用
      await new Promise(resolve => setTimeout(resolve, 1000));
      
      if (username === 'demo' && password === '123456') {
        const userInfo: UserInfo = {
          id: 'user_demo_001',
          username: 'demo',
          email: 'demo@example.com',
          avatar: 'https://via.placeholder.com/100x100/007AFF/FFFFFF?text=D',
          createdAt: Date.now() - 86400000 * 30, // 30天前
          lastLoginAt: Date.now(),
          preferences: {
            themeMode: 'auto',
            language: 'zh-CN',
            autoPlay: true,
            defaultCategory: 'movie',
            notifications: true,
            syncCollections: true
          }
        };
        
        // 保存用户信息
        await preferences.setPreferencesValue('com.suyizhang.tvbox', this.USER_KEY, JSON.stringify(userInfo));
        await preferences.setPreferencesValue('com.suyizhang.tvbox', this.TOKEN_KEY, 'mock_jwt_token_demo_user');
        
        return { success: true, user: userInfo };
      } else {
        return { success: false, error: '用户名或密码错误' };
      }
    } catch (error) {
      return { success: false, error: '登录失败' };
    }
  }

  // 登出
  static async logout(): Promise<void> {
    try {
      await preferences.deletePreferences('com.suyizhang.tvbox', [this.USER_KEY, this.TOKEN_KEY]);
    } catch (error) {
      console.error('Logout failed:', error);
    }
  }

  // 更新用户偏好
  static async updatePreferences(preferences_data: Partial<UserPreferences>): Promise<boolean> {
    try {
      const user = await this.getCurrentUser();
      if (!user) return false;
      
      user.preferences = { ...user.preferences, ...preferences_data };
      user.lastLoginAt = Date.now();
      
      await preferences.setPreferencesValue('com.suyizhang.tvbox', this.USER_KEY, JSON.stringify(user));
      return true;
    } catch (error) {
      console.error('Update preferences failed:', error);
      return false;
    }
  }

  // 同步收藏到云端
  static async syncFavoritesToCloud(): Promise<{ success: boolean; synced: number; error?: string }> {
    try {
      const favorites = await FavoriteService.getFavorites();
      const stats = await FavoriteService.getStatistics();
      
      // 模拟API调用到云端
      await new Promise(resolve => setTimeout(resolve, 1500));
      
      // 在实际项目中，这里会调用真实的云端API
      console.log('Syncing to cloud:', { favorites: favorites.length, stats });
      
      return {
        success: true,
        synced: favorites.length,
        error: undefined
      };
    } catch (error) {
      return {
        success: false,
        synced: 0,
        error: '同步失败: ' + error
      };
    }
  }

  // 从云端恢复收藏
  static async restoreFavoritesFromCloud(): Promise<{ success: boolean; restored: number; error?: string }> {
    try {
      // 模拟从云端获取收藏
      await new Promise(resolve => setTimeout(resolve, 2000));
      
      // 模拟恢复的收藏数据
      const mockCloudFavorites = [
        {
          id: 'cloud_fav_001',
          title: '云端电影1',
          subtitle: '来自云端收藏',
          sourceId: 'cloud_source_001',
          category: 'movie',
          createdAt: Date.now() - 86400000,
          updatedAt: Date.now()
        }
      ];
      
      // 添加到本地收藏
      for (const fav of mockCloudFavorites) {
        await FavoriteService.addToFavorites(fav);
      }
      
      return {
        success: true,
        restored: mockCloudFavorites.length,
        error: undefined
      };
    } catch (error) {
      return {
        success: false,
        restored: 0,
        error: '恢复失败: ' + error
      };
    }
  }

  // 从云端恢复收藏 (模拟)
  static async restoreFavoritesFromCloud(): Promise<{ success: boolean; restored: number; error?: string }> {
    try {
      // 模拟恢复过程
      await new Promise(resolve => setTimeout(resolve, 1500));
      
      return {
        success: true,
        restored: 3, // 模拟恢复了3个项目
        error: undefined
      };
    } catch (error) {
      return {
        success: false,
        restored: 0,
        error: '恢复失败'
      };
    }
  }
}