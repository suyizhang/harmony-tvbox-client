import { BusinessError } from '@kit.BasicServicesKit';

/**
 * 通用工具类库 - 提供项目中常用的工具函数
 */
export class Utils {
  // 日期时间工具
  static formatDate(timestamp: number, format: string = 'YYYY-MM-DD HH:mm:ss'): string {
    const date = new Date(timestamp);
    const map: Record<string, number | string> = {
      YYYY: date.getFullYear(),
      MM: String(date.getMonth() + 1).padStart(2, '0'),
      DD: String(date.getDate()).padStart(2, '0'),
      HH: String(date.getHours()).padStart(2, '0'),
      mm: String(date.getMinutes()).padStart(2, '0'),
      ss: String(date.getSeconds()).padStart(2, '0')
    };
    
    return format.replace(/YYYY|MM|DD|HH|mm|ss/g, match => String(map[match]));
  }

  static timeAgo(timestamp: number): string {
    const now = Date.now();
    const diff = now - timestamp;
    
    const minute = 60 * 1000;
    const hour = 60 * minute;
    const day = 24 * hour;
    const week = 7 * day;
    const month = 30 * day;
    
    if (diff < minute) return '刚刚';
    if (diff < hour) return `${Math.floor(diff / minute)}分钟前`;
    if (diff < day) return `${Math.floor(diff / hour)}小时前`;
    if (diff < week) return `${Math.floor(diff / day)}天前`;
    if (diff < month) return `${Math.floor(diff / week)}周前`;
    return `${Math.floor(diff / month)}个月前`;
  }

  // 字符串工具
  static truncate(str: string, maxLength: number, suffix: string = '...'): string {
    if (str.length <= maxLength) return str;
    return str.substring(0, maxLength - suffix.length) + suffix;
  }

  static capitalize(str: string): string {
    return str.charAt(0).toUpperCase() + str.slice(1).toLowerCase();
  }

  static camelCase(str: string): string {
    return str.replace(/[-_](\w)/g, (_, c) => c.toUpperCase());
  }

  static kebabCase(str: string): string {
    return str.replace(/([a-z0-9]|(?=[A-Z]))([A-Z])/g, '$1-$2').toLowerCase();
  }

  // 数组工具
  static chunk<T>(array: T[], size: number): T[][] {
    const chunks: T[][] = [];
    for (let i = 0; i < array.length; i += size) {
      chunks.push(array.slice(i, i + size));
    }
    return chunks;
  }

  static unique<T>(array: T[]): T[] {
    return [...new Set(array)];
  }

  static shuffle<T>(array: T[]): T[] {
    const shuffled = [...array];
    for (let i = shuffled.length - 1; i > 0; i--) {
      const j = Math.floor(Math.random() * (i + 1));
      [shuffled[i], shuffled[j]] = [shuffled[j], shuffled[i]];
    }
    return shuffled;
  }

  // 对象工具
  static deepClone<T>(obj: T): T {
    if (obj === null || typeof obj !== 'object') return obj;
    if (obj instanceof Date) return new Date(obj.getTime()) as T;
    if (obj instanceof Array) return obj.map(item => this.deepClone(item)) as T;
    
    const cloned = {} as T;
    for (const key in obj) {
      if (obj.hasOwnProperty(key)) {
        cloned[key] = this.deepClone(obj[key]);
      }
    }
    return cloned;
  }

  static omit<T extends Record<string, any>, K extends keyof T>(obj: T, keys: K[]): Omit<T, K> {
    const result = { ...obj };
    keys.forEach(key => delete result[key]);
    return result;
  }

  static pick<T extends Record<string, any>, K extends keyof T>(obj: T, keys: K[]): Pick<T, K> {
    const result = {} as Pick<T, K>;
    keys.forEach(key => {
      if (key in obj) {
        result[key] = obj[key];
      }
    });
    return result;
  }

  // 数字工具
  static clamp(num: number, min: number, max: number): number {
    return Math.min(Math.max(num, min), max);
  }

  static random(min: number, max: number): number {
    return Math.floor(Math.random() * (max - min + 1)) + min;
  }

  static formatFileSize(bytes: number): string {
    if (bytes === 0) return '0 B';
    
    const k = 1024;
    const sizes = ['B', 'KB', 'MB', 'GB'];
    const i = Math.floor(Math.log(bytes) / Math.log(k));
    
    return parseFloat((bytes / Math.pow(k, i)).toFixed(2)) + ' ' + sizes[i];
  }

  static formatDuration(seconds: number): string {
    const hours = Math.floor(seconds / 3600);
    const minutes = Math.floor((seconds % 3600) / 60);
    const secs = seconds % 60;
    
    if (hours > 0) {
      return `${hours}:${String(minutes).padStart(2, '0')}:${String(secs).padStart(2, '0')}`;
    }
    return `${minutes}:${String(secs).padStart(2, '0')}`;
  }

  // 验证工具
  static isValidEmail(email: string): boolean {
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    return emailRegex.test(email);
  }

  static isValidUrl(url: string): boolean {
    try {
      new URL(url);
      return true;
    } catch {
      return false;
    }
  }

  static isEmpty(value: any): boolean {
    if (value == null) return true;
    if (typeof value === 'string') return value.trim().length === 0;
    if (Array.isArray(value)) return value.length === 0;
    if (typeof value === 'object') return Object.keys(value).length === 0;
    return false;
  }

  // 异步工具
  static async sleep(ms: number): Promise<void> {
    return new Promise(resolve => setTimeout(resolve, ms));
  }

  static async retry<T>(
    fn: () => Promise<T>,
    attempts: number = 3,
    delay: number = 1000
  ): Promise<T> {
    try {
      return await fn();
    } catch (error) {
      if (attempts <= 1) throw error;
      await this.sleep(delay);
      return this.retry(fn, attempts - 1, delay * 2);
    }
  }

  // 错误处理
  static handleError(error: any, context: string = ''): string {
    let message = '操作失败';
    
    if (typeof error === 'string') {
      message = error;
    } else if (error instanceof Error) {
      message = error.message;
    } else if (error.code) {
      message = this.getErrorCodeMessage(error.code);
    }
    
    if (context) {
      message = `${context}: ${message}`;
    }
    
    console.error(`[Utils.handleError] ${message}`, error);
    return message;
  }

  private static getErrorCodeMessage(code: string): string {
    const errorCodes: Record<string, string> = {
      'NETWORK_ERROR': '网络连接失败',
      'TIMEOUT_ERROR': '请求超时',
      'AUTH_ERROR': '认证失败',
      'PERMISSION_DENIED': '权限不足',
      'FILE_NOT_FOUND': '文件不存在',
      'INVALID_INPUT': '输入无效'
    };
    return errorCodes[code] || `错误代码: ${code}`;
  }

  // 日志工具
  static log(level: 'debug' | 'info' | 'warn' | 'error', message: string, data?: any): void {
    const timestamp = this.formatDate(Date.now(), 'HH:mm:ss');
    const prefix = `[${timestamp}] [${level.toUpperCase()}]`;
    
    switch (level) {
      case 'debug':
        console.debug(prefix, message, data || '');
        break;
      case 'info':
        console.info(prefix, message, data || '');
        break;
      case 'warn':
        console.warn(prefix, message, data || '');
        break;
      case 'error':
        console.error(prefix, message, data || '');
        break;
    }
  }

  // 性能监控
  static measurePerformance<T>(fn: () => T, label: string = 'Operation'): { result: T; duration: number } {
    const start = performance.now();
    const result = fn();
    const duration = performance.now() - start;
    
    this.log('info', `${label} 耗时: ${duration.toFixed(2)}ms`);
    return { result, duration };
  }

  static async measureAsyncPerformance<T>(
    fn: () => Promise<T>,
    label: string = 'Async Operation'
  ): Promise<{ result: T; duration: number }> {
    const start = performance.now();
    const result = await fn();
    const duration = performance.now() - start;
    
    this.log('info', `${label} 耗时: ${duration.toFixed(2)}ms`);
    return { result, duration };
  }
}

/**
 * 防抖装饰器
 */
export function debounce<T extends (...args: any[]) => any>(
  func: T,
  wait: number
): (...args: Parameters<T>) => void {
  let timeout: number | null = null;
  
  return (...args: Parameters<T>) => {
    if (timeout) {
      clearTimeout(timeout);
    }
    timeout = setTimeout(() => func.apply(null, args), wait) as unknown as number;
  };
}

/**
 * 节流装饰器
 */
export function throttle<T extends (...args: any[]) => any>(
  func: T,
  limit: number
): (...args: Parameters<T>) => void {
  let inThrottle = false;
  
  return (...args: Parameters<T>) => {
    if (!inThrottle) {
      func.apply(null, args);
      inThrottle = true;
      setTimeout(() => inThrottle = false, limit);
    }
  };
}

/**
 * 单例装饰器
 */
export function singleton<T extends new (...args: any[]) => any>(constructor: T) {
  let instance: InstanceType<T>;
  
  return class extends constructor {
    constructor(...args: any[]) {
      super(...args);
      if (instance) {
        return instance;
      }
      instance = this as InstanceType<T>;
    }
  };
}