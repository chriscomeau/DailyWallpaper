//
//  FirstViewController.h
//
//  Created by Chris Comeau on 10-03-18.
//  Copyright Games Montreal 2010. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import "MBProgressHUD.h"
#import "TableViewController.h"
#import "ALAssetsLibrary+CustomPhotoAlbum.h"

@interface FirstViewController : UIViewController <UINavigationBarDelegate, UIScrollViewDelegate, UIActionSheetDelegate, MFMailComposeViewControllerDelegate, MFMessageComposeViewControllerDelegate> {
	
	IBOutlet UIScrollView *imageScrollView;
    UILabel *descriptionLabel;
	UIImageView *imageView;
    UIButton *bingButton;
   	UIButton *lockscreenButton;
    UILabel *labelTip;
    bool showTip;
    NSString *currentId;
    bool isFavorite;
    
	id appDelegate;
    //MBProgressHUD *HUD;
    //bool doHud;
    bool interfaceHidden;
    bool isVertical;
    bool alreadyLongPress;
    bool previewWasInfoHidden;
    
   	UIImageView *darkImage;
    UIActivityIndicatorView *spin;
    id prevNavigationBarDelegate;
    UIAlertView *alertBing;
    ALAssetsLibrary* library;

}

@property(nonatomic,retain) IBOutlet UIButton *bingButton;
@property(nonatomic,retain) IBOutlet UIButton *lockscreenButton;
@property(nonatomic,retain) IBOutlet UILabel *descriptionLabel;
@property(nonatomic,retain) IBOutlet UIImageView *imageView;
@property(nonatomic,retain) IBOutlet UIScrollView *imageScrollView;
@property(nonatomic,retain) IBOutlet UIImageView *darkImage;
@property(nonatomic,retain)  IBOutlet UIActivityIndicatorView *spin;
@property(nonatomic,retain) IBOutlet UILabel *labelTip;
@property(nonatomic,retain) IBOutlet UIButton *buttonFavorite;
@property(nonatomic, assign) BOOL fade;


- (void) saveImage: (UIImage*) image;
- (void)actionSave:(id)sender;
- (void)actionReload:(id)sender;
- (void)toggleInterface;
- (void)showInterface:(BOOL)show;
- (void) setupUI;
- (void)showPreview;
- (void)notifyForeground;
//- (void)hudTask;
//- (void)showHud:(NSString*)text;
- (void) updateImage;
- (void) updateImage2;
-(void)showSpin:(BOOL)show;
@end
