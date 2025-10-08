import { RunState, SessionConfig } from '../models/RunModels';
import { runViewModel } from '../viewmodels/RunViewModel';
import { ArcButton, ArcButtonOptions, ArcButtonPosition } from '@ohos.arkui.advanced.ArcButton';

@Entry
@Component
struct StartPage {
  @State private goalRunKm: number = 5;
  @State private hrThreshold: number = 170;
  @State private isStarting: boolean = false;

  aboutToAppear() {
    runViewModel.onStateChange((state: RunState) => {
    });
  }

  build() {
    Column() {
      Text('Track your running goal')
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .margin({ bottom: 5, top: 50 })
        .padding(2)
      Row() {
        Text('Distance (km):')
          .fontSize(14)
        Slider({
          value: this.goalRunKm,
          min: 1,
          max: 42,
          step: 1,
          style: SliderStyle.OutSet
        })
          .width('30%')
          .onChange((value: number) => {
            this.goalRunKm = value;
          })
        Text(this.goalRunKm.toFixed(0) + 'km')
          .fontSize(14)
          .fontColor(Color.White)
      }
      .margin({ bottom: 5 })

      Row() {
        Text('HR Threshold:')
          .fontSize(14)
        Slider({
          value: this.hrThreshold,
          min: 150,
          max: 200,
          step: 5,
          style: SliderStyle.OutSet,
        })
          .width('30%')
          .onChange((value: number) => {
            this.hrThreshold = value;
          })
        Text(this.hrThreshold.toFixed(0) + ' bpm')
          .fontSize(14)
          .fontColor(Color.White)
      }
      .padding(10)

      ArcButton({
        options: new ArcButtonOptions({
          label: 'Start Running',
          position: ArcButtonPosition.BOTTOM_EDGE,
          onClick: async () => {
            this.isStarting = true;
            const config: SessionConfig = {
              goalRunKm: this.goalRunKm,
              hrThreshold: this.hrThreshold
            };
            try {
              await runViewModel.startSession(config);
            } catch (error) {
              console.error('Failed to start session:', error);
              this.isStarting = false;
            }
          }
        ,

        })
      })
        .width('%100')
    }
    .height('%100')
    .justifyContent(FlexAlign.SpaceBetween)

  }
}