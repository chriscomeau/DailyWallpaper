//
//  OptionsViewController.h
//
//  Created by Chris Comeau on 10-02-12.
//  Copyright 2010 Games Montreal. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BingWallpaperiPhoneAppDelegate.h"


@interface OptionsViewController : UIViewController <UITextFieldDelegate> {

	id appDelegate;
    
    bool isVisible;
	
    UIScrollView *scrollView;
    
	IBOutlet UISwitch *switchSound;
	IBOutlet UISwitch *switchOld;

    IBOutlet UILabel *label1;
    IBOutlet UILabel *label2;

}

- (void)notifyForeground;

@property (nonatomic, retain) IBOutlet UIScrollView *scrollView;

@property(nonatomic,retain) IBOutlet UISwitch *switchSound;
@property(nonatomic,retain) IBOutlet UISwitch *switchOld;


@property(nonatomic,retain) IBOutlet UILabel *label1;
@property(nonatomic,retain) IBOutlet UILabel *label2;


@end
