import { appState } from '../common/AppState';

/**
 * 性能监控和优化服务
 */
export class PerformanceService {
  private static readonly PERF_KEY = 'performance_metrics';
  private static metrics: PerformanceMetrics = {
    launchTime: 0,
    pageLoadTimes: {},
    memoryUsage: [],
    apiCallTimes: {},
    errorCount: 0
  };

  // 性能数据结构
  interface PerformanceMetrics {
    launchTime: number;
    pageLoadTimes: Record<string, number[]>;
    memoryUsage: number[];
    apiCallTimes: Record<string, number[]>;
    errorCount: number;
    lastOptimization?: number;
  }

  // 启动性能监控
  static startLaunchTimer() {
    PerformanceService.metrics.launchTime = Date.now();
  }

  // 记录页面加载时间
  static recordPageLoad(pageName: string, loadTime: number) {
    if (!PerformanceService.metrics.pageLoadTimes[pageName]) {
      PerformanceService.metrics.pageLoadTimes[pageName] = [];
    }
    PerformanceService.metrics.pageLoadTimes[pageName].push(loadTime);
    
    // 保持最近10次记录
    if (PerformanceService.metrics.pageLoadTimes[pageName].length > 10) {
      PerformanceService.metrics.pageLoadTimes[pageName].shift();
    }
  }

  // 记录API调用时间
  static recordApiCall(apiName: string, callTime: number) {
    if (!PerformanceService.metrics.apiCallTimes[apiName]) {
      PerformanceService.metrics.apiCallTimes[apiName] = [];
    }
    PerformanceService.metrics.apiCallTimes[apiName].push(callTime);
    
    // 保持最近20次记录
    if (PerformanceService.metrics.apiCallTimes[apiName].length > 20) {
      PerformanceService.metrics.apiCallTimes[apiName].shift();
    }
  }

  // 记录错误
  static recordError(errorType: string) {
    PerformanceService.metrics.errorCount++;
    console.warn(`Performance: Error recorded - ${errorType}`);
  }

  // 获取性能报告
  static getPerformanceReport(): string {
    const metrics = PerformanceService.metrics;
    const launchTime = metrics.launchTime ? Date.now() - metrics.launchTime : 0;
    
    let report = `=== 性能报告 ===\n`;
    report += `启动时间: ${launchTime}ms\n`;
    report += `错误总数: ${metrics.errorCount}\n\n`;
    
    // 页面加载统计
    report += `页面加载时间统计:\n`;
    Object.entries(metrics.pageLoadTimes).forEach(([page, times]) => {
      if (times.length > 0) {
        const avg = times.reduce((a, b) => a + b, 0) / times.length;
        const max = Math.max(...times);
        const min = Math.min(...times);
        report += `  ${page}: 平均${avg.toFixed(0)}ms, 最大${max}ms, 最小${min}ms (${times.length}次)\n`;
      }
    });
    
    // API调用统计
    report += `\nAPI调用统计:\n`;
    Object.entries(metrics.apiCallTimes).forEach(([api, times]) => {
      if (times.length > 0) {
        const avg = times.reduce((a, b) => a + b, 0) / times.length;
        report += `  ${api}: 平均${avg.toFixed(0)}ms (${times.length}次)\n`;
      }
    });
    
    return report;
  }

  // 优化建议
  static getOptimizationSuggestions(): string[] {
    const suggestions: string[] = [];
    const metrics = PerformanceService.metrics;
    
    // 检查启动时间
    if (metrics.launchTime > 0) {
      const launchTime = Date.now() - metrics.launchTime;
      if (launchTime > 3000) {
        suggestions.push('启动时间较长，建议延迟加载非关键组件');
      }
    }
    
    // 检查页面加载时间
    Object.entries(metrics.pageLoadTimes).forEach(([page, times]) => {
      if (times.length > 0) {
        const avg = times.reduce((a, b) => a + b, 0) / times.length;
        if (avg > 1000) {
          suggestions.push(`页面 ${page} 加载较慢，建议优化渲染逻辑`);
        }
      }
    });
    
    // 检查错误率
    if (metrics.errorCount > 10) {
      suggestions.push('错误较多，建议加强错误处理和日志记录');
    }
    
    if (suggestions.length === 0) {
      suggestions.push('性能表现良好，继续保持！');
    }
    
    return suggestions;
  }

  // 清理旧数据
  static cleanupOldData() {
    // 清理超过30天的性能数据
    PerformanceService.metrics.memoryUsage = [];
    PerformanceService.metrics.lastOptimization = Date.now();
  }

  // 导出性能数据
  static exportPerformanceData(): string {
    return JSON.stringify(PerformanceService.metrics, null, 2);
  }
}