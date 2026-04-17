import { appState } from '../common/AppState';
import { FavoriteService } from './FavoriteService';
import { HistoryService } from './HistoryService';

/**
 * 数据分析服务
 */
export class AnalyticsService {
  // 获取使用统计
  static async getUsageStats(): Promise<UsageStats> {
    try {
      const favorites = appState.favorites;
      const history = appState.playHistory;
      const sources = appState.sources;
      
      // 计算各类统计数据
      const totalFavorites = favorites.length;
      const totalHistory = history.length;
      const totalSources = sources.length;
      const activeSources = sources.filter(s => s.status === '可用').length;
      
      // 分类统计
      const favoritesByCategory: Record<string, number> = {};
      const historyByDay: Record<string, number> = {};
      const sourceUsage: Record<string, number> = {};
      
      favorites.forEach(fav => {
        const cat = fav.category || 'other';
        favoritesByCategory[cat] = (favoritesByCategory[cat] || 0) + 1;
      });
      
      // 按日期分组历史记录
      history.forEach(item => {
        const date = new Date(item.timestamp).toLocaleDateString();
        historyByDay[date] = (historyByDay[date] || 0) + 1;
      });
      
      // 数据源使用频率
      history.forEach(item => {
        sourceUsage[item.sourceId] = (sourceUsage[item.sourceId] || 0) + 1;
      });
      
      // 计算观看时长统计
      const totalWatchTime = history.reduce((sum, item) => sum + (item.duration || 0), 0);
      const avgWatchTime = history.length > 0 ? totalWatchTime / history.length : 0;
      
      // 最受欢迎的内容
      const popularItems = history
        .sort((a, b) => (b.playCount || 0) - (a.playCount || 0))
        .slice(0, 5);
      
      return {
        overview: {
          totalFavorites,
          totalHistory,
          totalSources,
          activeSources,
          totalWatchTime,
          avgWatchTime
        },
        favoritesByCategory,
        historyByDay,
        sourceUsage,
        popularItems
      };
    } catch (error) {
      console.error('Get usage stats failed:', error);
      return this.getDefaultStats();
    }
  }

  // 获取观看趋势
  static async getWatchTrends(days: number = 7): Promise<WatchTrend[]> {
    try {
      const history = appState.playHistory;
      const trends: WatchTrend[] = [];
      
      for (let i = days - 1; i >= 0; i--) {
        const date = new Date();
        date.setDate(date.getDate() - i);
        const dateStr = date.toLocaleDateString();
        
        const dayHistory = history.filter(item => 
          new Date(item.timestamp).toLocaleDateString() === dateStr
        );
        
        trends.push({
          date: dateStr,
          count: dayHistory.length,
          totalDuration: dayHistory.reduce((sum, item) => sum + (item.duration || 0), 0),
          uniqueSources: new Set(dayHistory.map(item => item.sourceId)).size
        });
      }
      
      return trends;
    } catch (error) {
      console.error('Get watch trends failed:', error);
      return [];
    }
  }

  // 获取推荐内容
  static async getRecommendations(): Promise<Recommendation[]> {
    try {
      const favorites = appState.favorites;
      const history = appState.playHistory;
      
      // 基于收藏历史的简单推荐算法
      const recommendations: Recommendation[] = [];
      
      // 推荐同类别的热门内容
      const categoryCounts: Record<string, number> = {};
      favorites.forEach(fav => {
        const cat = fav.category || 'other';
        categoryCounts[cat] = (categoryCounts[cat] || 0) + 1;
      });
      
      // 找到最受欢迎的类别
      const topCategory = Object.entries(categoryCounts)
        .sort(([,a], [,b]) => b - a)[0]?.[0] || 'movie';
      
      // 模拟推荐内容
      const mockRecommendations = [
        { id: 'rec_001', title: '推荐电影 1', category: 'movie', reason: '基于您的观影历史' },
        { id: 'rec_002', title: '推荐剧集 1', category: 'tv_show', reason: '热门推荐' },
        { id: 'rec_003', title: '推荐动漫 1', category: 'anime', reason: '同类别热门' }
      ];
      
      return mockRecommendations;
    } catch (error) {
      console.error('Get recommendations failed:', error);
      return [];
    }
  }

  // 导出分析报告
  static async exportAnalyticsReport(): Promise<string> {
    try {
      const stats = await this.getUsageStats();
      const trends = await this.getWatchTrends(30);
      const recommendations = await this.getRecommendations();
      
      const report = {
        generatedAt: new Date().toISOString(),
        stats,
        trends,
        recommendations,
        summary: {
          totalItems: stats.overview.totalFavorites + stats.overview.totalHistory,
          engagement: stats.overview.totalHistory > 0 ? '活跃' : '新手',
          topCategory: Object.entries(stats.favoritesByCategory)
            .sort(([,a], [,b]) => b - a)[0]?.[0] || '无'
        }
      };
      
      return JSON.stringify(report, null, 2);
    } catch (error) {
      console.error('Export analytics report failed:', error);
      return '{"error": "生成报告失败"}';
    }
  }

  // 默认统计数据
  private static getDefaultStats(): UsageStats {
    return {
      overview: {
        totalFavorites: 0,
        totalHistory: 0,
        totalSources: 0,
        activeSources: 0,
        totalWatchTime: 0,
        avgWatchTime: 0
      },
      favoritesByCategory: {},
      historyByDay: {},
      sourceUsage: {},
      popularItems: []
    };
  }
}

// 数据类型定义
export interface UsageStats {
  overview: {
    totalFavorites: number;
    totalHistory: number;
    totalSources: number;
    activeSources: number;
    totalWatchTime: number;
    avgWatchTime: number;
  };
  favoritesByCategory: Record<string, number>;
  historyByDay: Record<string, number>;
  sourceUsage: Record<string, number>;
  popularItems: any[];
}

export interface WatchTrend {
  date: string;
  count: number;
  totalDuration: number;
  uniqueSources: number;
}

export interface Recommendation {
  id: string;
  title: string;
  category: string;
  reason: string;
}