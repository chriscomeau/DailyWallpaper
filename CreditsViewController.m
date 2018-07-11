//
//  CreditsViewController.m
//
//  Created by Chris Comeau on 10-02-15.
//  Copyright 2010 Games Montreal. All rights reserved.
//

#import "CreditsViewController.h"
#import "BingWallpaperiPhoneAppDelegate.h"
#if USE_TESTFLIGHT
#import "TestFlight.h"
#endif


@implementation CreditsViewController

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
        [FlurryAnalytics logEvent:@"HelpView"];
	}
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	appDelegate = (BingWallpaperiPhoneAppDelegate *)[[UIApplication sharedApplication] delegate];
    
	//[doneButton setTarget:self];
	//[doneButton setAction:@selector(actionDone:)];
	//doneButton.hidden = TRUE;
	
	//[doneButton addTarget:self action:@selector(actionDone:)];
	[doneButton addTarget:self action:@selector(actionDone:) forControlEvents:UIControlEventTouchUpInside];
	
	//doneButton.hidden = TRUE;
	
	/*if([appDelegate showingHelp] == YES)
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
     }*/
	
	//UIWebView *webView;
	
	//webView.opaque = NO;
	//webView.backgroundColor=[UIColor clearColor];
	
	//NSString *htmlData = @"<html><body style='background-color:transparent; font-family:'helvetica';'>This is a <b>test</b><br><br>thanks.</body></html>";
	//[webView loadHTMLString:htmlData baseURL:nil];
	
	//webView.hidden = TRUE;
	
	//navigationcontrollre.navigationBar.tintColor = [UIColor greenColor]
	
    //bigger text on ipad
    if([appDelegate isIpad])
    {
        UIFont *biggerFont = [UIFont fontWithName:@"Helvetica" size:24];
        UIFont *biggerFontBold = [UIFont fontWithName:@"Helvetica-Bold" size:24];
        
        [textView setFont:biggerFont];
        
        //buttons
        [doneButton.titleLabel setFont:biggerFontBold];
        
    }

    //corner
    [appDelegate cornerView:self.view];

}

- (void)actionDone:(id)sender
{
	//BingWallpaperiPhoneAppDelegate *appDelegate = (BingWallpaperiPhoneAppDelegate *)[[UIApplication sharedApplication] delegate];
	
	
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
        [TestFlight passCheckpoint:@"CreditsViewController:actionDone"];
#endif
}


- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
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


@end
