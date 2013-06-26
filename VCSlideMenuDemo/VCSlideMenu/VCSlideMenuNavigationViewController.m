#import "VCSlideMenuNavigationViewController.h"

@implementation VCSlideMenuNavigationViewController
#pragma mark - overridden super methods
-(UIViewController*)popViewControllerAnimated:(BOOL)animated{
    if (self.topViewController == self.lastViewController) {
        [self.rootViewController popRightNavigationController];
        return nil;
    } else {
        return [super popViewControllerAnimated:animated];
    }
}
@end
