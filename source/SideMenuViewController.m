//
//  SideMenuViewController.m
//  Skyriser


#import "SideMenuViewController.h"
#import "BingWallpaperiPhoneAppDelegate.h"
#import "ArchiveViewController.h"
//#import "FlurryAnalytics.h"
//#import "UIDevice-Hardware.h"

#import "HapticHelper.h"

@interface SideMenuViewController ()

@end

@implementation SideMenuViewController

@synthesize buttonLatest;
@synthesize buttonPopular;
@synthesize buttonRandom;
@synthesize buttonRight;
@synthesize buttonFavorites;
@synthesize buttonAd;
@synthesize buttonCoinyBlock;
@synthesize shadow;
@synthesize screenshot;
@synthesize labelSort;
@synthesize labeCoinyBlock;
@synthesize checkLatest;
@synthesize checkPopular;
@synthesize checkRandom;
@synthesize checkFavorites;
@synthesize checkAd;

NSRecursiveLock *lock10;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated 
{
    [super viewWillAppear:animated];
    
    //google analytics
    [Helpers setupGoogleAnalyticsForView:[[self class] description]];
    
    //checkmarks
    [self updateCheckmarks];
    
    //screenshot
    [[self view] bringSubviewToFront:screenshot];
    
    
    //notify
    if([appDelegate backgroundSupported])
    {
        [[NSNotificationCenter  defaultCenter] addObserver:self
                                                  selector:@selector(notifyForeground)
                                                      name:UIApplicationWillEnterForegroundNotification
                                                    object:nil];
    }
    

    
    BOOL exit = NO;
    if([appDelegate prefPurchasedRemoveAds])
        exit = YES;
    
    else if (![appDelegate isDebug] && [[BingWallpaperIAPHelper sharedInstance] productPurchased:[appDelegate productRemoveAds].productIdentifier])
        exit = YES;

    buttonAd.hidden = exit;
    checkAd.hidden = buttonAd.hidden;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}


- (void)viewWillDisappear:(BOOL)animated {
    
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    }

- (void)notifyForeground
{
    NSLog(@"ArchivetViewController::notifyForeground");
    
    //go back
    [[appDelegate archiveViewController] toggleSlide];    
}

- (void)viewDidLoad
{
    NSLog(@"%@", @"SideMenuViewController::viewDidLoad");
    
    [super viewDidLoad];
        
    appDelegate = (BingWallpaperiPhoneAppDelegate *)[[UIApplication sharedApplication] delegate];

    lock10 = [[NSRecursiveLock alloc] init];
    
    //self.view.alpha = 0.5f;
    
    buttonRight.hidden = NO;
    shadow.hidden = NO;
    screenshot.hidden = NO;
    shadow.alpha = 0.5f;
    
    [buttonRight addTarget:self action:@selector(actionRight:forEvent:) forControlEvents:UIControlEventTouchUpInside];
    
    //button fonts
    //UIFont *tempFont = [UIFont fontWithName:@"PTSans-Bold" size:22] ;
    UIFont *tempFont = kButtonFont;
    
    labelSort.font = tempFont;
    labeCoinyBlock.font = tempFont;
    
    //labelSort.textColor = RGBA(200,200,200, 255);
    labelSort.textColor = RGBA(255,255,255, 255);

    //labelSort.contentEdgeInsets = UIEdgeInsetsMake(10, 10, 0, 0);
    
    [buttonLatest addTarget:self action:@selector(actionLatest:forEvent:) forControlEvents:UIControlEventTouchUpInside];
    [buttonPopular addTarget:self action:@selector(actionPopular:forEvent:) forControlEvents:UIControlEventTouchUpInside];
    [buttonRandom addTarget:self action:@selector(actionRandom:forEvent:) forControlEvents:UIControlEventTouchUpInside];
    [buttonFavorites addTarget:self action:@selector(actionFavorites:forEvent:) forControlEvents:UIControlEventTouchUpInside];
    
    [buttonAd addTarget:self action:@selector(actionAd:forEvent:) forControlEvents:UIControlEventTouchUpInside];
    
    [buttonCoinyBlock addTarget:self action:@selector(actionCoinyBlock:forEvent:) forControlEvents:UIControlEventTouchUpInside];

    if (@available(iOS 11.0, *)) {
        buttonCoinyBlock.accessibilityIgnoresInvertColors = YES;
    }

    tempFont = kButtonFont;
    
    buttonLatest.titleLabel.font = tempFont;
    [buttonLatest setTitleColor:RGBA(200,200,200, 255) forState:UIControlStateHighlighted ];
    //buttonLatest.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    //buttonLatest.contentEdgeInsets = UIEdgeInsetsMake(10, 10, 0, 0);
    
    buttonPopular.titleLabel.font = tempFont;
    [buttonPopular setTitleColor:RGBA(200,200,200, 255) forState:UIControlStateHighlighted ];
    //buttonPopular.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    //buttonPopular.contentEdgeInsets = UIEdgeInsetsMake(10, 10, 0, 0);


    buttonRandom.titleLabel.font = tempFont;
    [buttonRandom setTitleColor:RGBA(200,200,200, 255) forState:UIControlStateHighlighted ];
    //buttonRandom.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    //buttonRandom.contentEdgeInsets = UIEdgeInsetsMake(10, 10, 0, 0);

    buttonFavorites.titleLabel.font = tempFont;
    [buttonFavorites setTitleColor:RGBA(200,200,200, 255) forState:UIControlStateHighlighted ];
    
    buttonAd.titleLabel.font = tempFont;
    [buttonAd setTitleColor:RGBA(200,200,200, 255) forState:UIControlStateHighlighted ];
    
	   
    //corner
    //[appDelegate cornerView:self.view];

}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)actionLatest:(id)sender forEvent:(UIEvent *)event
{
    NSLog(@"SideMenuViewController::actionLatest");
    
    
    [appDelegate setRandom:NO];
    [appDelegate setPopular:NO];
    [appDelegate setFavorites:NO];
    [appDelegate refresh];

    [self updateCheckmarks];

    //go back
    [[appDelegate archiveViewController] toggleSlide];
}

- (void)actionPopular:(id)sender forEvent:(UIEvent *)event
{
    NSLog(@"SideMenuViewController::actionPopular");
    
    [appDelegate setRandom:NO];
    [appDelegate setPopular:YES];
    [appDelegate setFavorites:NO];
    [appDelegate refresh];
    
    [self updateCheckmarks];
    
    //go back
    [[appDelegate archiveViewController] toggleSlide];    
}

- (void)actionRandom:(id)sender forEvent:(UIEvent *)event
{    
    NSLog(@"SideMenuViewController::actionRandom");
   
    
    [appDelegate setRandom:YES];
    [appDelegate setPopular:NO];
    [appDelegate setFavorites:NO];

    [appDelegate refresh];

    [self updateCheckmarks];

    //go back
    [[appDelegate archiveViewController] toggleSlide];
    
}

- (void)actionAd:(id)sender forEvent:(UIEvent *)event
{
    //go back
    [[appDelegate archiveViewController] toggleSlide];
    
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [[appDelegate archiveViewController] actionClose:self];
    });
}

- (void)actionCoinyBlock:(id)sender forEvent:(UIEvent *)event
{
    [HapticHelper generateFeedback:kFeedbackType];

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{

        [appDelegate gotoCoinyBlock];
    
    });
}

- (void)actionFavorites:(id)sender forEvent:(UIEvent *)event
{    
    NSLog(@"SideMenuViewController::actionFavorites");
   
    [appDelegate setRandom:NO];
    [appDelegate setPopular:NO];
    [appDelegate setFavorites:YES];
    [appDelegate refresh];

    [self updateCheckmarks];

    //go back
    [[appDelegate archiveViewController] toggleSlide];
    
}

- (void)actionRight:(id)sender forEvent:(UIEvent *)event
{    
    NSLog(@"SideMenuViewController::actionRight");
    
    [[appDelegate archiveViewController] toggleSlide];
}

-(void)setupShadow:(int)x;
{
    CGRect screenRect = [[UIScreen mainScreen] bounds];
	//CGFloat screenWidth = screenRect.size.width;
	CGFloat screenHeight = screenRect.size.height;

    shadow.hidden = NO;
    screenshot.hidden = NO;
    
    //int y = screenshot.frame.origin.y;
    //int y = -STATUS_BAR_HEIGHT; //-20
    int y = 0;
    
    //int height =  screenshot.frame.size.height;
    shadow.frame = CGRectMake(shadow.frame.origin.x, y, shadow.frame.size.width, screenHeight);
    screenshot.frame = CGRectMake(screenshot.frame.origin.x, y, screenshot.frame.size.width, screenHeight);
}

-(void)updateShadow:(int)x
{
    [lock10 lock];
        
    shadow.frame = CGRectMake(shadow.frame.origin.x  + x, shadow.frame.origin.y, shadow.frame.size.width, shadow.frame.size.height);
    screenshot.frame = CGRectMake(screenshot.frame.origin.x + x, screenshot.frame.origin.y, screenshot.frame.size.width, screenshot.frame.size.height);
    
    [lock10 unlock];
}


- (void)updateCheckmarks
{
    checkLatest.hidden = !([appDelegate random] == NO && [appDelegate popular] == NO && [appDelegate favorites] == NO);
    checkPopular.hidden = !([appDelegate random] == NO && [appDelegate popular] == YES && [appDelegate favorites] == NO);
    checkRandom.hidden = !([appDelegate random] == YES && [appDelegate popular] == NO && [appDelegate favorites] == NO);
    checkFavorites.hidden = !([appDelegate random] == NO && [appDelegate popular] == NO && [appDelegate favorites] == YES);
}

@end
