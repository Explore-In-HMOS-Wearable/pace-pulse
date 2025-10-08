@Component
export struct MetricCard {
  @Prop title?: string;
  @Prop value?: string;

  build() {
    Column() {
      Text(this.value)
        .fontSize(10)
        .fontWeight(FontWeight.Medium)
        .fontColor(Color.Gray)
      Text(this.title)
        .fontSize(10)
        .fontColor(Color.Gray)
    }
    .padding(5)
    .backgroundColor(Color.White)
    .borderRadius(8)
    .shadow(2)
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
  }
}