#import "VCSlideMenuRootViewController.h"
#import "VCSlideMenuViewController.h"
#import "VCSlideMenuNavigationViewController.h"

#define kDefaultAnimationDuration 0.3
#define kDefaultMenuWidth 280

typedef NS_ENUM(NSInteger, MenuState){
    MenuStateUnknown = 0,
    MenuStateInitialize = 1,
    MenuStateContentDisplayed = 2,
    MenuStateLeftMenuDisplayed = 3,
    MenuStateRightMenuDisplayed = 4,
    MenuStateMax = 5
};

typedef NS_ENUM(NSInteger, MenuPanningState){
    MenuPanningStateUnknown = 0,
    MenuPanningStateStopped = 1,
    MenuPanningStateLeft = 2,
    MenuPanningStateRight = 3,
    MenuPanningStateMax = 4
};

@interface VCSlideMenuRootViewController(){
    MenuState menuState;
    MenuPanningState menuPanningState;
    NSIndexPath *currentIndexPath;
    NSMutableDictionary *controllers;
}
@property (nonatomic, strong) UINavigationController *selectedViewController;
@property (nonatomic, strong) UIView *menuOverlay;
@end

@implementation VCSlideMenuRootViewController
#pragma mark - viewcontroller life cycle
- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
    CGRect bounds = self.view.bounds;
    CGFloat menuSize = [self _rightMenuSize];
    if (UIInterfaceOrientationIsLandscape(toInterfaceOrientation)){
        CGRect rightFrame = CGRectMake(bounds.size.width - menuSize, 0, menuSize, bounds.size.height);
        self.rightMenu.view.frame = rightFrame;
        self.menuOverlay.frame = (CGRect){CGPointZero, bounds.size};
    }
}

- (void)viewDidLoad{
    [super viewDidLoad];

    controllers = [NSMutableDictionary new];//[@[] mutableCopy];
    self.menuOverlay = [[UIView alloc] initWithFrame:CGRectZero];
    menuState = MenuStateInitialize;
    menuPanningState = MenuPanningStateStopped;
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(_tappedMenuOverlay:)];
    [self.menuOverlay addGestureRecognizer:tapGesture];
    
    UIPanGestureRecognizer *menuPanGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(_panMenuItem:)];
    [menuPanGesture setMaximumNumberOfTouches:2];
    [self.menuOverlay addGestureRecognizer:menuPanGesture];
    
    [self performSegueWithIdentifier:@"leftMenu" sender:self];
    self.isRightMenuEnabled = NO;
}

- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
    
    if ([self isViewLoaded] && self.view.window == nil){
        self.view = nil;
        [controllers removeAllObjects];
        controllers = nil;
        currentIndexPath = nil;
        _menuOverlay = nil;
        _selectedViewController = nil;
    }
}

#pragma mark - gestures
- (void)_tappedMenuOverlay:(UITapGestureRecognizer*)gesture{
    [self slideInCompletion:nil];
}

- (void)_panMenuItem:(UIPanGestureRecognizer*)gesture{
    UIView *panningView = gesture.view;
    CGPoint translation = [gesture translationInView:panningView];
    UIView *movingView = self.selectedViewController.view;
    
    if ([gesture state] == UIGestureRecognizerStateBegan){
        if (movingView.frame.origin.x + translation.x < 0){
            if (self.isRightMenuEnabled && self.rightMenu != nil){
                menuPanningState = MenuPanningStateLeft;
                [self _addRightMenu];
            } else {
                translation.x = 0.0;
                menuPanningState = MenuPanningStateRight;
            }
        } else {
            menuPanningState = MenuPanningStateRight;
        }
    }
    
    if (movingView.frame.origin.x + translation.x < 0){
        if (menuPanningState == MenuPanningStateRight)
            translation.x = 0.0;
    }
    
    if (translation.x > 0 && movingView.frame.origin.x >= [self _leftMenuSize]){
        if (menuPanningState == MenuPanningStateRight)
            translation.x = 0.0;
    }
    
    if (movingView.frame.origin.x + translation.x > 0){
        if (menuState == MenuStateRightMenuDisplayed || menuPanningState == MenuPanningStateLeft)
            translation.x = 0.0;
    }
    
    CGFloat menuSize = [self _leftMenuSize];
    CGRect bounds = self.view.bounds;
    CGPoint origin = movingView.frame.origin;
    CGFloat visiblePortion = bounds.size.width - menuSize;
    
    if ((-origin.x - translation.x) > (bounds.size.width - visiblePortion)){
        if (menuPanningState == MenuPanningStateLeft)
            translation.x = visiblePortion - bounds.size.width - movingView.frame.origin.x;
    }
    
    [movingView setCenter:CGPointMake([movingView center].x + translation.x, [movingView center].y)];
    [gesture setTranslation:CGPointZero inView:[panningView superview]];
    
    if ([gesture state] == UIGestureRecognizerStateEnded){
        CGFloat pCenterX = movingView.center.x;
        CGRect bounds = self.view.bounds;
        CGSize size = bounds.size;
        
        if (menuPanningState == MenuPanningStateRight){
            if (pCenterX > size.width)
                [self slideToSide];
            else
                [self slideInCompletion:nil];
        }
        
        if (menuPanningState == MenuPanningStateLeft){
            if (pCenterX < 0)
                [self _performSlideToLeftSide];
            else
                [self _performSlideIn:nil];
        }
    }
}

#pragma mark - public methods
- (UINavigationController*)navigationControllerForIndexPath:(NSIndexPath*)indexPath{
    return controllers[indexPath];
}

- (void)addContentViewController:(UIViewController*)viewController withIndexPath:(NSIndexPath*)indexPath{
    Boolean allowsCachingForViewController = NO;
    
    if (indexPath){
        currentIndexPath = indexPath;
        if ([self.leftMenu.slideMenuDataSource respondsToSelector:@selector(allowsCachingForViewControllerAtIndexPath:)]){
            allowsCachingForViewController = [self.leftMenu.slideMenuDataSource allowsCachingForViewControllerAtIndexPath:indexPath];
            
            if (allowsCachingForViewController)
                controllers[indexPath] = viewController;
        }
    }
}

- (void)slideToSide{
    if ([self.leftMenu.slideMenuDelegate respondsToSelector:@selector(slideMenuWillSlideToRight)]){
        [self.leftMenu.slideMenuDelegate slideMenuWillSlideToRight];
        
        [UIView animateWithDuration:[self _animationDuration]
                              delay:0.0
                            options:UIViewAnimationOptionCurveEaseInOut
                            animations:^{
                                [self _slideToSide:self.selectedViewController];
                            } completion:^(BOOL finished) {
                                [self _completeSlideToSide:self.selectedViewController];
                                if ([self.leftMenu.slideMenuDelegate respondsToSelector:@selector(slideMenuDidSlideToRight)])
                                    [self.leftMenu.slideMenuDelegate slideMenuDidSlideToRight];
                            }];
    }
}

- (void)popRightNavigationController{
    CGRect bounds = self.view.bounds;
    [self.navigationController willMoveToParentViewController:nil];
    
    [UIView animateWithDuration:[self _animationDuration]
                     animations:^{
                         self.navigationController.view.frame = CGRectMake(bounds.size.width, 0, bounds.size.width, bounds.size.height);
                     } completion:^(BOOL finished) {
                         [self.navigationController.view removeFromSuperview];
                         [self.navigationController removeFromParentViewController];
                     }];
}

- (void)pushRightNavigationController:(VCSlideMenuNavigationViewController*)navigationController{
    VCSlideMenuRootViewController *rootViewController = self;
    rootViewController.navigationController = navigationController;
    navigationController.rootViewController = rootViewController;
    
    NSArray *navViewControllers = navigationController.viewControllers;
    UIViewController *emptyViewController = [UIViewController new];
    NSArray *newControllers = @[emptyViewController, navViewControllers[0]];
    [navigationController setViewControllers:newControllers animated:NO];
    navigationController.lastViewController = navViewControllers[0];
    
    CGRect bounds = rootViewController.view.bounds;
    navigationController.view.frame = (CGRect){bounds.size.width, 0.0, bounds.size};
    [rootViewController addChildViewController:navigationController];
    [rootViewController.view addSubview:navigationController.view];
    
    [UIView animateWithDuration:[self _animationDuration]
                     animations:^{
                         navigationController.view.frame = (CGRect){CGPointZero, bounds.size};
                     } completion:^(BOOL finished) {
                         [navigationController didMoveToParentViewController:rootViewController];
                     }];
}

- (void)performRightMenuAction{
    [self _addRightMenu];
    [self _performSlideToLeftSide];
}

- (void)switchToContentViewController:(UINavigationController*)navigationController{
    CGRect bounds = self.view.bounds;
    self.view.userInteractionEnabled = NO;
    
    if ([self.leftMenu.slideMenuDataSource respondsToSelector:@selector(prepareToPresentViewController:)])
        [self.leftMenu.slideMenuDataSource prepareToPresentViewController:navigationController];
    
    BOOL hideContentOnStartup = ![self.leftMenu.slideMenuDataSource respondsToSelector:@selector(initiallySelectedIndexPath)];
    if ([self.leftMenu.slideMenuDataSource respondsToSelector:@selector(initiallySelectedIndexPath)])
        currentIndexPath = [self.leftMenu.slideMenuDataSource initiallySelectedIndexPath];
    
    Boolean slideOutThenIn = NO;
    if ([self.leftMenu.slideMenuDataSource respondsToSelector:@selector(allowsSlideOutThenInForIndexPath:)])
        slideOutThenIn = [self.leftMenu.slideMenuDataSource allowsSlideOutThenInForIndexPath:currentIndexPath];
    
    if (menuState != MenuStateInitialize || hideContentOnStartup){
        if (slideOutThenIn){
            [self _performSlideOut:^(BOOL completed) {
                [self.selectedViewController willMoveToParentViewController:nil];
                [self.selectedViewController.view removeFromSuperview];
                [self.selectedViewController removeFromParentViewController];
                
                navigationController.view.frame = (CGRect){bounds.size.width, 0, bounds.size};
                [self addChildViewController:navigationController];
                [self.view addSubview:navigationController.view];
                self.selectedViewController = navigationController;
                [self _performSlideIn:^(BOOL completed) {
                    [navigationController didMoveToParentViewController:self];
                    self.view.userInteractionEnabled = YES;
                }];
            }];
        } else {
            [self.selectedViewController willMoveToParentViewController:nil];
            [self.selectedViewController.view removeFromSuperview];
            [self.selectedViewController removeFromParentViewController];
            [self _slideToSide:navigationController];
            [self addChildViewController:navigationController];
            [self.view addSubview:navigationController.view];
            self.selectedViewController = navigationController;
            [self _performSlideIn:^(BOOL completed) {
                [navigationController didMoveToParentViewController:self];
                self.view.userInteractionEnabled = YES;
            }];
        }
    } else {
        [self.selectedViewController willMoveToParentViewController:nil];
        [self.selectedViewController.view removeFromSuperview];
        [self.selectedViewController removeFromParentViewController];
        [self _slideToSide:navigationController];
        [self addChildViewController:navigationController];
        [self.view addSubview:navigationController.view];
        self.selectedViewController = navigationController;
        
        BOOL slideLeft = NO;
        if (self.selectedViewController.view.frame.origin.x > 0)
            slideLeft = YES;
        
        if ((slideLeft) && ([self.leftMenu.slideMenuDataSource respondsToSelector:@selector(slideMenuWillSlideInFromLeft)]))
            [self.leftMenu.slideMenuDelegate slideMenuWillSlideInFromLeft];
        else if ([self.leftMenu.slideMenuDelegate respondsToSelector:@selector(slideMenuWillSlideInFromRight)])
            [self.leftMenu.slideMenuDelegate slideMenuWillSlideInFromRight];
        
        [self _slideIn:self.selectedViewController];
        
        if (menuState == MenuStateRightMenuDisplayed){
            [self.rightMenu willMoveToParentViewController:nil];
            [self.rightMenu.view removeFromSuperview];
            [self.rightMenu removeFromParentViewController];
        }
        
        [self _completeSlideIn:self.selectedViewController];
        
        if ((slideLeft) && ([self.leftMenu.slideMenuDelegate respondsToSelector:@selector(slideMenuDidSlideInFromLeft)]))
            [self.leftMenu.slideMenuDelegate slideMenuDidSlideInFromLeft];
        else if ([self.leftMenu.slideMenuDelegate respondsToSelector:@selector(slideMenuDidSlideInFromRight)])
            [self.leftMenu.slideMenuDelegate slideMenuDidSlideInFromRight];
        
        [navigationController didMoveToParentViewController:self];
        self.view.userInteractionEnabled = YES;
    }
}

- (void)slideInCompletion:(void (^)(BOOL))completion{
    BOOL slideLeft = NO;
    if (self.selectedViewController.view.frame.origin.x > 0)
        slideLeft = YES;
    
    if ((slideLeft) && ([self.leftMenu.slideMenuDelegate respondsToSelector:@selector(slideMenuWillSlideInFromLeft)]))
        [self.leftMenu.slideMenuDelegate slideMenuWillSlideInFromLeft];
    else if ([self.leftMenu.slideMenuDelegate respondsToSelector:@selector(slideMenuWillSlideInFromRight)])
        [self.leftMenu.slideMenuDelegate slideMenuWillSlideInFromRight];
    
    [UIView animateWithDuration:[self _animationDuration]
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         [self _slideIn:self.selectedViewController];
                     } completion:^(BOOL finished) {
                         if (completion != nil)
                             completion(finished);
                         
                         if (menuState == MenuStateRightMenuDisplayed){
                             [self.rightMenu willMoveToParentViewController:nil];
                             [self.rightMenu.view removeFromSuperview];
                             [self.rightMenu removeFromParentViewController];
                         }
                         
                         [self _completeSlideIn:self.selectedViewController];
                         
                         if ((slideLeft) && ([self.leftMenu.slideMenuDelegate respondsToSelector:@selector(slideMenuDidSlideInFromLeft)]))
                             [self.leftMenu.slideMenuDelegate slideMenuDidSlideInFromLeft];
                         else if ([self.leftMenu.slideMenuDelegate respondsToSelector:@selector(slideMenuDidSlideInFromRight)])
                             [self.leftMenu.slideMenuDelegate slideMenuDidSlideInFromRight];
                     }];
}

#pragma mark - private slide action methods
- (void)_addOverlay:(UINavigationController*)navigationController{
    [navigationController.view addSubview:self.menuOverlay];
    self.menuOverlay.frame = navigationController.view.bounds;
}

- (void)_addRightMenu{
    CGRect bounds = self.view.bounds;
    CGFloat menuSize = [self _rightMenuSize];
    
    CGFloat visiblePortion = bounds.size.width-menuSize;
    CGRect frame  = CGRectMake(visiblePortion, 0, menuSize, bounds.size.height);
    self.rightMenu.view.frame = frame;
    self.rightMenu.view.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleHeight;
    
    [self addChildViewController:self.rightMenu];
    [self.view insertSubview:self.rightMenu.view belowSubview:self.selectedViewController.view];
    menuState = MenuStateRightMenuDisplayed;
}

- (void)_completeSlideIn:(UINavigationController*)navigationController{
    [self _removeOverlay:navigationController];
    menuState = MenuStateContentDisplayed;
}

- (void)_completeSlideToLeftSide:(UINavigationController*)navigationController{
    [self _addOverlay:navigationController];
    menuState = MenuStateRightMenuDisplayed;
}

- (void)_completeSlideToSide:(UINavigationController*)navigationController{
    [self _addOverlay:navigationController];
    menuState = MenuStateLeftMenuDisplayed;
}

- (void)_performSlideIn:(void (^)(BOOL completed))completion{
    BOOL slideLeft = NO;
    if (self.selectedViewController.view.frame.origin.x > 0)
        slideLeft = YES;
    
    if ((slideLeft) && ([self.leftMenu.slideMenuDelegate respondsToSelector:@selector(slideMenuWillSlideInFromLeft)]))
        [self.leftMenu.slideMenuDelegate slideMenuWillSlideInFromLeft];
    else if ([self.leftMenu.slideMenuDelegate respondsToSelector:@selector(slideMenuWillSlideInFromRight)])
        [self.leftMenu.slideMenuDelegate slideMenuWillSlideInFromRight];
    
    [UIView animateWithDuration:[self _animationDuration]
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         [self _slideIn:self.selectedViewController];
                     }
                     completion:^(BOOL finished) {
                         if (completion != nil)
                             completion(finished);
                         
                         if (menuState == MenuStateRightMenuDisplayed) {
                             [self.rightMenu willMoveToParentViewController:nil];
                             [self.rightMenu.view removeFromSuperview];
                             [self.rightMenu removeFromParentViewController];
                         }
                         
                         [self _completeSlideIn:self.selectedViewController];
                         
                         if ((slideLeft) && ([self.leftMenu.slideMenuDelegate respondsToSelector:@selector(slideMenuDidSlideInFromLeft)]))
                             [self.leftMenu.slideMenuDelegate slideMenuDidSlideInFromLeft];
                         else if ([self.leftMenu.slideMenuDelegate respondsToSelector:@selector(slideMenuDidSlideInFromRight)])
                             [self.leftMenu.slideMenuDelegate slideMenuDidSlideInFromRight];
                     }];
}

- (void)_performSlideOut:(void (^)(BOOL completed))completion{
    if ([self.leftMenu.slideMenuDelegate respondsToSelector:@selector(slideMenuWillSlideOut)])
        [self.leftMenu.slideMenuDelegate slideMenuWillSlideOut];
    
    [UIView animateWithDuration:[self _animationDuration]
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         [self _slideOut:self.selectedViewController];
                     }
                     completion:^(BOOL finished) {
                         if (completion != nil)
                             completion(finished);
                         if ([self.leftMenu.slideMenuDelegate respondsToSelector:@selector(slideMenuDidSlideOut)])
                             [self.leftMenu.slideMenuDelegate slideMenuDidSlideOut];
                     }];
}

- (void)_performSlideToLeftSide{
    if ([self.leftMenu.slideMenuDelegate respondsToSelector:@selector(slideMenuWillSlideToLeft)])
        [self.leftMenu.slideMenuDelegate slideMenuWillSlideToLeft];
    
    [UIView animateWithDuration:[self _animationDuration]
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         [self _slideToLeftSide:self.selectedViewController];
                     }
                     completion:^(BOOL finished) {
                         [self _completeSlideToLeftSide:self.selectedViewController];
                         if ([self.leftMenu.slideMenuDelegate respondsToSelector:@selector(slideMenuDidSlideToLeft)])
                             [self.leftMenu.slideMenuDelegate slideMenuDidSlideToLeft];
                     }];
}

- (void)_removeOverlay:(UINavigationController*)navigationController{
    [self.menuOverlay removeFromSuperview];
}

- (void)_slideIn:(UINavigationController*)navigationController{
    CGRect bounds = self.view.bounds;
    navigationController.view.frame = CGRectMake(0.0,0.0,bounds.size.width,bounds.size.height);
}

- (void)_slideToLeftSide:(UINavigationController*)navigationController{
    CGRect bounds = self.view.bounds;
    CGFloat menuSize = [self _rightMenuSize];
    navigationController.view.frame = CGRectMake(-menuSize,0.0,bounds.size.width,bounds.size.height);
}

- (void)_slideOut:(UINavigationController*)navigationController{
    CGRect bounds = self.view.bounds;
    navigationController.view.frame = CGRectMake(bounds.size.width,0.0,bounds.size.width,bounds.size.height);
}

- (void)_slideToSide:(UINavigationController*)navigationController{
    CGRect bounds = self.view.bounds;
    CGFloat menuSize = [self _leftMenuSize];
    navigationController.view.frame = CGRectMake(menuSize,0.0,bounds.size.width,bounds.size.height);
}

#pragma mark - private helper methods
- (NSTimeInterval)_animationDuration{
    if ([self.leftMenu.slideMenuDataSource respondsToSelector:@selector(animationDuration)])
        return [self.leftMenu.slideMenuDataSource animationDuration];
    else
        return kDefaultAnimationDuration;
}

- (CGFloat)_leftMenuSize{
    if ([self.leftMenu.slideMenuDataSource respondsToSelector:@selector(widthForLeftMenuWhenVisibleAtIndexPath:)])
        return [self.leftMenu.slideMenuDataSource widthForLeftMenuWhenVisibleAtIndexPath:currentIndexPath];
    else
        return kDefaultMenuWidth;
}

- (CGFloat)_rightMenuSize{
    if ([self.leftMenu.slideMenuDataSource respondsToSelector:@selector(widthForRightMenuWhenVisibleAtIndexPath:)])
        return [self.leftMenu.slideMenuDataSource widthForRightMenuWhenVisibleAtIndexPath:currentIndexPath];
    else
        return kDefaultMenuWidth;
}
@end
