import { FavoriteItem, FavoriteCategory } from './FavoriteService';
import { AppState } from '../common/AppState';
import { fileIo } from '@kit.CoreFileKit';
import { common } from '@kit.AbilityKit';

/**
 * 收藏导入导出服务
 */
export class FavoriteImportExportService {
  private static readonly FILE_NAMES = {
    favorites: 'favorites.json',
    backup: 'favorites_backup_{timestamp}.json',
    export: 'favorites_export_{timestamp}.json'
  };

  /**
   * 导出收藏到JSON文件
   */
  static async exportFavorites(appState: AppState): Promise<string | null> {
    try {
      const exportData = {
        version: '1.0',
        exportTime: new Date().toISOString(),
        totalCount: appState.favorites.length,
        categories: appState.favoriteStats,
        favorites: appState.favorites.map(fav => ({
          id: fav.id,
          title: fav.title,
          category: fav.category,
          tags: fav.tags,
          addedTime: fav.addedTime,
          playCount: fav.playCount,
          lastPlayTime: fav.lastPlayTime,
          sourceInfo: fav.sourceInfo,
          description: fav.description,
          rating: fav.rating,
          notes: fav.notes
        }))
      };

      const jsonString = JSON.stringify(exportData, null, 2);
      const fileName = `favorites_export_${Date.now()}.json`;
      
      // 在实际HarmonyOS应用中，这里会使用文件选择器让用户选择保存位置
      // 现在我们先返回JSON字符串供下载使用
      return jsonString;
    } catch (error) {
      console.error('Export favorites failed:', error);
      return null;
    }
  }

  /**
   * 从JSON字符串导入收藏
   */
  static async importFavoritesFromJson(
    jsonString: string,
    appState: AppState,
    mergeMode: 'replace' | 'merge' = 'merge'
  ): Promise<{ success: boolean; imported: number; skipped: number; errors: string[] }> {
    try {
      const importData = JSON.parse(jsonString);
      
      // 验证数据格式
      if (!importData.favorites || !Array.isArray(importData.favorites)) {
        throw new Error('Invalid import file format');
      }

      const errors: string[] = [];
      let imported = 0;
      let skipped = 0;

      if (mergeMode === 'replace') {
        // 替换模式：清空现有收藏
        appState.favorites = [];
        appState.favoriteStats = {};
      }

      // 导入每个收藏项
      for (const favData of importData.favorites) {
        try {
          // 检查是否已存在相同ID的收藏
          const existingIndex = appState.favorites.findIndex(f => f.id === favData.id);
          
          if (existingIndex >= 0 && mergeMode === 'merge') {
            // 合并模式：跳过已存在的项目
            skipped++;
            continue;
          }

          // 创建新的收藏项
          const newFavorite: FavoriteItem = {
            id: favData.id,
            title: favData.title || '未知标题',
            category: favData.category || FavoriteCategory.OTHER,
            tags: favData.tags || [],
            addedTime: favData.addedTime || Date.now(),
            playCount: favData.playCount || 0,
            lastPlayTime: favData.lastPlayTime || 0,
            sourceInfo: favData.sourceInfo || {},
            description: favData.description || '',
            rating: favData.rating || 0,
            notes: favData.notes || ''
          };

          if (existingIndex >= 0 && mergeMode === 'replace') {
            // 替换模式：覆盖现有项目
            appState.favorites[existingIndex] = newFavorite;
          } else {
            // 添加新模式：追加新项目
            appState.favorites.push(newFavorite);
          }

          // 更新分类统计
          const category = newFavorite.category;
          appState.favoriteStats[category] = (appState.favoriteStats[category] || 0) + 1;
          
          imported++;
        } catch (itemError) {
          errors.push(`导入项目 ${favData.title || favData.id} 失败: ${itemError}`);
        }
      }

      // 保存更新后的收藏
      appState.saveFavorites();
      
      return {
        success: true,
        imported,
        skipped,
        errors
      };
    } catch (error) {
      console.error('Import favorites failed:', error);
      return {
        success: false,
        imported: 0,
        skipped: 0,
        errors: [`导入失败: ${error}`]
      };
    }
  }

  /**
   * 创建备份文件
   */
  static async createBackup(appState: AppState): Promise<string | null> {
    try {
      const backupData = {
        version: '1.0',
        backupTime: new Date().toISOString(),
        appVersion: '1.0.0',
        favorites: appState.favorites,
        stats: appState.favoriteStats
      };

      return JSON.stringify(backupData, null, 2);
    } catch (error) {
      console.error('Create backup failed:', error);
      return null;
    }
  }

  /**
   * 从备份文件恢复
   */
  static async restoreFromBackup(
    backupJson: string,
    appState: AppState
  ): Promise<{ success: boolean; restored: number; errors: string[] }> {
    try {
      const backupData = JSON.parse(backupJson);
      
      if (!backupData.favorites || !Array.isArray(backupData.favorites)) {
        throw new Error('Invalid backup file format');
      }

      // 恢复收藏数据
      appState.favorites = backupData.favorites.map((fav: any) => ({
        ...fav,
        addedTime: fav.addedTime || Date.now()
      }));
      
      appState.favoriteStats = backupData.stats || {};
      
      // 重新计算统计
      appState.favoriteStats = {};
      appState.favorites.forEach(fav => {
        appState.favoriteStats[fav.category] = (appState.favoriteStats[fav.category] || 0) + 1;
      });

      appState.saveFavorites();
      
      return {
        success: true,
        restored: appState.favorites.length,
        errors: []
      };
    } catch (error) {
      return {
        success: false,
        restored: 0,
        errors: [`恢复失败: ${error}`]
      };
    }
  }

  /**
   * 生成分享链接 (模拟)
   */
  static generateShareLink(favorites: FavoriteItem[], maxItems: number = 10): string {
    const shareData = {
      type: 'favorite_share',
      timestamp: Date.now(),
      itemCount: favorites.length,
      preview: favorites.slice(0, maxItems).map(fav => ({
        title: fav.title,
        category: fav.category,
        rating: fav.rating
      }))
    };
    
    return btoa(JSON.stringify(shareData));
  }

  /**
   * 解析分享链接 (模拟)
   */
  static parseShareLink(shareLink: string): any {
    try {
      return JSON.parse(atob(shareLink));
    } catch (error) {
      console.error('Parse share link failed:', error);
      return null;
    }
  }
}