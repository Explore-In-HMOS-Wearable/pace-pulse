import { RunState, SessionConfig, LiveMetrics, } from '../models/RunModels';
import { pedometerService } from '../services/PedometerService';
import { heartRateService } from '../services/HeartRateService';
import { VibrationService, Haptic } from '../services/VibrationService';
import { BusinessError } from '@kit.BasicServicesKit';
import { sensor } from '@kit.SensorServiceKit';
import { Permissions } from '@kit.AbilityKit';

class RunViewModel {
  private state: RunState;
  private vibrationService: VibrationService;
  private onStateChangeCallbacks: Array<(state: RunState) => void> = [];
  private startTime: number = 0;
  public static readonly REQUIRED_PERMISSIONS: Permissions[] = [
    'ohos.permission.ACTIVITY_MOTION',
    'ohos.permission.READ_HEALTH_DATA'
  ];

  constructor() {
    this.vibrationService = new VibrationService();
    this.state = this.getInitialState();
  }

  private getInitialState(): RunState {
    return {
      sessionConfig: {
        goalRunKm: 5,
        hrThreshold: 170
      },
      liveMetrics: {
        stepsTotal: 0,
        distanceKm: 0,
        heartRate: undefined,
        pace: 0,
        durationMinutes: 0
      },
      currentPage: 'start',
      isRunning: false,
      lastKmNotification: 0,
      heartRateExceeded: false
    };
  }

  onStateChange(callback: (state: RunState) => void): void {
    this.onStateChangeCallbacks.push(callback);
  }

  private notifyStateChange(): void {
    const currentState: RunState = this.getCurrentState();
    this.onStateChangeCallbacks.forEach((callback: (state: RunState) => void) => {
      try {
        callback(currentState);
      } catch (error) {
        console.error('Error in state change callback:', error);
      }
    });
  }

  async startSession(config: SessionConfig): Promise<void> {
    try {
      this.state.sessionConfig = this.cloneSessionConfig(config);
      this.state.isRunning = true;
      this.state.currentPage = 'running';
      this.startTime = Date.now();
      this.state.lastKmNotification = 0;
      this.state.heartRateExceeded = false;

      await this.subscribeToSensors();
      this.notifyStateChange();

      this.vibrationService.fire(Haptic.SHORT);
      console.info('Running session started');

    } catch (error) {
      const e: BusinessError = error as BusinessError;
      console.error(`Failed to start session: ${e.message}`);
    }
  }

  stopSession(): void {
    this.state.isRunning = false;
    this.state.currentPage = 'start';
    this.unsubscribeFromSensors();

    this.vibrationService.fire(Haptic.FINISH);
    this.notifyStateChange();
    console.info('Running session stopped');
  }

  private cloneSessionConfig(config: SessionConfig): SessionConfig {
    return {
      goalRunKm: config.goalRunKm,
      hrThreshold: config.hrThreshold
    };
  }

  private cloneLiveMetrics(metrics: LiveMetrics): LiveMetrics {
    return {
      stepsTotal: metrics.stepsTotal,
      distanceKm: metrics.distanceKm,
      heartRate: metrics.heartRate,
      pace: metrics.pace,
      durationMinutes: metrics.durationMinutes
    };
  }

  private cloneRunState(state: RunState): RunState {
    return {
      sessionConfig: this.cloneSessionConfig(state.sessionConfig),
      liveMetrics: this.cloneLiveMetrics(state.liveMetrics),
      currentPage: state.currentPage,
      isRunning: state.isRunning,
      lastKmNotification: state.lastKmNotification,
      heartRateExceeded: state.heartRateExceeded
    };
  }

  private async subscribeToSensors(): Promise<void> {
    await pedometerService.subscribeToPedometer(
      (data: sensor.PedometerResponse, distanceKm: number) => this.handlePedometerData(data, distanceKm),
      100000000
    );

    heartRateService.subscribeToHeartRate(
      (data: sensor.HeartRateResponse) => this.handleHeartRateData(data),
      200000000
    );
  }

  private unsubscribeFromSensors(): void {
    pedometerService.unsubscribeFromPedometer();
    heartRateService.unsubscribeFromHeartRate();
  }

  private handlePedometerData(data: sensor.PedometerResponse, distanceKm: number): void {
    if (!this.state.isRunning) {
      return;
    }

    const currentKm: number = Math.floor(distanceKm);

    this.state.liveMetrics.stepsTotal = data.steps;
    this.state.liveMetrics.distanceKm = distanceKm;
    this.state.liveMetrics.durationMinutes = (Date.now() - this.startTime) / (1000 * 60);
    this.state.liveMetrics.pace = this.calculatePace();

    if (currentKm > this.state.lastKmNotification && currentKm <= this.state.sessionConfig.goalRunKm) {
      this.state.lastKmNotification = currentKm;
      this.vibrationService.fire(Haptic.SHORT);
      console.info(`KM milestone reached: ${currentKm}km`);
    }

    if (distanceKm >= this.state.sessionConfig.goalRunKm) {
      this.vibrationService.fire(Haptic.FINISH);
      console.info('Goal distance reached!');
    }

    this.notifyStateChange();
  }

  private handleHeartRateData(data: sensor.HeartRateResponse): void {
    if (!this.state.isRunning) {
      return;
    }

    this.state.liveMetrics.heartRate = data.heartRate;

    const hrThresholdExceeded = data.heartRate > this.state.sessionConfig.hrThreshold;

    if (hrThresholdExceeded !== this.state.heartRateExceeded) {
      this.state.heartRateExceeded = hrThresholdExceeded;

      if (hrThresholdExceeded && this.state.currentPage !== 'heartRateAlert') {
        this.state.currentPage = 'heartRateAlert';
        this.vibrationService.fire(Haptic.HR_ALERT);
        console.warn('Heart rate threshold exceeded!');
      } else if (!hrThresholdExceeded && this.state.currentPage !== 'running') {
        this.state.currentPage = 'running';
        this.vibrationService.fire(Haptic.SHORT);
        console.info('Heart rate back to normal');
      }

      this.notifyStateChange();
    }
  }

  private calculatePace(): number {
    const durationMinutes: number = this.state.liveMetrics.durationMinutes;
    const distanceKm: number = this.state.liveMetrics.distanceKm;
    return distanceKm > 0 ? durationMinutes / distanceKm : 0;
  }

  navigateToPage(page: 'start' | 'running' | 'heartRateAlert'): void {
    this.state.currentPage = page;
    this.notifyStateChange();
  }

  getCurrentState(): RunState {
    return this.cloneRunState(this.state);
  }

  isGoalReached(): boolean {
    return this.state.liveMetrics.distanceKm >= this.state.sessionConfig.goalRunKm;
  }

  cleanup(): void {
    this.unsubscribeFromSensors();
    this.onStateChangeCallbacks = [];
  }
}

export const runViewModel = new RunViewModel();