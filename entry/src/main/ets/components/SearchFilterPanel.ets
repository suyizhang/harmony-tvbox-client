import { SearchFilter } from '../service/SearchService';
import { ButtonType } from '@kit.ArkUI';
import { Color } from '@kit.ArkUI';

@Component
export struct SearchFilterPanel {
  @Link filter: SearchFilter;
  @Link showPanel: boolean;
  private onFilterChange: () => void;

  constructor(onFilterChange: () => void) {
    this.onFilterChange = onFilterChange;
  }

  build() {
    if (!this.showPanel) return null;

    Column({ space: 16 }) {
      // 面板头部
      Row() {
        Text('🔍 高级搜索过滤器')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .layoutWeight(1)
        Button('✕', { type: ButtonType.Normal })
          .onClick(() => this.showPanel = false)
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)

      // 类型过滤
      Column({ space: 8 }) {
        Text('内容类型')
          .fontSize(14)
          .fontWeight(FontWeight.Medium)
        
        Row({ space: 8 }) {
          ForEach(['movie', 'tv', 'anime', 'documentary'], (type: string) => {
            Button(type === 'movie' ? '电影' : 
                   type === 'tv' ? '电视剧' :
                   type === 'anime' ? '动漫' : '纪录片', { type: ButtonType.Normal })
              .fontSize(12)
              .padding({ left: 12, right: 12, top: 6, bottom: 6 })
              .backgroundColor(this.filter.type?.includes(type) ? '#007AFF' : '#f0f0f0')
              .fontColor(this.filter.type?.includes(type) ? '#FFFFFF' : '#000000')
              .onClick(() => this.toggleTypeFilter(type))
          })
        }
      }

      // 年份过滤
      Column({ space: 8 }) {
        Text('年份范围')
          .fontSize(14)
          .fontWeight(FontWeight.Medium)
        
        Row({ space: 8 }) {
          TextInput({ placeholder: '起始年', text: this.filter.year?.min?.toString() || '' })
            .width(80)
            .onChange((value: string) => {
              this.filter.year = this.filter.year || {};
              this.filter.year.min = value ? parseInt(value) : undefined;
            })
          
          Text('-')
            .fontColor(Color.Gray)
          
          TextInput({ placeholder: '结束年', text: this.filter.year?.max?.toString() || '' })
            .width(80)
            .onChange((value: string) => {
              this.filter.year = this.filter.year || {};
              this.filter.year.max = value ? parseInt(value) : undefined;
            })
        }
      }

      // 评分过滤
      Column({ space: 8 }) {
        Text('评分范围')
          .fontSize(14)
          .fontWeight(FontWeight.Medium)
        
        Slider({
          value: this.filter.rating?.min || 0,
          min: 0,
          max: 10,
          step: 0.5
        })
        .width('100%')
        .onChange((value: number) => {
          this.filter.rating = this.filter.rating || {};
          this.filter.rating.min = value;
        })
        
        Text(`最低评分: ${this.filter.rating?.min || 0} 分`)
          .fontSize(12)
          .fontColor(Color.Gray)
      }

      // 操作按钮
      Row({ space: 12 }) {
        Button('应用过滤', { type: ButtonType.Normal })
          .layoutWeight(1)
          .onClick(() => {
            this.onFilterChange();
            this.showPanel = false;
          })
        
        Button('重置', { type: ButtonType.Normal })
          .layoutWeight(1)
          .onClick(() => {
            this.filter = {};
            this.onFilterChange();
          })
      }
    }
    .padding(16)
    .width('100%')
    .backgroundColor('#FFFFFF')
    .borderRadius(12)
    .shadow({ radius: 4, color: '#00000020', offsetX: 0, offsetY: 2 })
  }

  private toggleTypeFilter(type: string): void {
    this.filter.type = this.filter.type || [];
    const index = this.filter.type.indexOf(type);
    if (index > -1) {
      this.filter.type.splice(index, 1);
    } else {
      this.filter.type.push(type);
    }
  }
}