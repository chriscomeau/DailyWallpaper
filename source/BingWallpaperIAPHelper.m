//
//  BingWallpaperIAPHelper.m
//  BingWallpaperiPhone
//
//  Created by Chris Comeau on 3/24/13.
//
//


#import "BingWallpaperiPhoneAppDelegate.h"
#import "BingWallpaperIAPHelper.h"

@implementation BingWallpaperIAPHelper

+ (BingWallpaperIAPHelper *)sharedInstance {
    static dispatch_once_t once;
    static BingWallpaperIAPHelper * sharedInstance;
    dispatch_once(&once, ^{
        NSSet * productIdentifiers = [NSSet setWithObjects:
                                      IAP_ID_REMOVEADS,
                                      nil];
        sharedInstance = [[self alloc] initWithProductIdentifiers:productIdentifiers];
    });
	
    return sharedInstance;
}

@end