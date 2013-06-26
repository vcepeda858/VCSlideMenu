#import "VCSlideMenuViewController.h"
#import "VCSlideMenuRootViewController.h"

@interface VCSlideMenuViewController ()

@end

@implementation VCSlideMenuViewController
#pragma mark - gestures
- (BOOL)gestureRecognizer:(UIGestureRecognizer*)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer{
    return [otherGestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]];
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath{
    if ([self.slideMenuDataSource respondsToSelector:@selector(leftMenuSegueIdForIndexPath:)]){
        UINavigationController *navigationController = [self.rootViewController navigationControllerForIndexPath:indexPath];
        
        if (navigationController){
            [self.rootViewController switchToContentViewController:navigationController];
            return;
        }
        
        NSString *segueId = [self.slideMenuDataSource leftMenuSegueIdForIndexPath:indexPath];
        if (segueId)
            [self performSegueWithIdentifier:segueId sender:self];
    }
}
@end
