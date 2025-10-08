import { RunState } from '../models/RunModels';
import { runViewModel } from '../viewmodels/RunViewModel';
import { router } from '@kit.ArkUI';
import lottie, { AnimationItem } from '@ohos/lottie';

@Entry
@Component
struct HeartRateAlertPage {
  @State private runState: RunState = runViewModel.getCurrentState();
  @State private timer: number = 0;
  private politeChickyController: CanvasRenderingContext2D = new CanvasRenderingContext2D();
  private politeChicky: string = 'politeChicky';
  private politeChickyPath: string = 'rawfile/heartBeat.json';
  private animateItem?: AnimationItem;

  aboutToAppear() {
    this.runState = runViewModel.getCurrentState();

    this.timer = setInterval(() => {
      const state = runViewModel.getCurrentState();
      if (state.currentPage === 'running') {
        clearInterval(this.timer);
        router.back();
      }
      this.runState = state;
    }, 1000);
  }

  aboutToDisappear() {
    clearInterval(this.timer);
  }

  build() {
    Column() {
      Stack() {
        Column()
          .width(300)
          .height(300)
        Particle({
          particles: [
            {
              emitter: {
                particle: {
                  type: ParticleType.POINT,
                  config: {
                    radius: 5
                  },
                  count: 255,
                },
              },
              color: {
                range: [Color.White, Color.Red],
              },
            },
          ]
        }).width(200).height(200)
      }.width('10%').height('10%').align(Alignment.Top)

      Canvas(this.politeChickyController)
        .width(125)
        .height(125)
        .borderRadius(3)
        .onReady(() => {
          this.animateItem = lottie.loadAnimation({
            container: this.politeChickyController,
            renderer: 'canvas',
            loop: true,
            autoplay: true,
            name: this.politeChicky,
            path: this.politeChickyPath,
          });
        })

      Text(this.runState.liveMetrics.heartRate + ' bpm')
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor(Color.White)
    }
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .width('100%')
    .height('100%')
    .backgroundColor(Color.Black)

  }
}