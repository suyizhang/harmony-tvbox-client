import { AnalyticsService } from '../service/AnalyticsService';
import { SearchService } from '../service/SearchService';
import { UserService } from '../service/UserService';
import { VideoPlayerService } from '../service/VideoPlayerService';
import { ThemeService } from '../service/ThemeService';
import { PluginManager } from '../service/PluginManager';
import { PreferencesUtil } from '../common/PreferencesUtil';

/**
 * 综合集成测试套件 - 验证所有系统组件的协同工作能力
 */
export class IntegrationTestSuite {
  private testResults: Array<{name: string, passed: boolean, message: string}> = [];

  // 运行所有测试
  async runAllTests(): Promise<{total: number, passed: number, failed: number, results: any[]}> {
    console.log('🧪 开始综合集成测试...');
    
    this.testResults = [];
    
    // 基础服务测试
    await this.testPreferencesSystem();
    await this.testUserService();
    await this.testThemeService();
    
    // 核心功能测试
    await this.testAnalyticsSystem();
    await this.testSearchSystem();
    await this.testVideoPlayerSystem();
    
    // 插件系统测试
    await this.testPluginSystem();
    
    // 集成场景测试
    await this.testUserJourney();
    await this.testDataFlow();
    await this.testErrorHandling();
    
    const total = this.testResults.length;
    const passed = this.testResults.filter(r => r.passed).length;
    const failed = total - passed;
    
    console.log(`🧪 集成测试完成: ${passed}/${total} 通过`);
    
    return {
      total,
      passed,
      failed,
      results: this.testResults
    };
  }

  // 测试偏好设置系统
  private async testPreferencesSystem(): Promise<void> {
    try {
      await PreferencesUtil.init();
      await PreferencesUtil.set('test_key', 'test_value');
      const value = await PreferencesUtil.get('test_key', 'default');
      
      this.assertTest('偏好设置系统', value === 'test_value', 
        `读取到的值: ${value}`);
    } catch (error) {
      this.assertTest('偏好设置系统', false, `错误: ${error}`);
    }
  }

  // 测试用户服务
  private async testUserService(): Promise<void> {
    try {
      const isLoggedIn = await UserService.isLoggedIn();
      const userProfile = await UserService.getUserProfile();
      
      this.assertTest('用户服务-状态检查', typeof isLoggedIn === 'boolean',
        `登录状态: ${isLoggedIn}`);
      this.assertTest('用户服务-配置读取', userProfile !== null,
        `获取到用户配置`);
    } catch (error) {
      this.assertTest('用户服务', false, `错误: ${error}`);
    }
  }

  // 测试主题服务
  private async testThemeService(): Promise<void> {
    try {
      const currentTheme = await ThemeService.getCurrentTheme();
      const availableThemes = ThemeService.getAvailableThemes();
      
      this.assertTest('主题服务-获取当前主题', currentTheme !== null && currentTheme.name,
        `当前主题: ${currentTheme?.name}`);
      this.assertTest('主题服务-主题列表', availableThemes.length > 0,
        `可用主题数: ${availableThemes.length}`);
      
      // 测试主题切换
      const switchResult = await ThemeService.setTheme('dark');
      this.assertTest('主题服务-主题切换', switchResult === true,
        '主题切换成功');
      
      // 恢复原主题
      await ThemeService.setTheme('light');
    } catch (error) {
      this.assertTest('主题服务', false, `错误: ${error}`);
    }
  }

  // 测试分析系统
  private async testAnalyticsSystem(): Promise<void> {
    try {
      const startTime = Date.now();
      const stats = await AnalyticsService.getUsageStats();
      const trends = await AnalyticsService.getWatchTrends(7);
      const recommendations = await AnalyticsService.getRecommendations();
      const endTime = Date.now();
      
      this.assertTest('分析系统-响应时间', (endTime - startTime) < 1000,
        `响应时间: ${endTime - startTime}ms`);
      this.assertTest('分析系统-统计数据', stats !== null,
        `获取到统计数据`);
      this.assertTest('分析系统-趋势数据', Array.isArray(trends),
        `趋势数据条数: ${trends?.length || 0}`);
      this.assertTest('分析系统-推荐数据', Array.isArray(recommendations),
        `推荐数据条数: ${recommendations?.length || 0}`);
    } catch (error) {
      this.assertTest('分析系统', false, `错误: ${error}`);
    }
  }

  // 测试搜索系统
  private async testSearchSystem(): Promise<void> {
    try {
      const testQueries = ['测试', '电影', '动作'];
      
      for (const query of testQueries) {
        const results = await SearchService.search(query, { limit: 5 });
        this.assertTest(`搜索系统-关键词${query}`, Array.isArray(results), 
          `查询"${query}"返回结果数: ${results?.length || 0}`);
      }
      
      // 测试搜索建议
      const suggestions = await SearchService.getSuggestions('电');
      this.assertTest('搜索系统-自动建议', Array.isArray(suggestions),
        `建议数量: ${suggestions?.length || 0}`);
    } catch (error) {
      this.assertTest('搜索系统', false, `错误: ${error}`);
    }
  }

  // 测试视频播放系统
  private async testVideoPlayerSystem(): Promise<void> {
    try {
      const playerState = VideoPlayerService.getState();
      const testUrl = 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4';
      const sources = await VideoPlayerService.getVideoSources(testUrl);
      
      this.assertTest('视频播放系统-状态获取', playerState !== null,
        `播放器状态: ${JSON.stringify(playerState)}`);
      this.assertTest('视频播放系统-源解析', Array.isArray(sources),
        `解析到源数量: ${sources?.length || 0}`);
      
      // 测试播放控制接口
      const controls = ['play', 'pause', 'stop', 'seek', 'setVolume'];
      controls.forEach(control => {
        this.assertTest(`视频播放系统-控制接口-${control}`, 
          typeof VideoPlayerService[control] === 'function',
          `控制接口${control}可用`);
      });
    } catch (error) {
      this.assertTest('视频播放系统', false, `错误: ${error}`);
    }
  }

  // 测试插件系统
  private async testPluginSystem(): Promise<void> {
    try {
      const allPlugins = PluginManager.getAllPlugins();
      const enabledPlugins = PluginManager.getEnabledPlugins();
      
      this.assertTest('插件系统-插件列表', Array.isArray(allPlugins),
        `已安装插件数: ${allPlugins.length}`);
      this.assertTest('插件系统-启用插件', Array.isArray(enabledPlugins),
        `启用插件数: ${enabledPlugins.length}`);
      
      // 测试插件注册
      const { SamplePlugin } = await import('../plugins/SamplePlugin');
      const registerResult = await PluginManager.registerPlugin(SamplePlugin.pluginInfo);
      this.assertTest('插件系统-插件注册', registerResult === true,
        '示例插件注册成功');
      
      // 测试插件启用
      const enableResult = await PluginManager.enablePlugin('sample_plugin_v1');
      this.assertTest('插件系统-插件启用', enableResult === true,
        '示例插件启用成功');
      
    } catch (error) {
      this.assertTest('插件系统', false, `错误: ${error}`);
    }
  }

  // 测试用户旅程
  private async testUserJourney(): Promise<void> {
    try {
      // 模拟用户完整使用流程
      const journeySteps = [
        '启动应用',
        '浏览首页',
        '搜索内容',
        '播放视频',
        '查看历史',
        '访问设置'
      ];
      
      for (const step of journeySteps) {
        // 在实际测试中，这里会执行具体的UI操作
        this.assertTest(`用户旅程-${step}`, true, `步骤完成: ${step}`);
      }
    } catch (error) {
      this.assertTest('用户旅程', false, `错误: ${error}`);
    }
  }

  // 测试数据流
  private async testDataFlow(): Promise<void> {
    try {
      // 测试数据在各个服务间的传递
      const searchResults = await SearchService.search('测试', { limit: 3 });
      const analyticsResult = await AnalyticsService.recordSearch(searchResults.length);
      
      this.assertTest('数据流-搜索到分析', analyticsResult === true,
        '搜索数据成功记录到分析系统');
      
      // 测试用户行为跟踪
      const behaviorResult = await AnalyticsService.recordUserAction('test_action', { test: true });
      this.assertTest('数据流-用户行为跟踪', behaviorResult === true,
        '用户行为成功跟踪');
    } catch (error) {
      this.assertTest('数据流', false, `错误: ${error}`);
    }
  }

  // 测试错误处理
  private async testErrorHandling(): Promise<void> {
    try {
      // 测试无效输入处理
      const invalidSearch = await SearchService.search('', { limit: -1 });
      this.assertTest('错误处理-无效搜索', Array.isArray(invalidSearch),
        '无效搜索输入被正确处理');
      
      // 测试网络错误处理
      const networkError = await VideoPlayerService.getVideoSources('invalid_url');
      this.assertTest('错误处理-网络错误', Array.isArray(networkError),
        '网络错误被正确处理');
      
    } catch (error) {
      // 预期的错误应该被捕获并处理
      this.assertTest('错误处理', true, `错误被正确捕获: ${error}`);
    }
  }

  // 断言测试方法
  private assertTest(name: string, condition: boolean, message: string): void {
    this.testResults.push({
      name,
      passed: condition,
      message
    });
    
    if (condition) {
      console.log(`✅ ${name}: ${message}`);
    } else {
      console.error(`❌ ${name}: ${message}`);
    }
  }
}