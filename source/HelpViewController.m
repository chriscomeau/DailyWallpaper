//
//  HelpViewController.m
//
//  Created by Chris Comeau on 10-02-15.
//  Copyright 2010 Games Montreal. All rights reserved.
//

#import "HelpViewController.h"
#import "BingWallpaperiPhoneAppDelegate.h"
#if USE_TESTFLIGHT
#import "TestFlight.h"
#endif


@implementation HelpViewController

//@synthesize doneButton;
@synthesize doneButton;
@synthesize textView;
//@synthesize webView;


/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
    }
    return self;
}
*/

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/

- (void)viewWillAppear:(BOOL)animated 
{
    [super viewWillAppear:animated];
    
    //button
    if([appDelegate showingHelp] == YES)
	{
		//doneButton.text = @"Next";
		
		[doneButton setTitle:@"Next" forState:UIControlStateNormal];
		[doneButton setTitle:@"Next" forState:UIControlStateHighlighted];
		[doneButton setTitle:@"Next" forState:UIControlStateDisabled];
		[doneButton setTitle:@"Next" forState:UIControlStateSelected];
	}
	else
	{
		//doneButton.text = @"Done";
		
		[doneButton setTitle:@"Done" forState:UIControlStateNormal];
		[doneButton setTitle:@"Done" forState:UIControlStateHighlighted];
		[doneButton setTitle:@"Done" forState:UIControlStateDisabled];
		[doneButton setTitle:@"Done" forState:UIControlStateSelected];
	}	
    
    
    //scroll bars
	[textView flashScrollIndicators];
    
    
    if(USE_ANALYTICS == 1)
	{
		[[LocalyticsSession sharedLocalyticsSession] tagEvent:@"HelpView"];
        //[FlurryAnalytics logEvent:@"HelpView"];
	}
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	appDelegate = (BingWallpaperiPhoneAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    //set font
    UIFont* tempFont = [UIFont fontWithName:@"Century Gothic" size:13] ; 
	[textView setFont:tempFont];
	[textView setFont:tempFont];
    
    tempFont = [UIFont fontWithName:@"CenturyGothic-Bold" size:13] ; 
	doneButton.titleLabel.font = tempFont;
    [doneButton setTitleColor:[appDelegate buttonTextColor] forState:UIControlStateNormal];
	
	//[doneButton addTarget:self action:@selector(actionDone:)];
	[doneButton addTarget:self action:@selector(actionDone:) forControlEvents:UIControlEventTouchUpInside];
	
    //bigger text on ipad
    if([appDelegate isIpad])
    {
        UIFont *biggerFont = [UIFont fontWithName:@"Helvetica" size:24];
        UIFont *biggerFontBold = [UIFont fontWithName:@"Helvetica-Bold" size:24];
        
        [textView setFont:biggerFont];
        
        //buttons
        [doneButton.titleLabel setFont:biggerFontBold];
        
    }
    
    textView.scrollsToTop = NO;

    
    //corner
    [appDelegate cornerView:self.view];


}

- (void)actionDone:(id)sender
{
	//BingWallpaperiPhoneAppDelegate *appDelegate = (BingWallpaperiPhoneAppDelegate *)[[UIApplication sharedApplication] delegate];
	
    //marked as not 1st time
    [appDelegate setPrefOpened:YES];
    [appDelegate saveState];

	//if([[appDelegate keyString]  length] == 0)
	if([appDelegate showingHelp] == YES)
	{
		//first time
		[appDelegate alertHelpDoneFirstTime];
	}
	else 
	{
		[appDelegate alertHelpDone];

	}
    
#if USE_TESTFLIGHT
    if([appDelegate isTestflight])
        [TestFlight passCheckpoint:@"HelpViewController:actionDone"];
#endif
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
    
	//[doneButton release];
	//[doneButton release];
	//[webView release];

	//[super dealloc];
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
