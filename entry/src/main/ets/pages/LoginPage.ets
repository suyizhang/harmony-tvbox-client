import { UserService } from '../service/UserService';
import { AppStyles, Card, PrimaryButton, StatusBadge } from '../components/Styles';
import { UnifiedLoading, ErrorState } from '../components/LoadingStates';
import { appState } from '../common/AppState';
import { Column, Row, Text, Button, TextInput, Image } from '@ohos.arkui.ArkUI';

@Component
export struct LoginPage {
  @State username: string = '';
  @State password: string = '';
  @State loading: boolean = false;
  @State error: string = '';
  @State isRegisterMode: boolean = false;

  async login() {
    if (!this.username.trim() || !this.password.trim()) {
      this.error = '请输入用户名和密码';
      return;
    }

    this.loading = true;
    this.error = '';

    try {
      const result = await UserService.login(this.username, this.password);
      if (result.success && result.user) {
        // 登录成功，更新应用状态
        appState.status = `欢迎回来，${result.user.username}！`;
        appState.openHome();
      } else {
        this.error = result.error || '登录失败';
      }
    } catch (err) {
      this.error = '登录过程中发生错误';
    } finally {
      this.loading = false;
    }
  }

  async register() {
    // 注册功能暂未实现
    this.error = '注册功能开发中...';
  }

  build() {
    Column({ space: AppStyles.Spacing.L }) {
      // 返回按钮
      Button('← 返回', { type: ButtonType.Normal })
        .onClick(() => appState.openHome())
        .margin({ bottom: 16 })

      // 标题
      Text(this.isRegisterMode ? '用户注册' : '用户登录')
        .fontSize(AppStyles.FontSizes.Title1)
        .fontWeight(FontWeight.Bold)
        .margin({ bottom: 32 })

      // 登录表单
      Card() {
        Column({ space: AppStyles.Spacing.M }) {
          // 头像
          Image('https://via.placeholder.com/80x80/007AFF/FFFFFF?text=T')
            .width(80)
            .height(80)
            .borderRadius(40)
            .margin({ bottom: 16 })

          // 用户名输入
          Column({ space: AppStyles.Spacing.XS }) {
            Text('用户名')
              .fontSize(AppStyles.FontSizes.Caption1)
              .fontColor(AppStyles.Colors.Gray)
            TextInput({ placeholder: '请输入用户名', text: this.username })
              .width('100%')
              .height(44)
              .onChange((value: string) => {
                this.username = value;
              })
          }

          // 密码输入
          Column({ space: AppStyles.Spacing.XS }) {
            Text('密码')
              .fontSize(AppStyles.FontSizes.Caption1)
              .fontColor(AppStyles.Colors.Gray)
            TextInput({ placeholder: '请输入密码', text: this.password })
              .width('100%')
              .height(44)
              .type(InputType.Password)
              .onChange((value: string) => {
                this.password = value;
              })
          }

          // 错误提示
          if (this.error) {
            ErrorState({
              title: '错误',
              message: this.error,
              showRetry: false
            })
          }

          // 登录按钮
          if (this.loading) {
            UnifiedLoading({
              message: this.isRegisterMode ? '注册中...' : '登录中...',
              showProgress: true,
              size: 'medium'
            })
          } else {
            PrimaryButton({
              text: this.isRegisterMode ? '注册' : '登录',
              onClick: () => this.isRegisterMode ? this.register() : this.login()
            })
          }

          // 切换模式
          Row() {
            Text(this.isRegisterMode ? '已有账号？' : '没有账号？')
              .fontSize(AppStyles.FontSizes.Caption1)
              .fontColor(AppStyles.Colors.Gray)
            Button(this.isRegisterMode ? '去登录' : '去注册', { type: ButtonType.Normal })
              .fontSize(AppStyles.FontSizes.Caption1)
              .height(32)
              .backgroundColor('transparent')
              .fontColor(AppStyles.Colors.Primary)
              .onClick(() => {
                this.isRegisterMode = !this.isRegisterMode;
                this.error = '';
              })
          }
          .margin({ top: 16 })

          // 演示账号提示
          if (!this.isRegisterMode) {
            Card() {
              Column({ space: AppStyles.Spacing.XS }) {
                Text('演示账号')
                  .fontSize(AppStyles.FontSizes.Caption1)
                  .fontWeight(FontWeight.Medium)
                Text('用户名: demo')
                  .fontSize(AppStyles.FontSizes.Caption2)
                  .fontColor(AppStyles.Colors.Gray)
                Text('密码: 123456')
                  .fontSize(AppStyles.FontSizes.Caption2)
                  .fontColor(AppStyles.Colors.Gray)
              }
            }
            .padding(12)
            .margin({ top: 16 })
          }
        }
      }
      .padding(AppStyles.Spacing.L)
    }
    .padding(AppStyles.Spacing.M)
    .width('100%')
    .height('100%')
    .backgroundColor(AppStyles.Colors.LightGray)
    .alignItems(HorizontalAlign.Center)
  }
}