#ifndef VCSlideMenuDemo_MainMenuItemType_h
#define VCSlideMenuDemo_MainMenuItemType_h

typedef NS_ENUM(NSInteger, MainMenuItem){
    MainMenuItemUnknown = 0,
    MainMenuItemHome    = 1,
    MainMenuItemPage1   = 2,
    MainMenuItemPage2   = 3,
    MainMenuItemPage3   = 4,
    MainMenuItemPage4   = 5,
    MainMenuItemPage5   = 6,
    MainMenuItemPage6   = 7,
    MainMenuItemPage7   = 8,
    MainMenuItemPage8   = 9,
    MainMenuItemPage9   = 10,
    MainMenuItemPage10  = 11,
    MainMenuItemMax     = 12
};

#define kMainMenuItems @{ \
    @(MainMenuItemHome):NSLocalizedString(@"MainMenuItemHome", nil), @(MainMenuItemPage1):NSLocalizedString(@"MainMenuItemPage1", nil), @(MainMenuItemPage2):NSLocalizedString(@"MainMenuItemPage2", nil), @(MainMenuItemPage3):NSLocalizedString(@"MainMenuItemPage3", nil), @(MainMenuItemPage4):NSLocalizedString(@"MainMenuItemPage4", nil), @(MainMenuItemPage5):NSLocalizedString(@"MainMenuItemPage5", nil), @(MainMenuItemPage6):NSLocalizedString(@"MainMenuItemPage6", nil), @(MainMenuItemPage7):NSLocalizedString(@"MainMenuItemPage7", nil), @(MainMenuItemPage8):NSLocalizedString(@"MainMenuItemPage8", nil), @(MainMenuItemPage9):NSLocalizedString(@"MainMenuItemPage9", nil), @(MainMenuItemPage10):NSLocalizedString(@"MainMenuItemPage10", nil) }

typedef NS_ENUM(NSInteger, MainMenuSectionItem){
    MainMenuSectionItemUnknown  = 0,
    MainMenuSectionItemSection1 = 1,
    MainMenuSectionItemSection2 = 2,
    MainMenuSectionItemSection3 = 3,
    MainMenuSectionItemMax      = 4
};

#define kMainMenuSections @{ \
@(MainMenuSectionItemSection1):NSLocalizedString(@"MainMenuSectionItemSection1", nil), \
@(MainMenuSectionItemSection2):NSLocalizedString(@"MainMenuSectionItemSection2", nil),  \
@(MainMenuSectionItemSection3):NSLocalizedString(@"MainMenuSectionItemSection3", nil) }

#endif
