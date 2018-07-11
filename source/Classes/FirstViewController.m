//
//  FirstViewController.m
//
//  Created by Chris Comeau on 10-03-18.
//  Copyright Games Montreal 2010. All rights reserved.
//

#import "FirstViewController.h"
#import "BingWallpaperiPhoneAppDelegate.h"
#import <QuartzCore/QuartzCore.h>
#import "NSString+HTML.h"
#import "Crashlytics/Crashlytics.h"
#import "UIAlertView+Errors.h"

#import "HapticHelper.h"

@implementation FirstViewController
@synthesize imageScrollView;
@synthesize imageView;
@synthesize lockscreenButton;
@synthesize spin;
@synthesize darkImage;
@synthesize descriptionLabel;
@synthesize bingButton;
@synthesize labelTip;
@synthesize buttonFavorite;
@synthesize fade;

#define ZOOM_VIEW_TAG 100
#define ZOOM_STEP 2

UIBackgroundTaskIdentifier bgTaskSaveWallpaper;

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
    if (@available(iOS 11.0, *)) {
        self.imageView.accessibilityIgnoresInvertColors = YES;
    }

    appDelegate = (BingWallpaperiPhoneAppDelegate *)[[UIApplication sharedApplication] delegate];

	[self becomeFirstResponder];

    [self showSpin:NO];
    
    self.fade = NO;
    alertBing = nil;
    interfaceHidden = NO;
	isVertical = YES;
    alreadyLongPress = NO;
    previewWasInfoHidden = NO;
    //auto hide tab bar
    self.hidesBottomBarWhenPushed = YES;
    
    @try {
        library = [[ALAssetsLibrary alloc] init]; //crash?
    }
     @catch (NSException * ex) {
        [UIAlertView showError:@"Error reading image library, please sync with iTunes to correct this issue." withTitle:@"Error"];
    }
    
    bgTaskSaveWallpaper = UIBackgroundTaskInvalid;

    lockscreenButton.hidden = YES;
    buttonFavorite.hidden = NO;
    currentId = @"";
    isFavorite = NO;
    
    [bingButton addTarget:self action:@selector(actionBingLogo:) forControlEvents:UIControlEventTouchUpInside];
    [lockscreenButton addTarget:self action:@selector(actionLockscreen:) forControlEvents:UIControlEventTouchUpInside];
    [buttonFavorite addTarget:self action:@selector(actionFavorite:) forControlEvents:UIControlEventTouchUpInside];

	[imageScrollView setBackgroundColor:[UIColor blackColor]];
	
    imageScrollView.delegate = self;
    
    //hide it
    imageScrollView.hidden = YES;
   
   //tip
    UIFont* tempFont = [UIFont fontWithName:@"Century Gothic" size:15];
	[self.labelTip setFont:tempFont];
    self.labelTip.textColor = [UIColor whiteColor]; //[UIColor darkGrayColor];
    self.labelTip.hidden = false; //[appDelegate imageChanged];
    self.labelTip.alpha = 0.8f;
    self.labelTip.text = @"Tip: you can zoom and scroll this image.";
    //shadow
	self.labelTip.shadowColor = RGBA(90,90,90, 255);
	self.labelTip.shadowOffset = CGSizeMake(1.0, 1.0);
	self.labelTip.layer.masksToBounds = NO;
    showTip = YES;
  
    //rotation
    {
        [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationChanged:) name:@"UIDeviceOrientationDidChangeNotification" object:nil];
    }
    
    //desc
    descriptionLabel.text = @"";
    descriptionLabel.textAlignment = NSTextAlignmentLeft;
    descriptionLabel.contentMode = UIViewContentModeTop;
    
    //set font
    tempFont = [UIFont fontWithName:@"Century Gothic" size:15] ;
	[descriptionLabel setFont:tempFont];
	//shadow
	descriptionLabel.shadowColor = RGBA(90,90,90, 255);
	descriptionLabel.shadowOffset = CGSizeMake(1.0, 1.0);
	descriptionLabel.layer.masksToBounds = NO;

	
    //nav
    //add button
    UIBarButtonItem *rightButon = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(actionMenu:)];
    [self.navigationItem setRightBarButtonItem:rightButon animated:YES];
        
    [self showInterface:YES];
    
    //corner
    //[appDelegate cornerView:self.view];

}

-(void) updateLockscreenImage
{
	NSLog(@"FirstViewController::updateLockscreenImage");
	
    NSString *filename =  @"";
    NSString *fullFilename = @"";
    
    if([appDelegate showLockscreen])
        filename = @"lockscreen";
    else
        filename = @"lockscreen2";

	/*if([appDelegate isIpad])
    {
		lockscreenButton.frame = [appDelegate GetScreenRect];
		lockscreenButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentFill;

		if([appDelegate isPortrait])
		{
            fullFilename = [NSString stringWithFormat:@"%@_ipad.png", filename];
			[lockscreenButton setImage:[UIImage imageNamed:fullFilename] forState:UIControlStateNormal];
		}
		else
		{
            fullFilename = [NSString stringWithFormat:@"%@_ipad_landscape.png", filename];
			[lockscreenButton setImage:[UIImage imageNamed:fullFilename] forState:UIControlStateNormal];
		}
		
    }
	else*/ if([appDelegate isIphone5])
    {
        fullFilename = [NSString stringWithFormat:@"%@_iphone5.png", filename];
        [lockscreenButton setImage:[UIImage imageNamed:fullFilename] forState:UIControlStateNormal];
    }
	else
	{
        //normal
        fullFilename = [NSString stringWithFormat:@"%@", filename];
		[lockscreenButton setImage:[UIImage imageNamed:fullFilename] forState:UIControlStateNormal];
	}
    
    lockscreenButton.frame = CGRectMake(lockscreenButton.frame.origin.x, 0,
                                            lockscreenButton.frame.size.width, lockscreenButton.frame.size.height);
}

- (void) setupUI;
{
    NSLog(@"FirstViewController::setupUI");

    if(![appDelegate isDoneLaunching])
        return;
        
    if(![appDelegate checkOnline])
        return;
    
    [self updateImage];
}

- (void)notifyForeground
{
    NSLog(@"FirstViewController::notifyForeground");
}

-(BOOL)canBecomeFirstResponder {
    return YES;
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
	
    [self becomeFirstResponder];
    
    //reset
    //[kAppDelegate setSavedImage:nil];
    
    //google analytics
    [Helpers setupGoogleAnalyticsForView:[[self class] description]];
    
    //title
    /*UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 400, 44)];
    label.backgroundColor = [UIColor clearColor];
    label.font = [UIFont fontWithName:@"Century Gothic" size:20] ;
    label.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.5];
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor =[UIColor whiteColor];
    label.text= @"Details";
    [self navigationItem].titleView = label;
    [self.navigationItem.titleView sizeToFit];  //center*/
    
    //show
    //showTip = YES; //always show?
    [self showInterface:YES];

    lockscreenButton.hidden = YES;
 
    //out of bound?
    if([appDelegate idArray] && ([appDelegate indexToLoad] >= 0) && ([[appDelegate idArray] count] > [appDelegate indexToLoad])) {
    
        currentId = [[appDelegate idArray] objectAtIndex:[appDelegate indexToLoad]]; //crash???
        isFavorite = [appDelegate isFavorite:currentId];
    }
    else
        isFavorite = NO;
    
    buttonFavorite.hidden = NO;

    //shadow
    /*buttonFavorite.layer.cornerRadius = 8.0f;
    buttonFavorite.layer.masksToBounds = NO;
    buttonFavorite.layer.borderWidth = 1.0f;
    buttonFavorite.layer.shadowColor = [UIColor greenColor].CGColor;
    buttonFavorite.layer.shadowOpacity = 0.8;
    buttonFavorite.layer.shadowRadius = 12;
    buttonFavorite.layer.shadowOffset = CGSizeMake(12.0f, 12.0f);*/

    [self updateFavoriteButton];
    
    
    //nav
    //show
    [[appDelegate navController] setNavigationBarHidden:NO animated:YES];
    
    [appDelegate navController].navigationBar.translucent = YES;
    
    
	if([appDelegate backgroundSupported])
	{
		[[NSNotificationCenter  defaultCenter] addObserver:self
												  selector:@selector(notifyForeground)
													  name:UIApplicationWillEnterForegroundNotification
													object:nil]; 
	}
    
    //use thumb
    //show it
    imageScrollView.hidden = NO;
    
    //force
    self.fade = NO;
    [self updateImage2];
    
    //desc
    //descriptionLabel.text = [NSString stringWithFormat:@"..."];
    descriptionLabel.text = [NSString stringWithFormat:@""];
    
    [self updateLockscreenImage];
    
    //spin now
    [self showSpin:YES];
}


- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
	[self becomeFirstResponder];
    
    //[self setupUI];
    
    [self updateImage];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if(kIsIOS10_3 && ![appDelegate isDebug])
        {
            //10.3 review
            [SKStoreReviewController requestReview];
        }
    });

}

- (void)viewWillDisappear:(BOOL)animated {
    
    [HapticHelper generateFeedback:kFeedbackType];

	[self resignFirstResponder];
    
    //nav bar popped
    [[appDelegate navController] setNavigationBarHidden:NO animated:YES];

	[super viewWillDisappear:animated];

    //if(HUD)
    //doHud = false;
    //[HUD hide:YES];
    
    [self showSpin:NO];
}

- (void)showPreview
{
    NSLog(@"FirstViewController:showPreview");
    
    //test crash
    //http://support.crashlytics.com/knowledgebase/articles/92522-is-there-a-quick-way-to-force-a-crash-
    //[[Crashlytics sharedInstance] crash];
    //int *x = NULL; *x = 42;

    previewWasInfoHidden = descriptionLabel.hidden;
    
    [self showInterface:NO];
    
    lockscreenButton.hidden = NO;
}

- (void)viewDidDisappear:(BOOL)animated
{
    if (self.parentViewController == nil)
    {

        //NSLog(@"viewDidDisappear doesn't have parent so it's been popped");
    } else
    {
        //NSLog(@"PersonViewController view just hidden");
    }
}

- (void)actionSave:(id)sender
{
    [HapticHelper generateFeedback:kFeedbackType];

    if([appDelegate savedImage] == nil)
        return;
    
    [self saveImage:[appDelegate savedImage]];
}

- (void)actionReload:(id)sender
{
   [self setupUI];
}

- (void)actionMenu:(id)sender
{
    [HapticHelper generateFeedback:kFeedbackType];

    //if still loading
    if(darkImage.hidden == NO)
        return;
    
    if([appDelegate savedImage] == nil)
        return;
    
    NSString *textToShare = @"Check out this image from Daily Wallpaper for iOS!";
    NSURL *url = [NSURL URLWithString:@"http://itunes.apple.com/app/id557949358"];
    NSString *subject = @"Image from Daily Wallpaper for iOS";
    
    UIImage *image = [appDelegate savedImage];
    //NSArray *objectsToShare = @[textToShare, url, image];
    
    NSArray *objectsToShare = @[textToShare, url, image];
    
    UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:objectsToShare applicationActivities:nil];
    
    /*NSArray *excludeActivities = @[
                                   //UIActivityTypeAirDrop,
                                   //UIActivityTypePrint,
                                   //UIActivityTypeAssignToContact,
                                   //UIActivityTypeSaveToCameraRoll,
                                   //UIActivityTypeAddToReadingList,
                                   //UIActivityTypePostToFlickr,
                                   UIActivityTypePostToVimeo
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
    
    
    //disabled
    return;
    
    //lockscreen
    NSString *previewString = @"";
    if([appDelegate showLockscreen])
        previewString = @"Preview Lock Screen";
    else
        previewString = @"Preview";

    //popup
    //Share on Facebook, send in Email, Tweet on Twitter, Save to Photo Library
    UIActionSheet * actionSheet=nil;
    actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                              delegate:self
                                     cancelButtonTitle:@"Cancel"
                                destructiveButtonTitle:nil
                                otherButtonTitles:previewString, @"Save to Photo Library",  @"Email Image",  @"Text/SMS Image", nil
                                //otherButtonTitles: @"Save to Photo Library",  @"Email Image", nil
                                ];
    
    
    //[actionSheet showInView:self.view];
    actionSheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
	[actionSheet showInView:self.view];
}

-(void)alertView:(UIAlertView *)alertView willDismissWithButtonIndex:    (NSInteger)buttonIndex 
{

    if(alertView == alertBing)
    {
        if(buttonIndex==0)
        {
            //cancel
        }
        else if(buttonIndex==1)
        {
        	//[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.bing.com/"]];
        }
    }
    
}

- (void)actionBingLogo:(id)sender
{
    NSLog(@"FirstViewController::actionBingLogo");
    /*
    //alert
    alertBing = nil;
    alertBing = [[UIAlertView alloc] initWithTitle:@"Bing"
                                                    message:@"Skyriser Media is not affiliated with Bing. Visit bing.com for more info?"
                                                   delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
	[alertBing show];
    
	//[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.bing.com/"]];*/
}

- (void)actionFavorite:(id)sender
{
    [HapticHelper generateFeedback:kFeedbackType];

    if(isFavorite)
    {
        isFavorite = NO;
        [appDelegate removeFavorite:currentId];
    }
    else
    {
        isFavorite = YES;
        [appDelegate addFavorite:currentId];
        
        //increase view
        [self IncView];
    }
    
    [appDelegate saveState];
    [self updateFavoriteButton];
}

- (void)actionLockscreen:(id)sender
{
    NSLog(@"actionLockscreen::actionBingLogo");

    lockscreenButton.hidden = YES;
        
    [self showInterface:!previewWasInfoHidden];

}

- (void) didReceiveMemoryWarning 
{
	NSLog(@"didReceiveMemoryWarning");
	[super didReceiveMemoryWarning];
}


- (void)viewDidUnload {
    library = nil;
}


- (void)dealloc {
    //[super dealloc];
	
	//[imageView release];
    
    [[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];

    //[HUD removeFromSuperview];
	//[HUD release];
}

- (void)imageSavedToPhotosAlbum:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo 
{
    [self imageSavedFinished:error];
}

-(void) saveImage: (UIImage*) image
{
    /*
    //[self showHud:@"Saving"];
    
    [self showSpin:YES];
    
    UIApplication *app = [UIApplication sharedApplication];
    bgTaskSaveWallpaper = [app beginBackgroundTaskWithExpirationHandler:^{ 
        [app endBackgroundTask:bgTaskSaveWallpaper]; 
        bgTaskSaveWallpaper = UIBackgroundTaskInvalid;
    }];

    //The completion block to be executed after image taking action process done
    void (^completionBlock)(NSURL *, NSError *) = ^(NSURL *assetURL, NSError *error) {
        [self imageSavedFinished:error];
    };

    void (^failureBlock)(NSError *) = ^(NSError *error) {
        [self imageSavedFinished:error];
    };

    // save image to custom photo album
    [library saveImage:image
                        toAlbum:@"Daily Wallpaper"
                completionBlock:completionBlock
                   failureBlock:failureBlock];

    //save custom album
	 ***[library saveImage:image toAlbum:@"Daily Wallpaper" withCompletionBlock:^(NSError *error) {
     
        [self imageSavedFinished:error];
    }];****
     
     */

}

-(void)imageSavedFinished:(NSError *)error
{
    [self showSpin:NO];
    
    if(error)
    {
        NSLog(@"didFinishSavingWithError: %@", error);
        
          UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"The image could not be saved to your Photo Library." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert show];
    }
    else
    {
        /*UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Image Saved" message:@"The image has been saved to your Photo Library. Use the Photos application to set it as your\n Wallpaper or Lock Screen." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert show];*/
        
        [Helpers showMessageHud:@"Image saved"];

    }
    
    UIApplication *app = [UIApplication sharedApplication];
    if (bgTaskSaveWallpaper != UIBackgroundTaskInvalid) {
        [app endBackgroundTask:bgTaskSaveWallpaper]; 
        bgTaskSaveWallpaper = UIBackgroundTaskInvalid;
    }

}

- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
    if (event.type == UIEventSubtypeMotionShake) 
    {
        //random
        //[appDelegate setRandom:YES];
        //[self setupUI];
    }
}
/*-(UIView *) viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return imageView;
}*/

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return [scrollView viewWithTag:ZOOM_VIEW_TAG];
}
/*
- (void)showHud:(NSString*)text
{
    return;
    
    // Should be initialized with the windows frame so the HUD disables all user input by covering the entire screen
	
    UIView* tempView = self.view;
    //HUD = [[MBProgressHUD alloc] initWithWindow:[UIApplication sharedApplication].keyWindow];
    HUD = [[MBProgressHUD alloc] initWithView:tempView];
    
	// Add HUD to screen
	[self.view.window addSubview:HUD];
    
	// Register for HUD callbacks so we can remove it from the window at the right time
	HUD.delegate = self;
    
	//HUD.labelText = @"Test";
    HUD.labelText = text;
    
    HUD.userInteractionEnabled = NO;
    
     doHud = TRUE;
    //[HUD showWhileExecuting:@selector(hudTask) onTarget:self withObject:nil animated:YES];
    
    //delay?
    [self performSelector:@selector(showHud2) withObject:nil afterDelay:0.1
    ];

}

- (void)showHud2
{
    [HUD showWhileExecuting:@selector(hudTask) onTarget:self withObject:nil animated:YES];
}

- (void)hudWasHidden {
    
    //doHud = false;
    [HUD removeFromSuperview];
	//[HUD release];
    HUD = nil;
    
	// Remove HUD from screen when the HUD was hidden
	//[HUD removeFromSuperview];
	//[HUD release];
}

- (void)hudTask 
{
    
    int hudTimeStart = [[NSDate date] timeIntervalSince1970];
    bool doMinimum = true;
    //while(doHud)     
    while(doHud || doMinimum) //at least 1 sec
    { 
        int hudTimeCurrent =  [[NSDate date] timeIntervalSince1970]; 
        //int diff = [[NSDate date] timeIntervalSince1970] - hudTimeStart ;
        //doMinimum =  (diff <= 1000);
        //more than 5 secs
        int diff = (hudTimeCurrent - hudTimeStart) ; //in 1000ths or seconds?
        if(diff <= 1)
        {
            doMinimum = true;
        }
        else
        {
            doMinimum = false;
        }
        
        if( diff > 10)
        {
            doHud = false;
           
        }
    }
    
    //hide
    doHud = false;
    doMinimum = false;
    //[HUD hide:YES]; 
    [HUD hide:YES];
   // [HUD hide:YES afterDelay:2];
    
}
*/

- (void)handleSingleTap:(UIGestureRecognizer *)gestureRecognizer {

    //return;
    
    NSLog(@"FirstViewController::handleSingleTap");

    [self toggleInterface];
    
}

-(void)centerZoom
{
    CGFloat newContentOffsetX = (imageScrollView.contentSize.width - imageScrollView.frame.size.width) / 2;
    imageScrollView.contentOffset = CGPointMake(newContentOffsetX, 0);
}

-(void)maxZoom
{
    NSLog(@"FirstViewController::maxZoom");
    
    //sanity
    if([appDelegate savedImage] == nil)
        return;
    if(([appDelegate savedImage].size.width == 0) || ([appDelegate savedImage].size.height== 0))
        return;
    
    //resize
    float minimumScale = [imageScrollView frame].size.width  / [appDelegate savedImage].size.width;
    float maximumScale = [imageScrollView frame].size.height / [appDelegate savedImage].size.height;

    [imageScrollView setMinimumZoomScale:minimumScale];
    [imageScrollView setMaximumZoomScale:maximumScale * MAX_ZOOM_MULT];
    [imageScrollView setZoomScale:maximumScale animated:NO];
}

- (void)updateZoom
{
    NSLog(@"FirstViewController::updateZoom");
    
    //sanity
    if([appDelegate savedImage] == nil)
        return;
    if(([appDelegate savedImage].size.width == 0) || ([appDelegate savedImage].size.height== 0))
        return;
    
    //resize
    float minimumScale = [imageScrollView frame].size.width  / [appDelegate savedImage].size.width;
    float maximumScale = [imageScrollView frame].size.height / [appDelegate savedImage].size.height;

    [imageScrollView setMinimumZoomScale:minimumScale];
    [imageScrollView setMaximumZoomScale:maximumScale * MAX_ZOOM_MULT];
    
    //re-set zoom
    [imageScrollView setZoomScale:[imageScrollView zoomScale] animated:NO];

}


-(void)scrollViewDidEndDecelerating:(UIView *)scrollView
{
    showTip = NO;
    [self showInterface:YES];
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView // called when setContentOffset/scrollRectVisible:animated: finishes. not called if not animating
{
    showTip = NO;
    [self showInterface:YES];
}

- (void)scrollViewWillBeginZooming:(UIScrollView *)scrollView withView:(UIView *)view
{
    showTip = NO;
    [self showInterface:YES];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    showTip = NO;
    [self showInterface:YES];
}

/*

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView


- (void)scrollViewDidScroll:(UIScrollView *)scrollView;                                               // any offset changes

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView; // called when setContentOffset/scrollRectVisible:animated: finishes. not called if not animating
- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(float)scale; // scale between minimum and maximum. called after any 'bounce' animations
- (void)scrollViewDidZoom:(UIScrollView *)scrollView NS_AVAILABLE_IOS(3_2); // any zoom scale changes
*/

/*- (void)scrollViewDidScroll:(UIScrollView *)scrollView;  // any offset changes
{
    showTip = NO;
    [self showInterface:YES];
}*/

/*- (void)scrollViewDidZoom:(UIScrollView *)scrollView // any zoom scale changes
{
    showTip = NO;
    [self showInterface:YES];
}*/

-(void)showInterface:(BOOL)show
{
    NSLog(@"FirstViewController::showInterface");

    interfaceHidden = !show;

    descriptionLabel.hidden = interfaceHidden;
    buttonFavorite.hidden = interfaceHidden;
    
    //bingButton.hidden = interfaceHidden;
    bingButton.hidden = YES; //disabled
    
    //nav
    [[appDelegate navController] setNavigationBarHidden:interfaceHidden animated:YES];

    if(show)
    {
        labelTip.hidden = !showTip;
        
    }
    else
    {
        labelTip.hidden = YES;
    }
        
    [self updateZoom];
    //[self maxZoom];

    //flash scroll bars
    [imageScrollView flashScrollIndicators];

}

- (void)toggleInterface
{
    [HapticHelper generateFeedback:kFeedbackType];

    NSLog(@"FirstViewController::toggleInterface");

    //toggle    
    interfaceHidden = !interfaceHidden;
    
    [self showInterface:!interfaceHidden];

}

- (void)handleDoubleTap:(UIGestureRecognizer *)gestureRecognizer {
    // double tap zooms in
    
    [HapticHelper generateFeedback:kFeedbackType];

    NSLog(@"FirstViewController::handleDoubleTap");
    float newScale = 0;
    
    float minimumScale = [imageScrollView frame].size.width  / [appDelegate savedImage].size.width;
    float maximumScale = [imageScrollView frame].size.height / [appDelegate savedImage].size.height;

    float midScale = minimumScale + ((maximumScale - minimumScale) / 2);
    
    if([imageScrollView zoomScale] < midScale)
    {
        //in
        newScale = maximumScale;// / [imageScrollView zoomScale];
    }
    else
    {
        //out
        newScale = minimumScale;// / [imageScrollView zoomScale];

    }
    
    CGRect zoomRect = [self zoomRectForScale:newScale withCenter:[gestureRecognizer locationInView:gestureRecognizer.view]];
    [imageScrollView zoomToRect:zoomRect animated:YES];
}

- (void)handleTwoFingerTap:(UIGestureRecognizer *)gestureRecognizer {
    // two-finger tap zooms out
    /*float newScale = [imageScrollView zoomScale] / ZOOM_STEP;
    CGRect zoomRect = [self zoomRectForScale:newScale withCenter:[gestureRecognizer locationInView:gestureRecognizer.view]];
    [imageScrollView zoomToRect:zoomRect animated:YES];*/
}

- (void)handleLongPress:(UIGestureRecognizer *)gestureRecognizer {
    
    if (gestureRecognizer.state == UIGestureRecognizerStateEnded)
    {
        alreadyLongPress = NO;
        return;
    }
    
    if(alreadyLongPress)
        return;
    
    NSLog(@"FirstViewController::handleLongPress");
    
    alreadyLongPress = YES;
    
    
    [self actionMenu:0];
}


-(void) actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    
    NSLog(@"FirstViewController::actionSheet didDismissWithButtonIndex");


    //otherButtonTitles:@"Preview Lock Screen", @"Save to Photo Library", nil

    switch (buttonIndex)
    {
        
            
        /*case 1: //copy
            {
                //copy
                [appDelegate copyImageToClipboard: [appDelegate savedImage]];

            }
            break;*/
        
        case 0: //preview
            [self showPreview];
            break;
            
        case 1: //save
            [self actionSave:0];
            break;

         case 2: //email
           
            if([MFMailComposeViewController canSendMail] && [appDelegate savedImage] != nil)
            {
                NSString *footer = @"Check out Daily Wallpaper for iOS:\nhttp://itunes.apple.com/app/id557949358";
                NSString *body = [NSString stringWithFormat:@"%@\n\n\n%@", @"I wanted to share this photo with you!", footer];
                body = [body stringByReplacingOccurrencesOfString:@"\n\n" withString:@"\n"];
                [appDelegate sendEmailTo:@"" withSubject: @"Daily Wallpaper" withBody:body withImage:[appDelegate savedImage] withView:self ];
            }
            else
                [UIAlertView showError:@"Could not send email." withTitle:@"Error"];
            
            break;
            
         case 3: //sms
          if([MFMessageComposeViewController canSendText] && [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"sms:"]] &&
                    [MFMessageComposeViewController canSendAttachments] && [MFMessageComposeViewController isSupportedAttachmentUTI:(NSString *)kUTTypePNG] &&
                    [appDelegate savedImage] != nil)
                {
                    MFMessageComposeViewController *messageController = [[MFMessageComposeViewController alloc] init];
                    messageController.messageComposeDelegate = self;
                    
                    BOOL didAttachImage = [messageController addAttachmentData:UIImagePNGRepresentation([appDelegate savedImage]) typeIdentifier:(NSString*)kUTTypePNG filename:@"dailywallpaper.png"];
                    
                
                    if(didAttachImage)
                        [self presentViewController:messageController animated:YES completion:nil];
                    else
                        [UIAlertView showError:@"Could not send text message." withTitle:@"Error"];

                    
                    /*NSString *body = [NSString stringWithFormat:@"%@", mixed];
                    body = [body stringByReplacingOccurrencesOfString:@"\n\n" withString:@"\n"];
                    body = [body stringByReplacingOccurrencesOfString:@"\n" withString:@" "];

                    SHKItem *item = nil;

                    item = [SHKItem text:body];

                    [SHKTextMessage shareItem:item]; */
                    

                }
                else
                    [UIAlertView showError:@"Could not send text message." withTitle:@"Error"];

            break;

        /*case 3:
            //share
             {
                //alert
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" 
                                                                message:@"Share will be available soon."
                                                               delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alert show];
            }
            break;*/


        //case 5: //email
        //    break;

            
        default:
            break;
    }
    
    alreadyLongPress = NO;
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



- (CGRect)zoomRectForScale:(float)scale withCenter:(CGPoint)center {
    
    CGRect zoomRect;
    
    // the zoom rect is in the content view's coordinates. 
    //    At a zoom scale of 1.0, it would be the size of the imageScrollView's bounds.
    //    As the zoom scale decreases, so more content is visible, the size of the rect grows.
    zoomRect.size.height = [imageScrollView frame].size.height / scale;
    zoomRect.size.width  = [imageScrollView frame].size.width  / scale;
    
    // choose an origin so as to get the right center.
    zoomRect.origin.x    = center.x - (zoomRect.size.width  / 2.0);
    zoomRect.origin.y    = center.y - (zoomRect.size.height / 2.0);
    
    return zoomRect;
}

-(void) orientationChanged:(NSNotification *) object
{
    return;
    
    NSLog(@"FirstViewController::orientationChanged");
    
   
   interfaceHidden = YES;
   //[self toggleInterface];
    [self updateZoom];

}

/*
-(void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration:{
       CGRect screen = [[UIScreen mainScreen] bounds];
       float pos_y, pos_x;
       pos_y = UIDeviceOrientationIsLandscape([[UIDevice currentDevice] orientation]) ? screen.size.width/2  : screen.size.height/2;
       pos_x = UIDeviceOrientationIsLandscape([[UIDevice currentDevice] orientation]) ? screen.size.height/2 : screen.size.width/2;

       myImageView.center = CGPointMake(pos_x, pos_y);
}

*/

//center zoomout
-(void)scrollViewDidZoom:(UIScrollView *)pScrollView {

    //showTip = NO;
    //[self showInterface:YES];
    
    CGRect innerFrame = imageView.frame;
    CGRect scrollerBounds = pScrollView.bounds;

    if ( ( innerFrame.size.width < scrollerBounds.size.width ) || ( innerFrame.size.height < scrollerBounds.size.height ) )
    {
        CGFloat tempx = imageView.center.x - ( scrollerBounds.size.width / 2 );
        CGFloat tempy = imageView.center.y - ( scrollerBounds.size.height / 2 );
        CGPoint myScrollViewOffset = CGPointMake( tempx, tempy);

        pScrollView.contentOffset = myScrollViewOffset;

    }

    UIEdgeInsets anEdgeInset = { 0, 0, 0, 0};
    if ( scrollerBounds.size.width > innerFrame.size.width )
    {
        anEdgeInset.left = (scrollerBounds.size.width - innerFrame.size.width) / 2;
        anEdgeInset.right = -anEdgeInset.left;  // I don't know why this needs to be negative, but that's what works
    }
    if ( scrollerBounds.size.height > innerFrame.size.height )
    {
        anEdgeInset.top = (scrollerBounds.size.height - innerFrame.size.height) / 2;
        anEdgeInset.bottom = -anEdgeInset.top;  // I don't know why this needs to be negative, but that's what works
    }
    pScrollView.contentInset = anEdgeInset;
}

-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return;
    
        if(interfaceOrientation == UIInterfaceOrientationPortrait ||
            interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown)
            isVertical = YES;
        else
            isVertical = NO;
            
          [self updateZoom];
      
    /*typedef enum {
   UIInterfaceOrientationPortrait           = UIDeviceOrientationPortrait,
   UIInterfaceOrientationPortraitUpsideDown = UIDeviceOrientationPortraitUpsideDown,
   UIInterfaceOrientationLandscapeLeft      = UIDeviceOrientationLandscapeRight,
   UIInterfaceOrientationLandscapeRight     = UIDeviceOrientationLandscapeLeft
    } UIInterfaceOrientation;
    */
        
}

-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)orientation duration:(NSTimeInterval)duration
{
}


-(void)updateFavoriteButton
{
    UIImage *btnImage = nil;
    
    if(isFavorite) {
        btnImage = [UIImage imageNamed:@"favorite.png"];
    }
    else {
        btnImage = [UIImage imageNamed:@"favorite_off.png"];
    }

    [buttonFavorite setImage:btnImage forState:UIControlStateNormal];
}

-(void)updateImage
{
    NSLog(@"FirstViewController::updateImage");
    
    if([[appDelegate nameArray] count] == 0)
        return;

    if(![appDelegate isDoneLaunching])
        return;
        
    [self showSpin:YES];
    
    NSString *imagePath = [NSString stringWithFormat:URL_API_IMAGE, [appDelegate nameToLoad]];
    //NSString *imagePath = [NSString stringWithFormat:URL_API_IMAGE, @"test"]; //force error
    //NSURL *imageUrl = [NSURL URLWithString:imagePath];
    NSLog(@"imagePath: %@", imagePath);
    
    
    //[cell.thumbnailButton sd_setImageWithURL:[NSURL URLWithString:photoURL] forState:UIControlStateNormal placeholderImage:[appDelegate missingThumb] options:(SDWebImageHighPriority) completed:^(UIImage *newImage, NSError *error, SDImageCacheType cacheType, NSURL *imageURL)

    if (@available(iOS 11.0, *)) {
        self.imageView.accessibilityIgnoresInvertColors = YES;
    }

    
    __weak FirstViewController *weakSelf = self;
    UIImage *placeholder = [appDelegate savedImage];
    [self.imageView sd_setImageWithURL:[NSURL URLWithString:imagePath] placeholderImage:placeholder
                      completed:^(UIImage *newImage, NSError *error, SDImageCacheType cacheType, NSURL *imageURL)
                      {
                          
                            if(newImage && !error) {
                                if(weakSelf) {
                                    weakSelf.fade = YES;
                                    [kAppDelegate setSavedImage:newImage];
                                    
                                    dispatch_async(dispatch_get_main_queue(), ^{
                                            [weakSelf updateImage2];
                                    });

                                    
                                 } else {
                                    NSLog(@"weakSelf nil");
                                }
                        
                            }
                            else {
                                weakSelf.fade = NO;

                                [kHelpers showErrorHud:LOCALIZED(@"kStringConnectionError")];

                                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, kHudWaitDuration * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                                    [weakSelf.navigationController popViewControllerAnimated:YES];
                                 });

                            }
                            
                      }];

   /*[self.imageView setImageWithURLRequest:[NSURLRequest requestWithURL:imageUrl] placeholderImage:nil
                success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *newImage) {
                    if(weakSelf) {
                        weakSelf.fade = YES;
                        [kAppDelegate setSavedImage:newImage];
                        
                        dispatch_async(dispatch_get_main_queue(), ^{
                                [weakSelf updateImage2];
                        });

                        
                     } else {
                        NSLog(@"weakSelf nil");
                    }
                    
                } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                    weakSelf.fade = NO;

                    [kHelpers showErrorHud:LOCALIZED(@"kStringConnectionError")];

                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, kHudWaitDuration * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                        [weakSelf.navigationController popViewControllerAnimated:YES];
                     });
                    
                }
         ];*/

}
            
-(void)updateImage2
{
    NSLog(@"FirstViewController::updateImage2");
       
    [self showSpin:NO];
    
    if (@available(iOS 11.0, *)) {
        self.imageView.accessibilityIgnoresInvertColors = YES;
    }

  
    //show it
    imageScrollView.hidden = NO;
    
    //[imageView removeGestureRecognizer:<#(UIGestureRecognizer *)#>
    //remove old
    if ([imageScrollView.subviews count]>0)
    {
        //for (int i=0; i<[imageScrollView.subviews count]; ++i)
        for (int i=(int)[imageScrollView.subviews count]-1; i>=0; i--) //reverse
        {
            
            //protect
            if(i>0 && i<imageScrollView.subviews.count)
            {
                [[imageScrollView.subviews objectAtIndex:i] removeFromSuperview];
            }
        }
    }
    imageView = nil;
	imageView = [[UIImageView alloc] initWithImage:[appDelegate savedImage]];
    imageView.userInteractionEnabled = YES;
    
    if (@available(iOS 11.0, *)) {
        imageView.accessibilityIgnoresInvertColors = YES;
    }

    
	[imageScrollView addSubview:imageView];
	//[imageScrollView setContentSize:imageView.image.size];
	//[imageScrollView setScrollEnabled:YES];
	
    
    //gestures
    // set the tag for the image view
    [imageView setTag:ZOOM_VIEW_TAG];
    
    // add gesture recognizers to the image view
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap:)];
    UITapGestureRecognizer *twoFingerTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTwoFingerTap:)];    
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
    
    [doubleTap setNumberOfTapsRequired:2];
    [twoFingerTap setNumberOfTouchesRequired:2];
    
    //disable single when double
    [singleTap requireGestureRecognizerToFail:doubleTap];
    [singleTap requireGestureRecognizerToFail:longPress];
    
    [imageView addGestureRecognizer:singleTap];
    [imageView addGestureRecognizer:doubleTap];
    [imageView addGestureRecognizer:longPress];
    //[imageView addGestureRecognizer:twoFingerTap];

    //reset
    int newW = 480;
    //iphone 5
    if([appDelegate isIphone5])
    {
        newW = 568;
    }
    
    //CGRect oldFrame = imageScrollView.frame;           //test: origin=(x=0, y=-10) size=(width=320, height=568)
    //CGRect newFrame = CGRectMake(0, 0, 320, newW);     //test: origin=(x=0, y=0) size=(width=320, height=568)

    imageScrollView.frame = CGRectMake(0, 0, 320, newW); //glitch?
        imageView.frame = CGRectMake(0, 0, 320, newW);
    [imageScrollView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];

    //set image

    if(fade) {
        //cross-fade
            [UIView transitionWithView:self.view
                  duration:0.3f
                   options:UIViewAnimationOptionTransitionCrossDissolve
                animations:^{
                [imageView setImage:[appDelegate savedImage]];
            } completion:nil];
    }
    else {
        if([appDelegate savedImage] == nil)
            NSLog(@"updateImage2: savedImage = nil");
        else
            [imageView setImage:[appDelegate savedImage]];
    }
    

    
    //resize
    NSLog(@"[appDelegate savedImage].size: width:%f, height:%f", [appDelegate savedImage].size.width, [appDelegate savedImage].size.height);
    
    imageView.frame = CGRectMake(0, 0, [appDelegate savedImage].size.width, [appDelegate savedImage].size.height);
   	
    NSLog(@"imageView.frame width:%f, height:%f", imageView.frame.size.width, imageView.frame.size.height);

    [imageScrollView setContentSize:CGSizeMake(imageView.frame.size.width, imageView.frame.size.height)];

	[imageScrollView setCanCancelContentTouches:NO];
	imageScrollView.clipsToBounds = YES;	
	imageScrollView.indicatorStyle = UIScrollViewIndicatorStyleWhite;
	[imageScrollView setScrollEnabled:YES];

    imageView.contentMode  = UIViewContentModeScaleAspectFit;
    //imageScrollView.clipsToBounds = YES;
    //[imageScrollView setZoomScale:1];
    
    [self updateZoom];
    [self maxZoom];
    [self centerZoom];

    //already loaded
    NSString *descriptionString = nil;
    
    //in bounds?
    if([appDelegate descriptionArray] && ([appDelegate indexToLoad] < [[appDelegate descriptionArray] count]))
        descriptionString = [[appDelegate descriptionArray] objectAtIndex:[appDelegate indexToLoad]];

    [[appDelegate descriptionArray] objectAtIndex:[appDelegate indexToLoad]];

    if(descriptionString == nil || [descriptionString isEqualToString:@""])
    {
        descriptionString = [NSString stringWithFormat:@"???"];
    }
    else
    {
        //convert html
        descriptionString = [descriptionString stringByConvertingHTMLToPlainText];
        descriptionString = [descriptionString stringByReplacingOccurrencesOfString:@"[newline]" withString:@"\n"];
    }

    descriptionLabel.text = descriptionString;
    
    //flash scroll bars
    [imageScrollView flashScrollIndicators];
    
    //titlebar
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
    [self showSpin:NO];

    //done hud?
    //doHud = false;
    
    //increase view
    [self IncView];
}

-(void)IncView
{
    if(![appDelegate isDebug] && [appDelegate isOnline]) //not in debug
    {
        NSString *viewStringURL = [NSString stringWithFormat: URL_API_INC_VIEW, [appDelegate nameToLoad]];
        NSString *viewStringOut = [appDelegate getStringFromURL:viewStringURL];
        NSLog(@"views: %@", viewStringOut);
    }
}

-(void)showSpin:(BOOL)show
{
    spin.hidden = !show;
    if(show)
    [[self view] bringSubviewToFront:spin]; 
    
    darkImage.hidden = !show;
}

/*
- (BOOL)navigationBar:(UINavigationBar *)navigationBar shouldPopItem:(UINavigationItem *)item
{

    return YES;
}
*/

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


@end
