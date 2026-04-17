// 测试运行入口文件
import { IntegrationTest } from './IntegrationTest';

// 运行所有测试并输出结果
async function runTestSuite() {
  console.info('🧪 开始运行综合集成测试套件...');
  
  try {
    const results = await IntegrationTest.runAllTests();
    
    console.info('📊 测试结果汇总:');
    console.info(`总测试数: ${results.totalTests}`);
    console.info(`通过: ${results.passed} ✅`);
    console.info(`失败: ${results.failed} ❌`);
    console.info(`耗时: ${results.duration}ms`);
    console.info(`成功率: ${Math.round((results.passed/results.totalTests)*100)}%`);
    
    if (results.failed > 0) {
      console.error('❌ 失败的测试详情:');
      results.results.filter(r => !r.passed).forEach(result => {
        console.error(`  - ${result.testName}: ${result.message} (${result.duration}ms)`);
      });
    } else {
      console.info('🎉 所有测试通过！');
    }
    
    return results;
  } catch (error) {
    console.error('💥 测试套件运行失败:', error);
    throw error;
  }
}

// 导出运行函数
export { runTestSuite };