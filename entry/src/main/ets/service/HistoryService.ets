import { preferences } from '@kit.ArkData';
import { BusinessError } from '@kit.BasicServicesKit';

/**
 * 播放历史记录项
 */
export interface HistoryItem {
  id: string;
  title: string;
  subtitle: string;
  playUrl: string;
  timestamp: number;
  duration?: number;
  position?: number; // 播放位置（秒）
  thumbnail?: string;
}

/**
 * 历史记录管理服务
 */
export class HistoryService {
  private static readonly HISTORY_KEY = 'play_history';
  private static readonly MAX_HISTORY_ITEMS = 50;

  /**
   * 添加或更新播放历史
   */
  static async addToHistory(item: HistoryItem): Promise<void> {
    try {
      const history = await this.getHistory();
      
      // 移除重复项
      const filteredHistory = history.filter(h => h.id !== item.id);
      
      // 添加新项到开头
      filteredHistory.unshift(item);
      
      // 限制历史记录数量
      if (filteredHistory.length > this.MAX_HISTORY_ITEMS) {
        filteredHistory.splice(this.MAX_HISTORY_ITEMS);
      }
      
      // 保存到偏好设置
      await preferences.setPreferencesValue(
        'com.suyizhang.tvbox',
        this.HISTORY_KEY,
        JSON.stringify(filteredHistory)
      );
    } catch (error) {
      console.error('Failed to add to history:', error);
    }
  }

  /**
   * 获取播放历史
   */
  static async getHistory(): Promise<HistoryItem[]> {
    try {
      const result = await preferences.getPreferencesValue(
        'com.suyizhang.tvbox',
        this.HISTORY_KEY,
        '[]'
      );
      return JSON.parse(result as string) as HistoryItem[];
    } catch (error) {
      console.error('Failed to get history:', error);
      return [];
    }
  }

  /**
   * 删除指定历史记录
   */
  static async removeFromHistory(id: string): Promise<void> {
    try {
      const history = await this.getHistory();
      const filteredHistory = history.filter(h => h.id !== id);
      
      await preferences.setPreferencesValue(
        'com.suyizhang.tvbox',
        this.HISTORY_KEY,
        JSON.stringify(filteredHistory)
      );
    } catch (error) {
      console.error('Failed to remove from history:', error);
    }
  }

  /**
   * 清空所有历史记录
   */
  static async clearHistory(): Promise<void> {
    try {
      await preferences.deletePreferences(
        'com.suyizhang.tvbox',
        [this.HISTORY_KEY]
      );
    } catch (error) {
      console.error('Failed to clear history:', error);
    }
  }

  /**
   * 更新播放位置
   */
  static async updatePlayPosition(id: string, position: number): Promise<void> {
    try {
      const history = await this.getHistory();
      const item = history.find(h => h.id === id);
      if (item) {
        item.position = position;
        item.timestamp = Date.now();
        await this.addToHistory(item);
      }
    } catch (error) {
      console.error('Failed to update play position:', error);
    }
  }
}