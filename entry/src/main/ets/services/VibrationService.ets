import { vibrator } from '@kit.SensorServiceKit';
import { BusinessError } from '@kit.BasicServicesKit';

export enum Haptic {
  SHORT = 'short',
  LONG = 'long',
  FINISH = 'finish',
  HR_ALERT = 'hr_alert'
}

export class VibrationService {
  private startVibrate(duration: number): void {
    try {
      vibrator.startVibration({
        type: 'time',
        duration: duration
      }, {
        id: 0,
        usage: 'alarm'
      }).then(() => {
        console.info(`Vibration started for ${duration}ms`);
      }, (error: BusinessError) => {
        console.error(`Failed to start vibration. Code: ${error.code}, message: ${error.message}`);
      });
    } catch (err) {
      let e: BusinessError = err as BusinessError;
      console.error(`An unexpected error occurred. Code: ${e.code}, message: ${e.message}`);
    }
  }

  public fire(h: Haptic): void {
    switch (h) {
      case Haptic.SHORT:
        this.startVibrate(200);
        break;
      case Haptic.LONG:
        this.startVibrate(500);
        break;
      case Haptic.FINISH:
        this.startVibrate(500);
        setTimeout((): void => {
          this.startVibrate(150);
        }, 600);
        setTimeout((): void => {
          this.startVibrate(150);
        }, 850);
        break;
      case Haptic.HR_ALERT:
        this.startVibrate(600);
        setTimeout((): void => {
          this.startVibrate(600);
        }, 800);
        break;
    }
  }

  public stop(): void {
    try {
      vibrator.stopVibration(vibrator.VibratorStopMode.VIBRATOR_STOP_MODE_TIME).then(() => {
        console.info('Succeed in stopping vibration');
      }, (error: BusinessError) => {
        console.error(`Failed to stop vibration. Code: ${error.code}, message: ${error.message}`);
      });
    } catch (err) {
      let e: BusinessError = err as BusinessError;
      console.error(`An unexpected error occurred. Code: ${e.code}, message: ${e.message}`);
    }
  }
}
