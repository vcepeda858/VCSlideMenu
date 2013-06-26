@class VCSlideMenuViewController;
@class VCSlideMenuNavigationViewController;

@interface VCSlideMenuRootViewController : UIViewController
@property (strong, nonatomic, readonly) UINavigationController *selectedViewController;
@property (strong, nonatomic) VCSlideMenuViewController *leftMenu;
@property (strong, nonatomic) UIViewController *rightMenu;
@property (assign, nonatomic) Boolean isRightMenuEnabled;
@property (strong, nonatomic) VCSlideMenuNavigationViewController *navigationController;

- (UINavigationController*)navigationControllerForIndexPath:(NSIndexPath*)indexPath;
- (void)addContentViewController:(UIViewController*)viewController withIndexPath:(NSIndexPath*)indexPath;
- (void)slideToSide;
- (void)popRightNavigationController;
- (void)pushRightNavigationController:(VCSlideMenuNavigationViewController*)navigationController;
- (void)performRightMenuAction;
- (void)switchToContentViewController:(UINavigationController*)navigationController;
- (void)slideInCompletion:(void (^)(BOOL completed))completion;
@end
