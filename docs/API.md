# API Documentation

## Service Layer APIs

### ConfigService

```typescript
class ConfigService {
  // 获取当前配置
  async getCurrentConfig(): Promise<TVBoxConfig>
  
  // 加载远程配置
  async loadRemoteConfig(url: string): Promise<TVBoxConfig>
  
  // 保存配置到本地
  async saveLocalConfig(config: TVBoxConfig): Promise<void>
  
  // 重置为默认配置
  async resetToDefault(): Promise<void>
}
```

### BackendApiService

```typescript
class BackendApiService {
  // 获取数据源列表
  async getDataSources(): Promise<DataSource[]>
  
  // 搜索内容
  async search(keyword: string, filters?: SearchFilter): Promise<SearchResult[]>
  
  // 获取详情
  async getDetail(id: string): Promise<ContentDetail>
  
  // 获取分类列表
  async getCategories(): Promise<Category[]>
}
```

### FavoriteService

```typescript
class FavoriteService {
  // 添加收藏
  async addFavorite(item: ContentItem, category?: string): Promise<void>
  
  // 移除收藏
  async removeFavorite(id: string): Promise<void>
  
  // 获取收藏列表
  async getFavorites(category?: string): Promise<FavoriteItem[]>
  
  // 批量操作
  async batchOperation(operation: BatchOp, ids: string[]): Promise<void>
}
```

## Data Models

### TVBoxConfig
```typescript
interface TVBoxConfig {
  dataSourceUrl?: string;
  apiEndpoint?: string;
  mode: 'local' | 'api' | 'mock';
  theme: 'light' | 'dark' | 'auto';
  autoUpdate: boolean;
  cacheSize: number;
}
```

### ContentItem
```typescript
interface ContentItem {
  id: string;
  title: string;
  description?: string;
  cover?: string;
  category: string;
  tags: string[];
  rating?: number;
  year?: number;
}
```

## Events

- `configChanged` - 配置变更事件
- `favoriteChanged` - 收藏变更事件  
- `themeChanged` - 主题变更事件
- `userLoggedIn` - 用户登录事件