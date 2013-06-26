#import "VCSegueContent.h"
#import "VCSlideMenuRootViewController.h"
#import "VCSlideMenuViewController.h"

#import <QuartzCore/QuartzCore.h>

@implementation VCSegueContent
#pragma mark - initializers
- (id)initWithIdentifier:(NSString*)identifier
                  source:(UIViewController*)source
             destination:(UIViewController*)destination{
    if (self = [super initWithIdentifier:identifier
                                  source:source
                             destination:destination]){
        self.segueType = VCSegueTypeContent;
    }
    
    return self;
}

#pragma mark - perform
- (void)perform{
    VCSlideMenuViewController *source = self.sourceViewController;
    VCSlideMenuRootViewController *rootController = source.rootViewController;
    UINavigationController *destination = self.destinationViewController;
    
    UIButton *menuButton = [UIButton new];
    if ([rootController.leftMenu.slideMenuDataSource respondsToSelector:@selector(customizeLeftMenuButton:)])
        [rootController.leftMenu.slideMenuDataSource customizeLeftMenuButton:menuButton];
    
    [menuButton addTarget:rootController
                   action:@selector(slideToSide)
         forControlEvents:UIControlEventTouchUpInside];
    
    UINavigationItem *navigationItem = destination.navigationBar.topItem;
    navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:menuButton];
    
    Boolean hasRightMenu = NO;
    rootController.isRightMenuEnabled = NO;
    NSIndexPath *selectedIndexPath = [rootController.leftMenu.tableView indexPathForSelectedRow];
    
    if ([rootController.leftMenu.slideMenuDataSource respondsToSelector:@selector(hasRightMenuForIndexPath:)])
        hasRightMenu = [rootController.leftMenu.slideMenuDataSource hasRightMenuForIndexPath:selectedIndexPath];
    
    if (hasRightMenu){
        rootController.isRightMenuEnabled = YES;
        if ([rootController.leftMenu.slideMenuDataSource respondsToSelector:@selector(customizeRightMenuButton:)]){
            UIButton *rightMenuButton = [UIButton new];
            [rootController.leftMenu.slideMenuDataSource customizeRightMenuButton:rightMenuButton];
            [rightMenuButton addTarget:rootController
                                action:@selector(performRightMenuAction)
                      forControlEvents:UIControlEventTouchUpInside];
            
            UINavigationItem *navigationItem = destination.navigationBar.topItem;
            navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:rightMenuButton];
            
            if ([rootController.leftMenu.slideMenuDataSource respondsToSelector:@selector(rightMenuSegueIdForIndexPath:)]){
                NSString *rightMenuSegueId = [rootController.leftMenu.slideMenuDataSource rightMenuSegueIdForIndexPath:selectedIndexPath];
                if (rightMenuSegueId)
                    [rootController performSegueWithIdentifier:rightMenuSegueId sender:self];
            }
        }
    }
    
    if ([rootController.leftMenu.slideMenuDataSource respondsToSelector:@selector(customizeViewControllerLayer:)]){
        [rootController.leftMenu.slideMenuDataSource customizeViewControllerLayer:[destination.view layer]];
    } else {
        CALayer *layer = destination.view.layer;
        layer.shadowColor = [UIColor blackColor].CGColor;
        layer.shadowOpacity = 0.3;
        layer.shadowOffset = CGSizeMake(-15, 0);
        layer.shadowRadius = 10;
        layer.masksToBounds = NO;
        layer.shadowPath = [UIBezierPath bezierPathWithRect:layer.bounds].CGPath;
    }
    
    [rootController switchToContentViewController:destination];
    
    if ([rootController.leftMenu.slideMenuDataSource respondsToSelector:@selector(leftMenuSegueIdForIndexPath:)]){
        NSString *segueId = [rootController.leftMenu.slideMenuDataSource leftMenuSegueIdForIndexPath:selectedIndexPath];
        if (segueId)
            [rootController addContentViewController:destination withIndexPath:selectedIndexPath];
    }
    
    Boolean allowsPanGestureForIndexPath = NO;
    
    if ([rootController.leftMenu.slideMenuDataSource respondsToSelector:@selector(allowsPanGestureForIndexPath:)])
        allowsPanGestureForIndexPath = [rootController.leftMenu.slideMenuDataSource allowsPanGestureForIndexPath:selectedIndexPath];
    
    if (allowsPanGestureForIndexPath){
        UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:rootController action:@selector(_panMenuItem:)];
        [panGesture setMaximumNumberOfTouches:2];
        [panGesture setDelegate:source];
        [destination.view addGestureRecognizer:panGesture];
    }
}
@end
