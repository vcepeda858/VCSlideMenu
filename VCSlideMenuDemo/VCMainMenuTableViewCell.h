#import "MainMenuItemType.h"

@interface VCMainMenuTableViewCell : UITableViewCell
@property (nonatomic) MainMenuItem menuItemType;

+ (NSString*)cellIdentifier;
@end
