//
//  Helpers.m
//
//  Created by Chris Comeau on 2013-10-29.
//

#import <Foundation/Foundation.h>
//#import <FacebookSDK/FacebookSDK.h>
#import "BingWallpaperiPhoneAppDelegate.h"

#import "GAI.h"
#import "GAITracker.h"
#import "GAIDictionaryBuilder.h"
#import "GAIFields.h"


//singleton
//#define kHelpers [Helpers instance]
#define kHelpers Helpers

#define kAppDelegate ((BingWallpaperiPhoneAppDelegate *)[[UIApplication sharedApplication] delegate])
//System Versioning Preprocessor Macros
#define SYSTEM_VERSION_EQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define SYSTEM_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)

//wobble
#define RADIANS(degrees) ((degrees * M_PI) / 180.0)
#define WOBBLE_DEGREES 1
#define WOBBLE_SPEED 0.2 //0.25

//analytics

#define kIsIOS7 SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7")
#define kIsIOS7_1 SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.1")
#define kIsIOS8 SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8")
#define kIsIOS9 SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"9")
#define kIsIOS932 SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"9.3.2")
#define kIsIOS10 SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"10.0")
#define kIsIOS10_2 SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"10.2")
#define kIsIOS10_3 SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"10.3")
#define kIsIOS11_0 SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"11.0")

#define kBgQueue dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)

//color
#define RGB(r, g, b) [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:1]
#define RGBA(r, g, b, a) [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:a]


@interface Helpers : NSObject

//UI
+(void) offsetTextField:(UITextField*)textField;

//analytics
+(void) setupGoogleAnalyticsForView:(NSString*)viewName;
+(void) sendGoogleAnalyticsEventWithView:(NSString*)viewName andEvent:(NSString*)eventName;

//alerts
+(void) showAlertWithTitle:(NSString*)title andMessage:(NSString*)message;
+(void) showErrorHud:(NSString*)error;
+(void) showMessageHud:(NSString*)message;

//system
+ (BOOL) isDebug;
+ (BOOL) isRetina;
+ (BOOL) isIpad;
+(BOOL) checkOnline;
+(BOOL) isIphone5;
+(BOOL) isSimulator;


//image
+ (UIImage *)imageWithColor:(UIColor *)color andSize:(CGSize)size;
+ (UIImage*)imageByScalingAndCroppingForSize:(CGSize)targetSize withImage:(UIImage*)sourceImage;


//strings
//strings
//#define LOCALIZED(x) [NSString stringWithFormat:NSLocalizedString((x), nil)]
#define LOCALIZED(x) NSLocalizedString((x), nil)

//math
+ (double)randomFloatBetween:(double)smallNumber andBig:(double)bigNumber;

//init
+ (void)initGoogleAnalytics;
+ (void)initMailChimp:(id)sender;
+ (void)showMailChimp;
+ (void)shouldShowMailChimp;

@end
