//
//  MyTabBarController.m
//
//  Created by Chris Comeau on 11-06-26.
//  Copyright 2011 Skyriser Media. All rights reserved.
//

#import "MyTabBarController.h"
#import "BingWallpaperiPhoneAppDelegate.h"

@implementation MyTabBarController


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
   
    //force all
    return YES;
    
    if(interfaceOrientation == UIDeviceOrientationPortrait) return YES;
    //if(interfaceOrientation == UIDeviceOrientationLandscapeRight) return YES;
    return NO;

    
    //return NO;
    
    /*
    //return (interfaceOrientation == UIInterfaceOrientationPortrait);
    //return ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad);
    //return YES;
    
    appDelegate = (BingWallpaperiPhoneAppDelegate *)[[UIApplication sharedApplication] delegate];
     
    return [appDelegate isIpad];
     */
}


@end
