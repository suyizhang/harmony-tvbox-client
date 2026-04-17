@Component
export struct DetailPage {
  build() {
    Column({ space: 12 }) {
      Text('详情页')
        .fontSize(22)
        .fontWeight(FontWeight.Bold)

      Text('这里展示源详情、剧集列表、播放入口。')
      Text('当前阶段先做页面骨架，后面再接后端 /detail /play 接口。')
        .fontSize(12)
    }
    .padding(16)
    .width('100%')
    .height('100%')
  }
}
