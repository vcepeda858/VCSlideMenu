#import "VCMainMenuTableViewCell.h"

@interface VCMainMenuTableViewCell()
@property (weak, nonatomic) IBOutlet UILabel *menuItemText;
@property (weak, nonatomic) IBOutlet UIImageView *menuItemIcon;
@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;
@end

static NSString *cellId = @"MainMenuTableViewCell";
@implementation VCMainMenuTableViewCell
#pragma mark - properties
- (void)setMenuItemType:(MainMenuItem)menuItemType{
    NSAssert((menuItemType > MainMenuItemUnknown || menuItemType < MainMenuItemMax), @"Unknown MenuItemType when setting MainMenuTableViewCell menuOption");
    if (_menuItemType != menuItemType){
        _menuItemType = menuItemType;
        [self _setMenuOptionDisplay:menuItemType];
    }
}

#pragma mark - class methods
+ (NSString*)cellIdentifier{
    return cellId;
}

#pragma mark - initializers
- (id)initWithCoder:(NSCoder *)aDecoder{
    if (self = [super initWithCoder:aDecoder]){
        _menuItemText.text = @"";
        _menuItemIcon.image = nil;
    }
    return self;
}

- (void)awakeFromNib{
    [super awakeFromNib];
    self.backgroundImageView.image = [UIImage imageNamed:@"bg_mainMenuNormal"];
    self.backgroundImageView.highlightedImage = [UIImage imageNamed:@"bg_mainMenuSelected"];
}

#pragma mark - private methods
- (void)_setMenuOptionDisplay:(MainMenuItem)menuItemType{
    NSAssert((menuItemType > MainMenuItemUnknown || menuItemType < MainMenuItemMax), @"Unknown MenuItemType when setting MainMenuTableViewCell menuOption");
    self.menuItemIcon.image = [UIImage imageNamed:[[NSString stringWithFormat:@"iconMainMenu%i", menuItemType] stringByReplacingOccurrencesOfString:@" " withString:@""]];
    self.menuItemText.text = [kMainMenuItems[@(menuItemType)] uppercaseString];
}

#pragma mark - selection
- (void)setSelected:(BOOL)selected animated:(BOOL)animated{
    [super setSelected:selected animated:animated];
    self.backgroundImageView.highlighted = selected;
}
@end