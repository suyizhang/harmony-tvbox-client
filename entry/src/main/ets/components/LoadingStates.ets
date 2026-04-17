// 统一加载状态组件
@Component
export struct UnifiedLoading {
  @Prop message: string = '加载中...'
  @Prop showProgress: boolean = true
  @Prop size: 'small' | 'medium' | 'large' = 'medium'
  
  private getSizeValue(): number {
    switch (this.size) {
      case 'small': return 24
      case 'large': return 48
      default: return 36
    }
  }
  
  build() {
    Column({ space: 12 }) {
      if (this.showProgress) {
        LoadingProgress.create()
          .width(this.getSizeValue())
          .height(this.getSizeValue())
          .color('#007AFF')
      } else {
        // 自定义加载动画
        Text('⏳')
          .fontSize(this.getSizeValue())
          .animation({ duration: 1000, curve: Curve.Linear, iterations: -1 })
          .rotate({ angle: 360 })
      }
      
      Text(this.message)
        .fontSize(14)
        .fontColor('#666666')
    }
    .alignItems(HorizontalAlign.Center)
    .padding(20)
  }
}

// 错误状态组件
@Component
export struct ErrorState {
  @Prop title: string = '出错了'
  @Prop message: string = '发生未知错误'
  @Prop showRetry: boolean = true
  @Prop onRetry?: () => void
  
  build() {
    Column({ space: 16 }) {
      Text('❌')
        .fontSize(48)
      
      Text(this.title)
        .fontSize(18)
        .fontWeight(FontWeight.Medium)
        .fontColor('#FF3B30')
      
      Text(this.message)
        .fontSize(14)
        .fontColor('#666666')
        .textAlign(TextAlign.Center)
        .maxLines(3)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
      
      if (this.showRetry && this.onRetry) {
        Button('重试', { type: ButtonType.Normal })
          .width(120)
          .height(36)
          .backgroundColor('#007AFF')
          .onClick(() => this.onRetry!())
      }
    }
    .alignItems(HorizontalAlign.Center)
    .padding(32)
  }
}

// 空状态组件
@Component
export struct EmptyState {
  @Prop icon: string = '📭'
  @Prop title: string = '暂无数据'
  @Prop description: string = '没有找到相关内容'
  @Prop showAction: boolean = false
  @Prop actionText?: string
  @Prop onAction?: () => void
  
  build() {
    Column({ space: 16 }) {
      Text(this.icon)
        .fontSize(64)
      
      Text(this.title)
        .fontSize(18)
        .fontWeight(FontWeight.Medium)
        .fontColor('#333333')
      
      Text(this.description)
        .fontSize(14)
        .fontColor('#666666')
        .textAlign(TextAlign.Center)
      
      if (this.showAction && this.actionText && this.onAction) {
        Button(this.actionText, { type: ButtonType.Normal })
          .width(140)
          .height(36)
          .backgroundColor('#007AFF')
          .onClick(() => this.onAction!())
      }
    }
    .alignItems(HorizontalAlign.Center)
    .padding(32)
  }
}