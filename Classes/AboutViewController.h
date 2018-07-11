//
//  AboutViewController.h
//
//  Created by Chris Comeau on 10-02-12.
//  Copyright 2010 Games Montreal. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BingWallpaperiPhoneAppDelegate.h"
#import "MBProgressHUD.h"

@interface AboutViewController : UIViewController  <MBProgressHUDDelegate, MFMailComposeViewControllerDelegate, UIActionSheetDelegate, MFMessageComposeViewControllerDelegate, UIActionSheetDelegate> {

	IBOutlet UIButton *buttonMore;
	IBOutlet UIButton *buttonHome;
	IBOutlet UIButton *buttonFacebook;
	IBOutlet UIButton *buttonTwitter;
	IBOutlet UIButton *buttonIcon;
	IBOutlet UIButton *buttonEmail;
    IBOutlet UIButton *buttonVersion;
    IBOutlet UIImageView *imageViewQR;
    IBOutlet UIButton *buttonQR;
    IBOutlet UIImageView *imageViewBadge;
    IBOutlet UIImageView *imageViewTwitter;
    IBOutlet UIButton *buttonNoAds;

	IBOutlet UITextView *versionText;
	IBOutlet UITextView *appNameText;
	IBOutlet UITextView *copyrighText;
	IBOutlet UITextView *twitterText;
	IBOutlet UITextView *badgeText;

	IBOutlet UIButton *helpButton;
	IBOutlet UIButton *creditsButton;
	IBOutlet UIButton *shareButton;
	IBOutlet UIButton *rateButton;
	IBOutlet UIButton *restoreButton;
    IBOutlet UIButton *buttonStars;

    
    UIActionSheet *actionSheetShare;
    UIActionSheet *actionSheetTwitter;
    UIActionSheet *actionSheetContact;
    NSMutableArray  *arrayTwitterClients;
    
    UIAlertView *alertEmail;
    UIAlertView *alertBing;
    
    UIButton *bingButton;

	BOOL rotating;
    id appDelegate;
    UIDeviceOrientation currentOrientation;
    
    MBProgressHUD *HUD;
    bool doHud;
}

@property(nonatomic,retain) IBOutlet UIButton *buttonHome;
@property(nonatomic,retain) IBOutlet UIImageView *imageHome;
@property(nonatomic,retain) IBOutlet UIButton *buttonFacebook;
@property(nonatomic,retain) IBOutlet UIButton *buttonTwitter;
@property(nonatomic,retain) IBOutlet UIButton *buttonIcon;
@property(nonatomic,retain) IBOutlet UIButton *buttonVersion;
@property(nonatomic,retain) IBOutlet UIButton *buttonMore;
@property(nonatomic,retain) IBOutlet UIButton *buttonEmail;
@property(nonatomic,retain) IBOutlet UIButton *helpButton;
@property(nonatomic,retain) IBOutlet UIButton *creditsButton;
@property(nonatomic,retain) IBOutlet UIButton *shareButton;
@property(nonatomic,retain) IBOutlet UIButton *rateButton;
@property(nonatomic,retain) IBOutlet UIButton *restoreButton;
@property(nonatomic,retain) IBOutlet UIButton *buttonStars;
@property(nonatomic,retain) IBOutlet UIButton *bingButton;
@property(nonatomic,retain) IBOutlet UIImageView *imageViewQR;
@property(nonatomic,retain) IBOutlet UIButton *buttonQR;
@property(nonatomic,retain) IBOutlet UIButton *buttonNoAds;
@property(nonatomic,retain) IBOutlet UIImageView *imageViewBadge;
@property(nonatomic,retain) IBOutlet UIImageView *imageViewTwitter;
@property(nonatomic,retain) IBOutlet UITextView *versionText;
@property(nonatomic,retain) IBOutlet UITextView *appNameText;
@property(nonatomic,retain) IBOutlet UITextView *badgeText;
@property(nonatomic,retain) IBOutlet UITextView *copyrighText;
@property(nonatomic,retain) IBOutlet UITextView *twitterText;
@property(nonatomic,retain)  MBProgressHUD *HUD;

- (void)showHud:(NSString*)label;
- (void)hudTask;

@end
