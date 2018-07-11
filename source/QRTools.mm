//
//  QRTools.m
//  QRLockScreen
//
//  Created by Chris Comeau on 4/24/13.
//
//

#import "QRTools.h"
#import "QREncoder.h"

@implementation QRTools

+(UIImage *)qrFromString:(NSString *)string withSize:(int)size
{
	UIImage *newQRImage = nil;
	
	//generate
	DataMatrix* qrMatrix = [QREncoder encodeWithECLevel:QR_ECLEVEL_AUTO version:QR_VERSION_AUTO string:string];
	int qrcodeImageDimension = [qrMatrix dimension]; //get size
	newQRImage = [QREncoder renderDataMatrix:qrMatrix imageDimension:qrcodeImageDimension];
		
	assert(newQRImage);

	//resizes
	UIGraphicsBeginImageContext(CGSizeMake(size, size));
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGContextSetInterpolationQuality(context, kCGInterpolationNone);
	[newQRImage drawInRect:CGRectMake(0,0,size,size)];
	UIImage *resized = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();

	
	return resized;
}


@end
