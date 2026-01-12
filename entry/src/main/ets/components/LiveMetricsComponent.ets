import { RunState } from '../models/RunModels';
import { MetricCard } from './MetricCard';

@Component
export struct LiveMetricsComponent {
  @Prop runState!: RunState;

  build() {
    Grid() {
      GridItem() {
        MetricCard({ title: 'Steps', value: this.runState.liveMetrics.stepsTotal.toString() })
      }

      GridItem() {
        MetricCard({
          title: 'Heart Rate',
          value: this.runState.liveMetrics.heartRate ? `${this.runState.liveMetrics.heartRate} bpm` : '--'
        })
      }

      GridItem() {
        MetricCard({
          title: 'Pace',
          value: `${this.runState.liveMetrics.pace.toFixed(2)} min/km`
        })
      }

      GridItem() {
        MetricCard({
          title: 'Time',
          value: `${Math.floor(this.runState.liveMetrics.durationMinutes)}:${Math.round((this.runState.liveMetrics.durationMinutes %
            1) * 60).toString().padStart(2, '0')}`
        })
      }
    }
    .columnsTemplate('1fr 1fr')
    .rowsTemplate('1fr 1fr')
    .columnsGap(10)
    .rowsGap(10)
    .height(120)
    .width(120)
  }
}
