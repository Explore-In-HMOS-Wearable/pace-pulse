
@ObservedV2
export class NavigationService {
  private static instance: NavigationService;
  @Trace pageInfos: NavPathStack = new NavPathStack();

  private constructor() {}

  public static getInstance(): NavigationService {
    if (!NavigationService.instance) {
      NavigationService.instance = new NavigationService();
    }
    return NavigationService.instance;
  }
}