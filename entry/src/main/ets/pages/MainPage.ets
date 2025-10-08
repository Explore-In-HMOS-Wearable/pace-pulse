import { RunState } from '../models/RunModels';
import { runViewModel } from '../viewmodels/RunViewModel';
import { router } from '@kit.ArkUI';
import permissionsUtil from '../utils/PermissionManager';
import { abilityAccessCtrl, Permissions } from '@kit.AbilityKit';

@Entry
@Component
struct MainPage {
  @State private currentState: RunState = runViewModel.getCurrentState();
  @State private isInitialized: boolean = false;
  @State private permissionsGranted: boolean = false;
  @State private isLoading: boolean = true;
  private requiredPermissions: Permissions[] = [
    'ohos.permission.ACTIVITY_MOTION',
    'ohos.permission.READ_HEALTH_DATA'
  ];

  async aboutToAppear(): Promise<void> {
    console.info('MainPage aboutToAppear - Checking permissions');

    try {
      await this.checkAndRequestPermissions();
      this.setupStateListener();
      this.handleInitialNavigation();

    } catch (error) {
      this.isLoading = false;
    }
  }

  private async checkAndRequestPermissions(): Promise<void> {
    try {
      await permissionsUtil.checkPermissions(this.requiredPermissions);
      await this.verifyPermissions();
    } catch (error) {
    }
  }

  private async verifyPermissions(): Promise<void> {
    for (let permission of this.requiredPermissions) {
      const grantStatus = await permissionsUtil.checkAccessToken(permission);
      if (grantStatus !== abilityAccessCtrl.GrantStatus.PERMISSION_GRANTED) {
        throw new Error(`Permission ${permission} not granted`);
      }
    }

    this.permissionsGranted = true;
    this.isLoading = false;
    console.info('All permissions granted successfully');
    this.handleNavigation();
  }

  private setupStateListener(): void {
    if (this.isInitialized) {
      return;
    }
    this.isInitialized = true;
    runViewModel.onStateChange((state: RunState) => {
      console.info('State changed to:', state.currentPage);
      this.currentState = state;

      if (this.permissionsGranted) {
        this.handleNavigation();
      }
    });
  }

  private handleInitialNavigation(): void {
    if (!this.permissionsGranted) {
      return;
    }

    const initialState: RunState = runViewModel.getCurrentState();
    this.navigateToPage(initialState.currentPage);
    this.isInitialized = true;
  }

  private handleNavigation(): void {
    if (!this.isInitialized || !this.permissionsGranted) {
      return;
    }
    this.navigateToPage(this.currentState.currentPage);
  }

  private navigateToPage(page: 'start' | 'running' | 'heartRateAlert'): void {

    try {
      const currentUrl = router.getState().path;
      const targetUrl: string = this.getPageUrl(page);
      console.info(`Router navigating to: ${targetUrl}`);
      if (currentUrl === targetUrl) {
        console.info('Already on target page, skipping navigation');
        return;
      }
      router.pushUrl({
        url: targetUrl
      }).then(() => {
        console.info('Navigation successful');
      }).catch((error: Error) => {
        console.error('Navigation failed:', error.message);
      });

    } catch (error) {
      console.error('Navigation error:', error);
    }
  }

  private getPageUrl(page: 'start' | 'running' | 'heartRateAlert'): string {
    switch (page) {
      case 'start':
        return 'pages/StartPage';
      case 'running':
        return 'pages/RunningPage';
      case 'heartRateAlert':
        return 'pages/HeartRateAlertPage';
      default:
        return 'pages/StartPage';
    }
  }

  // permission button  as callback
  private async requestPermissionsManually(): Promise<void> {
    try {
      this.isLoading = true;
      await permissionsUtil.checkPermissions(this.requiredPermissions);
      await this.verifyPermissions();
    } catch (error) {
      console.error('Manual permission request failed:', error);
      this.isLoading = false;
    }
  }

  build() {
    Column() {
      if (this.isLoading) {
        // Loading state
        this.LoadingView()
      } else if (!this.permissionsGranted) {
        this.PermissionErrorView()
      } else {
        this.NormalLoadingView()
      }
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
  }

  @Builder
  LoadingView() {
    Column() {
      Text('Running Tracker')
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
        .margin({ bottom: 20 })

      LoadingProgress()
        .width(50)
        .height(50)

    }
  }

  @Builder
  PermissionErrorView() {
    Column() {
      Image($r('app.media.startIcon'))
        .width(80)
        .height(80)
        .margin({ bottom: 20 })

      Text('Permissions Required')
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .margin({ bottom: 10 })

      Text('This app needs activity and health data permissions to track your running metrics.')
        .fontSize(14)
        .textAlign(TextAlign.Center)
        .margin({ bottom: 30 })
        .padding({ left: 20, right: 20 })

      Button('Grant Permissions')
        .width(200)
        .height(40)
        .onClick(() => {
          this.requestPermissionsManually();
        })
    }
  }

  @Builder
  NormalLoadingView() {
    Column() {
      Text('Running Tracker')
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
        .margin({ bottom: 20 })

      LoadingProgress()
        .width(50)
        .height(50)

    }
  }
}