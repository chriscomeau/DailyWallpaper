#import "NSString+Utilities.h"
            
@implementation NSString (Utilities)

- (BOOL) contains:(NSString*)toCheck
{
    if(toCheck == nil)
        return NO;
    
    NSRange parametersRange = [self rangeOfString:toCheck];
    if (parametersRange.location == NSNotFound)
        return NO;
    else
        return YES;
}

@end
