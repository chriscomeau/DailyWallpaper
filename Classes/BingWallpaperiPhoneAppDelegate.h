//
//  BingWallpaperiPhoneAppDelegate.h
//
//  Created by Chris Comeau on 10-03-18.
//  Copyright Games Montreal 2010. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
//#import "LocalyticsSession.h"
//#import "FlurryAnalytics.h"
#import <AudioToolbox/AudioToolbox.h>
#import "WelcomeViewController.h"
#import "AboutViewController.h"
#import "QRViewController.h"
//#import "JSONKit.h"
#import "FirstViewController.h"
#import "ArchiveViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "SideMenuViewController.h"
#import "BingWallpaperIAPHelper.h"
#import <StoreKit/StoreKit.h>

//cleanup svn
//find . -type d -name '.svn' -print0 | xargs -0 rm -rdf
//find . -type d -name '.git' -print0 | xargs -0 rm -rdf
//find . -name ".DS_Store" -depth -exec rm {} \;

//sounds
//#define SOUND_1 @"sound1"

//logout IAP
//~/Library/Application\ Support/iPhone\ Simulator/6.1/Library/com.apple.itunesstored
//~/Library/Application Support/iPhone Simulator/6.1/Library/com.apple.itunesstored



/*
//no cache
header("Cache-Control: no-cache, must-revalidate"); //HTTP 1.1
header("Pragma: no-cache"); //HTTP 1.0
header("Expires: Sat, 26 Jul 1997 05:00:00 GMT"); // Date in the past

*/

#define kAppStoreURL @"https://itunes.apple.com/app/id557949358"
#define kAppStoreAppID 557949358


#define CACHE_POLICY_IMAGES NSURLRequestUseProtocolCachePolicy
#define CACHE_POLICY_AD NSURLRequestReloadIgnoringLocalCacheData

//urls
#ifdef DEBUG
#define URL_KEY @"8g7tj568g756"
#else
#define URL_KEY @"???"
#endif

#define URL_API_NUM_APPS @"???"
#define URL_API @"???"
#define URL_API_RANDOM @"???"
#define URL_API_POPULAR @"???"
#define URL_API_FAVORITES @"???"
#define URL_API_IMAGE @"???"
#define URL_API_THUMB @"???"
#define URL_API_INC_VIEW @"???"
#define URL_API_IN_REVIEW @"???"
#define URL_API_DELETE @"???"

//ads
#define URL_API_AD_LIST @"???"


//color
#define RGB(r, g, b) [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:1]
#define RGBA(r, g, b, a) [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:a]


typedef enum {
    APP_ID_PASSGRID = 0,
    APP_ID_DAILYWALL = 1,
    APP_ID_QRLOCK = 2,
    APP_ID_QUOTE = 3,
    APP_ID_GOLF = 4,

    APP_ID_COINY = 5,
    
} APP_ID;

#define APP_ID_CURRENT APP_ID_DAILYWALL


//http://www.idev101.com/code/User_Interface/sizes.html
#define STATUS_BAR_HEIGHT 20
#define NAV_BAR_HEIGHT 44
#define TOOL_BAR_HEIGHT 44 //?
#define TAB_BAR_HEIGHT 49

//System Versioning Preprocessor Macros

#define SYSTEM_VERSION_EQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define SYSTEM_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)

#define CLICK_DELAY 0.2f

#define MAX_LOAD 25 // 10

#define MAX_HUD_TIME 30
#define MIN_HUD_TIME 1

#define SPLASH_FADE_TIME 0.3f
#define SPLASH_FADE_TIME_LONG 1.0f
#define CHECKONLINE_REPEAT_TIME 5
#define CONNECTION_TIMEOUT 15
#define LOAD_MORE_DELAY_TIME 1.0 //0.5

#define CELL_HEIGHT_NORMAL 121
#define CELL_HEIGHT_MORE 121

#define MAX_ZOOM_MULT 4


//strings
#define STR_CELL_LOAGING_MORE @"Loading more..."

#define SLIDE_LEN 259
#define SLIDE_LEN_DETAILS 320
#define SLIDE_DELAY 0.3f //0.25f //0.5f
#define NUM_MINUTES_TO_REFRESH 60

//IAP
#define IAP_SECRET @"???"
#define IAP_ID_REMOVEADS @"com.skyriser.bingwallpapers.removeads"
#define IAP_URL_VERIFY @"https://sandbox.itunes.apple.com/verifyReceipt" //{"status":21000}

//wobble
#define RADIANS(degrees) ((degrees * M_PI) / 180.0)
#define WOBBLE_DEGREES 1
#define WOBBLE_SPEED 0.2 //0.25

@interface BingWallpaperiPhoneAppDelegate : NSObject <MFMailComposeViewControllerDelegate, UIAlertViewDelegate, UIApplicationDelegate, UINavigationBarDelegate> {
    UIWindow *window;
    UINavigationController *navController;
    UIImage *qrImage;
    
    BOOL showingHelp;
    BOOL prefRated;
    
    FirstViewController     *firstViewController;
	WelcomeViewController      *modalHelp;
	QRViewController        *modalQR;
    ArchiveViewController   *archiveViewController;
    AboutViewController		*aboutViewController;
    SideMenuViewController  *sideMenuViewController;
    
    UIImage *savedImage;
    UIImage *savedThumbImage;
    UIImage *savedAdImage;
    
    BOOL random;
    BOOL isDoneLaunching;
    BOOL isOnline;
    BOOL isLoading;
    BOOL alreadyLoadingNext;
    
    BOOL tableLoaded;
    BOOL alreadyFillTable;
    BOOL alreadyFillTable2;
    BOOL alreadySelectImage;
    BOOL emptyTable;
    BOOL isSliding;

    int currentMaxLoad;
    int totalItems;

    NSData          *apiData;
    
    NSMutableArray *nameArray;
    NSMutableArray *descriptionArray;
    NSMutableArray *idArray;
    
    
    int indexToLoad;
    UIImage *missingThumb;
    
    UIImage *cellBackImage1;
    UIImage *cellBackImage2;
    
  	BOOL prefOpened;
 	int prefRunCount;
    int prefNumApps;
    int currentAdId;
    NSString *currentAdUrl;
    BOOL prefPlaySound;
    BOOL prefShowAll;
    NSString *prefVersion;
    double lastTimeSince70;
    BOOL prefPurchasedRemoveAds;
    
    BOOL numAppsDownloaded;
    int numApps;
    NSDate *timeLastRefresh;

    SystemSoundID audioEffect;
	
	NSArray *products;
	SKProduct * productRemoveAds;
    
    NSMutableArray *adArray;
}


-(BOOL)backgroundSupported;
- (NSString *) platform;
- (NSString *) platformString;
- (BOOL)isIpad;
- (BOOL) isIphone5;
- (BOOL)isTestflight;
- (BOOL)isDebug;
- (BOOL)isSimulator;
- (BOOL)isRetina;
- (BOOL)openURL:(NSURL*)url;
- (BOOL)HasConnection;
- (NSString *)getSecureID;
-(void)cornerView:(UIView*)inView;
-(void)addNavigationController:(UINavigationController*)nav;

-(UIImage*) maskImage:(UIImage *)inputImage withMask:(UIImage *)inputMaskImage;
-(UIImage *)changeWhiteColorTransparent: (UIImage *)image;
-(UIImage *)colorizeImage: (UIImage *)image;
-(UIImage*) createMaskWithImage: (UIImage*) image;
-(UIImage*) getQRImage;
- (void)alertHelp:(BOOL)isAnimated;
- (void)alertQR:(BOOL)isAnimated;
- (void)sendEmailTo:(NSString *)to withSubject:(NSString *)subject withBody:(NSString *)body withImage:(UIImage*)image withView:(UIViewController*)theView;
- (void)alertHelpDone;
- (void)alertHelpDoneFirstTime;
- (void)alertHelpDoneNotAnimated;
- (void)gotoReviews;
- (void)gotoCoinyBlock;
//- (void)gotoGift;
- (void)gotoAd;
- (void)gotoFacebook;
- (void)gotoTwitter;
- (void)gotoQRScannerApp;
-(void)openRatings;
- (NSString*)getUserAgent;
- (NSString*)getVersionString;
- (NSString*)getVersionString2;
-(void)updateNumAppsBadge;
-(int)getNumApps;
-(void)hideNumAppsBadge;
- (void)pushAbout;
- (void) updateAd;
- (void) updateAd2;
- (void) fillTable;
- (void) fillTable2;
- (void)resetData;

- (void)loadNextImage;
- (void)selectImage:(int)index showView:(BOOL)show;
- (NSString*)nameToLoad;
- (void)saveState;
- (void)saveStateDefault;
- (void)loadState;
- (BOOL) checkOnline;
- (void) playSound:(NSString*)filename;
- (void)loadMore;
- (void)refresh;
- (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize;
-(void)copyImageToClipboard:(UIImage*)inImage;
- (BOOL) isTapForTap;
- (BOOL) isShowDefault;
- (NSString*) getStringFromURL:(NSString*)url;
- (void)fadeDefault;
- (void)fadeDefaultSetup;
- (void)loadIAP;
- (BOOL)isFavorite:(NSString*)idString;
- (void)addFavorite:(NSString*)idString;
- (void)removeFavorite:(NSString*)idString;
- (void)startWobble:(UIView *)view;
- (void)stopWobble:(UIView *)view;
-(void)updateInReview;
-(void)setupCache:(BOOL)empty;

@property (nonatomic, retain) UIImage *missingThumb;

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UINavigationController *navController;
@property (nonatomic, retain) IBOutlet FirstViewController *firstViewController;
@property (nonatomic, retain) UIImage *qrImage;
@property (nonatomic, retain) UIImage *savedImage;
@property (nonatomic, retain) UIImage *savedAdImage;
@property (nonatomic, retain) UIImage *savedThumbImage;
@property (assign, nonatomic) BOOL showingHelp;
@property (assign, nonatomic) BOOL prefRated;
@property (assign, nonatomic) BOOL random;
@property (assign, nonatomic) BOOL popular;
@property (assign, nonatomic) BOOL favorites;
@property (assign, nonatomic) BOOL favoritesModified;
@property(nonatomic, assign) BOOL isSliding;

@property (nonatomic, retain) NSMutableArray *idArray;
@property (nonatomic, retain) NSMutableArray *nameArray;
@property (nonatomic, retain) NSMutableArray *descriptionArray;
@property (nonatomic, retain) NSMutableArray *imageDownloadedFlag;
@property (nonatomic, retain) NSMutableArray *imageUpdatedFlag;
@property (nonatomic, retain) NSMutableArray *favoritesArray;

@property(nonatomic, assign) int indexToLoad;
@property(nonatomic, assign) BOOL isDoneLaunching;
@property(nonatomic, assign) BOOL isOnline;
@property(nonatomic, assign) BOOL isLoading;
@property(nonatomic, assign) BOOL tableLoaded;
@property(nonatomic, assign) int currentMaxLoad;
@property(nonatomic, assign) int totalItems;
@property (nonatomic, retain) NSMutableArray *imageThumbArray;
@property (nonatomic, retain) ArchiveViewController *archiveViewController;
@property (nonatomic, retain) AboutViewController *aboutViewController;
@property (nonatomic, retain) SideMenuViewController *sideMenuViewController;
@property(nonatomic,retain) IBOutlet UIImage *cellBackImage1;
@property(nonatomic,retain) IBOutlet UIImage *cellBackImage2;
@property (assign, nonatomic) int prefRunCount;
@property (assign, nonatomic) int prefNumApps;
@property (assign, nonatomic) int currentAdId;
@property (nonatomic, retain) NSString *currentAdUrl;
@property (assign, nonatomic) BOOL prefPlaySound;
@property (assign, nonatomic) BOOL prefPurchasedRemoveAds;
@property (assign, nonatomic) BOOL prefShowAll;
@property (nonatomic, retain) NSString *prefVersion;
@property (assign, nonatomic) double lastTimeSince70;
@property (assign, nonatomic) BOOL prefOpened;
@property(nonatomic, retain) NSDate *timeLastRefresh;
@property (assign, nonatomic) BOOL alreadyFadeDefault;
@property (strong, nonatomic) UIImageView *splash;
@property (nonatomic, retain) UIColor *buttonTextColor;
@property (assign, nonatomic) BOOL alreadySelectImage;
@property (nonatomic, retain) NSArray *products;
@property (nonatomic, retain) SKProduct * productRemoveAds;
@property (assign, nonatomic) BOOL showLockscreen;
@property (assign, nonatomic) BOOL inReview;
@property (assign, nonatomic) int prefMailchimpCount;
@property (assign, nonatomic) BOOL prefMailchimpShown;
@property (strong, nonatomic) NSOperationQueue *operationQueue;

@end
