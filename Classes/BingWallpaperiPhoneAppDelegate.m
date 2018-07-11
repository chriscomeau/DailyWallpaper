//
//  BingWallpaperiPhoneAppDelegate.m
//
//  Created by Chris Comeau on 10-03-18.
//  Copyright Games Montreal 2010. All rights reserved.
//

#import "BingWallpaperiPhoneAppDelegate.h"
#import "iRate.h"
//#import "iVersion.h"
#import "iNotify.h"
//#import "QRTools.h"
//#import "SecureUDID.h"
#import "NSString+HTML.h"
@import Firebase;

//#import "SHK.h"
//#import "SHKConfiguration.h"
//#import "SHKFacebook.h"
//#import "ShareKitDemoConfigurator.h"

#import "UIAlertView+Errors.h"
#import <SystemConfiguration/SCNetworkReachability.h>
#import "Reachability.h"
//#import "TapForTap.h"

#include <sys/types.h>
#include <sys/sysctl.h>
#import "Crashlytics/Crashlytics.h"

#if USE_TESTFLIGHT
    #import "TestFlight.h"
#endif

#import "BingWallpaperIAPHelper.h"
#import <StoreKit/StoreKit.h>

#import "AFNetworking.h"
#import "NSDate-Utilities.h"
//#import <CommonCrypto/CommonDigest.h>

//notification
enum {
    DAY_SUNDAY = 1,
    DAY_MONDAY = 2,
    DAY_TUESDAY = 3,
    DAY_WEDNESDAY = 4,
    DAY_THURSDAY = 5,
    DAY_FRIDAY = 6,
    DAY_SATURDAY = 7,
};


@implementation BingWallpaperiPhoneAppDelegate

@synthesize window;
@synthesize navController;
@synthesize qrImage;
@synthesize showingHelp;
@synthesize prefRated;
@synthesize idArray;
@synthesize nameArray;
@synthesize descriptionArray;
@synthesize favoritesArray;
@synthesize savedAdImage;
@synthesize savedImage;
@synthesize savedThumbImage;
@synthesize firstViewController;
@synthesize random;
@synthesize popular;
@synthesize favorites;
@synthesize favoritesModified;
@synthesize isDoneLaunching;
@synthesize isOnline;
@synthesize isLoading;
@synthesize currentMaxLoad;
@synthesize totalItems;
@synthesize imageThumbArray;
@synthesize archiveViewController;
@synthesize aboutViewController;
@synthesize sideMenuViewController;
@synthesize tableLoaded;
@synthesize missingThumb;
@synthesize imageDownloadedFlag;
@synthesize imageUpdatedFlag;
@synthesize indexToLoad;
@synthesize cellBackImage1;
@synthesize cellBackImage2;
@synthesize prefRunCount;
@synthesize prefNumApps;
@synthesize currentAdId;
@synthesize currentAdUrl;
@synthesize prefPlaySound;
@synthesize prefPurchasedRemoveAds;
@synthesize prefShowAll;
@synthesize prefVersion;
@synthesize lastTimeSince70;
@synthesize prefOpened;
@synthesize splash;
@synthesize alreadyFadeDefault;
@synthesize timeLastRefresh;
@synthesize alreadySelectImage;
@synthesize isSliding;
@synthesize products;
@synthesize productRemoveAds;
@synthesize showLockscreen;
@synthesize inReview;
@synthesize prefMailchimpCount;
@synthesize prefMailchimpShown;
@synthesize operationQueue;

NSRecursiveLock *lock1;
NSRecursiveLock *lock2;
NSRecursiveLock *lock3;
NSRecursiveLock *lock4;
NSRecursiveLock *lock5;
NSRecursiveLock *lock6;
NSRecursiveLock *lock7;
NSRecursiveLock *lock8;

SystemSoundID audioEffect;
UIBackgroundTaskIdentifier bgTaskThumb;
UIBackgroundTaskIdentifier bgTaskImage;


+ (void)initialize
{
 	//configure iRate
    [iRate sharedInstance].appStoreID = 557949358;
    [iRate sharedInstance].daysUntilPrompt = 3;
    [iRate sharedInstance].usesUntilPrompt = 3;
	//[iRate sharedInstance].debug = YES;
    
    //configure iNotify
	[iNotify sharedInstance].notificationsPlistURL = @"???";
	//[iNotify sharedInstance].debug = YES;
}

-(void) applicationWillEnterForeground:(UIApplication *)application
{
	//notification
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    
    //check online
    bool wasOnline = isOnline;
    isOnline = [self checkOnline];
    
    if(!wasOnline && isOnline)
    {
            [self refresh];
    }
    else if(timeLastRefresh == nil)
    {
            [self refresh];
    }
    else
    {
        //check time background
        #define NUM_MINUTES_TO_REFRESH 60
        int secsToRefresh = 60 * NUM_MINUTES_TO_REFRESH;
        int interval = [[NSDate date] timeIntervalSinceDate:timeLastRefresh];
        if(interval > secsToRefresh)
        {
            [self refresh];
        }
    }
}


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    //crash
    [Crashlytics startWithAPIKey:@"???"];

    showingHelp = false;
    random = NO;
    popular = NO;
    favorites = NO;
    favoritesModified = NO;
    isDoneLaunching = NO;
    isOnline = NO;
    tableLoaded = NO;
    alreadyFillTable = NO;
    alreadyFillTable2 = NO;
    emptyTable = NO;
    isLoading = NO;
    alreadyLoadingNext = NO;
    alreadySelectImage = NO;
    numAppsDownloaded = NO;
    isSliding = NO;
    numApps = 0;
    adArray = nil;
    showLockscreen = NO;
    inReview = YES;
    prefMailchimpCount = 0;
    prefMailchimpShown = YES;
    
    currentMaxLoad = 0; //MAX_LOAD;
    totalItems = 0;
    
    prefPurchasedRemoveAds = NO;
    prefPlaySound = NO;
    prefShowAll = YES;
    prefVersion = [NSString stringWithFormat:@""];
    lastTimeSince70 = 0;
    prefRunCount = 0;
    prefNumApps = 0;
    timeLastRefresh = nil;
    currentAdId = 0;
    currentAdUrl = @"";

    bgTaskThumb = UIBackgroundTaskInvalid;
    bgTaskImage = UIBackgroundTaskInvalid;
    
    self.buttonTextColor = RGBA(36,36,36, 255);//[UIColor darkGrayColor];

    //random
    srand(time(NULL));
    
    lock1 = [[NSRecursiveLock alloc] init];
    lock2 = [[NSRecursiveLock alloc] init];
    lock3 = [[NSRecursiveLock alloc] init];
    lock4 = [[NSRecursiveLock alloc] init];
    lock5 = [[NSRecursiveLock alloc] init];
    lock6 = [[NSRecursiveLock alloc] init];
    lock7 = [[NSRecursiveLock alloc] init];
    lock8 = [[NSRecursiveLock alloc] init];
    
    
    //indicator
    [AFNetworkActivityIndicatorManager sharedManager].enabled = YES;
    
    //data
    idArray = [[NSMutableArray alloc] initWithObjects:nil];
    nameArray = [[NSMutableArray alloc] initWithObjects:nil];
    descriptionArray = [[NSMutableArray alloc] initWithObjects:nil];
    imageThumbArray = [[NSMutableArray alloc] initWithObjects:nil];
    imageDownloadedFlag = [[NSMutableArray alloc] initWithObjects:nil];
    imageUpdatedFlag = [[NSMutableArray alloc] initWithObjects:nil];
    favoritesArray = [[NSMutableArray alloc] initWithObjects:nil];
    
    indexToLoad = 0;
    apiData = nil;
    savedAdImage = nil;
    
    // Setup Parse
    /*[Parse setApplicationId:@"parseAppId" clientKey:@"parseClientKey"];
    [Parse setApplicationId: kParseApplicationID
                  clientKey:kParseClientKey];
    [PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];*/

    //notification
    UILocalNotification *localNotif = [launchOptions objectForKey:UIApplicationLaunchOptionsLocalNotificationKey];
    if (localNotif) {
        [self processNotification:localNotif];
    }

    [self setupNotifications];

    //queue
    operationQueue = [[NSOperationQueue alloc] init];
    [operationQueue setMaxConcurrentOperationCount:3];

	//qr
    qrImage = nil;
    NSString *qrString = @"http://itunes.apple.com/app/id557949358";
	//qrImage = [QRTools qrFromString:qrString withSize:500];
    qrImage = [self generateQRCodeWithString:qrString scale:1.0f];

	//ios7 tint color
    if(SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7"))
        window.tintColor = RGBA(18, 64, 63, 255);

    //load
    [self loadState];
    
    prefRunCount++;
	//if(prefRunCount >= 10000)
	//	prefRunCount= 10000;

    //sharekit setup
    //DefaultSHKConfigurator *configurator = [[ShareKitDemoConfigurator alloc] init];
    //[SHKConfiguration sharedInstanceWithConfigurator:configurator];
    //[SHK flushOfflineQueue]; //offline

    
    //manually create controller
    //archiveViewController = [ArchiveViewController alloc];
    firstViewController = [[FirstViewController alloc] initWithNibName:@"FirstView" bundle:nil];
    aboutViewController = [[AboutViewController alloc] initWithNibName:@"AboutView" bundle:nil];
	sideMenuViewController = [SideMenuViewController alloc];
	    
    //force load
    //archiveViewController.view.hidden = NO;
    //modalHelp = [[HelpViewController alloc] initWithNibName:@"HelpView" bundle:nil];
    sideMenuViewController.view.hidden = NO;

    //force
    firstViewController.view.hidden = NO;
    archiveViewController.view.hidden = NO;
	aboutViewController.view.hidden = NO;
    
    //offset sidemenu view
    int offsetx = 0; //20;
    int offsety = 0; //STATUS_BAR_HEIGHT;//-320;
    sideMenuViewController.view.frame = CGRectMake(offsetx, offsety, sideMenuViewController.view.frame.size.width,
                                               sideMenuViewController.view.frame.size.height);  

    offsetx = 0;
    offsety = 0;//-STATUS_BAR_HEIGHT;
    navController.view.frame = CGRectMake(offsetx, offsety, navController.view.frame.size.width,
                                               navController.view.frame.size.height);
    
    //cell back
    cellBackImage1 =[UIImage imageNamed:@"cell_back.png"];
    cellBackImage2 =[UIImage imageNamed:@"cell_back2.png"];

    //missing
    missingThumb = [UIImage imageNamed:@"thumbMissing.png"];

    //nav bar
    //color
    //http://cocoadevblog.heroku.com/uinavigationcontroller-customization-tutorial
    //self.navController.navigationBar.tintColor = RGBA(0, 30, 30, 245);  //turcoise
    //self.navController.navigationBar.tintColor = RGBA(36, 129, 128, 200);  //turcoise
    
    //self.navController.navigationBar.tintColor = RGBA(18, 64, 63, 255);  //turcoise
    self.navController.navigationBar.barTintColor = RGBA(52,136,134, 255);  //turcoise
    self.navController.navigationBar.tintColor = RGBA(255, 255, 255, 255);  //turcoise

    self.navController.navigationBar.translucent = NO;
    
    self.navController.navigationBarHidden = NO; //hide
    [self.navController setNavigationBarHidden:NO animated:NO];
    
    //change font
    /*UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 400, 44)];
    label.backgroundColor = [UIColor clearColor];
    label.font = [UIFont boldSystemFontOfSize:20.0];
    label.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.5];
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor =[UIColor whiteColor];
    //label.text=self.title;
    label.text=@"test";
    self.navController.navigationItem.titleView = label;*/

    [self setupCache:NO];
    
    //title: On iPad devices, the UIStatusBarStyleDefault and UIStatusBarStyleBlackTranslucent styles default to the UIStatusBarStyleBlackOpaque appearance.
    
	//if(isIpad())
    /*if([self isIpad])
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackOpaque];
    else
        //[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackTranslucent];
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackOpaque];
    */
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
	[[UIApplication sharedApplication] setStatusBarHidden:NO];
	
    
    missingThumb = [UIImage imageNamed:@"thumbMissing.png"];

    
    //analytics
    
    if(USE_ANALYTICS == 1)
	{
		// NSLog(@"USE_ANALYTICS == 1");
		//events:
		//[[LocalyticsSession sharedLocalyticsSession] tagEvent:@"INTERESTING_EVENT"];
		//http://wiki.localytics.com/doku.php?id=iphone_integration
		
		//[[LocalyticsSession sharedLocalyticsSession] startSession:@"b164a4d32da6266aae40348-74fb5f90-e0f4-11e1-4b6c-00ef75f32667"];
        
        
        //[FlurryAnalytics startSession:@"75F7CRGP2CX9CJ3K78Z8"];
		
	}
	else
	{
		NSLog(@"USE_ANALYTICS == 0");
	}
    
    
    //testflight
#if USE_TESTFLIGHT
    if([self isTestflight])
	{
        [TestFlight takeOff:@"???"];
    }
#endif
    
     //inits
    [Helpers initGoogleAnalytics];
    [Helpers initMailChimp:self];

    //modals
    modalHelp = [[WelcomeViewController alloc] initWithNibName:@"WelcomeView" bundle:nil];
    modalQR = [[QRViewController alloc] initWithNibName:@"QRView" bundle:nil];

    //ready
    isDoneLaunching = YES;
    isOnline = [self checkOnline];
   
	
    //[window makeKeyAndVisible];
    

	//IAP
	[self loadIAP];
    
    //badge
    [self updateNumAppsBadge];

    //lockscsreen
    [self updateInReview];

    //save
    [self saveState];
    
    
    // Add the tab bar controller's current view as a subview of the window
    [window makeKeyAndVisible];
    window.rootViewController = navController;
    
    if(prefOpened == NO) //1st time only
    {
         //force wait, for sheet anim
        //[NSThread sleepForTimeInterval:0.3];

        //[self alertHelp:YES];
        [self performSelector:@selector(alertHelpFirstTime) withObject:nil afterDelay:0.1];
    }

    //tapfortap
    //[TapForTap initializeWithAPIKey: @"???"];

	[self fadeDefaultSetup];
	
    //mailchimp
    [Helpers shouldShowMailChimp];

    //background fetch
    [application setMinimumBackgroundFetchInterval:UIApplicationBackgroundFetchIntervalMinimum];

    
	return YES;
}

#if 1
//background fetch
- (void) application:(UIApplication *)application
performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
{
    NSLog(@"########### Received Background Fetch ###########");
    
    float secs = 1.0f;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, secs * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        completionHandler(UIBackgroundFetchResultNewData);
    });
    
}
#endif

-(void)setupCache:(BOOL)empty {
    
    if(empty) {
        
        //force delete cache
        int cacheSizeMemory = 0;
        int cacheSizeDisk = 0;
        NSURLCache *sharedCache = [[NSURLCache alloc] initWithMemoryCapacity:cacheSizeMemory diskCapacity:cacheSizeDisk diskPath:@"nsurlcache"];
        [NSURLCache setSharedURLCache:sharedCache];
        
        SDImageCache *imageCache = [SDImageCache sharedImageCache];
        [imageCache clearMemory];
        [imageCache clearDiskOnCompletion:^{
            
        }];

    }
    
    
    BOOL cache = YES;
    if(cache)
    {
        //cache, caching
        //1024*1024*10 = 10 MB
        int cacheSizeMemory = 4*1024*1024; // 4MB
        int cacheSizeDisk = 32*1024*1024; // 32MB
        //[[NSURLCache sharedURLCache] setMemoryCapacity:1024*1024*4]; //4mb
        //[[NSURLCache sharedURLCache] setDiskCapacity:1024*1024*32]; //32mb
        NSURLCache *sharedCache = [[NSURLCache alloc] initWithMemoryCapacity:cacheSizeMemory diskCapacity:cacheSizeDisk diskPath:@"nsurlcache"];
        [NSURLCache setSharedURLCache:sharedCache];
        //fix leak?
        //[[NSURLCache sharedURLCache] setMemoryCapacity:0];
        //[[NSURLCache sharedURLCache] setDiskCapacity:0];
    }
    else
    {
        //force delete cache
        int cacheSizeMemory = 0;
        int cacheSizeDisk = 0;
        NSURLCache *sharedCache = [[NSURLCache alloc] initWithMemoryCapacity:cacheSizeMemory diskCapacity:cacheSizeDisk diskPath:@"nsurlcache"];
        [NSURLCache setSharedURLCache:sharedCache];
    }

}

/*
// Optional UITabBarControllerDelegate method
- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController {
}
*/

/*
// Optional UITabBarControllerDelegate method
- (void)tabBarController:(UITabBarController *)tabBarController didEndCustomizingViewControllers:(NSArray *)viewControllers changed:(BOOL)changed {
}
*/

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    [lock8 lock];
    
    NSLog(@"applicationDidReceiveMemoryWarning");

    //empty cache
    //[[NSURLCache sharedURLCache] removeAllCachedResponses];
    
    //clear thumbs, nope
    //[imageThumbArray removeAllObjects];
    
    //clear image
    //savedImage = nil;
    
    [lock8 unlock];

}

-(void)addNavigationController:(UINavigationController*)nav
{
    [window addSubview:nav.view];
}

- (void)saveStateDefault
{
    NSLog(@"BingWallpaperiPhoneAppDelegate::saveStateDefault");
    
    //nothing yet
    
}

- (void)saveState
{
    NSLog(@"BingWallpaperiPhoneAppDelegate::saveState");
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    
    [prefs setBool:prefPurchasedRemoveAds forKey:@"prefPurchasedRemoveAds"];
  	[prefs setBool:prefPlaySound forKey:@"prefPlaySound"];
    [prefs setBool:prefShowAll forKey:@"prefShowAll"];

    prefVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    [prefs setObject:prefVersion forKey:@"prefVersion"];
                       
    if(lastTimeSince70 == 0)
        lastTimeSince70 = [[NSDate date] timeIntervalSince1970];
    
    [prefs setDouble:lastTimeSince70 forKey:@"lastTimeSince70"];
                         
    [prefs setInteger:prefRunCount forKey:@"prefRunCount"];
    [prefs setInteger:prefNumApps forKey:@"prefNumApps"];
    [prefs setInteger:currentAdId forKey:@"currentAdId"];
    
  	[prefs setBool:prefOpened forKey:@"prefOpened"];

    [prefs setInteger:prefMailchimpCount forKey:@"prefMailchimpCount"];
    [prefs setBool:prefMailchimpShown forKey:@"prefMailchimpShown"];

    //favorites
    [prefs setObject:favoritesArray forKey:@"favoritesArray"];
    
    [prefs synchronize];
}


- (void)loadState
{
    NSLog(@"BingWallpaperiPhoneAppDelegate::loadState");
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
	
    //set defaults
    
    NSDictionary *appDefaults = [NSDictionary dictionaryWithObjectsAndKeys:
                                 
                                 [NSNumber numberWithBool:NO], @"prefOpened",
                                 [NSNumber numberWithBool:YES], @"prefPlaySound",
                                 [NSNumber numberWithBool:NO], @"prefPurchasedRemoveAds",
                                 [NSNumber numberWithBool:YES], @"prefShowAll",
                                 [NSString stringWithFormat:@""], @"prefVersion",
                                 [NSNumber numberWithDouble:0], @"lastTimeSince70",
                                 [NSNumber numberWithDouble:0], @"prefRunCount",
                                 [NSNumber numberWithDouble:0], @"prefNumApps",
                                 [NSNumber numberWithDouble:APP_ID_QRLOCK], @"currentAdId",
                                 [NSNumber numberWithDouble:0], @"prefMailchimpCount",
                                 [NSNumber numberWithBool:NO], @"prefMailchimpShown",

                                 nil];
                                 
    [prefs registerDefaults:appDefaults];
    
    
  	prefPurchasedRemoveAds = [prefs boolForKey:@"prefPurchasedRemoveAds"];
    prefOpened = [prefs boolForKey:@"prefOpened"];
    prefPlaySound = [prefs boolForKey:@"prefPlaySound"];
    prefShowAll = YES; //[prefs boolForKey:@"prefShowAll"];
    lastTimeSince70 = [prefs doubleForKey:@"lastTimeSince70"];
    prefVersion = [prefs stringForKey:@"prefVersion"];
    prefRunCount = [prefs integerForKey:@"prefRunCount"];
    prefNumApps = [prefs integerForKey:@"prefNumApps"];
    currentAdId = [prefs integerForKey:@"currentAdId"];
    prefMailchimpCount = [prefs integerForKey:@"prefMailchimpCount"];
    prefMailchimpShown = [prefs boolForKey:@"prefMailchimpShown"];

    //favorites
    favoritesArray = [[prefs objectForKey:@"favoritesArray"] mutableCopy];
    if (!favoritesArray)
    {
        // create array if it doesn't exist in NSUserDefaults
        favoritesArray = [[NSMutableArray alloc] init];
    }
    
    //sort?
    [favoritesArray sortUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    
    
    //force banner
    if([self isDebug])
    {
        //prefPurchasedRemoveAds = NO;
    }
}

/*- (void)facebookLogin
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sharerAuthorized:) name:@"SHKAuthDidFinish" object:nil];

     //login
    SHKSharer *service = [[[SHKFacebook alloc] init] autorelease];
    [service authorize];


}*/

- (void)sharerAuthorized:(NSNotification *)notification {

     NSLog(@"AppDelegate::sharerAuthorized");
    
}

- (BOOL)handleOpenURL:(NSURL*)url
{
     NSLog(@"AppDelegate::handleOpenURL");

	/*NSString* scheme = [url scheme];
    if ([scheme hasPrefix:[NSString stringWithFormat:@"fb%@", SHKCONFIG(facebookAppId)]])
        return [SHKFacebook handleOpenURL:url];
    */
    //return [facebook handleOpenURL:url]; 
    
    return YES;
}

- (BOOL)application:(UIApplication *)application 
            openURL:(NSURL *)url 
  sourceApplication:(NSString *)sourceApplication 
         annotation:(id)annotation 
{
     NSLog(@"AppDelegate::openURL");

    return [self handleOpenURL:url];
    
    //return YES;
    
}

- (BOOL)application:(UIApplication *)application 
      handleOpenURL:(NSURL *)url
{
     NSLog(@"AppDelegate::handleOpenURL");

    return [self handleOpenURL:url];  
}


- (void)dealloc {
}

-(void) playSound:(NSString*)filename
{   
	if(!prefPlaySound)
		return;
    
    //invalid filename
    if( (filename == nil) || ([filename length] <= 0 ) || [filename isEqualToString:@""])
        return;
	
    //http://www.iphonedevsdk.com/forum/iphone-sdk-development/2940-help-please-playing-short-sound-tutorial-not-working.html
    //http://blogs.x2line.com/al/archive/2011/05/19/3831.aspx
    //http://iphone-dev-tips.alterplay.com/2009/12/shortest-way-to-play-sound-effect-on.html
    //http://stackoverflow.com/questions/818515/iphone-how-to-make-key-click-sound-for-custom-keypad
    
    
    
    NSString *path  = [[NSBundle mainBundle] pathForResource : filename ofType :@"wav"];
    if ([[NSFileManager defaultManager] fileExistsAtPath : path])
    {
        NSURL *pathURL = [NSURL fileURLWithPath : path];
        //AudioServicesCreateSystemSoundID((CFURLRef) pathURL, &audioEffect);
        AudioServicesCreateSystemSoundID((__bridge CFURLRef) pathURL, &audioEffect);

        AudioServicesPlaySystemSound(audioEffect);
    }
    else
    {
        NSLog(@"error, file not found: %@", path);
    }
    
    
}


-(void) testFlightFeedback
{
#if USE_TESTFLIGHT
    if([self isTestflight])
	{
      [TestFlight openFeedbackView];
    }
#endif
}


-(void) applicationDidEnterBackground:(UIApplication *)application
{
   /* alreadyLoaded = false;
    
	//going to background
    
    if(!prefRemember)
    {
		keyString = @"";
	}
    
	[self saveState];
	
	
	if(USE_ANALYTICS == 1)
	{
		// Close Localytics Session
		[[LocalyticsSession sharedLocalyticsSession] close];
		[[LocalyticsSession sharedLocalyticsSession] upload];
	}*/
	
	
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    [self applicationDidEnterBackground:application];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    //[self applicationWillEnterForeground:application];
     //notifications
    [self setupNotifications];
}

-(BOOL)backgroundSupported
{
	UIDevice* device = [UIDevice currentDevice];
	BOOL tempBackgroundSupported = NO;
	if ([device respondsToSelector:@selector(isMultitaskingSupported)])
		tempBackgroundSupported = device.multitaskingSupported;
	
	return tempBackgroundSupported;
}


//https://gist.github.com/1323251
- (NSString *) platform{
    size_t size;
    sysctlbyname("hw.machine", NULL, &size, NULL, 0);
    char *machine = malloc(size);
    sysctlbyname("hw.machine", machine, &size, NULL, 0);
    NSString *platform = [NSString stringWithUTF8String:machine];
    free(machine);
    return platform;
}

- (NSString *) platformString{
    NSString *platform = [self platform];
    if ([platform isEqualToString:@"iPhone1,1"])    return @"iPhone 1G";
    if ([platform isEqualToString:@"iPhone1,2"])    return @"iPhone 3G";
    if ([platform isEqualToString:@"iPhone2,1"])    return @"iPhone 3GS";
    
    if ([platform isEqualToString:@"iPhone3,1"])    return @"iPhone 4";
    if ([platform isEqualToString:@"iPhone3,3"])    return @"iPhone 4";
    if ([platform isEqualToString:@"iPhone4,1"])    return @"iPhone 4S";
    
	if ([platform isEqualToString:@"iPhone5,1"])    return @"iPhone 5";
    if ([platform isEqualToString:@"iPhone5,2"])    return @"iPhone 5";

    if ([platform isEqualToString:@"iPod1,1"])      return @"iPod Touch 1G";
    if ([platform isEqualToString:@"iPod2,1"])      return @"iPod Touch 2G";
    if ([platform isEqualToString:@"iPod3,1"])      return @"iPod Touch 3G";
    if ([platform isEqualToString:@"iPod4,1"])      return @"iPod Touch 4G";
    
    if ([platform isEqualToString:@"iPad1,1"])      return @"iPad";
    
    if ([platform isEqualToString:@"iPad2,1"])      return @"iPad 2 (WiFi)";
    if ([platform isEqualToString:@"iPad2,2"])      return @"iPad 2 (GSM)";
    if ([platform isEqualToString:@"iPad2,3"])      return @"iPad 2 (CDMA)";
    if ([platform isEqualToString:@"iPad2,4"])      return @"iPad 2 (WiFi)";
    
    if ([platform isEqualToString:@"iPad3,1"])      return @"iPad 3 (WiFi)";
    if ([platform isEqualToString:@"iPad3,2"])      return @"iPad 3 (GSM)";
    if ([platform isEqualToString:@"iPad3,3"])      return @"iPad 3 (CDMA)";

    //ipad 4
    if ([platform isEqualToString:@"iPad3,4"])      return @"iPad 4 (WiFi)";
    if ([platform isEqualToString:@"iPad3,5"])      return @"iPad 4";
    if ([platform isEqualToString:@"iPad3,6"])      return @"iPad 4";
    
    //ipad mini
    if ([platform isEqualToString:@"iPad2,5"])      return @"iPad mini (Wifi)";
    if ([platform isEqualToString:@"iPad2,6"])      return @"iPad mini";
    if ([platform isEqualToString:@"iPad2,7"])      return @"iPad mini";

    //sim
    if ([platform isEqualToString:@"i386"])         return @"Simulator";
    if ([platform isEqualToString:@"x86_64"])       return @"Simulator";
    
    return platform;
}


- (BOOL) isIpad
{
/*#ifdef UI_USER_INTERFACE_IDIOM
    return (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad);
#else
    return NO;
#endif*/

    return NO;
}

- (BOOL) isIphone5
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

-(UIImage*) getQRImage
{
    assert(qrImage);
    return qrImage;
}



- (UIImage*) createMaskWithImage: (UIImage*) inputImage
{
    CGImageRef image = inputImage.CGImage;
    
    int maskWidth               = CGImageGetWidth(image);
    int maskHeight              = CGImageGetHeight(image);
    //  round bytesPerRow to the nearest 16 bytes, for performance's sake
    int bytesPerRow             = (maskWidth + 15) & 0xfffffff0;
    int bufferSize              = bytesPerRow * maskHeight;
    
    //  allocate memory for the bits 
    CFMutableDataRef dataBuffer = CFDataCreateMutable(kCFAllocatorDefault, 0);
    CFDataSetLength(dataBuffer, bufferSize);
    
    //  the data will be 8 bits per pixel, no alpha
    CGColorSpaceRef colourSpace = CGColorSpaceCreateDeviceGray();
    CGContextRef ctx            = CGBitmapContextCreate(CFDataGetMutableBytePtr(dataBuffer),
                                                        maskWidth, maskHeight,
                                                        8, bytesPerRow, colourSpace, kCGImageAlphaNone);
    //  drawing into this context will draw into the dataBuffer.
    CGContextDrawImage(ctx, CGRectMake(0, 0, maskWidth, maskHeight), image);
    CGContextRelease(ctx);
    
    //  now make a mask from the data.
    CGDataProviderRef dataProvider  = CGDataProviderCreateWithCFData(dataBuffer);
    CGImageRef mask                 = CGImageMaskCreate(maskWidth, maskHeight, 8, 8, bytesPerRow,
                                                        dataProvider, NULL, FALSE);
    
    CGDataProviderRelease(dataProvider);
    CGColorSpaceRelease(colourSpace);
    CFRelease(dataBuffer);
    
    UIImage *returnImage = [UIImage imageWithCGImage:mask];
    CGImageRelease(mask);
    return returnImage;

}


- (UIImage*) maskImage:(UIImage *)inputImage withMask:(UIImage *)inputMaskImage {
    
	//return inputImage;
    
    //http://stackoverflow.com/questions/2776747/masking-a-uiimage
    
    /*
     CGImageRef maskRef = inputMaskImage.CGImage; 
     
     CGImageRef mask = CGImageMaskCreate(CGImageGetWidth(maskRef),
     CGImageGetHeight(maskRef),
     CGImageGetBitsPerComponent(maskRef),
     CGImageGetBitsPerPixel(maskRef),
     CGImageGetBytesPerRow(maskRef),
     CGImageGetDataProvider(maskRef), NULL, false);
     
     CGImageRef masked = CGImageCreateWithMask([inputImage CGImage], mask);
     CGImageRelease(mask);
     
     UIImage *maskedImage = [UIImage imageWithCGImage:masked];
     
     return maskedImage;*/
    
    
    
    //http://stackoverflow.com/questions/1133248/any-idea-why-this-image-masking-code-does-not-work
    
    CGImageRef masked = CGImageCreateWithMask([inputImage CGImage], [[self createMaskWithImage: inputMaskImage] CGImage]);
    
    UIImage *returnImage = [UIImage imageWithCGImage:masked];
    CGImageRelease(masked);
    return returnImage;
    
}


-(UIImage *)changeWhiteColorTransparent: (UIImage *)image
{
    /*
    CGImageRef rawImageRef=image.CGImage;
    
    const float colorMasking[6] = {222, 255, 222, 255, 222, 255};
    
    UIGraphicsBeginImageContext(image.size);
    CGImageRef maskedImageRef=CGImageCreateWithMaskingColors(rawImageRef, colorMasking);
    {
        //if in iphone
        CGContextTranslateCTM(UIGraphicsGetCurrentContext(), 0.0, image.size.height);
        CGContextScaleCTM(UIGraphicsGetCurrentContext(), 1.0, -1.0); 
    }
    
    CGContextDrawImage(UIGraphicsGetCurrentContext(), CGRectMake(0, 0, image.size.width, image.size.height), maskedImageRef);
    UIImage *result = UIGraphicsGetImageFromCurrentImageContext();
    CGImageRelease(maskedImageRef);
    UIGraphicsEndImageContext();    
    return result;
     */
    return nil;
}


-(UIImage *)colorizeImage: (UIImage *)image
{
		if(!image)
			return nil;
	
    // begin a new image context, to draw our colored image onto
    UIGraphicsBeginImageContext(image.size);
    
    // get a reference to that context we created
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // set the fill color
    //UIColor *color = RGBA(94, 94, 94, 255); //grey
    UIColor *color = RGBA(5, 88, 106, 255); //blue
    [color setFill];
    
    // translate/flip the graphics context (for transforming from CG* coords to UI* coords
    CGContextTranslateCTM(context, 0, image.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    
    // set the blend mode to color burn, and the original image
    //CGContextSetBlendMode(context, kCGBlendModeMultiply);
    CGContextSetBlendMode(context, kCGBlendModeNormal);
    
    /*
     
     kCGBlendModeNormal,
     kCGBlendModeMultiply,
     kCGBlendModeScreen,
     kCGBlendModeOverlay,
     kCGBlendModeDarken,
     kCGBlendModeLighten,
     kCGBlendModeColorDodge,
     kCGBlendModeColorBurn,
     kCGBlendModeSoftLight,
     kCGBlendModeHardLight,
     kCGBlendModeDifference,
     kCGBlendModeExclusion,
     kCGBlendModeHue,
     kCGBlendModeSaturation,
     kCGBlendModeColor,
     kCGBlendModeLuminosity,
     
     */
    
    
    
    CGRect rect = CGRectMake(0, 0, image.size.width, image.size.height);
    CGContextDrawImage(context, rect, image.CGImage);
    
    // set a mask that matches the shape of the image, then draw (color burn) a colored rectangle
    CGContextClipToMask(context, rect, image.CGImage);
    CGContextAddRect(context, rect);
    CGContextDrawPath(context,kCGPathFill);
    
    // generate a new UIImage from the graphics context we drew onto
    UIImage *coloredImg = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    
    return coloredImg;
}

- (void) mailComposeController:(MFMailComposeViewController*)controller
		   didFinishWithResult:(MFMailComposeResult)result
						 error:(NSError*)error
{
	if(result == MFMailComposeResultSent)
	{
		NSLog(@"mail sent");
	}
		
	//[tabBarController dismissViewControllerAnimated:YES completion:nil];
	[controller dismissViewControllerAnimated:YES completion:nil];

}

- (void)sendEmailTo:(NSString *)to withSubject:(NSString *)subject withBody:(NSString *)body withImage:(UIImage*)image withView:(UIViewController*)theView 
{
    
    if (![MFMailComposeViewController canSendMail])
    {
        return;
    }
        
	//old way
	/*
	 NSString *mailString = [NSString stringWithFormat:@"mailto:?to=%@&subject=%@&body=%@",
	 [to stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding], 
	 [subject stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding], 
	 [body stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding]];
	 
	 [[UIApplication sharedApplication] openURL:[NSURL URLWithString:mailString]];
	 */
	
	//new way 
       
	NSArray *recipients = [[NSArray alloc] initWithObjects:to, nil];
	NSArray *recipientEmpty = [[NSArray alloc] init];
	
	MFMailComposeViewController* controller = [[MFMailComposeViewController alloc] init];
	controller.mailComposeDelegate = self;
	[controller setSubject:subject];
	[controller setMessageBody:body isHTML:NO];
	
    //image
    if(image != nil)
    {
        NSData *jpegData = UIImageJPEGRepresentation(image, 9.0);
        NSString *fileName = @"dailywallpaper";
        fileName = [fileName stringByAppendingPathExtension:@"jpg"];
        [controller addAttachmentData:jpegData mimeType:@"image/jpeg" fileName:fileName];
    }

    //color
    //[[controller navigationBar] setTintColor:[UIColor blackColor]];
    
	//[[controller navigationBar] setTintColor:self.navController.navigationBar.tintColor];
    
    //disabled
    //[[controller navigationBar] setBarTintColor:self.navController.navigationBar.barTintColor];
    
	if([to  length] == 0)
		[controller setToRecipients: recipientEmpty];
	else
		[controller setToRecipients: recipients];
	
    [ theView presentViewController:controller animated:YES completion:NULL];
    
	//[controller release];
	
	//[recipients release];
	//[recipientEmpty release];
	
}

- (void)alertHelpFirstTime
{
    [self alertHelp:YES];
}

- (void)alertHelp:(BOOL)isAnimated
{
    //disabled
    return;
    
	//[self playSound:@"test"];

    //force wait, for sheet anim
    //[NSThread sleepForTimeInterval:0.3];

		
	//[self addSubView:myView]
	
	if(USE_ANALYTICS == 1)
	{
		//[[LocalyticsSession sharedLocalyticsSession] tagEvent:@"alertHelp"];
        //[FlurryAnalytics logEvent:@"alertHelp"];
        
	}
	
    
	[[self navController] presentViewController:modalHelp animated:isAnimated completion:NULL];
}


- (void)alertQR:(BOOL)isAnimated
{
	
	if(USE_ANALYTICS == 1)
	{
		//[[LocalyticsSession sharedLocalyticsSession] tagEvent:@"alerQR"];
        //[FlurryAnalytics logEvent:@"alerQR"];
        
	}
	[[self navController] presentViewController:modalQR animated:isAnimated completion:NULL];
}

- (void)alertHelpDone
{
	[ [self navController] dismissViewControllerAnimated:YES completion:nil];
}

- (void)alertHelpDoneFirstTime
{
	[ [self navController] dismissViewControllerAnimated:NO completion:nil];
	
	
	//ask key, after help
	//[self alertAskKey];
}

- (void)alertHelpDoneNotAnimated
{
	[ [self navController] dismissViewControllerAnimated:NO completion:nil];
}


- (void)gotoTwitter
{
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://twitter.com/BingWallpapers"]];
}

- (void)gotoQRScannerApp
{
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://itunes.apple.com/en/app/scan/id411206394?mt=8"]];
}

-(void)openRatings
{
    NSString *urlString = nil;
    
    //http://linkmaker.itunes.apple.com
    
    if(kIsIOS11_0)
    {
        urlString = [NSString stringWithFormat:@"https://itunes.apple.com/us/app/itunes-u/id%d?action=write-review", kAppStoreAppID];
        
    }
    else
    {
        urlString = [NSString stringWithFormat:@"http://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?id=%d&pageNumber=0&sortOrdering=1&type=Purple+Software&mt=8", kAppStoreAppID];
    }
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString] options:@{} completionHandler:nil];
    
}


- (void)gotoFacebook
{
	
	/*
     
	 <a href="http://www.facebook.com/pages/Password-Grid/169115183113120"  target='_blank'>Facebook</a>
	 
	 <iframe src="http://www.facebook.com/plugins/like.php?href=http%3A%2F%2Fwww.facebook.com%2Fpages%2FPassword-Grid%2F169115183113120&amp;layout=button_count&amp;show_faces=true&amp;width=450&amp;action=like&amp;colorscheme=light&amp;height=21" scrolling="no" frameborder="0" style="border:none; overflow:hidden; width:100px; height:21px;" allowTransparency="true"></iframe>
     
	 
	 
     */
	
	//fb://profile/BingWallpapers
	//fb://profile/210227459693
	
	//NSURL *fanPageURL = [NSURL URLWithString:@"fb://BingWallpapers"];
	
	//if(true)
	//if (![[UIApplication sharedApplication] openURL: fanPageURL]) 
	{
        //fanPageURL failed to open.  Open the website in Safari instead
        //NSURL *webURL = [NSURL URLWithString:@"http://www.facebook.com/pages/Password-Grid/169115183113120"];
		
		NSURL *webURL = [NSURL URLWithString:@"http://www.facebook.com/BingWallpapers"];
        [[UIApplication sharedApplication] openURL: webURL];
	}
    
}

- (void)gotoAd
{
    if(currentAdUrl == nil || [currentAdUrl length] <= 0)
        return;

    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:currentAdUrl]];
}

/*- (void)gotoGift
{
	if(USE_ANALYTICS == 1)
	{
		[[LocalyticsSession sharedLocalyticsSession] tagEvent:@"gotoGift"];
	}
	
	[self saveState];
	
	
    //http://stackoverflow.com/questions/5197035/gift-app-from-inside-the-app
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://buy.itunes.apple.com/WebObjects/MZFinance.woa/wa/giftSongsWizard?gift=1&salableAdamId=557949358&productType=C&pricingParameter=STDQ"]];
}*/

- (void)gotoCoinyBlock
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://itunes.apple.com/app/id914537554"]];
}

- (void)gotoReviews
{
	if(USE_ANALYTICS == 1)
	{
		//[[LocalyticsSession sharedLocalyticsSession] tagEvent:@"gotoReviews"];
        //[FlurryAnalytics logEvent:@"gotoReviews"];
        
	}
	
    [self openRatings];
	
    //old
    
    //[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?id=557949358&pageNumber=0&sortOrdering=1&type=Purple+Software&mt=8"]];
	
}

- (BOOL) isDebug
{
#ifdef DEBUG
    return YES;
#else
    return NO;
#endif
}

- (BOOL) isSimulator
{
#if TARGET_IPHONE_SIMULATOR
    return YES;
#else
    return NO;
#endif
}

- (BOOL) isRetina
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

- (BOOL) isTestflight
{
    //#ifdef DEBUG
    //    return NO;
    //#endif

    #if USE_TESTFLIGHT
        //return (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad);
        //http://en.wikipedia.org/wiki/IOS_version_history
        //return SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"3.1.3"); //to confirm?
        return true;
    #else
        return NO;
    #endif    
}

- (NSString *) getSecureID
{
   /*NSString *domain     = @"com.skyriser.bingwallpapers";
    NSString *key        = @"89rkgdfuiigudfkj";
    NSString *identifier = [SecureUDID UDIDForDomain:domain usingKey:key];
    // The returned identifier is a 36 character (128 byte + 4 dashes) string that is unique for that domain, key, and device tuple
    
    return identifier;
    */
    return @"?";
}

- (NSString*) getUserAgent
{
    //append version
    NSString *agent = [NSString stringWithFormat:@"BingWallpapers-iOS-%@", [self getVersionString2]];
    return agent; 
}

- (NSString*)getVersionString
{
    NSString *debugString = [NSString stringWithFormat:@"%@", [self isDebug]?@" (debug)":@""]; //add debug string
    NSString *output = [NSString stringWithFormat:@"%@%@",
						[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"], debugString];
	//NSLog(@"%@", [NSString stringWithFormat:@"getVersionString: %@", getVersionString2);
	
	return output;
}
- (NSString*)getVersionString2
{
    NSString *debugString = [NSString stringWithFormat:@"%@", [self isDebug]?@" (debug)":@""]; //add debug string
	NSString *output = [NSString stringWithFormat:@"%@ (%@)%@",
						[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"] ,
						[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"],
						debugString];
    
	//NSLog(@"%@", [NSString stringWithFormat:@"getVersionString2: %@", getVersionString2);
	
	return output;
}

// NSURLConnection Delegates
- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
{
    [lock1 lock];
    
    NSLog(@"BingWallpaperiPhoneAppDelegate::didReceiveAuthenticationChallenge");

    /*if (connection == connectionAPIWanted || connection == connectionAPIWantedPost)
    {
         NSURLCredential *newCredential = [NSURLCredential credentialWithUser:API_WANTED_USERNAME
                                                                        password:API_WANTED_PASSWORD
                                                                     persistence:NSURLCredentialPersistenceForSession];
        [[challenge sender] useCredential:newCredential forAuthenticationChallenge:challenge];
       
    }*/
    
    [lock1 unlock];
}


- (void)resetData
{
    NSLog(@"BingWallpaperiPhoneAppDelegate::resetData");
    
    //cancel queues
    [self.operationQueue cancelAllOperations];
    [[archiveViewController tableViewController].operationQueue cancelAllOperations];

    //reset
    currentMaxLoad = 0; //MAX_LOAD;
    totalItems = 0;
    tableLoaded = NO;
    alreadyLoadingNext = NO;
    
    //empty all
    if([self idArray])
        [[self idArray] removeAllObjects];
    if([self nameArray])
        [[self nameArray] removeAllObjects];
    if([self descriptionArray])
        [[self descriptionArray] removeAllObjects];
        
    if([self imageThumbArray])
        [[self imageThumbArray] removeAllObjects];
    
    //queue 
    if([self imageDownloadedFlag])
        [[self imageDownloadedFlag] removeAllObjects];

    if([self imageUpdatedFlag])
        [[self imageUpdatedFlag] removeAllObjects];
    

    //api
    if(apiData)
        apiData = nil;
        
    //nameToLoad = [NSString stringWithFormat:@""];

    //queue          
}


-(void)fillTable
{
    NSLog(@"%@", @"BingWallpaperiPhone::fillTable");
    
     //not ready yet
    if(![self isDoneLaunching])
        return;

    if(alreadyFillTable)
        return;
    
    alreadyFillTable = YES;
        
    
    if(apiData == nil || [apiData length] == 0) // not loaded yet
    {
        //apiData = [NSData dataWithContentsOfURL:[NSURL URLWithString:url]];
        
        if(apiData == nil)
        {
            NSLog(@"%@", @"BingWallpaperiPhone::fillTable: apiData == nil");
        }
        
        NSString *url = nil;
        
        if(random)
        {
            if(prefShowAll)
               url = [NSString stringWithFormat: URL_API_RANDOM, @"1"];
            else
               url = [NSString stringWithFormat: URL_API_RANDOM, @"0"];
        }
        else if(popular)
        {
            if(prefShowAll)
               url = [NSString stringWithFormat: URL_API_POPULAR, @"1"];
            else
               url = [NSString stringWithFormat: URL_API_POPULAR, @"0"];
        }
        else if(favorites)
        {
            if(prefShowAll)
               url = [NSString stringWithFormat: URL_API_FAVORITES, @"1"];
            else
               url = [NSString stringWithFormat: URL_API_FAVORITES, @"0"];
        }
        else
        {
            if(prefShowAll)
                url = [NSString stringWithFormat: URL_API, @"1"];
            else
                url = [NSString stringWithFormat: URL_API, @"0"];
        }
        
        
        
        NSURL *datasourceURL = [NSURL URLWithString:url];
        NSURLRequest *request = [NSURLRequest requestWithURL:datasourceURL];
        /*NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url
                                              cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                          timeoutInterval:20];*/

        AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
                    
        [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation* operation, id responseObject){
        
            apiData =  [operation responseData];
            [self fillTable2];
            
        }failure:^(AFHTTPRequestOperation* operation, NSError* error){
            apiData = nil;
        }];
    
        //[operation start];
        [operationQueue addOperation:operation];

    }
    else
    {
        [self fillTable2];
    }
   
   alreadyFillTable = NO;
}

-(void)fillTable2
{
    NSLog(@"%@", @"BingWallpaperiPhone::fillTable2");
      
    if(alreadyFillTable2)
        return;
        
    alreadyFillTable2 = YES;
    
    tableLoaded =  YES;
        
    //empty
    if(emptyTable == YES) 
    {
        [idArray removeAllObjects];
        [nameArray removeAllObjects];
        [descriptionArray removeAllObjects];
        [imageDownloadedFlag removeAllObjects];
        [imageUpdatedFlag removeAllObjects];
        [descriptionArray removeAllObjects];
        
        //table
        [[archiveViewController tableViewController].tableView reloadData];
    }
    
    if(apiData && [apiData length] > 0) //good
    {
        //jsonkit way
        //NSDictionary *jsonArray = [apiData objectFromJSONData];
        NSError* error;
        NSDictionary* jsonArray = [NSJSONSerialization JSONObjectWithData:apiData
                                                             options:0
                                                               error:&error];
        //how many total
        totalItems = (int)[jsonArray count];
        if([self favorites])
        {
            totalItems = (int)[favoritesArray count];
        }
        
        int newLoaded = 0;
        int i=0, j=0;
        for(NSDictionary *dict in jsonArray) 
        {
            //if(i >= currentMaxLoad)
            if([idArray count] >= currentMaxLoad)
                break;
            
            NSString *newName = [dict objectForKey:@"name"];
                       
            //already loaded?
            BOOL already = false;
            for(id item in nameArray)
            {
                if ([item isEqualToString:newName])
                {
                    //already in list
                    already = true;
                    break;
                }
            }  
            
            if(already)
            {
                j++;
                continue;
            }
            
            //favorite
            NSString *idString = [dict objectForKey:@"id"];
            if([self favorites] && ![self isFavorite:idString])
            {
                j++;
                continue;
            }
            
            NSString *tempString = [dict objectForKey:@"name"];
            //add name
            //[nameArray insertObject:tempString atIndex: i];
            [nameArray addObject:tempString];
            
            //add id
            //[idArray insertObject:idString atIndex: i];
            [idArray addObject:idString];
            
            tempString = [dict objectForKey:@"description"];
            if(tempString == nil || [tempString isEqualToString:@""])
                    tempString = [NSString stringWithFormat:@"(No description available)"];
            
            //clean
            tempString = [tempString stringByConvertingHTMLToPlainText];            
            tempString = [tempString stringByReplacingOccurrencesOfString:@"[newline]" withString:@"\n"];
            
            [descriptionArray addObject:tempString];
            
            //loaded flag
            [[self imageDownloadedFlag] addObject:[NSNumber numberWithBool:NO] ];
            [[self imageUpdatedFlag] addObject:[NSNumber numberWithBool:NO] ];
            
            //placeholder
            [imageThumbArray addObject:[self missingThumb]];
            
            newLoaded++;
            i++;
            j++;
        }
        
        if(newLoaded == 0)
        {
            NSLog(@"%@", @"BingWallpaperiPhone::fillTable2: nothing loaded");

            //reload table
            [ [[archiveViewController tableViewController] tableView] reloadData];

            alreadyFillTable2 = NO;
            
            //nothing loaded
            
            //show no results?
            [archiveViewController showNoResults:[self totalItems] == 0];
            
            return;
            
            /*
             UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" 
                                                            message:@"No more items to load."
                                                           delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [alert show];
            */
        }
        
        //start download 
        [self loadNextImage];
        
        //status
        //[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
        
        [self setIsLoading:YES];
		
		timeLastRefresh = [NSDate date];
        
        //show no results?
        [archiveViewController showNoResults:[self totalItems] == 0];
            
    }

    else //bad
    {
        isOnline = NO;
     
        //reset
        [self resetData];
        //[mainViewController showOffline];
    
        //error
        /*UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" 
                                                        message:@"Could not connect to server."
                                                       delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert show];*/
    }
    
    //inverse sort
    //NSSortDescriptor* sortDescriptor = [NSSortDescriptor sortDescriptorWithKey: @"self" ascending: NO];
    //NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    //appnameArray = [tempArray sortedArrayUsingDescriptors:sortDescriptors];
    
     alreadyFillTable2 = NO;
   
}


-(void)loadNextImage{

    // all images are ready to use!
    alreadyLoadingNext = NO;
    
    //reload table
    [[[archiveViewController tableViewController] tableView] reloadData];
    
    NSLog(@"BingWallpaperiPhoneAppDelegate::loadNextImage: done");
    
    //status
    //[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    
    [self setIsLoading:NO];
    
    [self preloadImages];
    
}


-(void)preloadImages
{
    return;
    
    for(int i=0; i<[[self imageUpdatedFlag] count];i++) {
        
                //already downloaded
                if([[[self imageUpdatedFlag] objectAtIndex:i] boolValue])
                    continue;
        
                //get photo
                NSString  *photoURL = [NSString stringWithFormat:URL_API_THUMB, [[self nameArray] objectAtIndex:i]];
                NSLog(@"photoURL: %@", photoURL);
            
                NSURL *datasourceURL = [NSURL URLWithString:photoURL];
                NSURLRequest *request = [NSURLRequest requestWithURL:datasourceURL];
                AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
                
                //__weak UIButton *weakSelf = cell.thumbnailButton;
                [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation* operation, id responseObject){
                    
                    
                            NSData* data =  [operation responseData];
                            UIImage *newImage = [[UIImage alloc] initWithData:data];
                            
                            //set image
                            [[self imageThumbArray] replaceObjectAtIndex:i withObject:newImage];
                            [[self imageDownloadedFlag] replaceObjectAtIndex:i withObject:[NSNumber numberWithBool:YES]];
                            [[self imageUpdatedFlag] replaceObjectAtIndex:i withObject:[NSNumber numberWithBool:YES]];
                    
                            [[archiveViewController tableViewController].tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:i inSection:0]] withRowAnimation:UITableViewRowAnimationNone];

                }failure:^(AFHTTPRequestOperation* operation, NSError* error){
                     //error

                }];
            
                //[operation start];
                [operationQueue addOperation:operation];
    }

}


-(void) updateAd
{
    NSLog(@"BingWallpaperiPhoneAppDelegate::updateAd");

    //disable
    //return; //???
    
    
    if(![self isOnline])
        return;
    
    savedAdImage = nil;

    
    //get list
    NSURL * url_afn = [NSURL URLWithString:URL_API_AD_LIST];
    NSURLRequest *request_afn = [[NSURLRequest alloc] initWithURL:url_afn];
    [AFJSONRequestOperation addAcceptableContentTypes:[NSSet setWithObject:@"text/html"]];
       AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request_afn
        success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON)
        {
            //save it
            adArray = JSON;
            [self updateAd2];
        }
        failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON)
        {
            adArray = nil;
            NSLog(@"Request Failed with Error: %@, %@", error, error.userInfo);
        }];
    
    [operation setShouldExecuteAsBackgroundTaskWithExpirationHandler:^{
            //timed out
        }];
    //[operation start];
    [operationQueue addOperation:operation];
}

-(void) updateAd2
{
    if(adArray == nil || [adArray count] == 0)
        return;
    
    NSMutableArray *ad_array_id = [[NSMutableArray alloc] initWithObjects:nil];
    NSMutableArray *ad_array_url_appstore = [[NSMutableArray alloc] initWithObjects:nil];
    NSMutableArray *ad_array_url_image = [[NSMutableArray alloc] initWithObjects:nil];
    
    for(NSDictionary *dict in adArray)
    {
        NSString *tempString = nil;
        NSNumber *tempNum = nil;
        
        tempNum = [NSNumber numberWithInt:[[dict objectForKey:@"app_id"] integerValue]];
        [ad_array_id addObject:tempNum];
        
        tempString = [dict objectForKey:@"url_appstore"];
        [ad_array_url_appstore addObject:tempString];
        
        tempString = [dict objectForKey:@"url_image"];
        [ad_array_url_image addObject:tempString];
        
    }
    
    //next
    currentAdId++;
    
    //loop
    if(currentAdId >= [ad_array_id count])
        currentAdId = 0;

    if([ad_array_id[currentAdId] intValue] == APP_ID_CURRENT)
        currentAdId++;
    
    //loop again
    if(currentAdId >= [ad_array_id count])
        currentAdId = 0;
    
    currentAdUrl = ad_array_url_appstore[currentAdId];
    
    [self saveState];

    //connection
    NSString  *url = ad_array_url_image[currentAdId];
    //NSURL * imageURL = [NSURL URLWithString:url];
    NSLog(@"url:%@", url);
         
    //savedAdImage = nil;
    AFImageRequestOperation *operationImage =
            [AFImageRequestOperation imageRequestOperationWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]]
            success:^(UIImage *image)
            {
                savedAdImage = image;
                if(savedAdImage != nil)
                    [archiveViewController showAd:YES];
                else
                    [archiveViewController showAd:NO];
            }
           ];
    
     [operationImage setShouldExecuteAsBackgroundTaskWithExpirationHandler:^{
            //timed out
        }];
   //[operationImage start];
    [operationQueue addOperation:operationImage];

    //[[UIApplication sharedApplication] endBackgroundTask:taskId];
}

- (BOOL)openURL:(NSURL*)url
{
    //BrowserViewController *bvc = [[BrowserViewController alloc] initWithUrls:url];
    //[self.navigationController pushViewController:bvc animated:YES];
   // [bvc release];
    
    //force wait, for sheet anim
    [NSThread sleepForTimeInterval:0.3];


    [[UIApplication sharedApplication] openURL:url];
    
    //[super openURL:url];
    
    //[[UIApplication sharedApplication] canOpenURL:
    //[NSURL URLWithString:@"googlechrome://"]];


    return YES;
}


//BOOL HasConnection()
- (BOOL)HasConnection
{
    Reachability *reachability = [Reachability reachabilityForInternetConnection];    
    NetworkStatus internetStatus = [reachability currentReachabilityStatus];
    
    if (internetStatus == NotReachable) 
    {
        //offline
        //NSLog(@"BingWallpaperiPhoneAppDelegate::HasConnection: no");

        return false;
    }
    //else if (internetStatus == ReachableViaWiFi || internetStatus == ReachableViaWWAN)
    else
    {
       //online
       //NSLog(@"BingWallpaperiPhoneAppDelegate::HasConnection: yes");

        return true;
    }
}


- (BOOL) checkOnline
{
   [lock5 lock];

    //not ready yet
    //if(![self isDoneLaunching])
     //   return NO;
    
    BOOL tempOnline = YES;
    

    if(![self HasConnection])
        tempOnline = NO;
    
        return tempOnline;
    
    [lock5 unlock];
}


- (void)loadMore 
{
    [lock7 lock];
    
    NSLog(@"%@", @"BingWallpaperiPhoneAppDelegate::loadMore");

    //wait 1st time
    /*if([self isFirstLoad])
    {
        [NSThread sleepForTimeInterval:0.3];
    }*/
    
    //isFirstLoad = NO;
    
    currentMaxLoad += MAX_LOAD;
    emptyTable = NO;
    [[archiveViewController tableViewController] loadMore];

    //update ad
    [archiveViewController updateBanner:YES];

    [lock7 unlock];
}

- (void)refresh 
{
    NSLog(@"%@", @"BingWallpaperiPhoneAppDelegate::refresh");
    
     //not ready yet
    if(![self isDoneLaunching])
        return;

    //hide show results
    [archiveViewController showNoResults:NO];
    
    //reset
    [self resetData];
   
    //[self fillTable];
    
    //[[archiveViewController tableViewController]  startLoading];
    [[archiveViewController tableViewController].tableView reloadData];
    
    //timestamp last refresh
    if([self checkOnline])
        timeLastRefresh = [NSDate date];

}

- (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize {
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
    
    //white background
    [[UIColor whiteColor] set];
    UIRectFill(CGRectMake(0, 0, newSize.width, newSize.height));

    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();    
    UIGraphicsEndImageContext();
    return newImage;
}


-(void)cornerView:(UIView*)inView
{
    //disabled
    return;
    
    float radius = 0.0f;
    if([self isIpad])
        radius = 5.0f;
    else
        radius = 5.0f;
    
    inView.layer.backgroundColor = [UIColor blackColor].CGColor;
    [inView.layer setMasksToBounds:YES];
    [inView.layer setCornerRadius:radius]; //5.0f or 8.0f?
    //inView.clipsToBounds = YES;
    //inView.layer.masksToBounds = YES;
}

- (void)selectImage:(int)index showView:(BOOL)show
{
    NSLog(@"BingWallpaperiPhoneAppDelegate::selectImage: %d", index);

    if(show)
    {
        if(alreadySelectImage)
            return;

        alreadySelectImage = YES;
        
        indexToLoad = index;
        
        //save thumb
				savedThumbImage = nil;
				//sanity check?
				if(index < imageThumbArray.count)
        	savedThumbImage = [imageThumbArray objectAtIndex:index];
        if(savedThumbImage)
        {
            //from web
            int imageH = 768;
            int imageW = 1366;
            
            savedThumbImage = [self imageWithImage:savedThumbImage scaledToSize:CGSizeMake(imageW,imageH)];
            savedImage =  savedThumbImage;
        }
        [archiveViewController selectImage:index showView:show];
    }
}

- (NSString*)nameToLoad
{
    NSLog(@"BingWallpaperiPhoneAppDelegate::nameToLoad");

    //if([nameArray count] == 0)
     //   return @"";

    NSAssert2(indexToLoad < [nameArray count], @"BingWallpaperiPhoneAppDelegate::nameToLoad %d out of bounds %d", indexToLoad, [nameArray count]);

    return [nameArray objectAtIndex:indexToLoad];
}


/*- (BOOL)navigationBar:(UINavigationBar *)navigationBar shouldPopItem:(UINavigationItem *)item
{
    //[[appDelegate navController] setNavigationBarHidden:YES animated:YES];

    return YES;
}*/


-(void)copyImageToClipboard:(UIImage*)inImage
{
    if(inImage != nil)
        [UIPasteboard generalPasteboard].image = inImage;
}


-(void)updateNumAppsBadge
{
    [archiveViewController updateBadge];
}

-(void)hideNumAppsBadge
{
    //int tabIndex = 1;
    //[[ [tabBarController tabBar].items objectAtIndex:tabIndex] setBadgeValue:nil];
    
    //save
    if(numApps > prefNumApps)
    {
        prefNumApps = numApps;
        [self saveState];
    }
}

-(int)getNumApps
{
    if(![self HasConnection])
    {
        numApps = 0;
    }
    else
    {
        if(!numAppsDownloaded) //not yet updated
        {
            NSURL *datasourceURL = [NSURL URLWithString:URL_API_NUM_APPS];
            NSURLRequest *request = [NSURLRequest requestWithURL:datasourceURL];
            AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
                        
            [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation* operation, id responseObject){
            
                //convert data to string, then string to int
                NSData* data =  [operation responseData];
                NSString* responseString = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
                numApps = [responseString intValue];
                numApps--; //dont count myself
                if(numApps < 0)
                    numApps = 0;
                else if(numApps > 99)
                    numApps = 99;
                
                numAppsDownloaded = YES;
                [self updateNumAppsBadge];

                
            }failure:^(AFHTTPRequestOperation* operation, NSError* error){
                numAppsDownloaded = NO;
                numApps = 0;
            }];
        
            //[operation start];
            [operationQueue addOperation:operation];
        
            return 0;
        }
    }
    
    return numApps;
}

- (void)pushAbout
{
    if(aboutViewController)
    {
        if(![self.navController.topViewController isKindOfClass:[aboutViewController class]])
        {
            [self.navController pushViewController:aboutViewController animated:YES];
        }
    }
    
    /*if(aboutViewController)
    {
        @try {
            [self.navController pushViewController:aboutViewController animated:YES];
        }
        @catch (NSException * ex) {
            //“Pushing the same view controller instance more than once is not supported” 
            //NSInvalidArgumentException
            NSLog(@"Exception: [%@]:%@",[ex  class], ex );
            NSLog(@"ex.name:'%@'", ex.name);
            NSLog(@"ex.reason:'%@'", ex.reason);
            //Full error includes class pointer address so only care if it starts with this error
            NSRange range = [ex.reason rangeOfString:@"Pushing the same view controller instance more than once is not supported"];

            if([ex.name isEqualToString:@"NSInvalidArgumentException"] &&
               range.location != NSNotFound)
            {
                //view controller already exists in the stack - just pop back to it
                [self.navController popToViewController:aboutViewController animated:NO];
            }else{
                NSLog(@"ERROR:UNHANDLED EXCEPTION TYPE:%@", ex);
            }
        }
        @finally
        {
            //NSLog(@"finally");
        }
    }
    else
    {
        NSLog(@"ERROR:pushViewController: viewController is nil");
    }*/
}


- (BOOL) isShowDefault
{
	//force hide, for Default.png
	return NO;
}

- (BOOL) isTapForTap
{
    BOOL value = NO;
    //value =  prefTap && ![self isIpad]; //iphone only, no ipad
    //value =  prefTap && ![self isIpad]; //iphone only, no ipad
    
    //value =  prefTap; //all
    
    return value;
 }

- (NSString*) getStringFromURL:(NSString*)url
{    
    NSURL *viewURL = [NSURL URLWithString:url];
    NSString* outStr = [[NSString alloc] initWithData:[NSData dataWithContentsOfURL:viewURL] encoding:NSASCIIStringEncoding];
    return outStr;
}

-(NSUInteger)supportedInterfaceOrientations
{
    if([self isIpad])
    {
        return UIInterfaceOrientationMaskAll;
    }
    else
    {
        //return UIDeviceOrientationPortrait;
        return UIInterfaceOrientationMaskAllButUpsideDown;

    }
}

- (BOOL)shouldAutorotate
{
    if([self isIpad])
    {
        return YES;
    }
    else
    {
        return NO;
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if([self isIpad])
    {
        return YES;
    }
    else 
    {
        if(interfaceOrientation == UIDeviceOrientationPortrait) 
            return YES;
        else 
            return NO;
    }
}

- (void)fadeDefaultSetup
{
	if([self isIphone5])
        splash = [[UIImageView alloc] initWithImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Default-568h@2x" ofType:@"png"]]];
    else
        splash = [[UIImageView alloc] initWithImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Default" ofType:@"png"]]];

	splash.alpha = 1.0f;
	splash.hidden = NO;
	[self.window addSubview:splash];
	[[self window] bringSubviewToFront:splash];
}

- (void)fadeDefault
{
	if(alreadyFadeDefault)
		return;
    
    if(splash == nil)
        return;
	
	alreadyFadeDefault = YES;
	
	//wait?
    //force wait, show default longer, ugly but good enough for now
    //[NSThread sleepForTimeInterval:0.2];
	
    //fade
    //if(true)
    {
        //iphone
        //UIImageView *splash = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Default.png"]];
		/*if(splash == nil)
		 splash = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Default.png"]];
		 
		 splash.alpha = 1.0f;
		 splash.hidden = NO;
		 [self.window addSubview:splash];
		 [[self window] bringSubviewToFront:splash];*/
		
        [UIView animateWithDuration:0.4f
                         animations:^{
                             splash.alpha = 0.0f;
                         }
                         completion:^(BOOL finished) {
                             [splash removeFromSuperview];
                             splash = nil;
                         }];
	}
}

- (void)addFavorite:(NSString*)idString
{
    if(!idString)
        return;
    
    //already in list
    if([self isFavorite:idString])
        return;
    
    //add
    [favoritesArray addObject:idString];
    
    favoritesModified = YES;
    
    [Helpers showMessageHud:@"Favorite added"];

}

- (void)removeFavorite:(NSString*)idString
{
    if(!idString)
        return;

    //not in list
    if(![self isFavorite:idString])
        return;
    
    //delete
    [favoritesArray removeObject:idString];
    
    favoritesModified = YES;
    
    [Helpers showMessageHud:@"Favorite removed"];

}

- (BOOL)isFavorite:(NSString*)idString
{
    if(!idString)
        return NO;
    
    BOOL value = NO;
    
    for(NSString *found in favoritesArray)
    {
        if([found isEqualToString:idString])
        {
            value = YES;
            break;
        }
    }
    
    return value;
}

- (void)loadIAP
{
    products = nil;

   //disabled
   //if([self isDebug] && ![self isSimulator])
   //   return;
    
	//offline
	if(![self checkOnline])
		return;
		

	[BingWallpaperIAPHelper sharedInstance];

    [[BingWallpaperIAPHelper sharedInstance] requestProductsWithCompletionHandler:^(BOOL success, NSArray *newProducts) {
        if (success) {
            products = newProducts;
			if(products != nil && [products count]>0)
				productRemoveAds = products[0];
        }
    }];
}

- (void)startWobble:(UIView *)view
{
	//disabled
    return;
    
     view.transform = CGAffineTransformRotate(CGAffineTransformIdentity, RADIANS(-WOBBLE_DEGREES));

     [UIView animateWithDuration:WOBBLE_SPEED
          delay:0.0 
          options:(UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionRepeat | UIViewAnimationOptionAutoreverse)
          animations:^ {
           view.transform = CGAffineTransformRotate(CGAffineTransformIdentity, RADIANS(WOBBLE_DEGREES));
          }
          completion:NULL
     ];
}

- (void)stopWobble:(UIView *)view
{
	//disabled
    return;
    
     [UIView animateWithDuration:WOBBLE_SPEED
          delay:0.0 
          options:(UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveLinear)
          animations:^ {
           view.transform = CGAffineTransformIdentity;
          }
          completion:NULL
      ];
}

-(void)updateInReview
{
    [self setShowLockscreen:NO];
    [self setInReview:YES];
	
	if(![self isOnline])
		return;
	
	//get list
    NSURL * url_afn = [NSURL URLWithString:URL_API_IN_REVIEW];
    NSURLRequest *request_afn = [[NSURLRequest alloc] initWithURL:url_afn];
    [AFJSONRequestOperation addAcceptableContentTypes:[NSSet setWithObject:@"text/html"]];
	AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request_afn
																						success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON)
										 {
											//save it
											if([JSON count] == 1)
											{
												int newValue = [[JSON[0] objectForKey:@"value"] integerValue];
												
                                                //not in review
                                                if(newValue == 0)
                                                {
                                                    [self setShowLockscreen:YES];
                                                    [self setInReview:NO];

                                                }
											}
										 }
										
                                        failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON)
										 {
											 NSLog(@"Request Failed with Error: %@, %@", error, error.userInfo);
										 }];
    
    [operation setShouldExecuteAsBackgroundTaskWithExpirationHandler:^{
							NSLog(@"Request timed out.");
	}];
    //[operation start];
    [operationQueue addOperation:operation];
}


#pragma mark -
#pragma mark Notifications

- (void)application:(UIApplication *)app didReceiveLocalNotification:(UILocalNotification *)notif {
    // Handle the notificaton when the app is running
    [self processNotification:notif];
    [self setupNotifications];
}

- (void) processNotification:(UILocalNotification *)notif {
    
    if(notif) {
        NSLog(@"Recieved Notification %@",notif);
    }
}

- (void)setupNotifications {
 
    //reset
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    
    //disabled
    //return;
    
    /*
    //push
    //support ios7-8
    if ([[UIApplication sharedApplication] respondsToSelector:@selector(registerUserNotificationSettings:)]) {
        //ios8
        UIUserNotificationSettings* notificationSettings = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert | UIUserNotificationTypeBadge | UIUserNotificationTypeSound categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:notificationSettings];
        [[UIApplication sharedApplication] registerForRemoteNotifications];
    } else {
        //ios7
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes: (UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
    }
     */
    
    //next monday
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    [gregorian setLocale:[NSLocale currentLocale]];
    NSDateComponents *components = [gregorian components:NSYearCalendarUnit | NSWeekCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit fromDate:[NSDate date]];

    //past monday, go to next week
    if([components weekday] >=  DAY_MONDAY)
        [components setWeek: [components week] + 1];
    
    [components setWeekday:DAY_MONDAY]; //Monday
    [components setHour:12]; //12pm
    [components setMinute:0];
    [components setSecond:0];

    //add
    NSDate *nextdDate = [gregorian dateFromComponents:components];
    nextdDate = [nextdDate dateByAddingDays:7];
    
    UILocalNotification *notif = [[UILocalNotification alloc] init];
    if (notif == nil)
        return;
    
    notif.fireDate = nextdDate;
    notif.repeatInterval = NSMonthCalendarUnit; //repeat every month
    notif.timeZone = [NSTimeZone defaultTimeZone];
    notif.alertBody = @"New wallpapers are available.";
    notif.alertAction = @"View";
    notif.soundName = UILocalNotificationDefaultSoundName;
    notif.applicationIconBadgeNumber = 1;
    
    // Schedule the notification
    [[UIApplication sharedApplication] scheduleLocalNotification:notif];
}

-(UIImage *) generateQRCodeWithString:(NSString *)string scale:(CGFloat) scale{
    NSData *stringData = [string dataUsingEncoding:NSUTF8StringEncoding ];
    
    CIFilter *filter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
    [filter setValue:stringData forKey:@"inputMessage"];
    [filter setValue:@"M" forKey:@"inputCorrectionLevel"];
    
    // Render the image into a CoreGraphics image
    CGImageRef cgImage = [[CIContext contextWithOptions:nil] createCGImage:[filter outputImage] fromRect:[[filter outputImage] extent]];
    
    //Scale the image usign CoreGraphics
    UIGraphicsBeginImageContext(CGSizeMake([[filter outputImage] extent].size.width * scale, [filter outputImage].extent.size.width * scale));
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetInterpolationQuality(context, kCGInterpolationNone);
    CGContextDrawImage(context, CGContextGetClipBoundingBox(context), cgImage);
    UIImage *preImage = UIGraphicsGetImageFromCurrentImageContext();
    
    //Cleaning up .
    UIGraphicsEndImageContext();
    CGImageRelease(cgImage);
    
    // Rotate the image
    UIImage *qrImage2 = [UIImage imageWithCGImage:[preImage CGImage]
                                            scale:[preImage scale]
                                      orientation:UIImageOrientationDownMirrored];
    return qrImage2;
}

@end
