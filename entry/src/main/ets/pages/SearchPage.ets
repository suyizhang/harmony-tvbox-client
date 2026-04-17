@Component
export struct SearchPage {
  @State keyword: string = ''

  build() {
    Column({ space: 12 }) {
      Text('搜索页')
        .fontSize(22)
        .fontWeight(FontWeight.Bold)

      TextInput({ placeholder: '搜索源名 / api', text: this.keyword })
        .onChange((value: string) => {
          this.keyword = value
        })

      Button('搜索')
      Text('这里后续接入统一搜索接口 /search?q=')
        .fontSize(12)
    }
    .padding(16)
    .width('100%')
    .height('100%')
  }
}
