import { appState } from '../common/AppState';
import { HistoryItem, HistoryService } from '../service/HistoryService';
import { AppStyles, StatusBadge } from '../components/Styles';
import { UnifiedLoading, ErrorState } from '../components/LoadingStates';
import { router } from '@kit.ArkUI';

@Component
export struct HistoryPage {
  @State historyItems: HistoryItem[] = [];
  @State loading: boolean = true;
  @State error: string = '';
  @State searchText: string = '';

  async aboutToAppear() {
    await this.loadHistory();
  }

  async loadHistory() {
    this.loading = true;
    this.error = '';
    
    try {
      this.historyItems = await HistoryService.getHistory();
      // 按时间倒序排列
      this.historyItems.sort((a, b) => b.timestamp - a.timestamp);
    } catch (err) {
      this.error = `加载历史记录失败: ${err}`;
      console.error('HistoryPage loadHistory error:', err);
    } finally {
      this.loading = false;
    }
  }

  filterHistory(): HistoryItem[] {
    if (!this.searchText.trim()) {
      return this.historyItems;
    }
    
    const searchLower = this.searchText.toLowerCase();
    return this.historyItems.filter(item => 
      item.title.toLowerCase().includes(searchLower) ||
      (item.subtitle && item.subtitle.toLowerCase().includes(searchLower))
    );
  }

  formatTime(timestamp: number): string {
    const date = new Date(timestamp);
    const now = new Date();
    const diffDays = Math.floor((now.getTime() - date.getTime()) / (1000 * 60 * 60 * 24));
    
    if (diffDays === 0) {
      return `今天 ${date.getHours().toString().padStart(2, '0')}:${date.getMinutes().toString().padStart(2, '0')}`;
    } else if (diffDays === 1) {
      return `昨天 ${date.getHours().toString().padStart(2, '0')}:${date.getMinutes().toString().padStart(2, '0')}`;
    } else if (diffDays < 7) {
      const weekdays = ['周日', '周一', '周二', '周三', '周四', '周五', '周六'];
      return `${weekdays[date.getDay()]} ${date.getHours().toString().padStart(2, '0')}:${date.getMinutes().toString().padStart(2, '0')}`;
    } else {
      return `${date.getFullYear()}-${(date.getMonth() + 1).toString().padStart(2, '0')}-${date.getDate().toString().padStart(2, '0')}`;
    }
  }

  build() {
    Column({ space: 16 }) {
      // 顶部导航
      Row() {
        Button('← 返回', { type: ButtonType.Normal })
          .onClick(() => router.back())
          .margin({ right: 16 })
        
        Text('📺 播放历史')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
      }
      .width('100%')
      .justifyContent(FlexAlign.Start)
      .padding(16)

      // 搜索框
      if (this.historyItems.length > 0) {
        Search({ placeholder: '搜索历史记录...' })
          .width('100%')
          .onChange((value: string) => {
            this.searchText = value;
          })
      }

      // 内容区域
      if (this.loading) {
        UnifiedLoading({
          message: '正在加载历史记录...',
          showProgress: true,
          size: 'medium'
        })
      } else if (this.error) {
        ErrorState({
          title: '加载失败',
          message: this.error,
          showRetry: true,
          onRetry: () => this.loadHistory()
        })
      } else {
        Column({ space: 12 }) {
          // 统计信息
          if (this.historyItems.length > 0) {
            Row() {
              Text(`共 ${this.historyItems.length} 条记录`)
                .fontSize(14)
                .fontColor('#666666')
              Button('🗑️ 清空', { type: ButtonType.Normal })
                .margin({ left: 16 })
                .onClick(async () => {
                  await HistoryService.clearHistory();
                  await this.loadHistory();
                })
            }
            .width('100%')
            .justifyContent(FlexAlign.SpaceBetween)
            .padding(8)
            .backgroundColor('#f5f5f5')
            .borderRadius(8)
          }

          // 历史记录列表
          if (this.filterHistory().length === 0) {
            Column() {
              Text(this.searchText ? '🔍 未找到匹配的记录' : '📺 暂无播放历史')
                .fontSize(16)
                .fontColor('#999999')
              if (!this.searchText) {
                Text('开始观看视频后，播放记录将显示在这里')
                  .fontSize(12)
                  .fontColor('#cccccc')
                  .margin({ top: 8 })
              }
            }
            .padding(32)
            .width('100%')
            .height(200)
            .justifyContent(FlexAlign.Center)
            .alignItems(HorizontalAlign.Center)
          } else {
            List({ space: 8 }) {
              ForEach(this.filterHistory(), (item: HistoryItem) => {
                ListItem() {
                  HistoryItemCard({
                    item: item,
                    onPlay: () => this.playItem(item),
                    onRemove: () => this.removeItem(item.id)
                  })
                }
              }, (item: HistoryItem) => item.id)
            }
            .width('100%')
          }
        }
      }
    }
    .width('100%')
    .height('100%')
    .padding(0)
  }

  async playItem(item: HistoryItem) {
    appState.playUrl = item.playUrl;
    appState.selectedSource = {
      id: item.id,
      title: item.title,
      subtitle: item.subtitle,
      raw: { key: item.id }
    };
    router.pushUrl({ url: 'pages/PlayerPage' });
  }

  async removeItem(id: string) {
    await HistoryService.removeFromHistory(id);
    await this.loadHistory();
  }
}

@Component
struct HistoryItemCard {
  private item: HistoryItem;
  private onPlay: () => void;
  private onRemove: () => void;

  build() {
    Row({ space: 12 }) {
      // 缩略图
      if (this.item.thumbnail) {
        Image(this.item.thumbnail)
          .width(80)
          .height(60)
          .objectFit(ImageFit.Cover)
          .borderRadius(4)
      } else {
        Column() {
          Text('🎬')
            .fontSize(24)
        }
        .width(80)
        .height(60)
        .backgroundColor('#f0f0f0')
        .borderRadius(4)
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
      }

      // 内容信息
      Column({ space: 4 }) {
        Text(this.item.title)
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
        
        if (this.item.subtitle) {
          Text(this.item.subtitle)
            .fontSize(12)
            .fontColor('#666666')
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
        }

        Row() {
          Text(this.formatTime(this.item.timestamp))
            .fontSize(10)
            .fontColor('#999999')
          if (this.item.duration) {
            Text(`⏱️ ${Math.floor(this.item.duration/60)}分钟`)
              .fontSize(10)
              .fontColor('#999999')
              .margin({ left: 8 })
          }
          if (this.item.position) {
            Text(`▶️ ${Math.floor(this.item.position/60)}分钟处`)
              .fontSize(10)
              .fontColor('#007AFF')
              .margin({ left: 8 })
          }
        }
      }
      .layoutWeight(1)

      // 操作按钮
      Column({ space: 4 }) {
        Button('▶️', { type: ButtonType.Normal })
          .width(40)
          .height(30)
          .onClick(() => this.onPlay())
        
        Button('🗑️', { type: ButtonType.Normal })
          .width(40)
          .height(30)
          .onClick(() => this.onRemove())
      }
    }
    .padding(12)
    .width('100%')
    .backgroundColor('#ffffff')
    .borderRadius(8)
    .shadow({ radius: 2, color: '#00000010', offsetX: 0, offsetY: 1 })
  }

  private formatTime(timestamp: number): string {
    const date = new Date(timestamp);
    const now = new Date();
    const diffDays = Math.floor((now.getTime() - date.getTime()) / (1000 * 60 * 60 * 24));
    
    if (diffDays === 0) {
      return `今天 ${date.getHours().toString().padStart(2, '0')}:${date.getMinutes().toString().padStart(2, '0')}`;
    } else if (diffDays === 1) {
      return `昨天 ${date.getHours().toString().padStart(2, '0')}:${date.getMinutes().toString().padStart(2, '0')}`;
    } else {
      return `${date.getMonth() + 1}/${date.getDate()}`;
    }
  }
}

// 搜索组件
@Component
struct Search {
  private placeholder: string;
  @Link searchText: string;

  build() {
    Row() {
      Image('data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iMTYiIGhlaWdodD0iMTYiIHZpZXdCb3g9IjAgMCAxNiAxNiIgZmlsbD0ibm9uZSIgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIj4KPGNpcmNsZSBjeD0iOCIgY3k9IjgiIHI9IjciIGZpbGw9IiM5OTk5OTkiLz4KPHBhdGggZD0iTTkuMzUgNy4zNUwxMS43NSA5Ljc1TDE0IDguNUwyMS41IDExTDExLjc1IDE2Ljc1TDEwLjY1IDE1LjY1TDE5IDcuNzVMOS4zNSA3LjM1WiIgZmlsbD0iIzk5OTk5OSIvPgo8L3N2Zz4K')
        .width(16)
        .height(16)
        .margin({ right: 8 })
      
      TextInput({ placeholder: this.placeholder, text: this.searchText })
        .placeholderColor('#999999')
        .fontSize(14)
        .layoutWeight(1)
        .onChange((value: string) => {
          this.searchText = value;
        })
    }
    .padding(12)
    .width('100%')
    .backgroundColor('#f5f5f5')
    .borderRadius(20)
  }
}