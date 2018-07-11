//
//  QRViewController.h
//
//  Created by Chris Comeau on 10-02-15.
//  Copyright 2010 Games Montreal. All rights reserved.
//

#import <UIKit/UIKit.h>

//#import "BingWallpaperiPhoneAppDelegate.h"

@interface QRViewController : UIViewController 
{
	id appDelegate;
	IBOutlet UIButton *doneButton;
    IBOutlet UITextView *textView;
    IBOutlet UIImageView *imageViewQR;
    IBOutlet UITextView *appTextView;
    IBOutlet UIButton *appImageButton;
    IBOutlet UIButton *appTextButton;


}

@property(nonatomic,retain) IBOutlet UIButton *doneButton;
@property(nonatomic,retain) IBOutlet UITextView *textView;
@property(nonatomic,retain) IBOutlet UIImageView *imageViewQR;
@property(nonatomic,retain) IBOutlet UITextView *appTextView;
@property(nonatomic,retain) IBOutlet UIButton *appImageButton;
@property(nonatomic,retain) IBOutlet UIButton *appTextButton;

@end
