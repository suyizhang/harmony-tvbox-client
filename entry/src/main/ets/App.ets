import { AppState } from './common/AppState';
import { AnalyticsService } from './service/AnalyticsService';
import { SearchService } from './service/SearchService';
import { UserService } from './service/UserService';
import { VideoPlayerService } from './service/VideoPlayerService';
import { ThemeService } from './service/ThemeService';
import { PluginManager } from './service/PluginManager';
import { PreferencesUtil } from './common/PreferencesUtil';
import { MainPage } from './pages/MainPage';
import { SettingsPage } from './pages/SettingsPage';
import { AnalyticsPage } from './pages/AnalyticsPage';
import { HistoryPage } from './pages/HistoryPage';
import { SearchPage } from './pages/SearchPage';
import { ThemeSettingsPage } from './pages/ThemeSettingsPage';
import { Column, Text } from '@ohos.arkui.ArkUI';

@Entry
@Component
struct TVBoxApp {
  @State appInitialized: boolean = false;
  @State initializationProgress: string = '正在启动应用...';
  @State errorMessage: string = '';

  async aboutToAppear() {
    await this.initializeApplication();
  }

  async initializeApplication(): Promise<void> {
    try {
      this.initializationProgress = '初始化存储系统...';
      await PreferencesUtil.init();

      this.initializationProgress = '加载用户配置...';
      await UserService.initialize();

      this.initializationProgress = '初始化主题系统...';
      await ThemeService.getCurrentTheme();

      this.initializationProgress = '启动插件系统...';
      await PluginManager.initialize();

      // 注册示例插件
      const { SamplePlugin } = await import('./plugins/SamplePlugin');
      await PluginManager.registerPlugin(SamplePlugin.pluginInfo);
      await PluginManager.enablePlugin('sample_plugin_v1');

      this.initializationProgress = '加载分析数据...';
      await AnalyticsService.recordAppLaunch();

      this.initializationProgress = '初始化播放器服务...';
      await VideoPlayerService.initialize();

      this.initializationProgress = '启动搜索服务...';
      await SearchService.initialize();

      // 模拟启动延迟以展示启动过程
      await new Promise(resolve => setTimeout(resolve, 500));

      this.appInitialized = true;
      AppState.setStatus('应用启动完成');
      
    } catch (error) {
      console.error('Application initialization failed:', error);
      this.errorMessage = `启动失败: ${error}`;
      AppState.setError(`应用启动失败: ${error}`);
    }
  }

  build() {
    Column() {
      if (!this.appInitialized && !this.errorMessage) {
        // 启动加载界面
        Column({ space: 20 }) {
          Text('🦈 HarmonyTVBox')
            .fontSize(32)
            .fontWeight(FontWeight.Bold)
          
          Text(this.initializationProgress)
            .fontSize(16)
            .fontColor('#666666')
          
          // 简单的进度指示器
          Column()
            .width('80%')
            .height(4)
            .backgroundColor('#f0f0f0')
            .borderRadius(2)
            .overlay(
              Column()
                .width('60%') // 模拟进度
                .height(4)
                .backgroundColor('#007AFF')
                .borderRadius(2)
            )
        }
        .width('100%')
        .height('100%')
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
      } else if (this.errorMessage) {
        // 错误界面
        Column({ space: 20 }) {
          Text('❌ 启动失败')
            .fontSize(24)
            .fontColor('#FF3B30')
          
          Text(this.errorMessage)
            .fontSize(16)
            .fontColor('#666666')
            .textAlign(TextAlign.Center)
        }
        .width('100%')
        .height('100%')
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
      } else {
        // 主应用界面
        MainPage()
      }
    }
    .width('100%')
    .height('100%')
    .onAppear(() => {
      console.log('TVBoxApp: Application started successfully');
    })
  }
}