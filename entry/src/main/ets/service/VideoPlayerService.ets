import { media } from '@kit.MediaKit';
import { BusinessError } from '@kit.BasicServicesKit';

/**
 * 视频播放服务
 */
export class VideoPlayerService {
  private player: media.AVPlayer | null = null;
  private currentUrl: string = '';

  /**
   * 初始化播放器
   */
  async initPlayer(): Promise<boolean> {
    try {
      this.player = await media.createAVPlayer();
      return true;
    } catch (error) {
      console.error('Failed to create AVPlayer:', error);
      return false;
    }
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
      
      // 设置播放源
      this.player.url = url;
      
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
  async pause(): Promise<void> {
    if (this.player) {
      await this.player.pause();
    }
  }

  /**
   * 恢复播放
   */
  async resume(): Promise<void> {
    if (this.player) {
      await this.player.play();
    }
  }

  /**
   * 停止播放
   */
  async stop(): Promise<void> {
    if (this.player) {
      await this.player.stop();
      this.player.reset();
    }
  }

  /**
   * 释放播放器资源
   */
  async release(): Promise<void> {
    if (this.player) {
      await this.player.release();
      this.player = null;
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
    return (currentTime / duration) * 100;
  }
}