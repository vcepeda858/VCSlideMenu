#import "VCSegue.h"

@implementation VCSegue
#pragma mark - initializers
- (id)initWithIdentifier:(NSString*)identifier
                  source:(UIViewController*)source
             destination:(UIViewController*)destination{
    if (self = [super initWithIdentifier:identifier
                                  source:source
                             destination:destination]){
        self.segueType = VCSegueTypeUnknown;
    }
    
    return self;
}
@end
