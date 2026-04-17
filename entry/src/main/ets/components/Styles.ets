// 统一样式组件库
export class AppStyles {
  // 动态颜色 - 将根据主题更新
  static Colors = {
    Primary: '#007AFF',
    Secondary: '#34C759',
    Orange: '#FF9500',
    Red: '#FF3B30',
    Gray: '#8E8E93',
    LightGray: '#F2F2F7',
    DarkGray: '#1C1C1E',
    Background: '#FFFFFF',
    CardBackground: '#FFFFFF'
  }

  // 更新主题颜色
  static updateThemeColors(theme: any) {
    this.Colors.Background = theme.backgroundColor
    this.Colors.CardBackground = theme.surfaceColor
    this.Colors.DarkGray = theme.textColor
    this.Colors.Gray = theme.secondaryTextColor
  }

  // 字体大小
  static readonly FontSizes = {
    LargeTitle: 34,
    Title1: 28,
    Title2: 22,
    Title3: 20,
    Headline: 17,
    Body: 15,
    Callout: 14,
    Subhead: 13,
    Footnote: 12,
    Caption1: 11,
    Caption2: 11
  }

  // 间距
  static readonly Spacing = {
    XXXS: 2,
    XXS: 4,
    XS: 8,
    S: 12,
    M: 16,
    L: 20,
    XL: 24,
    XXL: 32,
    XXXL: 40
  }

  // 圆角
  static readonly Radius = {
    Small: 6,
    Medium: 8,
    Large: 12,
    XL: 16,
    XXL: 20
  }

  // 阴影
  static readonly Shadows = {
    Card: {
      radius: 12,
      color: '#00000010',
      offsetX: 0,
      offsetY: 2,
      blurRadius: 8
    }
  }
}

// 通用组件
@Component
export struct Card {
  @BuilderParam content: () => void

  build() {
    Column() {
      this.content()
    }
    .padding(AppStyles.Spacing.L)
    .backgroundColor(AppStyles.Colors.CardBackground)
    .borderRadius(AppStyles.Radius.Large)
    .shadow(AppStyles.Shadows.Card)
    .width('100%')
  }
}

@Component
export struct PrimaryButton {
  @Prop text: string
  @Prop onClick: () => void
  @Prop disabled: boolean = false

  build() {
    Button(this.text, { type: ButtonType.Normal, stateEffect: true })
      .width('100%')
      .height(48)
      .backgroundColor(this.disabled ? AppStyles.Colors.Gray : AppStyles.Colors.Primary)
      .fontColor('#FFFFFF')
      .fontSize(AppStyles.FontSizes.Headline)
      .borderRadius(AppStyles.Radius.Medium)
      .enabled(!this.disabled)
      .onClick(() => {
        if (!this.disabled) this.onClick()
      })
  }
}

@Component
export struct StatusBadge {
  @Prop text: string
  @Prop type: 'success' | 'warning' | 'error' | 'info' = 'info'

  private getColor(): string {
    switch (this.type) {
      case 'success': return AppStyles.Colors.Secondary
      case 'warning': return AppStyles.Colors.Orange
      case 'error': return AppStyles.Colors.Red
      default: return AppStyles.Colors.Primary
    }
  }

  build() {
    Text(this.text)
      .fontSize(AppStyles.FontSizes.Caption1)
      .fontColor('#FFFFFF')
      .padding({ left: 8, right: 8, top: 4, bottom: 4 })
      .backgroundColor(this.getColor())
      .borderRadius(AppStyles.Radius.Small)
  }
}