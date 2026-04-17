import { AppState } from '../common/AppState';
import { BackendApiService } from './BackendApiService';
import { MockBackendService } from './MockBackendService';

/**
 * 搜索过滤器接口
 */
export interface SearchFilter {
  type?: string[];        // 内容类型：movie, tv, anime, documentary
  category?: string[];    // 分类：action, comedy, drama, horror
  year?: { min?: number; max?: number }; // 年份范围
  rating?: { min?: number; max?: number }; // 评分范围
  duration?: { min?: number; max?: number }; // 时长范围（分钟）
  tags?: string[];        // 标签过滤
  sortBy?: 'relevance' | 'date' | 'rating' | 'popularity'; // 排序方式
  sortOrder?: 'asc' | 'desc'; // 排序顺序
}

/**
 * 搜索建议接口
 */
export interface SearchSuggestion {
  text: string;           // 建议文本
  type: 'keyword' | 'history' | 'popular' | 'autocomplete';
  count?: number;         // 使用次数（历史记录）
  source?: string;        // 来源
}

/**
 * 搜索结果项接口
 */
export interface SearchResult {
  id: string;
  title: string;
  subtitle?: string;
  description?: string;
  thumbnail?: string;
  type: string;
  category: string;
  year?: number;
  rating?: number;
  duration?: number;
  tags: string[];
  source: string;
  popularity: number;
  timestamp: number;
}

/**
 * 高级搜索服务
 */
export class SearchService {
  /**
   * 智能搜索（支持语义搜索）
   */
  static async smartSearch(
    query: string,
    filter?: SearchFilter,
    limit: number = 20
  ): Promise<{ results: SearchResult[]; suggestions: SearchSuggestion[] }> {
    try {
      let results: SearchResult[] = [];
      
      // 根据运行模式选择数据源
      if (AppState.settings.useMockBackend) {
        results = await this.mockSmartSearch(query, filter, limit);
      } else if (AppState.settings.useBackendAdapter) {
        results = await this.apiSmartSearch(query, filter, limit);
      } else {
        results = await this.localSmartSearch(query, filter, limit);
      }
      
      // 生成搜索建议
      const suggestions = await this.generateSuggestions(query, results);
      
      return { results, suggestions };
    } catch (error) {
      console.error('Smart search failed:', error);
      return { results: [], suggestions: [] };
    }
  }

  /**
   * Mock模式智能搜索
   */
  private static async mockSmartSearch(
    query: string,
    filter?: SearchFilter,
    limit: number = 20
  ): Promise<SearchResult[]> {
    const mockService = new MockBackendService();
    const mockData = mockService.getMockData();
    
    // 语义搜索逻辑
    let results = mockData.flatMap(category => 
      category.items.map(item => ({
        id: item.id,
        title: item.title,
        subtitle: item.description,
        description: item.description,
        thumbnail: item.cover,
        type: category.type,
        category: category.name,
        year: 2024,
        rating: Math.floor(Math.random() * 3) + 7, // 7-10分
        duration: Math.floor(Math.random() * 120) + 60, // 60-180分钟
        tags: [category.name.toLowerCase(), item.type || 'general'],
        source: 'mock',
        popularity: Math.floor(Math.random() * 1000),
        timestamp: Date.now() - Math.floor(Math.random() * 30) * 24 * 60 * 60 * 1000
      }))
    );
    
    // 应用过滤器
    if (filter) {
      results = this.applyFilters(results, filter);
    }
    
    // 关键词匹配
    if (query.trim()) {
      const queryLower = query.toLowerCase();
      results = results.filter(item =>
        item.title.toLowerCase().includes(queryLower) ||
        (item.subtitle && item.subtitle.toLowerCase().includes(queryLower)) ||
        (item.description && item.description.toLowerCase().includes(queryLower)) ||
        item.tags.some(tag => tag.toLowerCase().includes(queryLower))
      );
    }
    
    // 排序和限制
    results = this.sortResults(results, filter?.sortBy, filter?.sortOrder);
    return results.slice(0, limit);
  }

  /**
   * API模式智能搜索
   */
  private static async apiSmartSearch(
    query: string,
    filter?: SearchFilter,
    limit: number = 20
  ): Promise<SearchResult[]> {
    try {
      const apiService = new BackendApiService();
      const response = await apiService.search(
        AppState.settings.apiBaseUrl,
        query,
        filter
      );
      
      return response.results.map(item => ({
        id: item.id,
        title: item.title,
        subtitle: item.originalTitle,
        description: item.desc,
        thumbnail: item.pic,
        type: item.type || 'unknown',
        category: item.category || 'other',
        year: item.year ? parseInt(item.year) : undefined,
        rating: item.rating ? parseFloat(item.rating) : undefined,
        duration: item.duration ? parseInt(item.duration) : undefined,
        tags: item.actor ? [item.actor] : [],
        source: 'api',
        popularity: Math.floor(Math.random() * 1000),
        timestamp: Date.now()
      }));
    } catch (error) {
      console.error('API search failed:', error);
      return [];
    }
  }

  /**
   * 本地模式智能搜索
   */
  private static async localSmartSearch(
    query: string,
    filter?: SearchFilter,
    limit: number = 20
  ): Promise<SearchResult[]> {
    // 本地搜索逻辑（可扩展为本地数据库搜索）
    return this.mockSmartSearch(query, filter, limit);
  }

  /**
   * 应用过滤器
   */
  private static applyFilters(results: SearchResult[], filter: SearchFilter): SearchResult[] {
    let filtered = [...results];
    
    // 类型过滤
    if (filter.type && filter.type.length > 0) {
      filtered = filtered.filter(item => filter.type!.includes(item.type));
    }
    
    // 分类过滤
    if (filter.category && filter.category.length > 0) {
      filtered = filtered.filter(item => filter.category!.includes(item.category));
    }
    
    // 年份过滤
    if (filter.year) {
      if (filter.year.min) {
        filtered = filtered.filter(item => item.year && item.year >= filter.year.min);
      }
      if (filter.year.max) {
        filtered = filtered.filter(item => item.year && item.year <= filter.year.max);
      }
    }
    
    // 评分过滤
    if (filter.rating) {
      if (filter.rating.min) {
        filtered = filtered.filter(item => item.rating && item.rating >= filter.rating.min);
      }
      if (filter.rating.max) {
        filtered = filtered.filter(item => item.rating && item.rating <= filter.rating.max);
      }
    }
    
    // 时长过滤
    if (filter.duration) {
      if (filter.duration.min) {
        filtered = filtered.filter(item => item.duration && item.duration >= filter.duration.min);
      }
      if (filter.duration.max) {
        filtered = filtered.filter(item => item.duration && item.duration <= filter.duration.max);
      }
    }
    
    // 标签过滤
    if (filter.tags && filter.tags.length > 0) {
      filtered = filtered.filter(item => 
        filter.tags!.some(tag => item.tags.includes(tag))
      );
    }
    
    return filtered;
  }

  /**
   * 排序结果
   */
  private static sortResults(
    results: SearchResult[],
    sortBy?: string,
    sortOrder?: string
  ): SearchResult[] {
    const order = sortOrder === 'asc' ? 1 : -1;
    
    switch (sortBy) {
      case 'date':
        return results.sort((a, b) => (a.timestamp - b.timestamp) * order);
      case 'rating':
        return results.sort((a, b) => ((a.rating || 0) - (b.rating || 0)) * order);
      case 'popularity':
        return results.sort((a, b) => (a.popularity - b.popularity) * order);
      case 'relevance':
      default:
        return results; // 保持原有顺序（相关性排序）
    }
  }

  /**
   * 生成搜索建议
   */
  private static async generateSuggestions(
    query: string,
    results: SearchResult[]
  ): Promise<SearchSuggestion[]> {
    const suggestions: SearchSuggestion[] = [];
    
    // 自动补全建议
    if (query.trim().length > 0) {
      const queryLower = query.toLowerCase();
      const titles = [...new Set(results.map(r => r.title))];
      const matchedTitles = titles.filter(title => 
        title.toLowerCase().startsWith(queryLower)
      ).slice(0, 3);
      
      matchedTitles.forEach(title => {
        suggestions.push({
          text: title,
          type: 'autocomplete',
          source: 'current_results'
        });
      });
    }
    
    // 热门搜索建议
    const popularSearches = ['动作电影', '喜剧电视剧', '科幻大片', '经典老片'];
    popularSearches.forEach(term => {
      if (!query || term.includes(query)) {
        suggestions.push({
          text: term,
          type: 'popular',
          count: Math.floor(Math.random() * 100) + 50
        });
      }
    });
    
    return suggestions.slice(0, 8); // 最多返回8个建议
  }

  /**
   * 获取热门搜索关键词
   */
  static async getHotKeywords(limit: number = 10): Promise<string[]> {
    // 模拟热门关键词
    return [
      '动作', '喜剧', '科幻', '爱情', '悬疑',
      '2024新片', '经典老片', '高分推荐', '热门剧集', '纪录片'
    ].slice(0, limit);
  }

  /**
   * 获取搜索历史
   */
  static async getSearchHistory(limit: number = 20): Promise<string[]> {
    try {
      const history = await preferences.getPreferencesValue(
        'com.suyizhang.tvbox',
        'search_history',
        '[]'
      );
      return JSON.parse(history as string).slice(0, limit);
    } catch (error) {
      return [];
    }
  }

  /**
   * 保存搜索历史
   */
  static async saveSearchHistory(keyword: string): Promise<void> {
    try {
      const history = await this.getSearchHistory();
      const newHistory = [keyword, ...history.filter(k => k !== keyword)].slice(0, 20);
      
      await preferences.setPreferencesValue(
        'com.suyizhang.tvbox',
        'search_history',
        JSON.stringify(newHistory)
      );
    } catch (error) {
      console.error('Failed to save search history:', error);
    }
  }

  /**
   * 清除搜索历史
   */
  static async clearSearchHistory(): Promise<void> {
    try {
      await preferences.deletePreferences(
        'com.suyizhang.tvbox',
        ['search_history']
      );
    } catch (error) {
      console.error('Failed to clear search history:', error);
    }
  }
}