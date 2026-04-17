import { preferences } from '@kit.ArkData';
import { appState } from '../common/AppState';

/**
 * 插件管理器 - 提供插件注册、加载、生命周期管理
 */
export class PluginManager {
  private static plugins: Map<string, Plugin> = new Map();
  private static pluginStates: Map<string, PluginState> = new Map();
  private static readonly PLUGIN_REGISTRY_KEY = 'plugin_registry';

  // 插件接口定义
  export interface Plugin {
    id: string;
    name: string;
    version: string;
    description: string;
    author: string;
    permissions: string[];
    dependencies?: string[];
    
    // 生命周期钩子
    onInstall?(): Promise<boolean>;
    onUninstall?(): Promise<boolean>;
    onEnable?(): Promise<boolean>;
    onDisable?(): Promise<boolean>;
    onUpdate?(oldVersion: string): Promise<boolean>;
    
    // 功能接口
    getComponents?(): PluginComponent[];
    getServices?(): PluginService[];
    getSettings?(): PluginSetting[];
  }

  export interface PluginComponent {
    type: 'page' | 'widget' | 'modal' | 'toolbar';
    name: string;
    component: string;
    route?: string;
    position?: 'home' | 'settings' | 'player' | 'search';
  }

  export interface PluginService {
    name: string;
    methods: string[];
    instance?: any;
  }

  export interface PluginSetting {
    key: string;
    type: 'toggle' | 'select' | 'input' | 'slider';
    label: string;
    description?: string;
    defaultValue?: any;
    options?: Array<{label: string, value: any}>;
    min?: number;
    max?: number;
  }

  export enum PluginState {
    INSTALLED = 'installed',
    ENABLED = 'enabled',
    DISABLED = 'disabled',
    ERROR = 'error'
  }

  // 注册插件
  static async registerPlugin(plugin: Plugin): Promise<boolean> {
    try {
      // 检查依赖
      if (plugin.dependencies) {
        for (const depId of plugin.dependencies) {
          if (!this.plugins.has(depId)) {
            console.error(`Plugin dependency not found: ${depId}`);
            return false;
          }
        }
      }

      // 注册插件
      this.plugins.set(plugin.id, plugin);
      this.pluginStates.set(plugin.id, PluginState.INSTALLED);

      // 保存到注册表
      await this.savePluginRegistry();

      console.log(`Plugin registered: ${plugin.name} v${plugin.version}`);
      return true;
    } catch (error) {
      console.error('Register plugin failed:', error);
      return false;
    }
  }

  // 启用插件
  static async enablePlugin(pluginId: string): Promise<boolean> {
    try {
      const plugin = this.plugins.get(pluginId);
      if (!plugin) {
        console.error(`Plugin not found: ${pluginId}`);
        return false;
      }

      // 执行启用钩子
      if (plugin.onEnable) {
        const success = await plugin.onEnable();
        if (!success) {
          this.pluginStates.set(pluginId, PluginState.ERROR);
          return false;
        }
      }

      this.pluginStates.set(pluginId, PluginState.ENABLED);
      await this.savePluginRegistry();

      // 注册组件和服务
      if (plugin.getComponents) {
        this.registerComponents(pluginId, plugin.getComponents());
      }
      if (plugin.getServices) {
        this.registerServices(pluginId, plugin.getServices());
      }

      appState.status = `插件已启用: ${plugin.name}`;
      return true;
    } catch (error) {
      console.error('Enable plugin failed:', error);
      this.pluginStates.set(pluginId, PluginState.ERROR);
      return false;
    }
  }

  // 禁用插件
  static async disablePlugin(pluginId: string): Promise<boolean> {
    try {
      const plugin = this.plugins.get(pluginId);
      if (!plugin) return false;

      // 执行禁用钩子
      if (plugin.onDisable) {
        await plugin.onDisable();
      }

      this.pluginStates.set(pluginId, PluginState.DISABLED);
      await this.savePluginRegistry();

      // 注销组件和服务
      this.unregisterComponents(pluginId);
      this.unregisterServices(pluginId);

      appState.status = `插件已禁用: ${plugin.name}`;
      return true;
    } catch (error) {
      console.error('Disable plugin failed:', error);
      return false;
    }
  }

  // 卸载插件
  static async uninstallPlugin(pluginId: string): Promise<boolean> {
    try {
      const plugin = this.plugins.get(pluginId);
      if (!plugin) return false;

      // 如果插件已启用，先禁用
      if (this.pluginStates.get(pluginId) === PluginState.ENABLED) {
        await this.disablePlugin(pluginId);
      }

      // 执行卸载钩子
      if (plugin.onUninstall) {
        await plugin.onUninstall();
      }

      // 从注册表中移除
      this.plugins.delete(pluginId);
      this.pluginStates.delete(pluginId);
      await this.savePluginRegistry();

      appState.status = `插件已卸载: ${plugin.name}`;
      return true;
    } catch (error) {
      console.error('Uninstall plugin failed:', error);
      return false;
    }
  }

  // 获取所有插件
  static getAllPlugins(): Array<{plugin: Plugin, state: PluginState}> {
    return Array.from(this.plugins.entries()).map(([id, plugin]) => ({
      plugin,
      state: this.pluginStates.get(id) || PluginState.INSTALLED
    }));
  }

  // 获取启用的插件
  static getEnabledPlugins(): Plugin[] {
    return Array.from(this.plugins.entries())
      .filter(([id]) => this.pluginStates.get(id) === PluginState.ENABLED)
      .map(([, plugin]) => plugin);
  }

  // 检查插件是否已安装
  static isPluginInstalled(pluginId: string): boolean {
    return this.plugins.has(pluginId);
  }

  // 检查插件是否已启用
  static isPluginEnabled(pluginId: string): boolean {
    return this.pluginStates.get(pluginId) === PluginState.ENABLED;
  }

  // 私有方法：保存插件注册表
  private static async savePluginRegistry(): Promise<void> {
    try {
      const registry = {
        plugins: Array.from(this.plugins.entries()),
        states: Array.from(this.pluginStates.entries())
      };
      await preferences.setPreferencesValue(
        'com.suyizhang.tvbox', 
        this.PLUGIN_REGISTRY_KEY, 
        JSON.stringify(registry)
      );
    } catch (error) {
      console.error('Save plugin registry failed:', error);
    }
  }

  // 私有方法：加载插件注册表
  private static async loadPluginRegistry(): Promise<void> {
    try {
      const registryStr = await preferences.getPreferencesValue(
        'com.suyizhang.tvbox', 
        this.PLUGIN_REGISTRY_KEY, 
        '{}'
      );
      const registry = JSON.parse(registryStr as string);
      
      if (registry.plugins) {
        this.plugins = new Map(registry.plugins);
      }
      if (registry.states) {
        this.pluginStates = new Map(registry.states);
      }
    } catch (error) {
      console.error('Load plugin registry failed:', error);
    }
  }

  // 私有方法：注册组件
  private static registerComponents(pluginId: string, components: PluginComponent[]): void {
    // 在实际项目中，这里会将组件注册到路由系统
    console.log(`Registering ${components.length} components for plugin: ${pluginId}`);
  }

  // 私有方法：注册服务
  private static registerServices(pluginId: string, services: PluginService[]): void {
    // 在实际项目中，这里会将服务注册到服务容器
    console.log(`Registering ${services.length} services for plugin: ${pluginId}`);
  }

  // 私有方法：注销组件
  private static unregisterComponents(pluginId: string): void {
    console.log(`Unregistering components for plugin: ${pluginId}`);
  }

  // 私有方法：注销服务
  private static unregisterServices(pluginId: string): void {
    console.log(`Unregistering services for plugin: ${pluginId}`);
  }

  // 初始化插件系统
  static async initialize(): Promise<void> {
    await this.loadPluginRegistry();
    console.log(`Plugin system initialized. Loaded ${this.plugins.size} plugins.`);
  }
}