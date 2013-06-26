#import "VCSegueRightMenu.h"
#import "VCSlideMenuRootViewController.h"
#import "VCSlideMenuRightViewController.h"

@implementation VCSegueRightMenu
#pragma mark - initializers
- (id)initWithIdentifier:(NSString *)identifier source:(UIViewController *)source destination:(UIViewController *)destination{
    if (self = [super initWithIdentifier:identifier source:source destination:destination]){
        self.segueType = VCSegueTypeRightMenu;
    }
    return self;
}

#pragma mark - perform
- (void)perform{
    VCSlideMenuRootViewController *source = self.sourceViewController;
    VCSlideMenuRightViewController *destination = self.destinationViewController;
    
    source.rightMenu = destination;
    destination.rootViewController = source;
}
@end
