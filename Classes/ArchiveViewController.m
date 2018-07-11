//
//  ArchiveViewController.m
//
//  Created by Chris Comeau on 10-03-18.
//  Copyright Games Montreal 2010. All rights reserved.
//

#import "ArchiveViewController.h"
#import "BingWallpaperiPhoneAppDelegate.h"
#import "BingWallpaperIAPHelper.h"
#import <StoreKit/StoreKit.h>
#import "UIAlertView+Errors.h"

#import "HapticHelper.h"

@implementation ArchiveViewController

@synthesize tableView;
@synthesize darkImage;
@synthesize spin;
@synthesize tableViewController;
//@synthesize navigationController;
//@synthesize adView;
@synthesize closeButton;
@synthesize offlineImage;
@synthesize noResultsImage;
@synthesize adButton;
@synthesize badgeText;
@synthesize imageViewBadge;
@synthesize slide;
@synthesize tableButton;
@synthesize HUD;
@synthesize firstTimeAd;
@synthesize toggleCustomAd;

NSRecursiveLock *lock8;

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
    firstTimeAd = YES;
    toggleCustomAd = YES;
    
    [self becomeFirstResponder];

    lock8 = [[NSRecursiveLock alloc] init];

    appDelegate = (BingWallpaperiPhoneAppDelegate *)[[UIApplication sharedApplication] delegate];

    [appDelegate setArchiveViewController:self];
    
	adDownloaded = NO;
	slide = NO;
    slideX = 0;
    
    noResultsImage.hidden = YES;
    offlineImage.hidden = YES;
    
    //show load
    tableView.hidden = YES;
    darkImage.hidden = YES;
    spin.hidden = YES;
    
    //UIFont* tempFont = [UIFont fontWithName:@"Century Gothic" size:17] ;
	
	closed = NO;
    doHud = NO;
    
    //list
    tableViewController = [[TableViewController alloc] initWithStyle:UITableViewCellStyleDefault];
    //hide it
    tableViewController.view.hidden = NO;
    //resize
    tableViewController.view.frame = tableView.frame;
    [self.view addSubview:tableViewController.view];
    
    self.tableView.scrollsToTop = NO;
    tableViewController.tableView.scrollsToTop = YES;
    //cell border
    //UIView *v = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 0)];
    tableViewController.tableView.tableFooterView = [UIView new];
	
	//fix separator ios7
    [tableViewController.tableView setSeparatorInset:UIEdgeInsetsZero];

	//for ad
	//oldTableHeight = tableViewController.tableView.frame.size.height - NAV_BAR_HEIGHT;
    
    UIImage *menuImage =[UIImage imageNamed:@"leftButton.png"];
    UIBarButtonItem *menuButton = [[UIBarButtonItem alloc] initWithImage:menuImage style:UIBarButtonItemStylePlain target:self action:@selector(actionMenu:)];
    [self.navigationItem setLeftBarButtonItem:menuButton animated:NO];

    //invisible button covering table, to slide back
    [tableButton addTarget:self action:@selector(toggleSlide) forControlEvents:UIControlEventTouchUpInside];
    [[self view] bringSubviewToFront:tableButton];   
    tableButton.hidden = YES;
    tableButton.userInteractionEnabled = NO;

	/*UIImage *aboutImage =[UIImage imageNamed:@"info_20.png"];
    UIBarButtonItem *aboutButton = [[UIBarButtonItem alloc] initWithImage:aboutImage style:UIBarButtonItemStylePlain target:self action:@selector(actionAbout:)];
    [self.navigationItem setRightBarButtonItem:aboutButton animated:NO];
	
    //badge
    UIBarButtonItem *barButtonBadge = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"rightButtonBadge.png"] style:UIBarButtonItemStylePlain target:self action:@selector(actionAbout:)];
    self.navigationItem.rightBarButtonItem = barButtonBadge;
    */
    //[self updateBadge];
    
	[closeButton addTarget:self action:@selector(actionClose:) forControlEvents:UIControlEventTouchUpInside];
	[adButton addTarget:self action:@selector(actionAd:) forControlEvents:UIControlEventTouchUpInside];

	self.closeButton.hidden = YES;
    self.adButton.hidden = YES;
    
    //delay?
    if([appDelegate isOnline])
        [appDelegate performSelector:@selector(updateAd) withObject:nil afterDelay:0.5];

    //banner
    self.bannerView.delegate = self;
    self.bannerView.hidden = YES;
    self.closeButton.hidden = YES;
    self.adButton.hidden = YES;

}

- (void)notifyForeground
{
    NSLog(@"ArchivetViewController::notifyForeground");

    //update
    [appDelegate setIsOnline:[appDelegate checkOnline]];

	//reset, show on foreground
	//closed = NO;
		
	//if(![appDelegate isOnline])
	//	[self showAd:NO];

    //ad
    [self updateBanner:YES];

    //else if(![appDelegate isShowDefault])
	//	[self showAd:YES]; //show on foreground
	
	if(![appDelegate isOnline])
	{
		[appDelegate refresh];
	}
	
	//offline
	if([appDelegate isOnline])
		[self showOffline:NO];
	else
		[self showOffline:YES];
	
	//reload?
    //[appDelegate refresh];
    
    //switch ad
    if([appDelegate isOnline] && !closed && !self.adButton.hidden)
        [appDelegate performSelector:@selector(updateAd) withObject:nil afterDelay:0.5];
}

/*
-(void)setupAd
{
	//int adX = self.adBack.frame.origin.x; //0;
	//int adY = self.adBack.frame.origin.y; //0;
	//int adHeight = self.adBack.frame.size.height; //50;
	//int adWidth = self.adBack.frame.size.width; //320;
	
	//CGRect screenRect = [[UIScreen mainScreen] bounds];

	//adY -= NAV_BAR_HEIGHT;
	//adY = screenRect.size.height - 64 - adHeight; //cleanup?

	//if(self.adView == nil)
	{
		//self.adView = [[TapForTapAdView alloc] initWithFrame: CGRectMake(adX, adY, adWidth, adHeight) delegate: self];
		
		//auto
		//[self.adBack setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleWidth];
		
		//move ad back
		//CGRect tempFrame = self.adBack.frame;
		//tempFrame.origin.y = adY;
		//self.adBack.frame = tempFrame;
		//self.adView.frame = tempFrame;
		
		//adView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin;
		
		//adView.hidden = YES;
		
		//[self.view addSubview: self.adView];
        
        //[[self view] bringSubviewToFront:self.adBack];
        //[[self view] bringSubviewToFront:self.adView];

		//closeButton.hidden = YES;
        //adBack.hidden = YES;
	}
}
*/

-(void)showOffline:(BOOL)show
{
    if(show)
    {
        //self.tableViewController.refreshControl.hidden = YES;
        self.tableViewController.tableView.hidden = YES;
        
        //hide other
        [self showNoResults:NO];
        
        [[self view] bringSubviewToFront:self.offlineImage];
        
        //animate
        self.offlineImage.hidden = NO;
        self.offlineImage.alpha = 0.0;
        [UIView animateWithDuration:0.5
                                delay:0.0
                        options: UIViewAnimationCurveEaseInOut
                     animations:^{self.offlineImage.alpha = 1.0;; }
                     completion:nil];
    }
    else
    {
        self.tableViewController.tableView.hidden = NO;
        offlineImage.hidden = YES;
    }

}

-(void)showNoResults:(BOOL)show
{
    if(show)
    {
        //self.tableViewController.refreshControl.hidden = NO;

        //hide other
        [self showOffline:NO];
        
        [[self view] bringSubviewToFront:self.noResultsImage];
        
        //animate
        self.noResultsImage.hidden = NO;
        self.noResultsImage.alpha = 0.0;
        [UIView animateWithDuration:0.3
                                delay:0.0
                        options: UIViewAnimationCurveEaseInOut
                     animations:^{self.noResultsImage.alpha = 1.0;; }
                     completion:nil];
    }
    else
    {
        //self.tableViewController.refreshControl.hidden = NO;
        noResultsImage.hidden = YES;
    }
}


-(void)hideAd
{
    int viewHeight = self.view.frame.size.height;
    
    //shrink table
    CGRect tempFrame = tableViewController.tableView.frame;
    tempFrame.size.height = viewHeight;
    tableViewController.tableView.frame = tempFrame;
    
    //[appDelegate setPrefPurchasedRemoveAds:YES];
    //[appDelegate saveState];
    

    self.adButton.hidden = YES;
    self.closeButton.hidden = YES;
    self.bannerView.hidden = YES;
}

-(void)showAd:(BOOL)show
{
    //random
    //int oddsCustom = 50;
    BOOL showCustomAd = NO;
    /*if(arc4random_uniform(100) > oddsCustom || firstTimeAd)
    {
        showCustomAd = YES;
        firstTimeAd = NO;
    }*/
    
    //just switch
    if(firstTimeAd)
    {
        toggleCustomAd = YES;
        //firstTimeAd = NO;
    }
    
    showCustomAd = toggleCustomAd;
    toggleCustomAd = !toggleCustomAd;

    
    //disabled
    if(YES && [appDelegate isDebug])
    {
        //[self hideAd];
        //return;
    }
    
    self.adButton.hidden = NO;

    BOOL exit = NO;

    int adHeight = self.adButton.frame.size.height; //50;
	int viewHeight = self.view.frame.size.height;

    if(closed)
        exit = YES;

	else if([appDelegate isShowDefault])
        exit = YES;
    
    else if(![appDelegate isOnline] && show)
        exit = YES;
    
    else if([appDelegate prefPurchasedRemoveAds])
         exit = YES;        

    else if (![appDelegate isDebug] && [[BingWallpaperIAPHelper sharedInstance] productPurchased:[appDelegate productRemoveAds].productIdentifier])
        exit = YES;
        
    //else if([appDelegate savedAdImage] == nil)
    //    exit = YES;
    
   
	//else if(show && adView != nil && adView.hidden == NO)
	//  exit = YES;
	//else if(!show && (adView == nil || adView.hidden == YES))
    //    exit = YES;

    
        
    if(exit)
    {
        [self hideAd];
    	return;
    }
    
	//if(!adDownloaded)
	//	return;
	
	NSLog(@"showAd");
	
	//tapfortap
	//http://developer.tapfortap.com/sdk
	
		
	//shrink table
	CGRect tempFrame = tableViewController.tableView.frame;
    tempFrame.size.height = viewHeight;
    if(show)
        tempFrame.size.height -= adHeight;
    
	//not on ipad
	if(![appDelegate isIpad])
	   tableViewController.tableView.frame = tempFrame;
	
    if(show && showCustomAd)
    {
        [[self view] bringSubviewToFront:self.adButton];
        [[self view] bringSubviewToFront:self.closeButton];

        //self.bannerView.alpha = 0;
        
//        self.bannerView.hidden = YES;
        
//        self.adButton.hidden = NO;
//        self.bannerView.hidden = YES;

        //cross-fade
        [UIView transitionWithView:self.adButton
                          duration:0.0f //0.3f
                           options:UIViewAnimationOptionTransitionCrossDissolve
                        animations:^{
                            [self.adButton setImage:[appDelegate savedAdImage] forState:UIControlStateNormal];
                        } completion:nil];

    }
    else if(show && !showCustomAd)
	{
        [[self view] bringSubviewToFront:self.adButton];

        //self.bannerView.alpha = 1.0f;

        //self.bannerView.hidden = NO;
        //self.adButton.hidden = YES;
        
        //cross-fade
        /*[UIView transitionWithView:self.adButton
                  duration:0.3f
                   options:UIViewAnimationOptionTransitionCrossDissolve 
                animations:^{
                  [self.adButton setImage:[appDelegate savedAdImage] forState:UIControlStateNormal];
            } completion:nil];*/
        
        

        //[self.adButton setImage:[appDelegate savedAdImage] forState:UIControlStateNormal];    
		//int adX = 0;
		//int adY = 0;
		
		//adX = self.adButton.frame.origin.x;
		//adY = self.adButton.frame.origin.y; //0;
		
        

        //[[self view] bringSubviewToFront:self.adButton];
        [[self view] bringSubviewToFront:self.bannerView];
		[[self view] bringSubviewToFront:self.closeButton];
		
        //fade in
        if(self.bannerView.hidden) //only of hidden
        {
            self.closeButton.alpha = 0.0;
            //self.adButton.alpha = 0.0;
            self.bannerView.alpha = 0.0;
            self.closeButton.hidden = NO;
            //self.adButton.hidden = NO;
            self.bannerView.hidden = NO;
            
            [UIView animateWithDuration:0.0 //0.5
                          delay:0.0
                        options: UIViewAnimationCurveEaseInOut
                     animations:^{
                         self.closeButton.alpha = 1.0;
                         //self.adButton.alpha = 1.0;
                         self.bannerView.alpha = 1.0;
                     }
                     completion:nil];
        }
        
        
        //force hide banner
        //self.bannerView.hidden = showCustomAd;

		//move close
		/*int offset = 1;
		tempFrame = closeButton.frame;
		tempFrame.origin.x = adWidth - tempFrame.size.width + offset;
		tempFrame.origin.y = adY - tempFrame.size.height/2 + offset;
		closeButton.frame = tempFrame;*/
        
        //move back
        //self.adBack.frame = self.adView.frame;
		
		//[self updateUIOrientation];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            
            //show iap alert every n times
            int n = 10;
            BOOL random = ([appDelegate prefRunCount] % n) == 0;
            if(random && !self.askedClose)
            {
                [self actionClose:nil];
            }

        });

	}
	else
	{
        //adButton.hidden = YES;
        closeButton.hidden = YES;
        self.bannerView.hidden = YES;
		//if(adView != nil)
		//	adView.hidden = YES;
	}
}

/*

// Hook up a button to this method to show an interstitial, or call it before pushing a view controller, etc.
- (IBAction) showInterstitial: (id)sender
{
    // Show an Interstitial
    [TapForTapInterstitial showWithRootViewController: self];
}

// Hook up a button to this method to show an app wall
- (IBAction) showMoreApps: (id)sender
{
    // Show an App Wall
    [TapForTapAppWall showWithRootViewController: self];
}

#pragma mark - TapForTapAdViewDelegate methods
*/

- (UIViewController *) rootViewController
{
    //return self; // or possibly self.navigationController
    return self.navigationController;
}

/*
- (void) tapForTapAdViewDidReceiveAd: (TapForTapAdView *)adView
{
    NSLog(@"tapForTapAdViewDidReceiveAd");
	
	if(closed)
		return;
	
	adDownloaded = YES;
	
	if(![appDelegate isOnline])
		[self showAd:NO];
    else if([appDelegate isTapForTap] && ![appDelegate isShowDefault])
		[self showAd:YES];
}

- (void) tapForTapAdView: (TapForTapAdView *)adView didFailToReceiveAd: (NSString *)reason
{
    NSLog(@"didFailToReceiveAd: %@", reason);
	[self showAd:NO];
}

- (void) tapForTapAdViewWasTapped: (TapForTapAdView *)adView
{
    NSLog(@"tapForTapAdViewWasTapped");
	
	//[self showAd:NO];
}
*/

- (void)toggleSlide
{
    [HapticHelper generateFeedback:kFeedbackType];

    NSLog(@"ArchiveViewController::toggleSlide");

    //to prevent slide while sliding
    if([appDelegate isSliding])
       return;
       
    //slide out view
    
    slide = !slide; //toggle
       
    if(!slide)
    {
        //back to normal
        //[appDelegate window].rootViewController = [appDelegate navController];

    }
    else
    {
        //show menu
     
        //screenshot
        //http://nickharris.wordpress.com/2012/02/05/ios-slide-out-navigation-code/
        // before swaping the views, we'll take a "screenshot" of the current view
        // by rendering its CALayer into the an ImageContext then saving that off to a UIImage
      
        //UIView *whichView = self.view;
        UIView *whichView = [appDelegate navController].view;
        CGSize viewSize = whichView.bounds.size;
        UIGraphicsBeginImageContextWithOptions(viewSize, NO, 0.0);
        CGContextRef context = UIGraphicsGetCurrentContext();

        //offset for title bar
        //CGRect statusFrame= [[UIApplication sharedApplication] statusBarFrame];
        int offset = 0; //-statusFrame.size.height;
        CGContextTranslateCTM(context, 0, offset);
        
        [whichView.layer renderInContext:UIGraphicsGetCurrentContext()];

        // Read the UIImage object
        UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();

        // pass this image off to the MenuViewController then swap it in as the rootViewController
        [[appDelegate sideMenuViewController].screenshot setImage:image];
        
        
        //[appDelegate navController].view.userInteractionEnabled = NO;
        [appDelegate window].rootViewController = [appDelegate sideMenuViewController];
    }
    
    //disable input
    [self tableViewController].view.userInteractionEnabled =  !slide;
    
  
    //invisible button
    tableButton.hidden = !slide;
    tableButton.userInteractionEnabled = slide;
  	//[[self view] bringSubviewToFront:tableButton];
  
    //todo: sanity test?
    
    float time = SLIDE_DELAY;
    int len = SLIDE_LEN; //259
    if(!slide)
        len *= -1; //other way 

    if(slide)
        [[appDelegate sideMenuViewController] setupShadow:0];
    else
         [[appDelegate sideMenuViewController] setupShadow:SLIDE_LEN];

    //start slide
    [appDelegate setIsSliding:YES];
    
    slideX = 0;
    [UIView animateWithDuration:time
                     animations:^{
                                                  slideX += len;
                         [[appDelegate sideMenuViewController] updateShadow:slideX];

                     }
     
                     completion:^(BOOL finished){
                         if(finished)
                         {
                             //slideView.hidden = YES;
                             [appDelegate setIsSliding:NO];
                             
                             if(!slide)
                                [appDelegate window].rootViewController = [appDelegate navController];

                         }
                    }
     ];

}

- (void)actionMenu:(id)sender
{
    [self toggleSlide];
    
    /*return;
    
    //popup
    UIActionSheet * actionSheet=nil;
    actionSheet = [[UIActionSheet alloc] initWithTitle:@"Sort by..."
                                              delegate:self
                                     cancelButtonTitle:@"Cancel"
                                destructiveButtonTitle:nil
                                otherButtonTitles:@"Latest",@"Popular", @"Random", nil];
    
    
    //[actionSheet showInView:self.view];
    [actionSheet showInView:self.view];*/
}

- (void)actionClose:(id)sender
{
    [HapticHelper generateFeedback:kFeedbackType];

    self.askedClose = YES;
    
	//old way
    /*if([appDelegate isDebug] && ![appDelegate isSimulator])
    {
        [self showAd:NO];
        closed = YES;
        return;
    }*/
    
    //offline ignore
    if(![appDelegate isOnline])
    {
        //message
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"In-App Purchases" message:@"Please try again when you are connected to the internet." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show]; 
        return;
	}
    
	SKProduct* product = [appDelegate productRemoveAds];

	if(product == nil)
	{
		//todo:chris: check
		[self showAd:NO];
		closed = YES;
		return;
	}
	
	//price
	NSNumberFormatter * _priceFormatter;
	_priceFormatter = [[NSNumberFormatter alloc] init];
	[_priceFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
	[_priceFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
	
	// Add to bottom of tableView:cellForRowAtIndexPath (before return cell)
	[_priceFormatter setLocale:product.priceLocale];
	NSString *price = [_priceFormatter stringFromNumber:product.price];
			
	alertRemoveAd = nil;
    alertRemoveAd = [[UIAlertView alloc] initWithTitle:@"Remove Ads"
											message:[NSString stringWithFormat:@"Do you want to permanently remove all banner ads and encourage an indie app developer? (%@)", price]
										   delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
	[alertRemoveAd show];
	
}

-(void)alertView:(UIAlertView *)alertView willDismissWithButtonIndex:    (NSInteger)buttonIndex
{
	
    if(alertView == alertRemoveAd)
    {
        if(buttonIndex==0)
        {
            //cancel
        }
        else if(buttonIndex==1)
        {
			//[self showAd:NO];
			//closed = YES;
			
			[self buyRemoveAds];
        }
	}
}

- (void)actionAd:(id)sender
{
    [appDelegate gotoAd];
}

- (void)actionAbout:(id)sender
{
    [HapticHelper generateFeedback:kFeedbackType];

    //slide menu
    if(slide)
    {
        [self toggleSlide];
    }
    
    /*int numApps = [appDelegate getNumApps];
    if(numApps > 0)
    {
        [appDelegate setPrefNumApps:numApps];
        [appDelegate saveState];
    }
    */
    
    //back
    UIBarButtonItem *newBackButton = [[UIBarButtonItem alloc] initWithTitle: @"" style: UIBarButtonItemStyleBordered target: nil action: nil];
    [[self navigationItem] setBackBarButtonItem: newBackButton];

    [appDelegate performSelector:@selector(pushAbout) withObject:nil afterDelay:0.1];
	//[appDelegate pushAbout];
}

-(void) actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    
    NSLog(@"ArchivetViewController::actionSheet didDismissWithButtonIndex");

    /*switch (buttonIndex)
    {
         case 0: //latest
            [appDelegate setRandom:NO];
            [appDelegate setPopular:NO];
            [appDelegate refresh];
            break;
            
        case 1: //popular, todo
            [appDelegate setRandom:NO];
            [appDelegate setPopular:YES];
            [appDelegate refresh];
            break;
    
        case 2: //random
            [appDelegate setRandom:YES];
            [appDelegate setPopular:NO];
            [appDelegate refresh];
            break;
		
            
        default:
            break;
    }*/
    
}

//iap
- (void)inAppAlertAppeared:(id)sender
{
    NSLog(@"ArchiveViewController: inAppAlertAppeared");

	doHud = NO;
}


//tethering, in-call
- (void)statusBarWillChangeFrame:(id)sender
{
    NSLog(@"ArchiveViewController: statusBarWillChangeFrame");

	[self showAd:YES];
}

- (void)updateBadge
{
    NSLog(@"ArchiveViewController: updateBadge");
    
    int numApps = [appDelegate getNumApps];
    NSLog(@"ArchiveViewController: numApps: %d", numApps);
    
	//show num
    if(numApps > 0 && numApps > [appDelegate prefNumApps])
    //if(YES) //force
    //if(NO) //disabled
    {
        // ButtonItem right
        UIButton* rightButton = [[UIButton alloc] initWithFrame:CGRectMake(0,0,27,23)];
        [rightButton setBackgroundImage:[UIImage imageNamed:@"rightButtonBadge.png"] forState:UIControlStateNormal];
        [rightButton setBackgroundColor:[UIColor clearColor]];
        [rightButton addTarget:self action:@selector(actionAbout:) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem* buttonItem = [[UIBarButtonItem alloc] initWithCustomView:rightButton];
        self.navigationItem.rightBarButtonItem = buttonItem;
    }
    else
    {
        UIImage *aboutImage =[UIImage imageNamed:@"rightButton.png"];
        UIBarButtonItem *aboutButton = [[UIBarButtonItem alloc] initWithImage:aboutImage style:UIBarButtonItemStylePlain target:self action:@selector(actionAbout:)];
        [self.navigationItem setRightBarButtonItem:aboutButton animated:NO];
    }
}

- (void)selectImage:(int)index showView:(BOOL)show
{
    [lock8 lock];

    if(show)
    {
        [HapticHelper generateFeedback:kFeedbackType];

        //back button
        UIBarButtonItem *newBackButton = [[UIBarButtonItem alloc] initWithTitle: @"" style: UIBarButtonItemStyleBordered target: nil action: nil];
        //[[[appDelegate firstViewController] navigationItem] setBackBarButtonItem: newBackButton];
        [[self navigationItem] setBackBarButtonItem: newBackButton];
        
        [[appDelegate navController] pushViewController:[appDelegate firstViewController] animated:YES];
    }
    
    [lock8 unlock];

}

-(BOOL)canBecomeFirstResponder {
    return YES;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
	
    [self becomeFirstResponder];
    
    //google analytics
    [Helpers setupGoogleAnalyticsForView:[[self class] description]];
    
    //check online
    [appDelegate setIsOnline:[appDelegate checkOnline]];


	//iap
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(productPurchased:) name:IAPHelperProductPurchasedNotification object:nil];
	
    [[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(statusBarWillChangeFrame:)
												 //name:UIApplicationWillChangeStatusBarFrameNotification
												 name:UIApplicationDidChangeStatusBarFrameNotification
											   object:nil];
	 
	 //for in-app confirm
    [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(inAppAlertAppeared:) 
                                               name:UIApplicationWillResignActiveNotification 
                                             object:nil];



    tableViewController.view.hidden = NO;
    
    //force hide, for Default.png
	if([appDelegate isShowDefault])
		tableViewController.view.hidden = YES;
    
    //nav
    [appDelegate navController].navigationBar.translucent = NO;

    //show load
    /* tableView.hidden = NO;
    darkImage.hidden = NO;
    spin.hidden = NO;*/


    //title
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 400, 44)];
    label.backgroundColor = [UIColor clearColor];
    label.font = [UIFont fontWithName:@"Century Gothic" size:20] ;
    //label.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.5];
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor =[UIColor whiteColor];
    label.text= @"Daily Wallpaper";
    [self navigationItem].titleView = label;
    [self.navigationItem.titleView sizeToFit];  //center

	    //notify
	if([appDelegate backgroundSupported])
	{
		[[NSNotificationCenter  defaultCenter] addObserver:self
												  selector:@selector(notifyForeground)
													  name:UIApplicationWillEnterForegroundNotification
													object:nil]; 
	}
    
    
    //reload
    //[appDelegate refresh]; //too often
	
	//offline
	if([appDelegate isOnline])
		[self showOffline:NO];
	else
		[self showOffline:YES];
    
    //badge
    [self updateBadge];
	
    
	//ad
    [self updateBanner:YES];
    
    
    //close anim
    CABasicAnimation *scale;
    scale = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    scale.fromValue = [NSNumber numberWithFloat:1.0f];
    scale.toValue = [NSNumber numberWithFloat:1.1f];
    scale.duration = 0.5f;
    scale.repeatCount = HUGE_VALF;
    scale.autoreverses = YES;
    [self.closeButton.layer removeAllAnimations];
    [self.closeButton.layer addAnimation:scale forKey:@"scale"];

}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
	[self becomeFirstResponder];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        firstTimeAd = NO;
    });
    
    //refresh, only after delay?
    //[appDelegate refresh];
    
    //hide test
    //tableView.hidden = YES;
    //tableViewController.view.hidden = YES;
    
    //test
    //[appDelegate alertHelp:YES];
    
    self.tableView.scrollsToTop = NO;
    tableViewController.tableView.scrollsToTop = YES;
	
	//if(false)
    /*if([appDelegate isTapForTap] && ![appDelegate isShowDefault])
    {
        [self showAd:YES];
    }*/
    
    
	//resize
	//[self showAd:YES];
	
    [self performSelector:@selector(updateBadge) withObject:nil afterDelay:0.3];
	
    //switch ad
	[appDelegate fadeDefault];
    
    //fix double click crash?
    [appDelegate setAlreadySelectImage:NO];
    
    //refresh on favorite modified
    if([appDelegate favorites] && [appDelegate favoritesModified])
    {
        [appDelegate setFavoritesModified:NO];
        [appDelegate refresh];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    
	[self resignFirstResponder];
    
	[super viewWillDisappear:animated];
	
	[[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [self.closeButton.layer removeAllAnimations];
}

- (void) didReceiveMemoryWarning 
{
	NSLog(@"didReceiveMemoryWarning");
	[super didReceiveMemoryWarning];
}

- (void)viewDidUnload {
}

- (BOOL)scrollViewShouldScrollToTop:(UIScrollView *)scrollView
{
    return YES;
}


- (void)dealloc {
    //[super dealloc];
	    
    //[HUD removeFromSuperview];
	//[HUD release];
}

- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event 
{
    if (event.type == UIEventSubtypeMotionShake) 
    {
        [appDelegate refresh];
    }
}

-(NSUInteger)supportedInterfaceOrientations
{
    if([appDelegate isIpad])
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
    if([appDelegate isIpad])
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
    if([appDelegate isIpad])
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

- (void)buyRemoveAds
{
    //disabled
    //if([appDelegate isDebug] && ![appDelegate isSimulator])
    //    return;
    
    //show hud
    doHud = YES;
    [self showHud:@"Connecting"];
    
	SKProduct* product = [appDelegate productRemoveAds];
	
    NSLog(@"Buying %@...", product.productIdentifier);
    [[BingWallpaperIAPHelper sharedInstance] buyProduct:product];
}

- (void)productPurchased:(NSNotification *)notification {
	
    NSString * productIdentifier = notification.object;
    [[appDelegate products] enumerateObjectsUsingBlock:^(SKProduct * product, NSUInteger idx, BOOL *stop) {
        if ([product.productIdentifier isEqualToString:productIdentifier]) {

            *stop = YES;
            doHud = NO;
			[self showAd:NO];
            [appDelegate setPrefPurchasedRemoveAds:YES];
            [appDelegate saveState];
            
            //message
					//disabled, because system already gives "You are all set" (or You're all set?)
           //[UIAlertView showError:@"Thanks for your support!" withTitle:@"In-App Purchases"];
        }
    }];
	
}

/*- (void)restoreRemoveAds
{
    [[BingWallpaperIAPHelper sharedInstance] restoreCompletedTransactions];
    [appDelegate setPrefPurchasedRemoveAds:YES];
    [appDelegate saveState];
    [self showAd:NO];
}
*/

- (void)showHud:(NSString*)label
{
	HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
	[self.navigationController.view addSubview:HUD];
	
	HUD.delegate = self;
	HUD.labelText = label;
	
	[HUD showWhileExecuting:@selector(hudTask) onTarget:self withObject:nil animated:YES];
}

- (void)hudTask
{
    NSDate *start = [NSDate date];
    NSTimeInterval timeInterval = ABS([start timeIntervalSinceNow]);
    
    //at least min, at most max
    while( (timeInterval < MIN_HUD_TIME) || (doHud && (timeInterval < MAX_HUD_TIME)) )
    {
       timeInterval = ABS([start timeIntervalSinceNow]);
    }
}


#pragma mark -
#pragma mark Banner

- (void)updateBanner:(BOOL)reload {
    
    if(![appDelegate isOnline])
    {
        [self hideAd];
        return;
    }
    
    //ad
    if([appDelegate prefPurchasedRemoveAds])
    {
        [self hideAd];
        return;
    }
    
    //force resize
    if(self.bannerView.hidden) {
        //[self hideAd];
    }
    

    GADRequest *request = [GADRequest request];
    // Enable test ads on simulators.
    //request.testDevices = @[ GAD_SIMULATOR_ID ];
    /*request.testDevices = [NSArray arrayWithObjects:
     @"MY_SIMULATOR_IDENTIFIER",
     @"MY_DEVICE_IDENTIFIER",
     nil];*/
    
    self.bannerView.adUnitID = kGoogleAdMobId;
    self.bannerView.rootViewController = self;
    [self.bannerView loadRequest:request];
    
}

- (void)adViewDidReceiveAd:(GADBannerView *)view {
    NSLog(@"adViewDidReceiveAd");
    
    [self showAd:YES];
    
    //self.bannerView.hidden = NO;
    //self.closeAdButton.hidden = YES;
    //self.adSpinner.hidden = YES;
    
}

- (void)adView:(GADBannerView *)view didFailToReceiveAdWithError:(GADRequestError *)error {
    
    NSLog(@"didFailToReceiveAdWithError");
    
    [self showAd:NO];
    
    //self.bannerView.hidden = YES;
    //self.closeAdButton.hidden = YES;
    //self.adSpinner.hidden = YES;
}

- (void)adViewWillDismissScreen:(GADBannerView *)adView {
    NSLog(@"adViewWillDismissScreen");
}

- (void)adViewDidDismissScreen:(GADBannerView *)adView {
    NSLog(@"adViewWillDismissScreen");
}

- (void)adViewWillLeaveApplication:(GADBannerView *)adView {
    NSLog(@"adViewWillLeaveApplication");
}


@end
