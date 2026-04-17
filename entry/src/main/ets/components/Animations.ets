// 动画工具类
export class AnimationUtils {
  // 页面切换动画时长
  static readonly PAGE_TRANSITION_DURATION = 300
  
  // 淡入动画
  static fadeIn(component: any, duration: number = 300) {
    return component.opacity(0)
      .animate({ duration: duration, curve: Curve.EaseInOut })
      .opacity(1)
  }
  
  // 滑动进入动画
  static slideIn(component: any, direction: 'left' | 'right' | 'up' | 'down' = 'left', duration: number = 300) {
    const offset = 100
    let translateX = 0
    let translateY = 0
    
    switch (direction) {
      case 'left': translateX = -offset; break
      case 'right': translateX = offset; break
      case 'up': translateY = offset; break
      case 'down': translateY = -offset; break
    }
    
    return component
      .translate({ x: translateX, y: translateY })
      .opacity(0)
      .animate({ duration: duration, curve: Curve.EaseOut })
      .translate({ x: 0, y: 0 })
      .opacity(1)
  }
  
  // 缩放动画
  static scaleIn(component: any, duration: number = 300) {
    return component.scale({ x: 0.8, y: 0.8 })
      .opacity(0)
      .animate({ duration: duration, curve: Curve.EaseOut })
      .scale({ x: 1, y: 1 })
      .opacity(1)
  }
  
  // 脉冲动画（用于按钮反馈）
  static pulse(component: any, duration: number = 200) {
    return component.animate({ duration: duration, curve: Curve.EaseInOut })
      .scale({ x: 0.95, y: 0.95 })
      .animate({ duration: duration, curve: Curve.EaseInOut })
      .scale({ x: 1, y: 1 })
  }
}

// 页面切换容器组件
@Component
export struct AnimatedPage {
  @Prop content: () => void
  @Prop animationType: 'fade' | 'slide' | 'scale' = 'slide'
  @Prop direction: 'left' | 'right' | 'up' | 'down' = 'left'
  
  build() {
    Column() {
      this.content()
    }
    .opacity(0)
    .onAppear(() => {
      // 页面出现时的动画
      switch (this.animationType) {
        case 'fade':
          // 淡入已在样式中处理
          break
        case 'slide':
          // 滑动已在样式中处理
          break
        case 'scale':
          // 缩放已在样式中处理
          break
      }
    })
  }
}

// 带动画的按钮组件
@Component
export struct AnimatedButton {
  @Prop text: string
  @Prop onClick: () => void
  @Prop type: any = ButtonType.Normal
  @Prop backgroundColor: string = '#007AFF'
  
  @State private isPressed: boolean = false
  
  build() {
    Button(this.text, { type: this.type })
      .backgroundColor(this.isPressed ? this.darkenColor(this.backgroundColor) : this.backgroundColor)
      .width('100%')
      .height(48)
      .fontSize(16)
      .fontWeight(FontWeight.Medium)
      .borderRadius(8)
      .onClick(() => {
        // 点击动画
        AnimationUtils.pulse(this.buttonRef)
        setTimeout(() => this.onClick(), 100)
      })
      .onTouch((event: TouchEvent) => {
        if (event.type === TouchType.Down) {
          this.isPressed = true
        } else if (event.type === TouchType.Up || event.type === TouchType.Cancel) {
          this.isPressed = false
        }
      })
  }
  
  private darkenColor(color: string): string {
    // 简单的颜色加深算法
    const factor = 0.8
    const hex = color.replace('#', '')
    const r = Math.max(0, parseInt(hex.substr(0, 2), 16) * factor).toString(16).padStart(2, '0')
    const g = Math.max(0, parseInt(hex.substr(2, 2), 16) * factor).toString(16).padStart(2, '0')
    const b = Math.max(0, parseInt(hex.substr(4, 2), 16) * factor).toString(16).padStart(2, '0')
    return `#${r}${g}${b}`
  }
}