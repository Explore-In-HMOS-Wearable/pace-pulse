import { sensor } from '@kit.SensorServiceKit';
import { BusinessError } from '@kit.BasicServicesKit';

interface PedometerStats {
  totalSteps: number;
  distanceKm: number;
  stepLength: number;
  durationMinutes: number;
}

export class PedometerService {
  private static instance: PedometerService;
  private isSubscribed: boolean = false;
  private callbacks: Set<(data: sensor.PedometerResponse, distanceKm: number) => void> = new Set();
  private totalSteps: number = 0;
  private stepLength: number = 0.75; // 75 cm average
  private startTime: number = 0;

  private constructor() {
  }

  public static getInstance(): PedometerService {
    if (!PedometerService.instance) {
      PedometerService.instance = new PedometerService();
    }
    return PedometerService.instance;
  }

  public setStepLength(lengthMeters: number): void {
    if (lengthMeters > 0 && lengthMeters < 2) {
      this.stepLength = lengthMeters;
      console.info(`Step length set to: ${lengthMeters} meters`);
    } else {
      console.warn('Invalid step length. Using default value.');
    }
  }

  public getStepLength(): number {
    return this.stepLength;
  }


  // Calculate distance from steps
  public calculateDistance(steps: number): number {
    // distance meter
    const distanceMeters = steps * this.stepLength;
    // distance km
    return distanceMeters / 1000;
  }

  public async subscribeToPedometer(
    callback: (data: sensor.PedometerResponse, distanceKm: number) => void,
    interval: number = 100000000
  ): Promise<void> {
    try {
      this.callbacks.add(callback);

      if (!this.isSubscribed) {
        this.totalSteps = 0;
        this.startTime = Date.now();

        sensor.on(sensor.SensorId.PEDOMETER, (data: sensor.PedometerResponse) => {
          console.info(`Pedometer data received: ${JSON.stringify(data)}`);

          this.totalSteps = data.steps;
          const distanceKm: number = this.calculateDistance(this.totalSteps);

          console.info(`Steps: ${this.totalSteps}, Distance: ${distanceKm.toFixed(2)} km`);

          this.notifyAllCallbacks(data, distanceKm);
        }, { interval: interval });

        this.isSubscribed = true;
        console.info('Successfully subscribed to pedometer sensor');
      }
    } catch (error) {
      const e: BusinessError = error as BusinessError;
      console.error(`Failed to subscribe to pedometer. Code: ${e.code}, message: ${e.message}`);
    }
  }

  public unsubscribeFromPedometer(callback?: (data: sensor.PedometerResponse, distanceKm: number) => void): void {
    try {
      if (callback) {
        this.callbacks.delete(callback);
        if (this.callbacks.size === 0 && this.isSubscribed) {
          sensor.off(sensor.SensorId.PEDOMETER);
          this.isSubscribed = false;
          console.info('Unsubscribed from pedometer sensor (no more callbacks)');
        }
      } else {
        this.callbacks.clear();
        if (this.isSubscribed) {
          sensor.off(sensor.SensorId.PEDOMETER);
          this.isSubscribed = false;
          console.info('Unsubscribed from pedometer sensor (all callbacks removed)');
        }
      }
    } catch (error) {
      const e: BusinessError = error as BusinessError;
      console.error(`Failed to unsubscribe from pedometer. Code: ${e.code}, message: ${e.message}`);
    }
  }

  public getCurrentStats(): PedometerStats {
    const currentTime = Date.now();
    const durationMinutes = this.startTime > 0 ? (currentTime - this.startTime) / (1000 * 60) : 0;

    return {
      totalSteps: this.totalSteps,
      distanceKm: this.calculateDistance(this.totalSteps),
      stepLength: this.stepLength,
      durationMinutes: durationMinutes
    };
  }

  public resetCounter(): void {
    this.totalSteps = 0;
    this.startTime = Date.now();
    console.info('Step counter reset');
  }

  public estimateCaloriesBurned(steps?: number): number {
    const stepCount = steps || this.totalSteps;
    return stepCount * 0.045;
  }

  public calculatePace(durationMinutes: number, distanceKm: number): number {
    if (distanceKm > 0) {
      return durationMinutes / distanceKm;
    }
    return 0;
  }

  private notifyAllCallbacks(data: sensor.PedometerResponse, distanceKm: number): void {
    this.callbacks.forEach(callback => {
      try {
        callback(data, distanceKm);
      } catch (error) {
        console.error('Error in pedometer callback:', error);
      }
    });
  }

  public isSubscribedToPedometer(): boolean {
    return this.isSubscribed;
  }

  public getCallbackCount(): number {
    return this.callbacks.size;
  }

  public cleanup(): void {
    this.unsubscribeFromPedometer();
    this.callbacks.clear();
    this.totalSteps = 0;
    this.startTime = 0;
  }
}

export class StepCalculator {
  public static calculateDistance(steps: number, stepLengthMeters: number = 0.75): number {
    return (steps * stepLengthMeters) / 1000;
  }

  public static calculateStepsForDistance(distanceKm: number, stepLengthMeters: number = 0.75): number {
    return Math.round((distanceKm * 1000) / stepLengthMeters);
  }

  public static estimateStepLength(heightCm: number): number {
    return (heightCm * 0.43) / 100;
  }

  public static distanceToSteps(distanceKm: number, stepLengthMeters: number = 0.75): number {
    return Math.round((distanceKm * 1000) / stepLengthMeters);
  }

  public static calculatePace(durationMinutes: number, distanceKm: number): string {
    if (distanceKm > 0) {
      const pace = durationMinutes / distanceKm;
      const minutes = Math.floor(pace);
      const seconds = Math.round((pace - minutes) * 60);
      return `${minutes}:${seconds.toString().padStart(2, '0')} min/km`;
    }
    return '0:00 min/km';
  }
}

export const pedometerService = PedometerService.getInstance();