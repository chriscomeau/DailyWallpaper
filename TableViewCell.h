//
//  TableViewCell.h
//  Skyriser
//

#import <UIKit/UIKit.h>

@interface TableViewCell : UITableViewCell
{
    id appDelegate;
    UIImageView *backImageView;

    UIButton *thumbnailButton;
    
    UILabel *textTitle;
    UILabel *textDesc;
    
    UILabel *textLoadingMore;
    UIActivityIndicatorView *spinLoadMore;
    
    //async
    NSIndexPath *indexPathInTableView;    
    NSMutableData *activeDownload;
    NSURLConnection *imageConnection;
    
}
@property (assign, nonatomic) int hash;

@property(nonatomic,retain)  IBOutlet UIButton *thumbnailButton;
@property(nonatomic,retain)  IBOutlet UIImageView *backImageView;
@property(nonatomic,retain)  IBOutlet UILabel *textTitle;
@property(nonatomic,retain)  IBOutlet UILabel *textDesc; 
@property(nonatomic,retain)  IBOutlet UILabel *textLoadingMore; 
@property(nonatomic,retain)  IBOutlet UIActivityIndicatorView *spinLoadMore;

@property (nonatomic, retain) NSIndexPath *indexPathInTableView;
@property (nonatomic, retain) NSMutableData *activeDownload;
@property (nonatomic, retain) NSURLConnection *imageConnection;

@end
