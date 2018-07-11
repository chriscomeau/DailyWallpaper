//
//  SideMenuViewController.h
//  Skyriser

#import <UIKit/UIKit.h>


@interface SideMenuViewController : UIViewController <UIActionSheetDelegate>
{
    id appDelegate;

    UIButton *buttonLatest;
    UIButton *buttonPopular;
    UIButton *buttonRandom;
    UIButton *buttonFavorites;
    UIButton *buttonAd;
    UIButton *buttonCoinyBlock;

    UIImageView *checkLatest;
    UIImageView *checkPopular;
    UIImageView *checkRandom;
    UIImageView *checkFavorites;
    UIImageView *checkAd;

    UILabel *labelSort;
    
    UIButton *buttonRight;
    
    UIImageView *shadow;
    UIImageView *screenshot;
    
    UIAlertView *alertRemoveAd;

}

@property(nonatomic,retain)  IBOutlet UILabel *labelSort;
@property(nonatomic,retain)  IBOutlet UILabel *labeCoinyBlock;
@property(nonatomic,retain)  IBOutlet UIButton *buttonLatest;
@property(nonatomic,retain)  IBOutlet UIButton *buttonPopular;
@property(nonatomic,retain)  IBOutlet UIButton *buttonRandom;
@property(nonatomic,retain)  IBOutlet UIButton *buttonFavorites;
@property(nonatomic,retain)  IBOutlet UIButton *buttonAd;
@property(nonatomic,retain)  IBOutlet UIButton *buttonCoinyBlock;

@property(nonatomic,retain)  IBOutlet UIButton *buttonRight;

@property(nonatomic,retain)  IBOutlet UIImageView *shadow;
@property(nonatomic,retain)  IBOutlet UIImageView *screenshot;

@property(nonatomic,retain)  IBOutlet UIImageView *checkLatest;
@property(nonatomic,retain)  IBOutlet UIImageView *checkPopular;
@property(nonatomic,retain)  IBOutlet UIImageView *checkRandom;
@property(nonatomic,retain)  IBOutlet UIImageView *checkFavorites;
@property(nonatomic,retain)  IBOutlet UIImageView *checkAd;

-(void)setupShadow:(int)x;
-(void)updateShadow:(int)x;
-(void)updateCheckmarks;

@end
