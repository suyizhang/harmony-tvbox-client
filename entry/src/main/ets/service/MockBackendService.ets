import { BackendApiService, BackendDetail, BackendPlayResponse, BackendSource } from './BackendApiService';

/**
 * Mock 后端服务 - 模拟真实后端API响应
 */
export class MockBackendService extends BackendApiService {
  private mockSources: BackendSource[] = [
    {
      id: "mock_source_1",
      title: "热门影视",
      subtitle: "最新热门电影电视剧",
      searchable: true
    },
    {
      id: "mock_source_2", 
      title: "动漫天地",
      subtitle: "日本动漫、国漫精选",
      searchable: true
    },
    {
      id: "mock_source_3",
      title: "综艺娱乐",
      subtitle: "搞笑综艺、真人秀",
      searchable: true
    }
  ];

  private mockDetails: Map<string, BackendDetail> = new Map([
    ["movie_001", {
      id: "movie_001",
      title: "流浪地球2",
      description: "太阳即将毁灭，人类在地球表面建造出巨大的推进器，寻找新的家园。然而宇宙之路危机四伏，为了拯救地球，流浪地球时代的年轻人再次挺身而出，展开争分夺秒的生死之战。",
      playUrl: "https://mock-stream.example.com/movie001.mp4"
    }],
    ["movie_002", {
      id: "movie_002", 
      title: "满江红",
      description: "南宋绍兴年间，岳飞死后四年，秦桧率兵与金国会谈。会谈前夜，金国使者死在宰相驻地，所携密信也不翼而飞。一个小兵与亲兵营副统领机缘巧合被裹挟进巨大阴谋之中。",
      playUrl: "https://mock-stream.example.com/movie002.mp4"
    }],
    ["tv_001", {
      id: "tv_001",
      title: "狂飙",
      description: "京海市一线刑警安欣，在与黑恶势力的斗争中，不断遭到保护伞的打击，始终无法将犯罪分子绳之以法。全国政法队伍教育整顿工作开展后，临江省派出指导组入驻京海。",
      playUrl: "https://mock-stream.example.com/tv001.mp4"
    }]
  ]);

  async fetchSources(baseUrl: string): Promise<BackendSource[]> {
    // 模拟网络延迟
    await new Promise(resolve => setTimeout(resolve, 800));
    console.log(`[Mock] Fetching sources from ${baseUrl}`);
    return [...this.mockSources];
  }

  async fetchDetail(baseUrl: string, id: string): Promise<BackendDetail> {
    await new Promise(resolve => setTimeout(resolve, 600));
    console.log(`[Mock] Fetching detail for ${id} from ${baseUrl}`);
    
    const detail = this.mockDetails.get(id);
    if (!detail) {
      throw new Error(`Mock detail not found for id: ${id}`);
    }
    return { ...detail };
  }

  async fetchPlay(baseUrl: string, id: string): Promise<BackendPlayResponse> {
    await new Promise(resolve => setTimeout(resolve, 400));
    console.log(`[Mock] Fetching play url for ${id} from ${baseUrl}`);
    
    const detail = this.mockDetails.get(id);
    if (!detail || !detail.playUrl) {
      throw new Error(`Mock play url not found for id: ${id}`);
    }
    
    return {
      id: id,
      url: detail.playUrl,
      type: "mp4"
    };
  }

  // 添加一些测试方法
  getAvailableIds(): string[] {
    return Array.from(this.mockDetails.keys());
  }

  addMockDetail(detail: BackendDetail) {
    this.mockDetails.set(detail.id, detail);
  }
}