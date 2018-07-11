// CustomUITabBarController.m

#import "CustomUITabBarController.h"
#import "BingWallpaperiPhoneAppDelegate.h"

@implementation CustomUITabBarController

- (void)viewDidLoad {
    [super viewDidLoad];
        
    appDelegate = (BingWallpaperiPhoneAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    //doesn't work in ios5?
    if(SYSTEM_VERSION_LESS_THAN(@"5"))
    {
        
        CGRect frame = CGRectMake(0.0, 0.0, self.view.bounds.size.width, 48);
        UIView *v = [[UIView alloc] initWithFrame:frame];
        [v setBackgroundColor:[[UIColor alloc] initWithRed:0.2  green:0.6  blue:0.2 alpha:0.3]]; //turcoise ???
        
        

        [v setAlpha:0.5];
        //[[self tabBar] addSubview:v];
        [[self tabBar] insertSubview:v atIndex:0];
        //[v release];
    }
    else
    {   
        //ios5
        self.tabBar.tintColor = RGBA(18, 64, 63, 255);  //turcoise
        self.tabBar.selectedImageTintColor = RGBA(39,178,160, 255);  //turcoise
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
@end
