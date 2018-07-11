//
//  TableViewCell.m
//  Skyriser


#import "TableViewCell.h"
#import "BingWallpaperiPhoneAppDelegate.h"

@implementation TableViewCell

@synthesize backImageView;
@synthesize textTitle;
@synthesize textDesc;
@synthesize spinLoadMore;
@synthesize textLoadingMore;
@synthesize thumbnailButton;

@synthesize indexPathInTableView;
@synthesize activeDownload;
@synthesize imageConnection;
@synthesize hash;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        hash = 0;
    }
    
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

}


- (void)prepareForReuse
{
    [super prepareForReuse];
    //self.myImage.image = nil;
    
    [self.thumbnailButton setImage:[kAppDelegate missingThumb] forState:UIControlStateNormal];

}


@end
