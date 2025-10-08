import { RunState } from '../models/RunModels';
import { runViewModel } from '../viewmodels/RunViewModel';
import { ArcButton, ArcButtonOptions, ArcButtonPosition, ArcButtonStyleMode, ColorMetrics, router } from '@kit.ArkUI';
import { LiveMetricsComponent } from '../components/LiveMetricsComponent';

@Entry
@Component
struct RunningPage {
  @State private runState: RunState = runViewModel.getCurrentState();
  @State private timer: number = 0;

  aboutToAppear() {
    this.runState = runViewModel.getCurrentState();
    runViewModel.onStateChange((state: RunState) => {
      this.runState = state;
      if (state.currentPage === 'heartRateAlert') {
        router.pushUrl({ url: 'pages/HeartRateAlertPage' });
      }
    });

    // Timer for UI updates
    this.timer = setInterval(() => {
      this.runState = runViewModel.getCurrentState();
    }, 10000);
  }

  aboutToDisappear() {
    clearInterval(this.timer);
  }

  build() {
    Scroll() {
      Column() {

        ArcButton({
          options: new ArcButtonOptions({
            label: 'End',
            position: ArcButtonPosition.TOP_EDGE,
            styleMode: ArcButtonStyleMode.CUSTOM,
            backgroundColor: ColorMetrics.resourceColor($r('app.color.button')),
            onClick: () => {
              runViewModel.stopSession();
              router.back();
            }
          })
        })
          .width('%100')
        Blank()
          .height(40)
        Column() {
          Text(`${this.runState.liveMetrics.distanceKm.toFixed(2)} km`)
            .fontSize(36)
            .fontWeight(FontWeight.Bold)
            .fontColor(Color.Pink)

          Text(`of ${this.runState.sessionConfig.goalRunKm} km`)
            .fontSize(16)
            .fontColor(Color.Gray)


        }
        .margin({ top: 5, bottom: 30 })

        Stack() {
          LiveMetricsComponent({ runState: this.runState })
          Progress({
            value: this.runState.liveMetrics.distanceKm,
            total: this.runState.sessionConfig.goalRunKm,
            type: ProgressType.Ring,

          })
            .style({ strokeWidth: 5 })
            .width(200)
            .height(200)
            .color(Color.Pink)

        }
        .margin({ bottom: 10 })

        if (this.runState.lastKmNotification > 0) {
          Text(`Reached ${this.runState.lastKmNotification} km!`)
            .fontSize(14)
            .fontColor(Color.Green)
            .margin({ top: 20 })
        }
      }
      .margin({ left: 15 })
    }

  }
}

