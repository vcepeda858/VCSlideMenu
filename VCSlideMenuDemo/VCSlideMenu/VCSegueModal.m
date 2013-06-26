#import "VCSegueModal.h"
#import "VCSlideMenuRootViewController.h"
#import "VCSlideMenuViewController.h"

@implementation VCSegueModal
#pragma mark - initializers
- (id)initWithIdentifier:(NSString *)identifier source:(UIViewController *)source destination:(UIViewController *)destination{
    if (self = [super initWithIdentifier:identifier source:source destination:destination]){
        self.segueType = VCSegueTypeModal;
        _shouldAnimateSegue = YES;
    }
    return self;
}

#pragma mark - perform
- (void)perform{
    VCSlideMenuViewController *source = self.sourceViewController;
    VCSlideMenuRootViewController *rootViewController = source.rootViewController;
    
    if ([rootViewController.leftMenu.slideMenuDataSource respondsToSelector:@selector(prepareToPresentModalViewController:)])
        [rootViewController.leftMenu.slideMenuDataSource prepareToPresentModalViewController:self.destinationViewController];
    
    [rootViewController slideInCompletion:^(BOOL completed) {
        [self.sourceViewController presentModalViewController:self.destinationViewController animated:self.shouldAnimateSegue];
    }];
}
@end
