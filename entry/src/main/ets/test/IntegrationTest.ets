import { appState } from '../common/AppState';
import { UserService } from '../service/UserService';
import { AnalyticsService } from '../service/AnalyticsService';
import { PerformanceService } from '../service/PerformanceService';
import { UpdateService } from '../service/UpdateService';
import { AppConfigService } from '../service/AppConfigService';
import { FavoriteService } from '../service/FavoriteService';
import { HistoryService } from '../service/HistoryService';

/**
 * 综合集成测试套件
 */
export class IntegrationTest {
  private static testResults: TestResult[] = [];

  // 测试结果接口
  interface TestResult {
    testName: string;
    passed: boolean;
    message: string;
    duration: number;
    timestamp: number;
  }

  // 运行所有测试
  static async runAllTests(): Promise<TestSuiteResult> {
    PerformanceService.startLaunchTimer();
    const startTime = Date.now();
    
    const tests = [
      { name: '用户服务测试', fn: () => this.testUserService() },
      { name: '收藏服务测试', fn: () => this.testFavoriteService() },
      { name: '历史服务测试', fn: () => this.testHistoryService() },
      { name: '分析服务测试', fn: () => this.testAnalyticsService() },
      { name: '配置服务测试', fn: () => this.testAppConfigService() },
      { name: '更新服务测试', fn: () => this.testUpdateService() },
      { name: '性能服务测试', fn: () => this.testPerformanceService() },
      { name: '应用状态测试', fn: () => this.testAppState() }
    ];

    for (const test of tests) {
      await this.runSingleTest(test.name, test.fn);
    }

    const endTime = Date.now();
    const totalDuration = endTime - startTime;

    return {
      totalTests: tests.length,
      passed: this.testResults.filter(r => r.passed).length,
      failed: this.testResults.filter(r => !r.passed).length,
      duration: totalDuration,
      results: this.testResults,
      timestamp: endTime
    };
  }

  // 运行单个测试
  private static async runSingleTest(testName: string, testFn: () => Promise<void>): Promise<void> {
    const startTime = Date.now();
    try {
      await testFn();
      const duration = Date.now() - startTime;
      this.testResults.push({
        testName,
        passed: true,
        message: '测试通过',
        duration,
        timestamp: startTime
      });
    } catch (error) {
      const duration = Date.now() - startTime;
      this.testResults.push({
        testName,
        passed: false,
        message: error.message || '测试失败',
        duration,
        timestamp: startTime
      });
    }
  }

  // 用户服务测试
  private static async testUserService(): Promise<void> {
    // 测试登录状态检查
    const isLoggedIn = await UserService.isLoggedIn();
    if (typeof isLoggedIn !== 'boolean') {
      throw new Error('登录状态检查返回无效值');
    }

    // 测试演示登录
    const loginResult = await UserService.login('demo', '123456');
    if (!loginResult.success) {
      throw new Error('演示登录失败');
    }

    // 测试获取当前用户
    const user = await UserService.getCurrentUser();
    if (!user || !user.username) {
      throw new Error('获取用户信息失败');
    }

    // 测试登出
    await UserService.logout();
  }

  // 收藏服务测试
  private static async testFavoriteService(): Promise<void> {
    const testItem = {
      id: 'test_fav_001',
      title: '测试收藏',
      subtitle: '测试副标题',
      sourceId: 'test_source_001',
      category: 'movie',
      createdAt: Date.now(),
      updatedAt: Date.now()
    };

    // 测试添加收藏
    const addResult = await FavoriteService.addToFavorites(testItem);
    if (!addResult) {
      throw new Error('添加收藏失败');
    }

    // 测试获取收藏
    const favorites = await FavoriteService.getFavorites();
    if (!Array.isArray(favorites)) {
      throw new Error('获取收藏列表失败');
    }

    // 测试是否已收藏
    const isFavorited = await FavoriteService.isFavorited('test_fav_001');
    if (!isFavorited) {
      throw new Error('收藏状态检查失败');
    }

    // 测试删除收藏
    const removeResult = await FavoriteService.removeFromFavorites('test_fav_001');
    if (!removeResult) {
      throw new Error('删除收藏失败');
    }
  }

  // 历史服务测试
  private static async testHistoryService(): Promise<void> {
    const testItem = {
      id: 'test_hist_001',
      title: '测试历史',
      sourceId: 'test_source_001',
      timestamp: Date.now(),
      duration: 3600,
      playCount: 1
    };

    // 测试添加历史记录
    const addResult = await HistoryService.addToHistory(testItem);
    if (!addResult) {
      throw new Error('添加历史记录失败');
    }

    // 测试获取历史记录
    const history = await HistoryService.getHistory();
    if (!Array.isArray(history)) {
      throw new Error('获取历史记录失败');
    }

    // 测试清空历史记录
    const clearResult = await HistoryService.clearHistory();
    if (!clearResult) {
      throw new Error('清空历史记录失败');
    }
  }

  // 分析服务测试
  private static async testAnalyticsService(): Promise<void> {
    // 测试获取使用统计
    const stats = await AnalyticsService.getUsageStats();
    if (!stats || typeof stats !== 'object') {
      throw new Error('获取使用统计失败');
    }

    // 测试获取观看趋势
    const trends = await AnalyticsService.getWatchTrends(7);
    if (!Array.isArray(trends)) {
      throw new Error('获取观看趋势失败');
    }

    // 测试获取推荐
    const recommendations = await AnalyticsService.getRecommendations();
    if (!Array.isArray(recommendations)) {
      throw new Error('获取推荐失败');
    }
  }

  // 配置服务测试
  private static async testAppConfigService(): Promise<void> {
    // 测试获取配置
    const config = await AppConfigService.getConfig();
    if (!config || typeof config !== 'object') {
      throw new Error('获取配置失败');
    }

    // 测试保存配置
    const saveResult = await AppConfigService.saveConfig({ debugMode: true });
    if (!saveResult) {
      throw new Error('保存配置失败');
    }

    // 测试获取单项配置
    const debugMode = await AppConfigService.getConfigItem('debugMode');
    if (typeof debugMode !== 'boolean') {
      throw new Error('获取单项配置失败');
    }
  }

  // 更新服务测试
  private static async testUpdateService(): Promise<void> {
    // 测试获取当前版本
    const version = UpdateService.getCurrentVersion();
    if (!version || typeof version !== 'string') {
      throw new Error('获取版本失败');
    }

    // 测试检查更新
    const updateResult = await UpdateService.checkForUpdates();
    if (!updateResult || typeof updateResult !== 'object') {
      throw new Error('检查更新失败');
    }

    // 测试获取更新日志
    const changelog = UpdateService.getChangelog();
    if (!Array.isArray(changelog)) {
      throw new Error('获取更新日志失败');
    }
  }

  // 性能服务测试
  private static async testPerformanceService(): Promise<void> {
    // 测试启动计时器
    PerformanceService.startLaunchTimer();
    
    // 测试记录页面加载时间
    PerformanceService.recordPageLoad('test_page', 250);
    
    // 测试记录API调用时间
    PerformanceService.recordApiCall('test_api', 150);
    
    // 测试获取性能报告
    const report = PerformanceService.getPerformanceReport();
    if (!report || typeof report !== 'string') {
      throw new Error('获取性能报告失败');
    }

    // 测试获取优化建议
    const suggestions = PerformanceService.getOptimizationSuggestions();
    if (!Array.isArray(suggestions)) {
      throw new Error('获取优化建议失败');
    }
  }

  // 应用状态测试
  private static async testAppState(): Promise<void> {
    // 测试导航方法
    appState.openHome();
    appState.openSearch();
    appState.openFavorites();
    appState.openSettings();
    appState.openAnalytics();

    // 测试主题切换
    await appState.toggleTheme();

    // 测试错误处理
    appState.setError('测试错误信息');
    if (appState.error !== '测试错误信息') {
      throw new Error('错误处理失败');
    }
    appState.clearError();

    // 测试加载状态
    appState.setLoading(true);
    if (!appState.isLoading) {
      throw new Error('加载状态设置失败');
    }
    appState.setLoading(false);
  }

  // 获取测试结果摘要
  static getTestSummary(): string {
    const total = this.testResults.length;
    const passed = this.testResults.filter(r => r.passed).length;
    const failed = total - passed;
    
    let summary = `🧪 测试结果摘要\n`;
    summary += `总测试数: ${total}\n`;
    summary += `通过: ${passed} ✅\n`;
    summary += `失败: ${failed} ❌\n`;
    summary += `成功率: ${total > 0 ? Math.round((passed/total)*100) : 0}%\n\n`;
    
    if (failed > 0) {
      summary += `❌ 失败的测试:\n`;
      this.testResults.filter(r => !r.passed).forEach(result => {
        summary += `  - ${result.testName}: ${result.message}\n`;
      });
    }
    
    return summary;
  }
}

// 测试结果接口
interface TestSuiteResult {
  totalTests: number;
  passed: number;
  failed: number;
  duration: number;
  results: TestResult[];
  timestamp: number;
}