#import "VCSeguePush.h"
#import "VCSlideMenuRootViewController.h"
#import "VCSlideMenuRightViewController.h"
#import "VCSlideMenuNavigationViewController.h"

@implementation VCSeguePush
#pragma mark - initializers
- (id)initWithIdentifier:(NSString *)identifier source:(UIViewController *)source destination:(UIViewController *)destination{
    if (self = [super initWithIdentifier:identifier source:source destination:destination]){
        self.segueType = VCSegueTypePush;
    }
    return self;
}

#pragma mark - perform
- (void)perform{
    VCSlideMenuRightViewController *source = self.sourceViewController;
    VCSlideMenuRootViewController *rootViewController = source.rootViewController;
    VCSlideMenuNavigationViewController *destinationViewController = self.destinationViewController;
    
    [rootViewController pushRightNavigationController:destinationViewController];
}
@end
