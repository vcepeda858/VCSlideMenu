@protocol VCSlideMenuDataSource <NSObject>
@optional
// caches viewcontroller 
- (Boolean)allowsCachingForViewControllerAtIndexPath:(NSIndexPath*)indexPath;
// allows the user to use a pan gesture to slide the menu's in and out for the given index path
- (Boolean)allowsPanGestureForIndexPath:(NSIndexPath*)indexPath;
// animates the view out then in when selected
- (Boolean)allowsSlideOutThenInForIndexPath:(NSIndexPath*)indexPath;
// allows a right hand menu for index path
- (Boolean)hasRightMenuForIndexPath:(NSIndexPath*)indexPath;
// width for left hand menu at index path
- (CGFloat)widthForLeftMenuWhenVisibleAtIndexPath:(NSIndexPath*)indexPath;
// width for right hand menu at index path
- (CGFloat)widthForRightMenuWhenVisibleAtIndexPath:(NSIndexPath*)indexPath;
// index path for the initially selected menu item
- (NSIndexPath*)initiallySelectedIndexPath;
// duration for the animiation transition of displaying and hiding a menu
- (NSTimeInterval)animationDuration;
// customize look of left menu button
- (void)customizeLeftMenuButton:(UIButton*)leftMenuButton;
// customize look of right menu button
- (void)customizeRightMenuButton:(UIButton*)rightMenuButton;
// customize the view controller layer being displayed
- (void)customizeViewControllerLayer:(CALayer*)layer;
// prepare modal view controller before being displayed when selected as a menu item
- (void)prepareToPresentModalViewController:(UIViewController*)viewController;
// prepare view controller before being displayed when selected as a menu item
- (void)prepareToPresentViewController:(UINavigationController*)navigationController;

@required
// segue id for left menu item at index path
- (NSString*)leftMenuSegueIdForIndexPath:(NSIndexPath*)indexPath;
// segue id for right menu item at index path
- (NSString*)rightMenuSegueIdForIndexPath:(NSIndexPath*)indexPath;
@end

@protocol VCSlideMenuDelegate <NSObject>
@optional
- (void)slideMenuWillSlideToRight;
- (void)slideMenuDidSlideToRight;
- (void)slideMenuWillSlideInFromLeft;
- (void)slideMenuDidSlideInFromLeft;
- (void)slideMenuWillSlideInFromRight;
- (void)slideMenuDidSlideInFromRight;
- (void)slideMenuWillSlideOut;
- (void)slideMenuDidSlideOut;
- (void)slideMenuWillSlideToLeft;
- (void)slideMenuDidSlideToLeft;
@end

@class VCSlideMenuRootViewController;

@interface VCSlideMenuViewController : UIViewController<UIGestureRecognizerDelegate, UITableViewDataSource, UITableViewDelegate>
@property (strong, nonatomic) VCSlideMenuRootViewController *rootViewController;
@property (strong, nonatomic) NSObject<VCSlideMenuDataSource> *slideMenuDataSource;
@property (strong, nonatomic) NSObject<VCSlideMenuDelegate> *slideMenuDelegate;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@end
