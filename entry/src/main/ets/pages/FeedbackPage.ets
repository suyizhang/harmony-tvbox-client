import { appState } from '../common/AppState';
import { Card, PrimaryButton } from '../components/Styles';
import { Column, Row, Text, Button, List, ListItem, TextArea, Rating } from '@ohos.arkui.ArkUI';
import { ButtonType } from '@ohos.arkui.ArkUI';
import { FontWeight } from '@ohos.arkui.ArkUI';

@Component
export struct FeedbackPage {
  @State feedbackType: 'bug' | 'feature' | 'rating' | 'general' = 'general';
  @State rating: number = 5;
  @State feedbackText: string = '';
  @State contactInfo: string = '';
  @State submitted: boolean = false;
  @State recentFeedbacks: Array<{
    id: string;
    type: string;
    content: string;
    rating?: number;
    time: string;
    status: 'pending' | 'reviewed' | 'resolved';
  }> = [];

  async aboutToAppear() {
    await this.loadRecentFeedbacks();
  }

  async loadRecentFeedbacks() {
    // 模拟加载用户最近的反馈
    this.recentFeedbacks = [
      {
        id: 'fb_001',
        type: 'rating',
        content: '应用整体体验很好，希望能增加更多视频源',
        rating: 4,
        time: '2026-04-17 14:30',
        status: 'reviewed'
      },
      {
        id: 'fb_002',
        type: 'feature',
        content: '建议添加视频剪辑功能，可以截取精彩片段',
        time: '2026-04-16 09:15',
        status: 'pending'
      }
    ];
  }

  async submitFeedback() {
    if (!this.feedbackText.trim()) {
      appState.setError('请填写反馈内容');
      return;
    }

    const feedback = {
      id: 'fb_' + Date.now(),
      type: this.feedbackType,
      content: this.feedbackText,
      rating: this.feedbackType === 'rating' ? this.rating : undefined,
      contact: this.contactInfo || undefined,
      time: new Date().toLocaleString('zh-CN'),
      status: 'pending'
    };

    // 模拟提交反馈
    console.log('提交反馈:', feedback);
    
    // 添加到本地列表
    this.recentFeedbacks.unshift(feedback);
    
    // 清空表单
    this.feedbackText = '';
    this.contactInfo = '';
    this.submitted = true;
    
    appState.status = '感谢您的反馈！我们会认真考虑您的建议。';
    
    // 3秒后重置提交状态
    setTimeout(() => {
      this.submitted = false;
    }, 3000);
  }

  getFeedbackTypeText(type: string): string {
    const types = {
      bug: '🐛 问题报告',
      feature: '💡 功能建议',
      rating: '⭐ 应用评分',
      general: '💬 一般反馈'
    };
    return types[type] || '💬 反馈';
  }

  getStatusText(status: string): string {
    const statuses = {
      pending: '⏳ 待处理',
      reviewed: '👀 已查看',
      resolved: '✅ 已解决'
    };
    return statuses[status] || '未知';
  }

  build() {
    Column({ space: 16 }) {
      // 返回按钮
      Button('← 返回', { type: ButtonType.Normal })
        .onClick(() => appState.openSettings())
        .margin({ bottom: 16 })

      // 标题
      Text('💬 意见反馈')
        .fontSize(24)
        .fontWeight(FontWeight.Bold)

      // 反馈表单
      Card() {
        Column({ space: 16 }) {
          Text('提交反馈')
            .fontSize(18)
            .fontWeight(FontWeight.Medium)
          
          // 反馈类型选择
          Column({ space: 8 }) {
            Text('反馈类型')
              .fontSize(14)
              .fontColor('#333333')
            
            Row({ space: 8 }) {
              ForEach(['general', 'bug', 'feature', 'rating'], (type: string) => {
                Button(this.getFeedbackTypeText(type).split(' ')[1])
                  .fontSize(12)
                  .padding({ left: 12, right: 12, top: 6, bottom: 6 })
                  .backgroundColor(this.feedbackType === type ? '#007AFF' : '#f0f0f0')
                  .fontColor(this.feedbackType === type ? '#FFFFFF' : '#000000')
                  .onClick(() => this.feedbackType = type as any)
              })
            }
          }

          // 评分组件（仅在评分类型时显示）
          if (this.feedbackType === 'rating') {
            Column({ space: 8 }) {
              Text('应用评分')
                .fontSize(14)
                .fontColor('#333333')
              
              Row() {
                Rating({ rating: this.rating, total: 5 })
                  .onChange((value: number) => this.rating = value)
                Text(`${this.rating} 分`)
                  .fontSize(14)
                  .margin({ left: 8 })
                  .fontColor('#FF9500')
              }
            }
          }

          // 反馈内容
          Column({ space: 8 }) {
            Text('反馈内容')
              .fontSize(14)
              .fontColor('#333333')
            
            TextArea({ placeholder: '请详细描述您的想法、建议或遇到的问题...', text: this.feedbackText })
              .height(120)
              .onChange((value: string) => this.feedbackText = value)
          }

          // 联系方式
          Column({ space: 8 }) {
            Text('联系方式（可选）')
              .fontSize(14)
              .fontColor('#333333')
            
            TextInput({ placeholder: '邮箱或手机号', text: this.contactInfo })
              .onChange((value: string) => this.contactInfo = value)
          }

          // 提交按钮
          Button(this.submitted ? '✅ 已提交' : '📤 提交反馈', { type: ButtonType.Normal })
            .width('100%')
            .height(44)
            .enabled(!this.submitted && this.feedbackText.trim().length > 0)
            .onClick(() => this.submitFeedback())
        }
      }

      // 最近反馈
      if (this.recentFeedbacks.length > 0) {
        Card() {
          Column({ space: 12 }) {
            Row() {
              Text('📝 最近反馈')
                .fontSize(18)
                .fontWeight(FontWeight.Medium)
                .layoutWeight(1)
              Button('查看全部', { type: ButtonType.Normal })
                .height(28)
            }
            
            ForEach(this.recentFeedbacks.slice(0, 3), (feedback) => {
              ListItem() {
                Column({ space: 8 }) {
                  Row() {
                    Text(this.getFeedbackTypeText(feedback.type))
                      .fontSize(12)
                      .padding({ left: 6, right: 6, top: 2, bottom: 2 })
                      .backgroundColor('#f0f0f0')
                      .borderRadius(4)
                    Text(feedback.time)
                      .fontSize(10)
                      .fontColor('#999999')
                      .margin({ left: 8 })
                    Text(this.getStatusText(feedback.status))
                      .fontSize(10)
                      .fontColor(this.getStatusColor(feedback.status))
                      .margin({ left: 8 })
                  }
                  
                  Text(feedback.content)
                    .fontSize(14)
                    .maxLines(2)
                    .textOverflow({ overflow: TextOverflow.Ellipsis })
                  
                  if (feedback.rating) {
                    Row() {
                      Rating({ rating: feedback.rating, total: 5, readonly: true })
                      Text(`${feedback.rating} 分`)
                        .fontSize(12)
                        .fontColor('#FF9500')
                        .margin({ left: 4 })
                    }
                  }
                }
                .padding(8)
              }
            })
          }
        }
      }

      // 常见问题
      Card() {
        Column({ space: 8 }) {
          Text('❓ 常见问题')
            .fontSize(18)
            .fontWeight(FontWeight.Medium)
          
          List() {
            ListItem() {
              Column({ space: 4 }) {
                Text('Q: 如何获得技术支持？')
                  .fontSize(14)
                  .fontWeight(FontWeight.Medium)
                Text('A: 可通过反馈页面联系我们，或查看在线帮助文档')
                  .fontSize(12)
                  .fontColor('#666666')
              }
            }
            ListItem() {
              Column({ space: 4 }) {
                Text('Q: 插件开发有什么要求？')
                  .fontSize(14)
                  .fontWeight(FontWeight.Medium)
                Text('A: 遵循插件开发规范，确保兼容性和安全性')
                  .fontSize(12)
                  .fontColor('#666666')
              }
            }
          }
        }
      }
    }
    .padding(16)
    .width('100%')
    .height('100%')
    .backgroundColor('#F2F2F7')
  }

  private getStatusColor(status: string): string {
    const colors = {
      pending: '#FF9500',
      reviewed: '#007AFF',
      resolved: '#34C759'
    };
    return colors[status] || '#666666';
  }
}