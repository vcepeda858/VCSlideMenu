#import "VCSegueLeftMenu.h"
#import "VCSlideMenuRootViewController.h"
#import "VCSlideMenuViewController.h"

@implementation VCSegueLeftMenu
#pragma mark - initializers
- (id)initWithIdentifier:(NSString *)identifier source:(UIViewController *)source destination:(UIViewController *)destination{
    if (self = [super initWithIdentifier:identifier source:source destination:destination]){
        self.segueType = VCSegueTypeLeftMenu;
    }
    return self;
}

#pragma mark - perform
- (void)perform{
    VCSlideMenuRootViewController *rootViewController = self.sourceViewController;
    VCSlideMenuViewController *leftMenu = self.destinationViewController;
    CGRect bounds = rootViewController.view.bounds;
    leftMenu.view.frame = CGRectMake(0,0,bounds.size.width,bounds.size.height);
    
    [leftMenu willMoveToParentViewController:rootViewController];
    [rootViewController addChildViewController:leftMenu];
    [rootViewController.view addSubview:leftMenu.view];
    rootViewController.leftMenu = leftMenu;
    
    leftMenu.rootViewController = rootViewController;
    [UIView animateWithDuration:1.0
                     animations:^{
                         leftMenu.view.alpha = 1.0;
                     }
                     completion:^(BOOL finished) {
                         [leftMenu didMoveToParentViewController:rootViewController];
                         
                         if ([rootViewController.leftMenu.slideMenuDataSource respondsToSelector:@selector(initiallySelectedIndexPath)]) {
                             NSIndexPath *selectedIndexPath = [rootViewController.leftMenu.slideMenuDataSource initiallySelectedIndexPath];
                             [leftMenu.tableView selectRowAtIndexPath:selectedIndexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
                             NSString *initialSegueId = [rootViewController.leftMenu.slideMenuDataSource leftMenuSegueIdForIndexPath:selectedIndexPath];
                             
                             if (initialSegueId)
                                 [leftMenu performSegueWithIdentifier:initialSegueId sender:leftMenu];
                         }
                     }];
}
@end
