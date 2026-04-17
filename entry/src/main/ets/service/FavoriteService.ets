import { preferences } from '@kit.ArkData';
import { BusinessError } from '@kit.BasicServicesKit';

/**
 * 收藏项
 */
export interface FavoriteItem {
  id: string;
  title: string;
  subtitle: string;
  description?: string;
  thumbnail?: string;
  sourceId: string;
  category?: string;
  tags?: string[];
  createdAt: number;
  updatedAt: number;
}

/**
 * 收藏分类
 */
export enum FavoriteCategory {
  MOVIE = 'movie',
  TV_SHOW = 'tv_show',
  ANIME = 'anime',
  VARIETY = 'variety',
  DOCUMENTARY = 'documentary',
  OTHER = 'other'
}

/**
 * 收藏管理服务
 */
export class FavoriteService {
  private static readonly FAVORITES_KEY = 'favorites';
  private static readonly MAX_FAVORITES = 200;

  /**
   * 添加收藏
   */
  static async addToFavorites(item: Omit<FavoriteItem, 'createdAt' | 'updatedAt'>): Promise<boolean> {
    try {
      const favorites = await this.getFavorites();
      
      // 检查是否已收藏
      const existingIndex = favorites.findIndex(f => f.id === item.id);
      
      const now = Date.now();
      if (existingIndex >= 0) {
        // 更新现有收藏
        favorites[existingIndex] = {
          ...favorites[existingIndex],
          ...item,
          updatedAt: now
        };
      } else {
        // 添加新收藏
        if (favorites.length >= this.MAX_FAVORITES) {
          // 移除最旧的收藏
          favorites.sort((a, b) => a.updatedAt - b.updatedAt);
          favorites.shift();
        }
        
        favorites.push({
          ...item,
          createdAt: now,
          updatedAt: now
        });
      }
      
      await preferences.setPreferencesValue(
        'com.suyizhang.tvbox',
        this.FAVORITES_KEY,
        JSON.stringify(favorites)
      );
      
      return true;
    } catch (error) {
      console.error('Failed to add favorite:', error);
      return false;
    }
  }

  /**
   * 移除收藏
   */
  static async removeFromFavorites(id: string): Promise<boolean> {
    try {
      const favorites = await this.getFavorites();
      const filteredFavorites = favorites.filter(f => f.id !== id);
      
      await preferences.setPreferencesValue(
        'com.suyizhang.tvbox',
        this.FAVORITES_KEY,
        JSON.stringify(filteredFavorites)
      );
      
      return true;
    } catch (error) {
      console.error('Failed to remove favorite:', error);
      return false;
    }
  }

  /**
   * 获取所有收藏
   */
  static async getFavorites(): Promise<FavoriteItem[]> {
    try {
      const result = await preferences.getPreferencesValue(
        'com.suyizhang.tvbox',
        this.FAVORITES_KEY,
        '[]'
      );
      return JSON.parse(result as string) as FavoriteItem[];
    } catch (error) {
      console.error('Failed to get favorites:', error);
      return [];
    }
  }

  /**
   * 获取收藏项
   */
  static async getFavorite(id: string): Promise<FavoriteItem | null> {
    try {
      const favorites = await this.getFavorites();
      return favorites.find(f => f.id === id) || null;
    } catch (error) {
      console.error('Failed to get favorite:', error);
      return null;
    }
  }

  /**
   * 检查是否已收藏
   */
  static async isFavorited(id: string): Promise<boolean> {
    try {
      const favorite = await this.getFavorite(id);
      return favorite !== null;
    } catch (error) {
      return false;
    }
  }

  /**
   * 清空所有收藏
   */
  static async clearFavorites(): Promise<boolean> {
    try {
      await preferences.deletePreferences(
        'com.suyizhang.tvbox',
        [this.FAVORITES_KEY]
      );
      return true;
    } catch (error) {
      console.error('Failed to clear favorites:', error);
      return false;
    }
  }

  /**
   * 批量删除收藏
   */
  static async batchDeleteFavorites(ids: string[]): Promise<{ success: number; failed: number }> {
    try {
      const favorites = await this.getFavorites();
      let success = 0;
      let failed = 0;
      
      const filteredFavorites = favorites.filter(fav => {
        if (ids.includes(fav.id)) {
          success++;
          return false;
        } else {
          return true;
        }
      });
      
      await preferences.setPreferencesValue(
        'com.suyizhang.tvbox',
        this.FAVORITES_KEY,
        JSON.stringify(filteredFavorites)
      );
      
      return { success, failed };
    } catch (error) {
      console.error('Batch delete favorites failed:', error);
      return { success: 0, failed: ids.length };
    }
  }

  /**
   * 批量更新收藏分类
   */
  static async batchUpdateCategory(ids: string[], category: FavoriteCategory): Promise<{ success: number; failed: number }> {
    try {
      const favorites = await this.getFavorites();
      let success = 0;
      let failed = 0;
      
      const updatedFavorites = favorites.map(fav => {
        if (ids.includes(fav.id)) {
          success++;
          return { ...fav, category, updatedAt: Date.now() };
        }
        return fav;
      });
      
      await preferences.setPreferencesValue(
        'com.suyizhang.tvbox',
        this.FAVORITES_KEY,
        JSON.stringify(updatedFavorites)
      );
      
      return { success, failed };
    } catch (error) {
      console.error('Batch update category failed:', error);
      return { success: 0, failed: ids.length };
    }
  }

  /**
   * 批量添加标签
   */
  static async batchAddTags(ids: string[], tags: string[]): Promise<{ success: number; failed: number }> {
    try {
      const favorites = await this.getFavorites();
      let success = 0;
      let failed = 0;
      
      const updatedFavorites = favorites.map(fav => {
        if (ids.includes(fav.id)) {
          success++;
          const existingTags = fav.tags || [];
          const newTags = [...new Set([...existingTags, ...tags])]; // 去重合并
          return { ...fav, tags: newTags, updatedAt: Date.now() };
        }
        return fav;
      });
      
      await preferences.setPreferencesValue(
        'com.suyizhang.tvbox',
        this.FAVORITES_KEY,
        JSON.stringify(updatedFavorites)
      );
      
      return { success, failed };
    } catch (error) {
      console.error('Batch add tags failed:', error);
      return { success: 0, failed: ids.length };
    }
  }

  /**
   * 获取收藏统计信息
   */
  static async getFavoriteStats(): Promise<{ 
    total: number; 
    byCategory: Record<string, number>; 
    recentlyAdded: number 
  }> {
    try {
      const favorites = await this.getFavorites();
      const total = favorites.length;
      const byCategory: Record<string, number> = {};
      const oneWeekAgo = Date.now() - (7 * 24 * 60 * 60 * 1000);
      let recentlyAdded = 0;
      
      favorites.forEach(fav => {
        const cat = fav.category || FavoriteCategory.OTHER;
        byCategory[cat] = (byCategory[cat] || 0) + 1;
        if (fav.createdAt > oneWeekAgo) {
          recentlyAdded++;
        }
      });
      
      return { total, byCategory, recentlyAdded };
    } catch (error) {
      console.error('Get favorite stats failed:', error);
      return { total: 0, byCategory: {}, recentlyAdded: 0 };
    }
  }

  /**
   * 按分类获取收藏
   */
  static async getFavoritesByCategory(category: FavoriteCategory): Promise<FavoriteItem[]> {
    try {
      const favorites = await this.getFavorites();
      return favorites.filter(f => f.category === category);
    } catch (error) {
      console.error('Failed to get favorites by category:', error);
      return [];
    }
  }

  /**
   * 获取收藏统计
   */
  static async getStatistics(): Promise<Record<string, number>> {
    try {
      const favorites = await this.getFavorites();
      const stats: Record<string, number> = {};
      
      favorites.forEach(f => {
        const cat = f.category || FavoriteCategory.OTHER;
        stats[cat] = (stats[cat] || 0) + 1;
      });
      
      return stats;
    } catch (error) {
      console.error('Failed to get statistics:', error);
      return {};
    }
  }
}