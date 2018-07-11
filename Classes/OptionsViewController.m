//
//  OptionsViewController.m
//
//  Created by Chris Comeau on 10-02-12.
//  Copyright 2010 Games Montreal. All rights reserved.
//

#import "OptionsViewController.h"
#if USE_TESTFLIGHT
#import "TestFlight.h"
#endif


@implementation OptionsViewController

@synthesize switchSound;
@synthesize switchOld;

@synthesize label1;
@synthesize label2;
@synthesize scrollView;

- (void)notifyForeground
{
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
	
    //google analytics
    [Helpers setupGoogleAnalyticsForView:[[self class] description]];
    
	isVisible = true;
    
	//notify
	if([appDelegate backgroundSupported])
	{
		[[NSNotificationCenter  defaultCenter] addObserver:self
												  selector:@selector(notifyForeground)
													  name:UIApplicationWillEnterForegroundNotification
													object:nil]; 
	}
	
}

- (void)viewWillDisappear:(BOOL)animated {
	
	isVisible = false;
    
	//notify
	if([appDelegate backgroundSupported])
	{
		[[NSNotificationCenter defaultCenter] removeObserver:self]; 
	}
	
	
	[super viewWillDisappear:animated];
	
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	[super viewDidLoad];
	
	appDelegate = (BingWallpaperiPhoneAppDelegate *)[[UIApplication sharedApplication] delegate];
	
    
    //set font
    UIFont* tempFont = [UIFont fontWithName:@"Century Gothic" size:17] ; 
	[label1 setFont:tempFont];
	[label2 setFont:tempFont];

    tempFont = kButtonFont;

    [self.view setMultipleTouchEnabled:YES];

	isVisible = false;
	
	//icon warning.png
	//UIImageView * myView = [[ UIImageView  alloc ]  initWithImage :  [UIImage  imageNamed : @"warning.png" ]];
	
     //doesn't work in ios5?
    if(SYSTEM_VERSION_LESS_THAN(@"5"))
    {
    }
    else
    {
        //UIColor *color = [UIColor greenColor];
        UIColor *color = RGBA(39,178,160, 255); //turquoise

        switchSound.onTintColor = color;
        switchOld.onTintColor = color;
	}
	
	switchSound.on = NO; //[appDelegate prefPlaySound];
	[switchSound addTarget:self action:@selector(actionSound:) forControlEvents:UIControlEventValueChanged];
    
    switchOld.on = [appDelegate prefShowAll];
	[switchOld addTarget:self action:@selector(actionOld:) forControlEvents:UIControlEventValueChanged];
    
    
    //disabled
    switchSound.enabled = NO;
    switchSound.enabled = YES;
    

    [self becomeFirstResponder];
    
    //scroll
    int wiggle = 0;
    scrollView.contentSize=CGSizeMake(self.view.frame.size.width, self.view.frame.size.height+wiggle);

    scrollView.scrollsToTop = NO;

    //corner
    [appDelegate cornerView:self.view];
}

- (void)actionOld:(id)sender
{
	[appDelegate setPrefShowAll:[sender isOn]];
	[appDelegate saveState];
}

- (void)actionSound:(id)sender
{
	[appDelegate setPrefPlaySound:[sender isOn]];
	[appDelegate saveState];
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


- (void)dealloc {
	
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


@end
