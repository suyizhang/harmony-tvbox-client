@Component
export struct PlayerPage {
  build() {
    Column({ space: 12 }) {
      Text('播放页')
        .fontSize(22)
        .fontWeight(FontWeight.Bold)

      Text('这里后续接入 HarmonyOS 视频播放组件。')
      Text('如果后端返回直链播放地址，可在此页进行播放。')
        .fontSize(12)
    }
    .padding(16)
    .width('100%')
    .height('100%')
  }
}
