//
//  QRTools.h
//  QRLockScreen
//
//  Created by Chris Comeau on 4/24/13.
//
//

#import <Foundation/Foundation.h>

@interface QRTools : NSObject

+(UIImage *)qrFromString:(NSString *)string withSize:(int)size;

@end
