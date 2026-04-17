import { ThemeService } from '../service/ThemeService';
import { appState } from '../common/AppState';
import { Card, PrimaryButton } from '../components/Styles';
import { Column, Row, Text, Button, List, ListItem, Image } from '@ohos.arkui.ArkUI';
import { ButtonType } from '@ohos.arkui.ArkUI';
import { FontWeight } from '@ohos.arkui.ArkUI';
import { AppStorage } from '@ohos.arkui.ArkUI';

@Component
export struct ThemeSettingsPage {
  @State currentTheme: any = null;
  @State availableThemes: Array<{key: string, name: string, preview: string}> = [];
  @State customColors: Record<string, string> = {};
  @State selectedColorKey: string = '';
  @State newColorValue: string = '#007AFF';
  @State previewMode: boolean = false;

  async aboutToAppear() {
    await this.loadThemeData();
  }

  async loadThemeData() {
    this.currentTheme = await ThemeService.getCurrentTheme();
    this.availableThemes = ThemeService.getAvailableThemes();
    this.customColors = await ThemeService.getCustomColors();
  }

  async applyTheme(themeKey: string) {
    const success = await ThemeService.setTheme(themeKey as any);
    if (success) {
      this.currentTheme = await ThemeService.getCurrentTheme();
      appState.status = `已切换到${ThemeService.themes[themeKey as keyof typeof ThemeService.themes]?.name}`;
    }
  }

  async setCustomColor() {
    if (this.selectedColorKey) {
      const success = await ThemeService.setCustomColor(this.selectedColorKey, this.newColorValue);
      if (success) {
        this.customColors[this.selectedColorKey] = this.newColorValue;
        appState.status = '自定义颜色已保存';
      }
    }
  }

  startPreview(themeKey: string) {
    this.previewMode = true;
    ThemeService.applyThemeToSystem(themeKey as any);
  }

  stopPreview() {
    this.previewMode = false;
    if (this.currentTheme) {
      ThemeService.applyThemeToSystem(
        Object.keys(ThemeService.themes).find(key => 
          ThemeService.themes[key as keyof typeof ThemeService.themes] === this.currentTheme
        ) as any
      );
    }
  }

  build() {
    Column({ space: 16 }) {
      // 返回按钮
      Button('← 返回', { type: ButtonType.Normal })
        .onClick(() => appState.openSettings())
        .margin({ bottom: 16 })

      // 标题
      Text('🎨 主题设置')
        .fontSize(24)
        .fontWeight(FontWeight.Bold)

      // 当前主题预览
      if (this.currentTheme) {
        Card() {
          Column({ space: 12 }) {
            Text('当前主题')
              .fontSize(18)
              .fontWeight(FontWeight.Medium)
            
            Row({ space: 16 }) {
              // 主题色彩展示
              Column({ space: 8 }) {
                Row({ space: 8 }) {
                  Column()
                    .width(40)
                    .height(40)
                    .backgroundColor(this.currentTheme.colors.primary)
                    .borderRadius(8)
                  Column()
                    .width(40)
                    .height(40)
                    .backgroundColor(this.currentTheme.colors.secondary)
                    .borderRadius(8)
                }
                Row({ space: 8 }) {
                  Column()
                    .width(40)
                    .height(40)
                    .backgroundColor(this.currentTheme.colors.background)
                    .borderRadius(8)
                  Column()
                    .width(40)
                    .height(40)
                    .backgroundColor(this.currentTheme.colors.card)
                    .borderRadius(8)
                }
              }
              
              // 主题信息
              Column({ space: 4 }) {
                Text(this.currentTheme.name)
                  .fontSize(16)
                  .fontWeight(FontWeight.Medium)
                Text(`主色: ${this.currentTheme.colors.primary}`)
                  .fontSize(12)
                  .fontColor('#666666')
                Text(`背景: ${this.currentTheme.colors.background}`)
                  .fontSize(12)
                  .fontColor('#666666')
              }
              .layoutWeight(1)
            }
          }
        }
      }

      // 预设主题选择
      Card() {
        Column({ space: 12 }) {
          Text('选择主题')
            .fontSize(18)
            .fontWeight(FontWeight.Medium)
          
          List() {
            ForEach(this.availableThemes, (theme) => {
              ListItem() {
                Row({ space: 12 }) {
                  // 主题预览色块
                  Column()
                    .width(60)
                    .height(60)
                    .backgroundColor(theme.preview)
                    .borderRadius(8)
                    .overlay(
                      this.currentTheme?.colors.primary === theme.preview ? 
                      Text('✓').fontSize(20).fontColor('#FFFFFF') : Text('')
                    )
                  
                  // 主题信息
                  Column({ space: 4 }) {
                    Text(theme.name)
                      .fontSize(16)
                      .fontWeight(FontWeight.Medium)
                    Text(`主题ID: ${theme.key}`)
                      .fontSize(12)
                      .fontColor('#666666')
                  }
                  .layoutWeight(1)
                  
                  // 操作按钮
                  Row({ space: 8 }) {
                    if (this.previewMode) {
                      Button('退出预览', { type: ButtonType.Normal })
                        .onClick(() => this.stopPreview())
                    } else {
                      Button('预览', { type: ButtonType.Normal })
                        .onClick(() => this.startPreview(theme.key))
                    }
                    Button('应用', { type: ButtonType.Normal })
                      .onClick(() => this.applyTheme(theme.key))
                  }
                }
              }
            }, (theme) => theme.key)
          }
        }
      }

      // 自定义颜色设置
      if (Object.keys(this.customColors).length > 0) {
        Card() {
          Column({ space: 12 }) {
            Text('自定义颜色')
              .fontSize(18)
              .fontWeight(FontWeight.Medium)
            
            ForEach(Object.entries(this.customColors), ([key, color]) => {
              Row({ space: 12 }) {
                Text(key)
                  .width(80)
                  .fontSize(14)
                Column()
                  .width(40)
                  .height(40)
                  .backgroundColor(color)
                  .borderRadius(6)
                Text(color)
                  .fontSize(12)
                  .fontColor('#666666')
                Button('删除', { type: ButtonType.Normal })
                  .height(32)
                  .onClick(async () => {
                    delete this.customColors[key];
                    await ThemeService.setCustomColor(key, '');
                  })
              }
            })
          }
        }
      }

      // 添加自定义颜色
      Card() {
        Column({ space: 12 }) {
          Text('添加自定义颜色')
            .fontSize(18)
            .fontWeight(FontWeight.Medium)
          
          Row({ space: 8 }) {
            // 颜色选择器（简化版）
            Button('🎨', { type: ButtonType.Normal })
              .width(40)
              .height(40)
              .onClick(() => {
                // 在实际项目中这里会打开颜色选择器
                this.newColorValue = '#' + Math.floor(Math.random()*16777215).toString(16).padStart(6, '0');
              })
            
            TextInput({ placeholder: '颜色键名', text: this.selectedColorKey })
              .layoutWeight(1)
              .onChange((value: string) => this.selectedColorKey = value)
            
            TextInput({ placeholder: '颜色值', text: this.newColorValue })
              .width(100)
              .onChange((value: string) => this.newColorValue = value)
          }
          
          Button('添加颜色', { type: ButtonType.Normal })
            .onClick(() => this.setCustomColor())
            .enabled(!!this.selectedColorKey && !!this.newColorValue)
        }
      }

      // 操作按钮
      Row({ space: 12 }) {
        PrimaryButton({
          text: '🔄 重置为默认',
          onClick: async () => {
            await ThemeService.resetToDefault();
            await this.loadThemeData();
            appState.status = '已重置为默认主题';
          }
        })
        
        Button('导出配置', { type: ButtonType.Normal })
          .onClick(() => {
            appState.status = '主题配置导出功能开发中';
          })
      }
    }
    .padding(16)
    .width('100%')
    .height('100%')
    .backgroundColor('#F2F2F7')
  }
}