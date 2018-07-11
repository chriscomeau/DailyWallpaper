//
//  Helpers.m
//
//  Created by Chris Comeau on 2013-10-29.
//

#import "Helpers.h"
#import "GAI.h"
#import "GAITracker.h"
#import "GAIDictionaryBuilder.h"
#import "GAIFields.h"
#import "NSString+Utilities.h"
#import <SystemConfiguration/SCNetworkReachability.h>
#import "Reachability.h"
#import "SVProgressHUD.h"
#import "ChimpKit.h"
#import "SubscribeAlertView.h"
#import <ImageIO/ImageIO.h>
#import <ImageIO/CGImageSource.h>
#import <ImageIO/CGImageProperties.h>
#import "NYXImagesKit.h"

#import "HapticHelper.h"

@implementation Helpers

+(void) setupGoogleAnalyticsForView:(NSString*)viewName {
    // returns the same tracker you created in your app delegate
    // defaultTracker originally declared in AppDelegate.m
    id tracker = [[GAI sharedInstance] defaultTracker];
    
    //can be null
    if(!tracker)
        return;
    
    // This screen name value will remain set on the tracker and sent with
    // hits until it is set to a new value or to nil.
    [tracker set:kGAIScreenName value:@"HomeController"];
    
    // manual screen tracking
    [tracker send:[[GAIDictionaryBuilder createAppView] build]];
}

+(void) sendGoogleAnalyticsEventWithView:(NSString*)viewName andEvent:(NSString*)eventName {
    // returns the same tracker you created in your app delegate
    // defaultTracker originally declared in AppDelegate.m
    id tracker = [[GAI sharedInstance] defaultTracker];

    
    //can be null
    if(!tracker)
        return;

    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:viewName    // Event category (required)
                                                          action:eventName  // Event action (required)
                                                           label:@""         // Event label
                                                           value:nil] build]];    // Event value
}

+(void)showAlertWithTitle:(NSString*)title andMessage:(NSString*)message {
        UIAlertView *alert = [[UIAlertView alloc]
                                     initWithTitle:title
                                     message:message
                                     delegate:self
                                     cancelButtonTitle:@"OK"
                                     otherButtonTitles:nil];
        [alert show];
}

+(void) showErrorHud:(NSString*)error {

    [SVProgressHUD showErrorWithStatus:error];
    //after delay
    float secs = 1.0f;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, secs * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [SVProgressHUD dismiss];
    });

}
+(void) showMessageHud:(NSString*)message {

    [SVProgressHUD showSuccessWithStatus:message];
    //after delay
    float secs = 1.0f;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, secs * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [SVProgressHUD dismiss];
    });

}

+ (BOOL) checkOnline {
    BOOL tempOnline = YES;
    
    if(![self hasConnection])
        tempOnline = NO;
    
    return tempOnline;
}

+ (BOOL) hasConnection {
    Reachability *reachability = [Reachability reachabilityForInternetConnection];    
    NetworkStatus internetStatus = [reachability currentReachabilityStatus];
    
    if (internetStatus == NotReachable) 
    {
        return false;
    }
    else
    {
        return true;
    }
}

+(void) offsetTextField:(UITextField*)textField {
    UIView *paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 5, textField.frame.size.height)];
    textField.leftView = paddingView;
    textField.leftViewMode = UITextFieldViewModeAlways;
}

+ (BOOL) isIpad
{
    #ifdef UI_USER_INTERFACE_IDIOM
        return (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad);
    #else
        return NO;
    #endif
}

+ (UIImage *)imageWithColor:(UIColor *)color andSize:(CGSize)size
{
    UIImage *img = nil;

    CGRect rect = CGRectMake(0, 0, size.width, size.height);
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context,
                               color.CGColor);
    CGContextFillRect(context, rect);

    img = UIGraphicsGetImageFromCurrentImageContext();

    UIGraphicsEndImageContext();

    return img;
}


+ (UIImage*)imageByScalingAndCroppingForSize:(CGSize)targetSize withImage:(UIImage*)sourceImage
{
    if(!sourceImage)
        return nil;
    /*
    if([self isRetina])
    {
        targetSize.height *=2;
        targetSize.width *=2;
    }
    
    UIImage *output = sourceImage;

    output = [output scaleToSize:targetSize usingMode:NYXResizeModeAspectFill];

    output = [output cropToSize:targetSize usingMode:NYXCropModeCenter];
    
    return output;
    */

    //UIImage *sourceImage = self;
    UIImage *newImage = nil;    
    CGSize imageSize = sourceImage.size;
    CGFloat width = imageSize.width;
    CGFloat height = imageSize.height;
    CGFloat targetWidth = targetSize.width;
    CGFloat targetHeight = targetSize.height;
    CGFloat scaleFactor = 0.0;
    CGFloat scaledWidth = targetWidth;
    CGFloat scaledHeight = targetHeight;
    CGPoint thumbnailPoint = CGPointMake(0.0,0.0);

    if (CGSizeEqualToSize(imageSize, targetSize) == NO) 
    {
        CGFloat widthFactor = targetWidth / width;
        CGFloat heightFactor = targetHeight / height;

        if (widthFactor > heightFactor) 
        {
            scaleFactor = widthFactor; // scale to fit height
        }
        else
        {
            scaleFactor = heightFactor; // scale to fit width
        }

        scaledWidth  = width * scaleFactor;
        scaledHeight = height * scaleFactor;

        // center the image
        if (widthFactor > heightFactor)
        {
            thumbnailPoint.y = (targetHeight - scaledHeight) * 0.5; 
        }
        else
        {
            if (widthFactor < heightFactor)
            {
                thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5;
            }
        }
    }   

    UIGraphicsBeginImageContext(targetSize); // this will crop

    CGRect thumbnailRect = CGRectZero;
    thumbnailRect.origin = thumbnailPoint;
    thumbnailRect.size.width  = scaledWidth;
    thumbnailRect.size.height = scaledHeight;

    [sourceImage drawInRect:thumbnailRect];

    newImage = UIGraphicsGetImageFromCurrentImageContext();

    if(newImage == nil)
    {
        NSLog(@"could not scale image");
    }

    //pop the context to get back to the default
    UIGraphicsEndImageContext();

    return newImage;
}

+ (BOOL) isSimulator
{

#if TARGET_IPHONE_SIMULATOR
    return YES;
#else
    return NO;
#endif

}


+ (BOOL) isDebug
{
#ifdef DEBUG
    return YES;
#else
    return NO;
#endif
}

+ (BOOL) isRetina
{
   if ([[UIScreen mainScreen] respondsToSelector:@selector(displayLinkWithTarget:selector:)] &&
        ([UIScreen mainScreen].scale == 2.0)) 
    {
      // Retina display
      return YES;
    }
    else 
    {
        return NO;
    }
}


+ (BOOL) isIphone5
{
   if ( fabs( ( double )[ [ UIScreen mainScreen ] bounds ].size.height - ( double )568 ) < DBL_EPSILON )
    {
      // iphone 5
      return YES;
    }
    else 
    {
        return NO;
    }
}

/*
+(float) getLatitude {
    float latitude = kAppDelegate.locationManager.location.coordinate.latitude;
    return latitude;
}

+(float) getLongitude {
    float longitude = kAppDelegate.locationManager.location.coordinate.longitude;
    return longitude;
}
*/
+ (double)randomFloatBetween:(double)smallNumber andBig:(double)bigNumber {
    double diff = bigNumber - smallNumber;
    return (((double) (arc4random() % ((unsigned)RAND_MAX + 1)) / RAND_MAX) * diff) + smallNumber;
}

/*+(void) startUpdatingLocation {
     [kAppDelegate startUpdatingLocation];
}
*/

+ (void)initMailChimp:(id)sender
{
    //mailchimp
    [ChimpKit setTimeout:15];
    ChimpKit *ck = [[ChimpKit alloc] initWithDelegate:sender  andApiKey:kMailChimpAPIKey];
    
    if(ck == nil) {
        NSLog(@"ChimpKit init error.");
        return;
    }
    
    //manual subscribe?
    /*// Build the params dictionary (please see documentation at http://apidocs.mailchimp.com/1.3 )
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setValue:kMailChimpListID forKey:@"id"];
    [params setValue:@"someemail@example.com" forKey:@"email_address"];
    [params setValue:@"true" forKey:@"double_optin"];
    [params setValue:@"true" forKey:@"update_existing"];

    NSMutableDictionary *mergeVars = [NSMutableDictionary dictionary];
    [mergeVars setValue:@"First" forKey:@"FNAME"];
    [mergeVars setValue:@"Last" forKey:@"LNAME"];
    [params setValue:mergeVars forKey:@"merge_vars"];

    [ck callApiMethod:@"listSubscribe" withParams:params];
    */
    
    //http://chesstris.com/2012/07/10/mailchimp-signups-from-ios-how-to-add-a-subscriber-to-a-mailchimp-group/
    
    // get the lists
    // [ck callApiMethod:@"lists" withParams:nil];
     
    // get the list groups
    /*NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setValue:kMailChimpListID forKey:@"id"];
    [ck callApiMethod:@"listInterestGroupings" withParams:params];*/
}

+ (void)showMailChimp
{
    //disabled
    return;
    
    SubscribeAlertView *alert = [[SubscribeAlertView alloc]
                                 initWithTitle:@"Newsletter Sign-up"
                                 message:@"To sign up for the newsletter please input your email address below."
                                 apiKey:kMailChimpAPIKey
                                 listId:kMailChimpListID
                                 cancelButtonTitle:@"Cancel"
                                 subscribeButtonTitle:@"Confirm"];
    [alert show];
    
    [kAppDelegate setPrefMailchimpShown:YES];
    [kAppDelegate saveState];
}

+ (void)shouldShowMailChimp
{
    float secs = 0.5f;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, secs * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        if(![Helpers checkOnline])
            return;
        
        if([kAppDelegate inReview])
            return;

        if([kAppDelegate prefMailchimpShown])
            return;
        
        int numShow = [kAppDelegate prefMailchimpCount];
        if(numShow >= kMailChimpShowMax)
        {
            [kAppDelegate setPrefMailchimpShown:YES];
            [kAppDelegate saveState];

            //delay
            [Helpers showMailChimp];
        }
        else
        {
            //inc
            [kAppDelegate setPrefMailchimpCount:numShow+1];
            [kAppDelegate saveState];
        }
        
    });
}



+ (void)initGoogleAnalytics
{
    [GAI sharedInstance].trackUncaughtExceptions = NO;
    [GAI sharedInstance].dispatchInterval = 20;
    [[[GAI sharedInstance] logger] setLogLevel:kGAILogLevelWarning];
    [[GAI sharedInstance] trackerWithTrackingId:kGoogleAnalyticsTrackingID];

}

@end




