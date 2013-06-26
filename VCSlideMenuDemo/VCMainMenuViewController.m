#import "VCMainMenuViewController.h"
#import "VCSegue.h"
#import "VCSegueModal.h"
#import "VCSegueType.h"
#import "MainMenuItemType.h"
#import "VCMainMenuTableViewCell.h"
#import <QuartzCore/QuartzCore.h>

@interface VCMainMenuViewController ()<VCSlideMenuDataSource, VCSlideMenuDelegate>{
    NSDictionary *mainMenuBySection;
    NSIndexPath *previousSelectedIndexPath;
}
@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;
@end

@implementation VCMainMenuViewController
#pragma mark - initialization
- (id)initWithCoder:(NSCoder *)aDecoder{
    if (self = [super initWithCoder:aDecoder]){
        mainMenuBySection = @{};
    }
    return self;
}

#pragma mark - viewcontroller life cycle
- (void)viewDidLoad{
    [super viewDidLoad];
    
    self.backgroundImageView.image = [[UIImage imageNamed:@"bg_mainMenu"] resizableImageWithCapInsets:UIEdgeInsetsMake(2,2,2,2)];
    
    // cell registration
    [self.tableView registerNib:[UINib nibWithNibName:@"VCMainMenuTableViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:[VCMainMenuTableViewCell cellIdentifier]];
    
    mainMenuBySection = [self _generateMenuItems];
    self.slideMenuDataSource = self;
    self.slideMenuDelegate = self;
}

- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
    
    if ([self isViewLoaded] && self.view.window == nil){
        self.view = nil;
        mainMenuBySection = nil;
        previousSelectedIndexPath = nil;
    }
}

#pragma mark - private methods
- (NSDictionary*)_generateMenuItems{
    return @{
             @(MainMenuSectionItemSection1):@[@(MainMenuItemHome)],
             @(MainMenuSectionItemSection2):@[@(MainMenuItemPage1), @(MainMenuItemPage2), @(MainMenuItemPage3)],
             @(MainMenuSectionItemSection3):@[@(MainMenuItemPage4), @(MainMenuItemPage5), @(MainMenuItemPage6), @(MainMenuItemPage7), @(MainMenuItemPage8), @(MainMenuItemPage9), @(MainMenuItemPage10)]
            };
}

- (NSIndexPath*)_indexPathForMenuItem:(MainMenuItem)aMenuItem{
    NSIndexPath __block *menuItemIndexPath = nil;
    for (int __block section = MainMenuSectionItemUnknown + 1; section < MainMenuSectionItemMax; section++){
        NSArray *menuItemsForSection = mainMenuBySection[@(section)];
        if (menuItemsForSection){
            [menuItemsForSection enumerateObjectsUsingBlock:^(NSNumber *menuItem, NSUInteger row, BOOL *stop) {
                if ([menuItem integerValue] == aMenuItem){
                    menuItemIndexPath = [NSIndexPath indexPathForItem:row inSection:section-1];
                    section = MainMenuSectionItemMax;
                    *stop = YES;
                }
            }];
        }
    }
    return  menuItemIndexPath;
}

- (MainMenuItem)_menuItemForIndexPath:(NSIndexPath*)indexPath{
    NSAssert(indexPath.section + 1 > MainMenuSectionItemUnknown && indexPath.section + 1 < MainMenuSectionItemMax, @"Unknown MenuSection for menuItemForIndexPath");
    NSArray *menuItemsForSection = mainMenuBySection[@(indexPath.section+1)];
    NSAssert(indexPath.row < [menuItemsForSection count], @"Unknown MenuRow for menuItemForIndexPath");
    return [menuItemsForSection[indexPath.row] integerValue];
}

#pragma mark Segue
- (void)prepareForSegue:(UIStoryboardSegue*)segue sender:(id)sender{
    if ([segue isKindOfClass:[VCSegue class]]){
        VCSegueType segueType = ((VCSegue*)segue).segueType;
        if (segueType == VCSegueTypeModal)
            [self highlightRowAtIndexPath:previousSelectedIndexPath];
    }
}

#pragma mark - CGSBSlideMenuDataSource
- (Boolean)allowsCachingForViewControllerAtIndexPath:(NSIndexPath*)indexPath{
    return NO;
}

- (Boolean)allowsPanGestureForIndexPath:(NSIndexPath*)indexPath{
    MainMenuItem menuItem = [self _menuItemForIndexPath:indexPath];
    switch (menuItem) {
        case MainMenuItemHome:
        case MainMenuItemPage1:
        case MainMenuItemPage2:
        case MainMenuItemPage3:
        case MainMenuItemPage4:
        case MainMenuItemPage5:
        case MainMenuItemPage6:
        case MainMenuItemPage7:
        case MainMenuItemPage8:
        case MainMenuItemPage9:
        case MainMenuItemPage10:
            return YES;
            break;
        default:
            return NO;
    }
}

- (Boolean)allowsSlideOutThenInForIndexPath:(NSIndexPath*)indexPath{
    return YES;
}

- (Boolean)hasRightMenuForIndexPath:(NSIndexPath*)indexPath{
    MainMenuItem menuItem = [self _menuItemForIndexPath:indexPath];
    switch (menuItem) {
        case MainMenuItemPage2:
        case MainMenuItemPage4:
        case MainMenuItemPage6:
        case MainMenuItemPage8:
        case MainMenuItemPage10:
            return YES;
            break;
        case MainMenuItemHome:
        case MainMenuItemPage1:
        case MainMenuItemPage3:
        case MainMenuItemPage5:
        case MainMenuItemPage7:
        case MainMenuItemPage9:
        default:
            return NO;
    }
}

- (CGFloat)widthForLeftMenuWhenVisibleAtIndexPath:(NSIndexPath*)indexPath{
    MainMenuItem menuItem = [self _menuItemForIndexPath:indexPath];
    switch (menuItem) {
        case MainMenuItemHome:
        case MainMenuItemPage1:
        case MainMenuItemPage2:
        case MainMenuItemPage3:
        case MainMenuItemPage4:
        case MainMenuItemPage5:
        case MainMenuItemPage6:
        case MainMenuItemPage7:
        case MainMenuItemPage8:
        case MainMenuItemPage9:
        case MainMenuItemPage10:
        default:
            return 220;
    }
}

- (CGFloat)widthForRightMenuWhenVisibleAtIndexPath:(NSIndexPath*)indexPath{
    MainMenuItem menuItem = [self _menuItemForIndexPath:indexPath];
    switch (menuItem) {
        case MainMenuItemHome:
        case MainMenuItemPage1:
        case MainMenuItemPage2:
        case MainMenuItemPage3:
        case MainMenuItemPage4:
        case MainMenuItemPage5:
        case MainMenuItemPage6:
        case MainMenuItemPage7:
        case MainMenuItemPage8:
        case MainMenuItemPage9:
        case MainMenuItemPage10:
        default:
            return 200;
    }
}

- (NSIndexPath*)initiallySelectedIndexPath{
    return [self _indexPathForMenuItem:MainMenuItemHome];
}

- (NSTimeInterval)animationDuration{
    return 0.3;
}

- (void)customizeLeftMenuButton:(UIButton*)leftMenuButton{
    leftMenuButton.frame = CGRectMake(0, 0, 40, 29);
    [leftMenuButton setImage:[UIImage imageNamed:@"iconMenu"] forState:UIControlStateNormal];
    [leftMenuButton setBackgroundImage:[[UIImage imageNamed:@"button_bg_mainMenu_normal"] resizableImageWithCapInsets:UIEdgeInsetsMake(13, 5, 13, 5)] forState:UIControlStateNormal];
    [leftMenuButton setBackgroundImage:[[UIImage imageNamed:@"button_bg_mainMenu_normal"] resizableImageWithCapInsets:UIEdgeInsetsMake(13, 5, 13, 5)] forState:UIControlStateHighlighted];
    [leftMenuButton setAdjustsImageWhenHighlighted:NO];
    [leftMenuButton setAdjustsImageWhenDisabled:NO];
}

- (void)customizeRightMenuButton:(UIButton*)rightMenuButton{
    rightMenuButton.frame = CGRectMake(0, 0, 40, 29);
    [rightMenuButton setImage:[UIImage imageNamed:@"iconMenu"] forState:UIControlStateNormal];
    [rightMenuButton setBackgroundImage:[[UIImage imageNamed:@"button_bg_mainMenu_normal"] resizableImageWithCapInsets:UIEdgeInsetsMake(13, 5, 13, 5)] forState:UIControlStateNormal];
    [rightMenuButton setBackgroundImage:[[UIImage imageNamed:@"button_bg_mainMenu_normal"] resizableImageWithCapInsets:UIEdgeInsetsMake(13, 5, 13, 5)] forState:UIControlStateHighlighted];
    [rightMenuButton setAdjustsImageWhenHighlighted:NO];
    [rightMenuButton setAdjustsImageWhenDisabled:NO];
}

- (void)customizeViewControllerLayer:(CALayer*)layer{
    layer.shadowColor = [UIColor blackColor].CGColor;
    layer.shadowOpacity = 0.5;
    layer.shadowOffset = CGSizeMake(-15, 0);
    layer.shadowRadius = 10;
    layer.masksToBounds = NO;
    layer.shadowPath =[UIBezierPath bezierPathWithRect:layer.bounds].CGPath;
}

- (void)prepareToPresentModalViewController:(UIViewController*)viewController{}

- (void)prepareToPresentViewController:(UINavigationController*)navigationController{}

- (NSString*)leftMenuSegueIdForIndexPath:(NSIndexPath*)indexPath{
    MainMenuItem menuItem = [self _menuItemForIndexPath:indexPath];
    return [NSString stringWithFormat:@"MainMenuSegue%i", menuItem];
}

- (NSString*)rightMenuSegueIdForIndexPath:(NSIndexPath*)indexPath{
    NSString *segueId = nil;
    if ([self hasRightMenuForIndexPath:indexPath]){
        MainMenuItem menuItem = [self _menuItemForIndexPath:indexPath];
        segueId = [NSString stringWithFormat:@"rightMenu%i", menuItem];
    }
    return segueId;
}

#pragma mark - CGSBSlideMenuDelegate
- (void)slideMenuWillSlideToRight{
    NSLog(@"%@", NSStringFromSelector(_cmd));
}

- (void)slideMenuDidSlideToRight{
    NSLog(@"%@", NSStringFromSelector(_cmd));
}

- (void)slideMenuWillSlideInFromLeft{
    NSLog(@"%@", NSStringFromSelector(_cmd));
}

- (void)slideMenuDidSlideInFromLeft{
    NSLog(@"%@", NSStringFromSelector(_cmd));
}

- (void)slideMenuWillSlideInFromRight{
    NSLog(@"%@", NSStringFromSelector(_cmd));
}

- (void)slideMenuDidSlideInFromRight{
    NSLog(@"%@", NSStringFromSelector(_cmd));
}

- (void)slideMenuWillSlideOut{
    NSLog(@"%@", NSStringFromSelector(_cmd));
}

- (void)slideMenuDidSlideOut{
    NSLog(@"%@", NSStringFromSelector(_cmd));
}

- (void)slideMenuWillSlideToLeft{
    NSLog(@"%@", NSStringFromSelector(_cmd));
}

- (void)slideMenuDidSlideToLeft{
    NSLog(@"%@", NSStringFromSelector(_cmd));
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return [mainMenuBySection count];
}

- (NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section{
    return [mainMenuBySection[@(section+1)] count];
}

- (VCMainMenuTableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath{
    VCMainMenuTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[VCMainMenuTableViewCell cellIdentifier]
                                                                      forIndexPath:indexPath];
    cell.menuItemType = [mainMenuBySection[@(indexPath.section+1)][indexPath.row] integerValue];
    return cell;
}

#pragma mark - UITableViewDelegate
- (UIView *)tableView:(UITableView*)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *customView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.tableView.frame.size.width, 22)];
    customView.backgroundColor = [UIColor blackColor];
    customView.layer.shadowPath = [UIBezierPath bezierPathWithRect:CGRectMake(0.0, 0.0, customView.frame.size.width, 32.0)].CGPath;
    customView.layer.shadowOpacity = 0.3f;
    
    UIImageView *background = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.tableView.frame.size.width, 22)];
    background.image = [[UIImage imageNamed:@"bg_mainMenuSectionHeader"] resizableImageWithCapInsets:UIEdgeInsetsMake(10, 3, 10, 3)];
    [customView addSubview:background];
	
	UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    headerLabel.frame = CGRectMake(0.0, 0.0, tableView.frame.size.width, 22.0);
	headerLabel.text = [kMainMenuSections[@(section+1)] uppercaseString];
	[customView addSubview:headerLabel];
    
	return customView;
}

- (void)tableView:(UITableView*)tableView didUnhighlightRowAtIndexPath:(NSIndexPath*)indexPath{
    previousSelectedIndexPath = [self.tableView indexPathForSelectedRow];
}

- (void)highlightRowAtIndexPath:(NSIndexPath*)indexPath{
    [self.tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
}
@end
