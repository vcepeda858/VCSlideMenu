#import "VCSlideMenuRootViewController.h"

@interface VCSlideMenuNavigationViewController : UINavigationController
@property (strong, nonatomic) VCSlideMenuRootViewController *rootViewController;
@property (strong, nonatomic) UIViewController *lastViewController;
@end
