// models/RunState.ts

export interface RunState {
  sessionConfig: SessionConfig;
  liveMetrics: LiveMetrics;
  currentPage: 'start' | 'running' | 'heartRateAlert';
  isRunning: boolean;
  lastKmNotification: number;
  heartRateExceeded: boolean;
}

export interface SessionConfig {
  goalRunKm: number;
  hrThreshold: number;
}

export interface LiveMetrics {
  stepsTotal: number;
  distanceKm: number;
  heartRate?: number;
  pace: number;
  durationMinutes: number;
}


export interface PedometerData {
  steps: number;
}

export interface HeartRateData {
  heartRate: number;
}