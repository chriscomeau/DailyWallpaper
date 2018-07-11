#import "UIImage+Utilities.h"
#import <CommonCrypto/CommonDigest.h>

@implementation UIImage (Utilities)

- (NSString*)hashString {
    unsigned char result[16];
    NSData *imageData = [NSData dataWithData:UIImagePNGRepresentation(self)];
    CC_MD5([imageData bytes], [imageData length], result);
    NSString *imageHash = [NSString stringWithFormat:
                           @"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
                           result[0], result[1], result[2], result[3], 
                           result[4], result[5], result[6], result[7],
                           result[8], result[9], result[10], result[11],
                           result[12], result[13], result[14], result[15]
                           ];
    return imageHash;
}

@end
