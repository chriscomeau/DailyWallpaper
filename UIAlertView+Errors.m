#import "UIAlertView+Errors.h"

@implementation UIAlertView(Errors)

+ (void)showError:(NSString *)error withTitle:title{
	UIAlertView *v = [[UIAlertView alloc] initWithTitle:title
												 message:error
												delegate:nil
									   cancelButtonTitle:NSLocalizedString(@"OK", nil)
									   otherButtonTitles:nil];
	
	[v show];
}

@end
