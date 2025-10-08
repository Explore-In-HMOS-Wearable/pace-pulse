import { Vibrator, VibrateOptions } from '@kit.SensorServiceKit';
export enum Haptic {
  SHORT = 'short',
  LONG = 'long',
  FINISH = 'finish',
  HR_ALERT = 'hr_alert',
}

export class VibrationService {
  private vibrate(mode: 'short' | 'long'): void {
    const opts: VibrateOptions = {
      mode: mode,
      success: () => {
        console.info('Vibration completed successfully');
      },

    };

    try {
      Vibrator.vibrate(opts);
    } catch (e) {
      console.error('Vibration error:', e);
    }
  }

  public fire(h: Haptic): void {
    switch (h) {
      case Haptic.SHORT:
        this.vibrate('short');
        break;
      case Haptic.LONG:
        this.vibrate('long');
        break;
      case Haptic.FINISH:
        this.vibrate('long');
        setTimeout((): void => {
          this.vibrate('short');
        }, 250);
        setTimeout((): void => {
          this.vibrate('short');
        }, 450);
        break;
      case Haptic.HR_ALERT:
        this.vibrate('long');
        setTimeout((): void => {
          this.vibrate('long');
        }, 500);
        break;
    }
  }
}