# HarmonyTVBox 部署指南

## 📱 项目概述
HarmonyTVBox 是一个基于 HarmonyOS 的智能电视盒子应用，提供视频播放、搜索、收藏、数据分析等功能，支持插件扩展和主题个性化。

## 🏗️ 技术架构
- **前端框架**: HarmonyOS ArkUI
- **开发语言**: TypeScript/ECMAScript
- **架构模式**: MVVM + 微服务
- **数据存储**: Preferences API + 本地文件
- **插件系统**: 模块化插件架构

## 📋 环境要求

### 开发环境
- **IDE**: DevEco Studio 4.0+
- **SDK**: HarmonyOS SDK API 9+
- **Node.js**: v16+
- **Git**: 2.0+

### 运行环境
- **设备**: HarmonyOS 4.0+ 设备
- **内存**: 至少 128MB 可用内存
- **存储**: 至少 50MB 可用空间

## 🚀 快速开始

### 1. 克隆项目
```bash
 git clone https://github.com/suyizhang/harmony-tvbox-client.git
 cd harmony-tvbox-client
```

### 2. 安装依赖
```bash
# 项目使用纯 TypeScript 开发，无需额外依赖
# 确保 DevEco Studio 已安装相关 SDK
```

### 3. 导入项目
1. 打开 DevEco Studio
2. 选择 "Open" → 选择项目目录
3. 等待依赖解析完成
4. 同步项目配置

### 4. 配置项目
编辑 `entry/src/main/resources/base/profile/configure.json`:
```json
{
  "app": {
    "bundleName": "com.suyizhang.tvbox",
    "vendor": "suyizhang",
    "version": {
      "code": 100,
      "name": "1.0.0"
    }
  }
}
```

### 5. 运行应用
1. 连接 HarmonyOS 设备或启动模拟器
2. 点击 DevEco Studio 的 "Run" 按钮
3. 等待应用编译和安装
4. 在设备上启动应用

## 🔧 功能配置

### 视频源配置
编辑 `entry/src/main/ets/common/AppState.ts`:
```typescript
// 配置视频源
appState.settings.configUrl = "https://your-config-url.com/config.json";
```

### 主题设置
- 进入 "设置" → "主题设置"
- 选择预设主题或自定义颜色
- 实时预览效果

### 插件管理
- 进入 "设置" → "插件管理" → "插件市场"
- 浏览可用插件
- 安装、启用、配置或卸载插件

## 📦 插件开发

### 创建新插件
1. 在 `entry/src/main/ets/plugins/` 创建插件文件
2. 实现 `PluginManager.Plugin` 接口
3. 注册插件组件和服务
4. 在 `PluginIntegrationService` 中集成

### 插件示例结构
```typescript
export class MyPlugin {
  static readonly pluginInfo: PluginManager.Plugin = {
    id: 'my_plugin_v1',
    name: '我的插件',
    version: '1.0.0',
    description: '插件描述',
    author: '开发者名称',
    permissions: ['需要的权限'],
    
    // 生命周期钩子
    async onInstall() { /* 安装逻辑 */ },
    async onEnable() { /* 启用逻辑 */ },
    
    // 组件和服务
    getComponents() { /* 返回UI组件 */ },
    getServices() { /* 返回服务接口 */ },
    getSettings() { /* 返回设置项 */ }
  };
}
```

## 📊 性能优化

### 启动优化
- 使用懒加载减少初始包大小
- 优化图片和资源加载
- 延迟初始化非关键服务

### 内存优化
- 及时释放不用的对象引用
- 使用对象池复用频繁创建的对象
- 监控内存使用，及时GC

### 响应优化
- 使用异步操作避免阻塞UI
- 实现数据缓存减少重复请求
- 优化搜索算法提高响应速度

## 🔍 调试技巧

### 日志查看
```typescript
import { Utils } from '../common/Utils';

Utils.log('info', '应用启动', { version: '1.0.0' });
```

### 性能监控
```typescript
const { result, duration } = Utils.measurePerformance(() => {
  // 要测量的代码
  return heavyComputation();
}, '重计算操作');
```

### 错误追踪
```typescript
try {
  // 可能出错的代码
} catch (error) {
  const message = Utils.handleError(error, '操作名称');
  appState.setError(message);
}
```

## 📈 监控分析

### 用户行为跟踪
- 页面访问统计
- 功能使用频率
- 错误发生情况
- 性能指标监控

### 数据分析
- 观看时长统计
- 内容偏好分析
- 使用趋势预测
- 个性化推荐

## 🚢 发布部署

### 应用打包
1. 在 DevEco Studio 中选择 "Build" → "Build HAP(s)"
2. 生成的 HAP 文件位于 `entry/build/outputs/hap/`
3. 签名应用：`Build` → `Generate Key and CSR`

### 应用发布
1. 登录 [AppGallery Connect](https://developer.huawei.com/consumer/cn/service/josp/agc/index.html)
2. 创建应用并上传 HAP 文件
3. 填写应用信息和截图
4. 提交审核

## 🆘 故障排除

### 常见问题

**Q: 应用启动失败**
A: 检查设备兼容性、权限配置、依赖完整性

**Q: 插件加载失败**
A: 检查插件配置、依赖关系、权限声明

**Q: 主题切换无效**
A: 清除应用缓存、重启应用、检查主题文件

**Q: 搜索无结果**
A: 检查网络连接、搜索配置、数据源状态

### 获取帮助
- 提交 Issue: [GitHub Issues](https://github.com/suyizhang/harmony-tvbox-client/issues)
- 邮件联系: suyizhang@example.com
- 文档中心: [项目 Wiki](https://github.com/suyizhang/harmony-tvbox-client/wiki)

## 📄 许可证

本项目采用 MIT 许可证 - 查看 [LICENSE](LICENSE) 文件了解详情。

## 🙏 致谢

感谢所有为项目贡献代码的开发者和使用者！