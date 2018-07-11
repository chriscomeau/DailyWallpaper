//
//  AboutViewController.m
//
//  Created by Chris Comeau on 10-02-12.
//  Copyright 2010 Games Montreal. All rights reserved.
//

#import "BingWallpaperiPhoneAppDelegate.h"
#import "AboutViewController.h"
#import <QuartzCore/QuartzCore.h>
//#import <Twitter/Twitter.h>
//#import "SHKFacebook.h"
//#import "SHKTwitter.h"
//#import "SHKTextMessage.h"
//#import "UIDevice-Hardware.h"
#import "UIAlertView+Errors.h"
#import "HapticHelper.h"

#if USE_TESTFLIGHT
    #import "TestFlight.h"
#endif

//static const CGFloat kPadding = 10;

@implementation AboutViewController

@synthesize buttonMore;
@synthesize buttonHome;
@synthesize buttonFacebook;
@synthesize buttonTwitter;
@synthesize buttonIcon;
@synthesize buttonVersion;
@synthesize buttonEmail;
@synthesize versionText;
@synthesize helpButton;
@synthesize creditsButton;
@synthesize shareButton;
@synthesize rateButton;
@synthesize restoreButton;
@synthesize imageViewQR;
@synthesize buttonQR;
@synthesize buttonNoAds;
@synthesize buttonStars;
@synthesize appNameText;
@synthesize badgeText;
@synthesize copyrighText;
@synthesize imageViewBadge;
@synthesize imageViewTwitter;
@synthesize twitterText;
@synthesize bingButton;
@synthesize HUD;

NSRecursiveLock *lock9;


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	appDelegate = (BingWallpaperiPhoneAppDelegate *)[[UIApplication sharedApplication] delegate];
	
    lock9 = [[NSRecursiveLock alloc] init];

    doHud = NO;
    rotating = NO;
    actionSheetShare = nil;
    actionSheetTwitter = nil;
    actionSheetContact = nil;
    
    arrayTwitterClients = [[NSMutableArray alloc] initWithObjects:nil];
    
    alertEmail = nil;
    alertBing = nil;
    
     //set font
    UIFont* tempFont = [UIFont fontWithName:@"Century Gothic" size:15] ; 
	[appNameText setFont:tempFont];
    
    //badge
    imageViewBadge.hidden = YES;
    badgeText.hidden = YES;
    
    tempFont = [UIFont fontWithName:@"HelveticaNeue-Bold" size:13] ;
	[badgeText setFont:tempFont];
    
    tempFont = [UIFont fontWithName:@"Century Gothic" size:12] ; 
    [versionText setFont:tempFont];
    [copyrighText setFont:tempFont];
    [twitterText setFont:tempFont];
	
	//year
	NSDate *date = [NSDate date];
	NSUInteger componentFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit;
	NSDateComponents *components = [[NSCalendar currentCalendar] components:componentFlags fromDate:date];
	NSInteger year = [components year];
	NSString *yearString = [NSString stringWithFormat:@"%d", year];
	NSString *copyrightString = copyrighText.text;
	copyrightString = [copyrightString stringByReplacingOccurrencesOfString:@"xxxx" withString:yearString];
	copyrighText.text = copyrightString;
    
    tempFont = [UIFont fontWithName:@"Century Gothic" size:13] ;

	buttonMore.titleLabel.font = tempFont;
	buttonEmail.titleLabel.font = tempFont;
	helpButton.titleLabel.font = tempFont;
	creditsButton.titleLabel.font = tempFont;
	shareButton.titleLabel.font = tempFont;
	rateButton.titleLabel.font = tempFont;
	restoreButton.titleLabel.font = tempFont;
    

    UIColor *buttonColor = [appDelegate buttonTextColor]; //[UIColor darkGrayColor];
    [buttonMore setTitleColor:buttonColor forState:UIControlStateNormal];
    [buttonEmail setTitleColor:buttonColor forState:UIControlStateNormal];
    [helpButton setTitleColor:buttonColor forState:UIControlStateNormal];
    [creditsButton setTitleColor:buttonColor forState:UIControlStateNormal];
    [shareButton setTitleColor:buttonColor forState:UIControlStateNormal];
    [rateButton setTitleColor:buttonColor forState:UIControlStateNormal];
    [restoreButton setTitleColor:buttonColor forState:UIControlStateNormal];

    //back
    //UIBarButtonItem *newBackButton = [[UIBarButtonItem alloc] initWithTitle: @"Back" style: UIBarButtonItemStyleBordered target: nil action: nil];
    //[[self navigationItem] setBackBarButtonItem: newBackButton];

	//versionText.text = [NSString stringWithFormat:@"Version %@",
	//					[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"]];
	
	//if(false) //if([appDelegate isDebug])
	//	versionText.text = [appDelegate getVersionString2];
	//else
		versionText.text = [appDelegate getVersionString2];

	//versionText.text = @"Version 1.0a";
	
    [bingButton addTarget:self action:@selector(actionBingLogo:) forControlEvents:UIControlEventTouchUpInside];
	[buttonMore addTarget:self action:@selector(actionMore:) forControlEvents:UIControlEventTouchUpInside];	
	[buttonHome addTarget:self action:@selector(actionHome:) forControlEvents:UIControlEventTouchUpInside];
	[buttonIcon addTarget:self action:@selector(actionQR:) forControlEvents:UIControlEventTouchUpInside];
	[buttonVersion addTarget:self action:@selector(actionVersion:) forControlEvents:UIControlEventTouchUpInside];
	[buttonFacebook addTarget:self action:@selector(actionFacebook:) forControlEvents:UIControlEventTouchUpInside];
	[buttonTwitter addTarget:self action:@selector(actionTwitter:) forControlEvents:UIControlEventTouchUpInside];	
	[buttonEmail addTarget:self action:@selector(actionEmail:) forControlEvents:UIControlEventTouchUpInside];
	[helpButton addTarget:self action:@selector(actionHelp:) forControlEvents:UIControlEventTouchUpInside];
	[shareButton addTarget:self action:@selector(actionShare:) forControlEvents:UIControlEventTouchUpInside];	
	[rateButton addTarget:self action:@selector(actionRate:) forControlEvents:UIControlEventTouchUpInside];
	[buttonStars addTarget:self action:@selector(actionRate:) forControlEvents:UIControlEventTouchUpInside];
    [restoreButton addTarget:self action:@selector(actionRestore:) forControlEvents:UIControlEventTouchUpInside];

	//sound
	//[appDelegate playSound:nil];
	
	//force
	[self becomeFirstResponder];
    
#if 0
    //qr
    UIImage* image = NULL;
    /*NSString *qrString = @"http://itunes.apple.com/app/id557949358";
    
        //https://github.com/jverkoey/ObjQREncoder
 
    image = [QREncoder encode:qrString size:qrSize correctionLevel: QRCorrectionLevelLow];*/
    
    image = [appDelegate getQRImage];
    
    UIImage *maskedImg  = nil;
   
    if (SYSTEM_VERSION_LESS_THAN(@"4.2")) 
    {        
        maskedImg = [appDelegate maskImage:image withMask:image]; //[UIImage copyWithZone:]: unrecognized selector before 4.2
    }
    else
    {
        maskedImg = [appDelegate maskImage:image withMask:[image copy]];
    }
    
    UIImage *coloredImg = [appDelegate colorizeImage:maskedImg];
    

    //UIImage *coloredImg = [appDelegate colorizeImage:image];
    
    
    UIImage *newImage = coloredImg;
    
    
    //image = [QREncoder encode:@"http://vocaro.com/trevor/blog-test-test/"];
    //image = [QREncoder encode:@"http://vocaro.com/trevor/blog/2009/10/12/resize-a-uiimage-the-right-way/"];
    //image = [QREncoder encode:@"http://itunes.apple.com/app/id557949358"];
   
    //null?
    
        
    //http://stackoverflow.com/questions/1367994/uiimageview-resize


    //imageViewQR.autoresizingMask = ( UIViewAutoresizingFlexibleWidth );
        
    //google charts
    /*NSURL *imageURL = [NSURL URLWithString:@"http://chart.apis.google.com/chart?cht=qr&chs=200x200&chl=http://itunes.apple.com/app/id557949358"];
    
    UIImage *image = [[UIImage alloc] initWithData: [NSData dataWithContentsOfURL:imageURL]]; 
    
    */
    
    
    if(newImage)
    {
        [imageViewQR setAlpha:0.8];
        [imageViewQR layer].magnificationFilter = kCAFilterNearest;
        [imageViewQR setImage:newImage];
        
        //const float colorMasking[6] = {0.0, 0.0, 0.0, 0.0, 0.0, 0.0};
        //UIImage * image2 = NULL;
        
        //const float colorMasking[6] = {1.0, 1.0, 1.0, 1.0, 1.0, 1.0};
        //image2 = [UIImage imageWithCGImage: CGImageCreateWithMaskingColors(image.CGImage, colorMasking)];

        //UIImage *newImage = [UIImage imageWithData:UIImagePNGRepresentation(oldImage)];
        
       /* UIImage *image2 = [self maskImage:image withMask:image];

        if(image2)
        {
            //[imageViewQR setAlpha:0.8];
            [imageViewQR layer].magnificationFilter = kCAFilterNearest;
            [imageViewQR setImage:image2];
        }*/
        
        /*UIImage *image2 = [self changeWhiteColorTransparent:image];

        
        if(image2)
        {
            //[imageViewQR setAlpha:0.8];
            [imageViewQR layer].magnificationFilter = kCAFilterNearest;
            [imageViewQR setImage:image2];
        }*/
    }
    
    //rotation
    if([appDelegate isIpad])
    {
        //[[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
        
        //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationChanged:) name:@"UIDeviceOrientationDidChangeNotification" object:nil];
    }
    
#endif

    //corner
    [appDelegate cornerView:self.view];
    
    //hide twitter
    buttonTwitter.hidden = YES;
    imageViewTwitter.hidden = YES;
    twitterText.hidden = YES;
    
    //disabled
    helpButton.hidden = YES;
    imageViewQR.hidden = buttonQR.hidden = YES;

    if (@available(iOS 11.0, *)) {
        self.imageHome.accessibilityIgnoresInvertColors = YES;
    }

    
    //noads
    [buttonNoAds addTarget:self action:@selector(actionAd:forEvent:) forControlEvents:UIControlEventTouchUpInside];
}


- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
	
	[self becomeFirstResponder];
    
    rotating = NO;
    
    //badge
    [self performSelector:@selector(updateBadge) withObject:nil afterDelay:0.3];
    
    //wobble
    if(!imageViewBadge.hidden)
        [appDelegate startWobble:buttonMore];

}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
	
    [self becomeFirstResponder];
    
    //google analytics
    [Helpers setupGoogleAnalyticsForView:[[self class] description]];
    
    //title
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 44)];
    label.backgroundColor = [UIColor clearColor];
    label.font = [UIFont fontWithName:@"Century Gothic" size:20] ;
    //label.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.5];
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor =[UIColor whiteColor];
    label.text= @"About";
    [self navigationItem].titleView = label;
    [self.navigationItem.titleView sizeToFit];  //center
    
    //rotation
    if([appDelegate isIpad])
    {
        //[[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
        
        //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationChanged:) name:@"UIDeviceOrientationDidChangeNotification" object:nil];
    }
    
    currentOrientation = [[UIDevice currentDevice] orientation];

    [self updateUIOrientation];
    
    
    //hide badge
    imageViewBadge.hidden = YES;
    badgeText.hidden = YES;
    
     //tab badge
    [appDelegate hideNumAppsBadge];
    
    //stars
    buttonStars.hidden = [appDelegate inReview];

    //iap
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(productPurchased:) name:IAPHelperProductPurchasedNotification object:nil];
    
    //for in-app confirm
    [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(inAppAlertAppeared:) 
                                               name:UIApplicationWillResignActiveNotification 
                                             object:nil];

    if([appDelegate backgroundSupported])
	{
		[[NSNotificationCenter  defaultCenter] addObserver:self
												  selector:@selector(notifyForeground)
													  name:UIApplicationWillEnterForegroundNotification
													object:nil]; 
	}
    
    [self updateUI];
}


-(void)updateUI
{
    //ads
    buttonNoAds.hidden = [appDelegate prefPurchasedRemoveAds];

}

-(void)actionAd:(id)sender forEvent:(UIEvent *)event
{
    //go back
    [self.navigationController popViewControllerAnimated:YES];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [[appDelegate archiveViewController] actionClose:self];
    });
}


//iap
- (void)inAppAlertAppeared:(id)sender
{
    NSLog(@"AboutViewController: inAppAlertAppeared");

	doHud = NO;
}

- (void)viewWillDisappear:(BOOL)animated {
    
    [HapticHelper generateFeedback:kFeedbackType];

	[self resignFirstResponder];
	
	//[[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    //[[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
	
    [super viewWillDisappear:animated];
    
    //rotation
    //[[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];
    
    rotating = NO;
    
    //iap
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    //wobble
    [appDelegate stopWobble:buttonMore];
}

- (void)updateBadge
{
    NSLog(@"AboutViewController: updateBadge");

    int numApps = [appDelegate getNumApps];
    NSLog(@"AboutViewController: numApps: %d", numApps);
    
    //show num
    if(numApps > 0)
    {
        imageViewBadge.hidden = NO;
        badgeText.hidden = NO;
        
        badgeText.text = [NSString stringWithFormat:@"%d", numApps];
        
        [appDelegate startWobble:buttonMore];
    }
    else
    {
        imageViewBadge.hidden = YES;
        badgeText.hidden = YES;
        badgeText.text = [NSString stringWithFormat:@""];
        [appDelegate stopWobble:buttonMore];
    }

}

- (void)updateUIOrientation
{
    [lock9 lock];
    
    NSLog(@"ConvertViewController::updateUIOrientation");

    //if([appDelegate isIpad])
    {
         //move twitter
        CGRect tempFrame = buttonTwitter.frame;
        tempFrame.origin.x = copyrighText.frame.origin.x;
        buttonTwitter.frame = tempFrame;
        
        tempFrame = imageViewTwitter.frame;
        tempFrame.origin.x = copyrighText.frame.origin.x;
        imageViewTwitter.frame = tempFrame;
   
        int offset = 4;
        
        //move red Badge
        tempFrame = imageViewBadge.frame;
        tempFrame.origin.x = buttonMore.frame.origin.x + buttonMore.frame.size.width - imageViewBadge.frame.size.width/2 - offset;
        tempFrame.origin.y = buttonMore.frame.origin.y - imageViewBadge.frame.size.height/2 + offset;
        imageViewBadge.frame = tempFrame;
        
        tempFrame = badgeText.frame;
        tempFrame.origin.x = buttonMore.frame.origin.x + buttonMore.frame.size.width - badgeText.frame.size.width/2 - offset;
        tempFrame.origin.y = buttonMore.frame.origin.y - badgeText.frame.size.height/2 - 2 + offset;
        badgeText.frame = tempFrame;
        
        //keep updating
        if(rotating)
            [self performSelector:@selector(updateUIOrientation) withObject:nil afterDelay:0.01];

    }
    
    [lock9 unlock];
}

- (void)actionHelp:(id)sender
{
	
	[appDelegate alertHelp:YES];
}

- (void)actionShare:(id)sender
{
	
    NSString *textToShare = @"Check out Daily Wallpaper for iOS!";
    NSURL *url = [NSURL URLWithString:@"http://itunes.apple.com/app/id557949358"];
    NSString *subject = @"Daily Wallpaper for iOS";
    
    //UIImage *image = [UIImage imageNamed:@"share_image"];
    //NSArray *objectsToShare = @[textToShare, url, image];
    
    NSArray *objectsToShare = @[textToShare, url];
    
    UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:objectsToShare applicationActivities:nil];
    
    /*NSArray *excludeActivities = @[
                                   UIActivityTypeAirDrop,
                                   UIActivityTypePrint,
                                   //UIActivityTypeAssignToContact,
                                   //UIActivityTypeSaveToCameraRoll,
                                   UIActivityTypeAddToReadingList,
                                   //UIActivityTypePostToFlickr,
                                   //UIActivityTypePostToVimeo
                                   ];
    
    activityVC.excludedActivityTypes = excludeActivities;*/
    
    //email subject
    [activityVC setValue:subject forKey:@"subject"];
    
    if([appDelegate isIpad]) {
        if ( [activityVC respondsToSelector:@selector(popoverPresentationController)] ) {
            // iOS8
            activityVC.popoverPresentationController.sourceView = sender;
        }
        
    }

    //self is a view, not view controller, try to use root instead
    [self.view.window.rootViewController presentViewController:activityVC animated:YES completion:nil];

    
    
    return;
    
	if(USE_ANALYTICS == 1)
	{
		//[[LocalyticsSession sharedLocalyticsSession] tagEvent:@"actionShare"];
        //[FlurryAnalytics logEvent:@"actionShare"];
	}
	
	
    actionSheetShare=nil;
        actionSheetShare = [[UIActionSheet alloc] initWithTitle:@"Tell a Friend"
                                        delegate:self
                               cancelButtonTitle:@"Cancel"
                          destructiveButtonTitle:nil 
                               otherButtonTitles: @"Email", @"Text Message", @"QR Code",/* @"Gift App", @"Facebook", @"Twitter",*/

                            nil];
    
    
    
    actionSheetShare.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
    [actionSheetShare showInView:self.view];
	
    //[actionSheet release];
    

}


- (void)actionRestore:(id)sender
{
    //offline ignore
    if(![appDelegate isOnline])
    {
        //message
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"In-App Purchases" message:@"Please try again when you are connected to the internet." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show]; 
        return;
	}
    
	[self restoreRemoveAds];
}

- (void)actionRate:(id)sender
{
	//[appDelegate alertComingSoon];
	
	[appDelegate gotoReviews];
}

-(void)actionFacebook:(id)sender
{

	[appDelegate gotoFacebook];

}

-(void)actionTwitter:(id)sender
{
    NSLog(@"actionTwitter");

    if(USE_ANALYTICS == 1)
	{
		//[[LocalyticsSession sharedLocalyticsSession] tagEvent:@"actionTwitter"];
        //[FlurryAnalytics logEvent:@"actionTwitter"];
	}
	
	
    
    [arrayTwitterClients removeAllObjects];//clear
    
    NSString *title = [NSString stringWithFormat:@"Open In..."];
    //NSString *title = nil;
    
    NSURL *url = nil;
    
     //tweetbot
    url = [NSURL URLWithString:@"tweetbot://"];
    if([[UIApplication sharedApplication] canOpenURL:url])
        [arrayTwitterClients insertObject:@"Tweetbot"atIndex: [arrayTwitterClients count]];
    
    
    //twitter
    url = [NSURL URLWithString:@"twitter://"];
    if([[UIApplication sharedApplication] canOpenURL:url])
        [arrayTwitterClients insertObject:@"Twitter"atIndex: [arrayTwitterClients count]];
    
    //to add: tweetdeck, hootsuite, tweetie, echofon
    //                     @"tweetbot:///user_profile/{username}", // TweetBot
    //                 @"echofon:///user_timeline?{username}", // Echofon

    //chrome
    /*url = [NSURL URLWithString:@"googlechrome://"];
    if([[UIApplication sharedApplication] canOpenURL:url])
        [arrayTwitterClients insertObject:@"Chrome"atIndex: [arrayTwitterClients count]];
    */
    
    //safari
    [arrayTwitterClients insertObject:@"Safari"atIndex: [arrayTwitterClients count]];

    
    actionSheetTwitter = nil;
    
    if([arrayTwitterClients count] == 1) //just safari
    {
            [appDelegate openURL:[NSURL URLWithString:@"http://twitter.com/DailyWallApp"]]; //web
    }
    else
    {
            //show sheet
    
             actionSheetTwitter = nil;
             actionSheetTwitter = [[UIActionSheet alloc] initWithTitle:title
                                                        delegate:self
                                                        cancelButtonTitle:nil
                                                        destructiveButtonTitle:nil
                                                        otherButtonTitles:nil];
            //add buttons
            for (NSString* string in arrayTwitterClients)
            {
                [actionSheetTwitter addButtonWithTitle:string];
            }
            //add cancel
            [actionSheetTwitter addButtonWithTitle:@"Cancel"];
            actionSheetTwitter.cancelButtonIndex = actionSheetTwitter.numberOfButtons - 1;

        
			[actionSheetTwitter showInView:self.view];
            //[actionSheet showFromRect:myImageRect inView:self.view animated:YES];

    }

	//[appDelegate gotoTwitter];
}


-(BOOL)canBecomeFirstResponder
{
	return YES;
}

//accelerometer, shake
 - (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event
 {
	 if(event.type == UIEventSubtypeMotionShake)
	 {
	 //convert1Text.text = @"";
	 //convert2Text.text = @"";
		// [appDelegate playSound:nil];
	 }
 }

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    NSLog(@"AboutViewController::didRotateFromInterfaceOrientation");

    if([appDelegate isIpad])
    {
        rotating = NO;
    
        [self updateUIOrientation];
        
    }
}

- (void) willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    NSLog(@"AboutViewController::willRotateToInterfaceOrientation");

    if([appDelegate isIpad])
    {
        rotating = YES;
    
        [self updateUIOrientation];
    }
}


-(void) orientationChanged:(NSNotification *) notification
{
     NSLog(@"AboutViewController::orientationChanged");

    if([appDelegate isIpad])
    {
        UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
        //Ignoring specific orientations
        if (orientation == UIDeviceOrientationFaceUp || orientation == UIDeviceOrientationFaceDown
            || orientation == UIDeviceOrientationUnknown || currentOrientation == orientation)
        {
                //return;
        }
       

        currentOrientation = orientation;

        [self updateUIOrientation];

        //[self updateBadge];
    }
}

- (void) didReceiveMemoryWarning 
{
	NSLog(@"didReceiveMemoryWarning");
	[super didReceiveMemoryWarning];
}


- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}

- (void)actionEmail:(id)sender
{
    actionSheetContact=nil;
    actionSheetContact = [[UIActionSheet alloc] initWithTitle:@"Contact Us"
                                        delegate:self
                               cancelButtonTitle:@"Cancel"
                          destructiveButtonTitle:nil
                               //otherButtonTitles: @"Email", @"Text Message", @"QR Code", @"Gift App", @"Facebook", @"Twitter",
                               otherButtonTitles: @"Email", @"Newsletter",
                               nil];
    
    

	if([Helpers isIpad])
	{
		actionSheetContact.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
		[actionSheetContact showFromRect:[sender frame] inView:self.view animated:YES];

	}
	else
    {
        actionSheetContact.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
        [actionSheetContact showInView:self.view];

	}
    
}

- (void)actionBingLogo:(id)sender
{
    NSLog(@"AboutViewController::actionBingLogo");

    //alert
    alertBing = nil;
    alertBing = [[UIAlertView alloc] initWithTitle:@"Bing"
                                                    message:@"Skyriser Media is not affiliated with Bing. Visit bing.com for more info?"
                                                   delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
	[alertBing show];
    
	//[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.bing.com/"]];
}


-(void)alertView:(UIAlertView *)alertView willDismissWithButtonIndex:    (NSInteger)buttonIndex 
{

    //if(alertView == alertEmail)
    {
        if(buttonIndex==0)
        {
            //cancel
        }
        else if(buttonIndex==1)
        {
            //Code that will run after you press ok button 
        


            #if USE_TESTFLIGHT
                if([appDelegate isTestflight])
                    [TestFlight passCheckpoint:@"AboutViewController:actionEmail"];
            #endif

                
                
            /*NSString *version  = [NSString stringWithFormat:@"%@ (%@)", 
                                  [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"] , 
                                  [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"]];*/

           // NSString *version  = [NSString stringWithFormat:@"%@",
           //                       [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"] ];

			NSString *version = [appDelegate getVersionString2];
            NSString *iosVersion = [[UIDevice currentDevice] systemVersion];
            NSString *model = [appDelegate platformString];
            NSString *body = [NSString stringWithFormat: @"App Version: %@\niOS Version: %@\niOS Device: %@\n\n-----\nFeedback:\n\n\n-----\n", version, iosVersion, model];
            //NSString *body = [NSString stringWithFormat: @"App Version: %@\niOS Version: %@\n\nFeedback:\n\n\n", version, iosVersion];
            
            [appDelegate sendEmailTo:@"info@skyriser.com" withSubject: @"Daily Wallpaper iOS Feedback" withBody:body withImage:nil withView:self];
            
        }
	}
    
    /*else if(alertView == alertBing)
    {
        if(buttonIndex==0)
        {
            //cancel
        }
        else if(buttonIndex==1)
        {
        	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.bing.com/"]];
        }
    }*/
    
}

- (void)actionMore:(id)sender
{
	NSLog(@"actionMore triggered");
    
    //in app web page
    //[appDelegate alertMore:YES];
    
    //safari web page
    //[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.skyriser.com/iphone_small.php"]];
        
    //https://developer.apple.com/library/ios/#qa/qa1633/_index.html
   
    //app store
    if(SYSTEM_VERSION_LESS_THAN(@"6"))
    {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"itms-apps://itunes.com/apps/skyrisermedia"]];

    }
    else
    {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"itms-apps://itunes.apple.com/us/artist/skyriser-media/id359807334"]];
    }
}

- (void)actionHome:(id)sender
{
	NSLog(@"actionHome triggered");
	
	if(USE_ANALYTICS == 1)
	{
		//[[LocalyticsSession sharedLocalyticsSession] tagEvent:@"About: ActionHome"];
        //[FlurryAnalytics logEvent:@"About: ActionHome"];
	}
	
	//[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://skyriser.com/"]];	
	//[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.skyriser.com/iphone_small.php"]];
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.skyriser.com/"]];	
}

- (void)actionQR:(id)sender
{
#if USE_TESTFLIGHT
    if([appDelegate isTestflight])
       [TestFlight passCheckpoint:@"AboutViewController:actionQR"];
#endif
	NSLog(@"actionHome actionQR");
	
	//[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://itunes.apple.com/app/id557949358"]];
    
    [appDelegate alertQR:YES];

}

- (void)actionVersion:(id)sender
{
 #if USE_TESTFLIGHT
    if([appDelegate isTestflight])
        [TestFlight passCheckpoint:@"AboutViewController:actionVersion"];
#endif
    
	NSLog(@"actionVersion");
	
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://dailywallpaperapp.com/changelog.php"]];
}


/*- (void)willPresentActionSheet:(UIActionSheet *)actionSheet  // before animation and showing view
{
    for (UIView* view in [actionSheet subviews])
    {
        if ([[[view class] description] isEqualToString:@"UIThreePartButton"])
        {
            if ([view respondsToSelector:@selector(title)])
            {
                NSString* title = [view performSelector:@selector(title)];
                if ([title isEqualToString:@"Email"] && [view respondsToSelector:@selector(setEnabled:)])
                {
                    [view performSelector:@selector(setEnabled:) withObject:NO];
                }
            }
        }
    }
}*/

-(void) actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{

    if(actionSheet == actionSheetTwitter)
    {
        if(buttonIndex == [arrayTwitterClients count]) //cancel
        {
             if(USE_ANALYTICS == 1)
                {
                    //[[LocalyticsSession sharedLocalyticsSession] tagEvent:@"actionTwitter:Cancel"];
                    //[FlurryAnalytics logEvent:@"actionTwitter:Cancel"];
                }
            return;
        }
        else
        {
            NSString *clientString = [arrayTwitterClients objectAtIndex:buttonIndex];
            if([clientString isEqualToString:@"Safari"])
            {
                if(USE_ANALYTICS == 1)
                {
                    //[[LocalyticsSession sharedLocalyticsSession] tagEvent:@"actionTwitter:Safari"];
                    //[FlurryAnalytics logEvent:@"actionTwitter:Safari"];
                }
                
                [appDelegate openURL:[NSURL URLWithString:@"http://twitter.com/DailyWallApp"]]; //web
            }
            else if([clientString isEqualToString:@"Chrome"])
            {
                if(USE_ANALYTICS == 1)
                {
                    //[[LocalyticsSession sharedLocalyticsSession] tagEvent:@"Chrome"];
                    //[FlurryAnalytics logEvent:@"actionTwitter:Chrome"];
                }
                
                [appDelegate openURL:[NSURL URLWithString:@"googlechrome://twitter.com/DailyWallApp"]]; //web
            }
            else if([clientString isEqualToString:@"Tweetbot"])
            {
                if(USE_ANALYTICS == 1)
                {
                    //[[LocalyticsSession sharedLocalyticsSession] tagEvent:@"actionTwitter:Tweetbot"];
                    //[FlurryAnalytics logEvent:@"actionTwitter:Tweetbot"];
                }
                
                //[appDelegate openURL:[NSURL URLWithString:@"tweetbot://user_profile/BingWallpapers"]]; //tweetbot
                [appDelegate openURL:[NSURL URLWithString:@"tweetbot:///user_profile/DailyWallApp"]]; //tweetbot, extra / for optional 1st param
            }
            else if([clientString isEqualToString:@"Twitter"])
            {
                if(USE_ANALYTICS == 1)
                {
                    //[[LocalyticsSession sharedLocalyticsSession] tagEvent:@"actionTwitter:Twitter"];
                    //[FlurryAnalytics logEvent:@"actionTwitter:Twitter"];
                }
                [appDelegate openURL:[NSURL URLWithString:@"twitter:///user?screen_name=DailyWallApp"]]; //Twitter
            }
           
        }
        
    }
    else if(actionSheet == actionSheetContact)
    {
        switch (buttonIndex) 
            {
              
                case 0:
                    //email
                    {
                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Send Feedback"
                                                        message:@"Do you want to send an email with your feedback to the developer? Please include detailed information."
                                                       delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
                        [alert show];
                    }

                    break;
                
                 case 1:
                    //newsletter
                    [Helpers showMailChimp];
                    
                    break;
                
                    
                default:
                    break;
            }
    }
    else if(actionSheet == actionSheetShare)
    {
            //SHKItem *item = nil;
            NSString *urlString = [NSString stringWithFormat:@"http://itunes.apple.com/app/id557949358"];

            //otherButtonTitles: @"Email", @"Text Message", @"QR Code", @"Gift App", @"Facebook", @"Twitter",

            switch (buttonIndex) 
            {
                case 0:
                    //email
                    if([MFMailComposeViewController canSendMail])
                    {
                        [appDelegate sendEmailTo:@"" withSubject: @"Daily Wallpaper for iOS" withBody:@"Check out this application:\n\nhttp://itunes.apple.com/app/id557949358" withImage:nil withView:self ];
                    }
                    else
                    	[UIAlertView showError:@"Could not send email." withTitle:@"Error"];
                    
                    break;
                
                case 1:
                    //Text/SMS
                    
                    #if TARGET_IPHONE_SIMULATOR
                    //break;
                    #endif
                   
                    if([MFMessageComposeViewController canSendText] && [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"sms:"]])
                    {
                        NSString *descString = [NSString stringWithFormat:@"Check out this application: Daily Wallpaper for iOS: %@", urlString];
                        //NSURL *url = [NSURL URLWithString:urlString];
                        //item = [SHKItem URL:url title:descString contentType:SHKURLContentTypeWebpage];
                        //item = [SHKItem text:descString];
                        
                        MFMessageComposeViewController *textComposer = [[MFMessageComposeViewController alloc] init];
                        [textComposer setMessageComposeDelegate:self];
                        [textComposer setBody:descString];
                        [self presentViewController:textComposer animated:YES completion:NULL];


                        //[SHKTextMessage shareItem:item];
                    }
                    else
                    	[UIAlertView showError:@"Could not send text message." withTitle:@"Error"];

                    break;

                                   
                case 2:
                    //qr
                    [self actionQR:nil];
                    break;
                    
                /*case 3:
                    [appDelegate gotoGift];
                    break;*/
     
                    
                /*case 3:
                    //facebook
                    {
                        NSString *descString = [NSString stringWithFormat:@"Check out this application: Daily Wallpaper for iOS: %@", urlString];          
                        //with link, image
                        item = [SHKItem URL:[NSURL URLWithString:urlString] title:descString contentType:SHKURLContentTypeWebpage];
                        NSString *pictureURL = @"http://dailywallpaperapp.com/images/screenshot1.jpg"; //screenshot
                        item.facebookURLSharePictureURI = pictureURL;
                        [SHKFacebook shareItem:item]; 
                    }
                    break;
                    
                case 4:
                    //twitter
                    {
                        NSString *descString = [NSString stringWithFormat:@"Check out this application: Daily Wallpaper for iOS: %@", urlString];          
                        item = [SHKItem text:descString];
                        [SHKTwitter shareItem:item]; 
                    }
                    break;*/
                    
                default:
                    break;
            }
        }
    
}

- (void)dealloc {
	
    //[[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];
    
	/*[buttonMore release];
	[buttonHome release];
	[buttonIcon release];
    [buttonVersion release];
	[buttonEmail release];
	[versionText release];
	[helpButton release];
	[shareButton release];
	[rateButton release];
    
    [super dealloc];*/
}

- (void)restoreRemoveAds
{
    [self showHud:@"Connecting"];
    
    [[BingWallpaperIAPHelper sharedInstance] restoreCompletedTransactions];
    
    //[appDelegate setPrefPurchasedRemoveAds:YES];
    //[appDelegate saveState];
}

- (void)productPurchased:(NSNotification *)notification {
	
    NSString * productIdentifier = notification.object;
    [[appDelegate products] enumerateObjectsUsingBlock:^(SKProduct * product, NSUInteger idx, BOOL *stop) {
        if ([product.productIdentifier isEqualToString:productIdentifier]) {

            *stop = YES;
            doHud = NO;
			//[self showAd:NO];
            
            if(product.productIdentifier == [appDelegate productRemoveAds].productIdentifier)
                [appDelegate setPrefPurchasedRemoveAds:YES];

            [appDelegate saveState];
            
            //message
           //[UIAlertView showError:@"Thanks for your support!" withTitle:@"In-App Purchases"];
            [UIAlertView showError:@"Restore purchases successful!" withTitle:@"In-App Purchases"];
        }
    }];
	
}

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

- (void)notifyForeground
{
    NSLog(@"AboutViewController::notifyForeground");
	
    //update
    [appDelegate setIsOnline:[appDelegate checkOnline]];
    
    //update
    [self viewDidAppear:YES];

}

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult) result
{
    switch (result) {
        case MessageComposeResultCancelled:
            break;
            
        case MessageComposeResultFailed:
        {
            //UIAlertView *warningAlert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Failed to send SMS!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            //[warningAlert show];
            break;
        }
            
        case MessageComposeResultSent:
            break;
            
        default:
            break;
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
