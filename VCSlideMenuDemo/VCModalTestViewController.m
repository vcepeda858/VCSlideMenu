#import "VCModalTestViewController.h"

@interface VCModalTestViewController ()

@end

@implementation VCModalTestViewController
- (IBAction)close:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
