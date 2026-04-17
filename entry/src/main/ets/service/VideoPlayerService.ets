import { media } from '@kit.MediaKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { emitter } from '@kit.BasicServicesKit';
import { common } from '@kit.AbilityKit';

/**
 * 视频播放服务
 */
export class VideoPlayerService {
  private player: media.AVPlayer | null = null;
  private currentUrl: string = '';
  private context: common.Context | null = null;

  constructor(context?: common.Context) {
    this.context = context || null;
  }

  /**
   * 初始化播放器
   */
  async initPlayer(): Promise<boolean> {
    try {
      this.player = await media.createAVPlayer();
      
      // 设置播放器事件监听
      this.setupPlayerListeners();
      
      return true;
    } catch (error) {
      console.error('Failed to create AVPlayer:', error);
      return false;
    }
  }

  /**
   * 设置播放器事件监听
   */
  private setupPlayerListeners(): void {
    if (!this.player) return;

    // 播放状态变化监听
    this.player.on('stateChange', (state) => {
      console.info(`Player state changed to: ${state}`);
      
      // 发送状态变化事件
      emitter.emit({
        eventId: 1,
        priority: emitter.EventPriority.LOW
      }, {
        type: 'player_state_change',
        state: state
      });
    });

    // 播放完成监听
    this.player.on('endOfStream', () => {
      console.info('Playback completed');
      emitter.emit({
        eventId: 2,
        priority: emitter.EventPriority.LOW
      }, {
        type: 'playback_completed'
      });
    });

    // 错误监听
    this.player.on('error', (error: BusinessError) => {
      console.error(`Player error: ${error.code} - ${error.message}`);
      emitter.emit({
        eventId: 3,
        priority: emitter.EventPriority.HIGH
      }, {
        type: 'player_error',
        error: error
      });
    });
  }

  /**
   * 播放视频
   */
  async play(url: string): Promise<boolean> {
    if (!this.player) {
      const initialized = await this.initPlayer();
      if (!initialized) return false;
    }

    try {
      this.currentUrl = url;
      
      // 重置播放器状态
      await this.player.reset();
      
      // 设置播放源
      this.player.url = url;
      
      // 设置媒体类型（自动检测）
      this.player.setMediaSource(this.currentUrl, media.ContentType.VIDEO);
      
      // 准备播放
      await this.player.prepare();
      
      // 开始播放
      await this.player.play();
      
      return true;
    } catch (error) {
      console.error('Failed to play video:', error);
      return false;
    }
  }

  /**
   * 暂停播放
   */
  async pause(): Promise<boolean> {
    if (!this.player) return false;
    
    try {
      await this.player.pause();
      return true;
    } catch (error) {
      console.error('Failed to pause video:', error);
      return false;
    }
  }

  /**
   * 恢复播放
   */
  async resume(): Promise<boolean> {
    if (!this.player) return false;
    
    try {
      await this.player.play();
      return true;
    } catch (error) {
      console.error('Failed to resume video:', error);
      return false;
    }
  }

  /**
   * 停止播放
   */
  async stop(): Promise<boolean> {
    if (!this.player) return false;
    
    try {
      await this.player.stop();
      await this.player.reset();
      return true;
    } catch (error) {
      console.error('Failed to stop video:', error);
      return false;
    }
  }

  /**
   * 跳转到指定时间
   */
  async seekTo(seconds: number): Promise<boolean> {
    if (!this.player) return false;
    
    try {
      await this.player.seek(seconds * 1000); // 转换为毫秒
      return true;
    } catch (error) {
      console.error('Failed to seek video:', error);
      return false;
    }
  }

  /**
   * 设置音量 (0.0 - 1.0)
   */
  async setVolume(volume: number): Promise<boolean> {
    if (!this.player || volume < 0 || volume > 1) return false;
    
    try {
      await this.player.setVolume(volume);
      return true;
    } catch (error) {
      console.error('Failed to set volume:', error);
      return false;
    }
  }

  /**
   * 获取当前播放时间
   */
  getCurrentTime(): number {
    if (!this.player) return 0;
    return this.player.currentTime / 1000; // 转换为秒
  }

  /**
   * 获取视频总时长
   */
  getDuration(): number {
    if (!this.player) return 0;
    return this.player.duration / 1000; // 转换为秒
  }

  /**
   * 释放播放器资源
   */
  async release(): Promise<boolean> {
    if (!this.player) return true;
    
    try {
      await this.player.stop();
      await this.player.release();
      this.player = null;
      return true;
    } catch (error) {
      console.error('Failed to release player:', error);
      return false;
    }
  }

  /**
   * 获取播放状态
   */
  getStatus(): string {
    if (!this.player) return '未初始化';
    
    switch (this.player.state) {
      case 'idle': return '空闲';
      case 'initialized': return '已初始化';
      case 'prepared': return '已准备';
      case 'playing': return '播放中';
      case 'paused': return '已暂停';
      case 'stopped': return '已停止';
      case 'error': return '错误';
      default: return '未知';
    }
  }

  /**
   * 获取播放进度
   */
  getProgress(): number {
    if (!this.player) return 0;
    
    const currentTime = this.player.currentTime;
    const duration = this.player.duration;
    
    if (duration <= 0) return 0;
    return Math.round((currentTime / duration) * 100);
  }

  /**
   * 检查是否正在播放
   */
  isPlaying(): boolean {
    return this.player?.state === 'playing';
  }

  /**
   * 检查是否已暂停
   */
  isPaused(): boolean {
    return this.player?.state === 'paused';
  }

  /**
   * 获取播放器实例（用于高级操作）
   */
  getPlayerInstance(): media.AVPlayer | null {
    return this.player;
  }

  /**
   * 设置播放速度
   */
  async setPlaybackSpeed(speed: number): Promise<boolean> {
    if (!this.player) return false;
    
    try {
      await this.player.setSpeed(speed);
      return true;
    } catch (error) {
      console.error('Failed to set playback speed:', error);
      return false;
    }
  }

  /**
   * 获取支持的播放速度列表
   */
  getSupportedSpeeds(): number[] {
    return [0.5, 0.75, 1.0, 1.25, 1.5, 2.0];
  }
}