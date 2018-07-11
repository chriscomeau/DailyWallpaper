

#import "TableViewController.h"
#import "TableViewCell.h"

#import "BingWallpaperiPhoneAppDelegate.h"
//#import "SHKFacebook.h"
//#import "SHKTwitter.h"
//#import "FlurryAnalytics.h"
#import "UIAlertView+Blocks.h"
#import "AFNetworking.h"
#import "UIImage+Utilities.h"
#import "NSDate+TimeAgo.h"

#import "HapticHelper.h"

@implementation TableViewController

@synthesize operationQueue;

- (void)viewDidLoad {
    
    NSLog(@"%@", @"TableViewController::viewDidLoad");

    [super viewDidLoad];

    numRows = 0;
    
    appDelegate = (BingWallpaperiPhoneAppDelegate *)[[UIApplication sharedApplication] delegate];

    //bring to front    
    self.tableView.rowHeight = CELL_HEIGHT_NORMAL;
    
    self.tableView.scrollsToTop = YES;

    //background    

    //UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"background-green.png"]];
    //self.tableView.backgroundView = imageView;
	
	self.tableView.backgroundColor = [UIColor clearColor];
	self.tableView.opaque = NO;
	self.tableView.backgroundView = nil;
    
        //pull to refresh
    self.refreshControl = [[UIRefreshControl alloc] init];
    self.refreshControl.tintColor = RGBA(52,136,134, 255);
    [self.refreshControl addTarget:self action:@selector(startRefresh) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:self.refreshControl];
    [self.tableView sendSubviewToBack:self.refreshControl];
    
    //operations
    operationQueue = [[NSOperationQueue alloc] init];
    [operationQueue setMaxConcurrentOperationCount:3];
    
    //separator
    if([self.tableView respondsToSelector:@selector(setCellLayoutMarginsFollowReadableWidth:)])
    {
        self.tableView.cellLayoutMarginsFollowReadableWidth = NO;
    }

}

- (void)startRefresh {
    
    //[self.refreshControl endRefreshing];

    //[appDelegate performSelector:@selector(refresh) withObject:nil afterDelay:0.5];
    [appDelegate setupCache:YES];
    
    //reload ad
    [appDelegate performSelector:@selector(updateAd) withObject:nil afterDelay:0.5];

    [appDelegate refresh];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    self.tableView.scrollsToTop = YES;    
}

- (BOOL)scrollViewShouldScrollToTop:(UIScrollView *)scrollView
{
    return YES;
}


//to hide empty cell border, separator
/*- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    if ([self numberOfSectionsInTableView:tableView] == (section+1)){
        return [UIView new];
    }
    return nil;
}*/

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
       
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
    int totalItems = [appDelegate totalItems] ;
    int numArray = [[appDelegate nameArray] count];

    //not ready yet
    if(![appDelegate isDoneLaunching])
    {
        NSLog(@"TableViewController::tableView:numberOfRowsInSection: %d", 0);
        return 0;
    }
    
    if(![appDelegate isOnline])
     {
        NSLog(@"TableViewController::tableView:numberOfRowsInSection: %d", 0);
        return 0;
    }

    int rows = 0;
    
    rows = [[appDelegate nameArray] count];
    
    if(numArray < totalItems || ![appDelegate tableLoaded] )
        rows++; //for load more
    
   
    numRows = rows;
    NSLog(@"TableViewController::tableView:numberOfRowsInSection: %d", rows);
    
    //show no results?
    //[[appDelegate archiveViewController] showNoResults:[appDelegate totalItems] == 0];
    
    return rows;

}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
    TableViewCell *cell = nil;
    TableViewCell *cellMore = nil;
    
    UIImage *cellBackImage = nil;
    if(indexPath.row % 2 != 0) //alternate
        cellBackImage = [appDelegate cellBackImage1];
    else
        cellBackImage = [appDelegate cellBackImage2];
    
    BOOL isMore = NO;
    
    int totalItems = [appDelegate totalItems] ;
    int numArray = (int)[[appDelegate nameArray] count];
    
    if(![appDelegate tableLoaded]) //start with load more
    {
        isMore = YES;
        NSLog(@"TableViewController::cellForRowAtIndexPath: total:%d, row:%d, type=isMore1", totalItems, indexPath.row);

    }
    else if(indexPath.row == numRows-1) //last row
    {
        if(numArray < totalItems) //need to load more
        {
            isMore = YES;
            NSLog(@"TableViewController::cellForRowAtIndexPath: total:%d, row:%d, type=isMore2", totalItems, indexPath.row);
            
            //reload ad, if not 1st row
            if([appDelegate isOnline] && indexPath.row > 0)
                [appDelegate performSelector:@selector(updateAd) withObject:nil afterDelay:0.5];

        }
    }
       
    if(isMore)
    {
       cellMore = [tableView dequeueReusableCellWithIdentifier:@"CellIdentifierMore"];
        
               
        if (cellMore == nil) 
        {
            // Create a temporary UIViewController to instantiate the custom cell.
            UIViewController *temporaryController = [[UIViewController alloc] initWithNibName:@"TableViewCell" bundle:nil];
            // Grab a pointer to the custom cell.
            cellMore = (TableViewCell *)temporaryController.view;
        }
        
        
        //hide all
        cellMore.thumbnailButton.hidden = YES;
        cellMore.textTitle.hidden = YES;
        cellMore.textDesc.hidden = YES;
        //cellMore.textDesc.highlightedTextColor = [UIColor blackColor];

        if(cellMore.spinLoadMore.hidden) //dont re-show, messes up anim
            cellMore.spinLoadMore.hidden = NO;
		
        cellMore.textLoadingMore.hidden = NO;
        cellMore.backImageView.hidden = NO;
        
        cellMore.spinLoadMore.color = RGBA(52,136,134, 255);

        if( [appDelegate isOnline] ) //online
        {
             if(cellMore.spinLoadMore.hidden) //dont re-show, messes up anim
                cellMore.spinLoadMore.hidden = NO;
            
            cellMore.textLoadingMore.hidden = NO;
           
            cellMore.textLoadingMore.text = STR_CELL_LOAGING_MORE;

            UIFont* tempFont = [UIFont fontWithName:@"Century Gothic" size:12];
            [[cellMore textLoadingMore] setFont: tempFont];
            cellMore.textLoadingMore.textColor = RGBA(94, 94, 94, 255); //grey
            cellMore.textLoadingMore.highlightedTextColor = RGBA(94, 94, 94, 255); //grey

            //fx
            cellMore.textLoadingMore.textAlignment = NSTextAlignmentLeft;
            cellMore.textLoadingMore.contentMode = UIViewContentModeTop;

             //wait
            //[NSThread sleepForTimeInterval:2];  
            
            int interval = LOAD_MORE_DELAY_TIME;
            
            //cancel previous, when switching fast between lists
            [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(loadMore2) object:nil]; 
            [self performSelector:@selector(loadMore2) withObject:nil afterDelay:interval];            
            //[appDelegate loadMore];
        }
        else 
        {
            cellMore.spinLoadMore.hidden = YES;
            cellMore.textLoadingMore.hidden = YES;
            
            //offline
            /*
            //highlight, allow click
            //cellMore.selectionStyle = UITableViewCellSelectionStyleGray; 
            cellMore.selectionStyle = UITableViewCellSelectionStyleNone;
            
            cellMore.textLabel.text=@"";
            //cellMore.textLabel.text=@"Offline, please click to try again.";
            //cell.textLabel.textAlignment = NSTextAlignmentCenter;*/

        }
        
        
        [cellMore.backImageView setImage:cellBackImage];
        return cellMore;
        
    }
    
    else 
    {
        //normal cell
        cell = [tableView dequeueReusableCellWithIdentifier:@"TableViewCell"];
        
        if (cell == nil)
        {
            //http://stackoverflow.com/questions/540345/how-do-you-load-custom-uitableviewcells-from-xib-files
            // Create a temporary UIViewController to instantiate the custom cell.
            UIViewController *temporaryController = [[UIViewController alloc] initWithNibName:@"TableViewCell" bundle:nil];
            // Grab a pointer to the custom cell.
            cell = (TableViewCell *)temporaryController.view;
        }
        
        //which cell
        cell.hash = indexPath.row;

        //show all
        cell.thumbnailButton.hidden = YES;
        cell.backImageView.hidden = NO;
        //cell.textTitle.hidden = NO;
        cell.textDesc.hidden = NO;
        
        //spinner
        cell.spinLoadMore.hidden = YES;
        cell.textLoadingMore.hidden = YES;
        
        //no highlight
        //cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.selectionStyle = UITableViewCellSelectionStyleBlue;

        //fonts
        [[cell textTitle] setFont: [UIFont fontWithName:@"CenturyGothic-Bold" size:17] ];
        cell.textTitle.highlightedTextColor = [UIColor blackColor];;
              
        //test array
        @try {
                cell.textTitle.text = [[appDelegate nameArray] objectAtIndex:indexPath.row];
        }
        @catch (NSException *exception) {
            NSLog(@"Caught %@: %@", [exception name], [exception reason]);
        }
        @finally {
            
        }
                
        [[cell textDesc] setFont: [UIFont fontWithName:@"Century Gothic" size:11]];
        cell.textDesc.textColor = RGBA(94, 94, 94, 255); //grey
        cell.textDesc.highlightedTextColor = RGBA(94, 94, 94, 255); //grey
        
        NSString *desc = [[appDelegate descriptionArray] objectAtIndex:indexPath.row];
        cell.textDesc.text = desc;
        //fx
        cell.textDesc.textAlignment = NSTextAlignmentLeft;
        cell.textDesc.contentMode = UIViewContentModeTop;
                
        //back
        cell.backImageView.hidden = FALSE;
        
        //image left
        cell.thumbnailButton.hidden = FALSE;
        
        if (@available(iOS 11.0, *)) {
            cell.thumbnailButton.accessibilityIgnoresInvertColors = YES;
        }


        //- (void)sd_setImageWithURL:(NSURL *)url forState:(UIControlState)state placeholderImage:(UIImage *)placeholder options:(SDWebImageOptions)options completed:(SDWebImageCompletionBlock)completedBlock {
        //typedef void(^SDWebImageCompletionBlock)(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL);

        //cell.thumbnailButton.backgroundColor = [UIColor blueColor];
        
        NSString  *photoURL = [NSString stringWithFormat:URL_API_THUMB, [[appDelegate nameArray] objectAtIndex:indexPath.row]];
        [cell.thumbnailButton sd_setBackgroundImageWithURL:[NSURL URLWithString:photoURL] forState:UIControlStateNormal placeholderImage:[appDelegate missingThumb] options:(SDWebImageHighPriority)
                        completed:^(UIImage *newImage, NSError *error, SDImageCacheType cacheType, NSURL *imageURL)
                      {
                          
                            if(newImage && !error) {
                            
                                if(indexPath.row < [appDelegate imageThumbArray].count)
                                    [[appDelegate imageThumbArray] replaceObjectAtIndex:indexPath.row withObject:newImage];
                                
                                if(indexPath.row < [appDelegate imageDownloadedFlag].count)
                                    [[appDelegate imageDownloadedFlag] replaceObjectAtIndex:indexPath.row withObject:[NSNumber numberWithBool:YES]];
                                
                                if(indexPath.row < [appDelegate imageUpdatedFlag].count)
                                    [[appDelegate imageUpdatedFlag] replaceObjectAtIndex:indexPath.row withObject:[NSNumber numberWithBool:YES]];
                            }
                      }];

        
         //hide
        [cell imageView].hidden = TRUE;
        
        //click on thumb
        [cell.thumbnailButton addTarget:self action:@selector(actionThumbnail:forEvent:) forControlEvents:UIControlEventTouchUpInside];

        //back
        [cell.backImageView setImage:cellBackImage];
        return cell;
        

        //updated
        
        
          //fade? compare images
        //UIImage *oldImage = [[cell thumbnailButton] backgroundImageForState:UIControlStateNormal];
        //if([ [[appDelegate missingThumb] hashString ] isEqualToString:[newThumb hashString]])
        BOOL downloaded = [[[appDelegate imageDownloadedFlag] objectAtIndex:indexPath.row] boolValue];
        if(downloaded)
        {
            //set normal
            UIImage *newThumb = [[appDelegate imageThumbArray] objectAtIndex:indexPath.row];
            
            BOOL updated = NO;
            updated = [[[appDelegate imageUpdatedFlag] objectAtIndex:indexPath.row] boolValue];

            if(updated) {
                //fade
                        [[appDelegate imageUpdatedFlag] replaceObjectAtIndex:indexPath.row withObject:[NSNumber numberWithBool:NO]];
                
                        //dispatch_async(dispatch_get_main_queue(), ^{
                
                
                        //missing
                        //[[cell thumbnailButton] setBackgroundImage:[appDelegate missingThumb]  forState:UIControlStateNormal];
                
                        //set normal
                        //[[cell thumbnailButton] setBackgroundImage:newThumb  forState:UIControlStateNormal];
        
                         //set fade animation
                          dispatch_async(dispatch_get_main_queue(), ^{
                            [UIView transitionWithView:cell.thumbnailButton
                                           duration:0.3f
                                            options:UIViewAnimationOptionTransitionCrossDissolve
                                         animations:^{
                                             [cell.thumbnailButton setImage:newThumb forState:UIControlStateNormal];
                                             
                                         } completion:NULL];
                        });

            }
            else
            {
                //normal
                [[cell thumbnailButton] setBackgroundImage:newThumb  forState:UIControlStateNormal];

            }

        }
        else
        {
                [[cell thumbnailButton] setBackgroundImage:[appDelegate missingThumb]  forState:UIControlStateNormal];

                //get photo
                NSString  *photoURL = [NSString stringWithFormat:URL_API_THUMB, [[appDelegate nameArray] objectAtIndex:indexPath.row]];
                NSLog(@"photoURL: %@", photoURL);
            
                NSURL *datasourceURL = [NSURL URLWithString:photoURL];
                NSURLRequest *request = [NSURLRequest requestWithURL:datasourceURL];
                AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
                
                //__weak UIButton *weakSelf = cell.thumbnailButton;
                [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation* operation, id responseObject){
                    
                         if(cell.thumbnailButton) {
                    
                            NSData* data =  [operation responseData];
                            UIImage *newImage = [[UIImage alloc] initWithData:data];
                            
                            //set image
                            if(indexPath.row < [appDelegate imageUpdatedFlag].count)
                            [[appDelegate imageThumbArray] replaceObjectAtIndex:indexPath.row withObject:newImage];
                            
                            if(indexPath.row < [appDelegate imageDownloadedFlag].count)
                                [[appDelegate imageDownloadedFlag] replaceObjectAtIndex:indexPath.row withObject:[NSNumber numberWithBool:YES]];
                            
                            if(indexPath.row < [appDelegate imageUpdatedFlag].count)
                                [[appDelegate imageUpdatedFlag] replaceObjectAtIndex:indexPath.row withObject:[NSNumber numberWithBool:YES]];

                            //reload
                            //dispatch_async(dispatch_get_main_queue(), ^{
                                //fade blocks?
                                    //[self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
                                    //[self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];

                            //});
                            
                         
                     } else {
                         NSLog(@"weakSelf nil");
                     }
                    
                    
                }failure:^(AFHTTPRequestOperation* operation, NSError* error){
                     //error

                }];
            
                //[operation start];
                [operationQueue addOperation:operation];
        }
        
        
        //hide
        [cell imageView].hidden = TRUE;
        
        //click on thumb
        [cell.thumbnailButton addTarget:self action:@selector(actionThumbnail:forEvent:) forControlEvents:UIControlEventTouchUpInside];

        //click
        [cell.backImageView setImage:cellBackImage];
        return cell;
    }
    
    // Remove seperator inset
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    
    // Prevent the cell from inheriting the Table View's margin settings
    if ([cell respondsToSelector:@selector(setPreservesSuperviewLayoutMargins:)]) {
        [cell setPreservesSuperviewLayoutMargins:NO];
    }
    
    // Explictly set your cell's layout margins
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
    
}


-(void)showScreenshot2:(NSNumber*)number
{   
    //remove highlight
    //[(UITableView*)[self view] deselectRowAtIndexPath: [(UITableView*)[self view] indexPathForSelectedRow ] animated:NO];
    
    [appDelegate selectImage:[number intValue] showView:YES];
    
    //[self showScreenshot: [number intValue]];
}

- (void)showScreenshot:(int)index
{
    //[[appDelegate mainViewController] showScreenshot: index];
}

- (void)actionThumbnail:(id)sender forEvent:(UIEvent *)event
{    
    NSLog(@"TableViewController::actionThumbnail");
    
    UITableView *tempTableView = (UITableView*)[self view];
    
    NSIndexPath *indexPath = 
    [tempTableView indexPathForRowAtPoint:[[[event touchesForView:sender] anyObject] locationInView:tempTableView]];
    
    //[self performSelector:@selector(showScreenshot2:) withObject:[NSNumber numberWithInt:indexPath.row] afterDelay:CLICK_DELAY];
    
    [self performSelector:@selector(showScreenshot2:) withObject:[NSNumber numberWithInt:indexPath.row] afterDelay:0.0];

}


// the user selected a row in the table.
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)newIndexPath 
{
    NSLog(@"TableViewController::didSelectRowAtIndexPath");
    
    //load more
    if(newIndexPath.row == [[appDelegate nameArray] count] )
    {
        
        //online allow manual load more offline
        if( [appDelegate isOnline] ) //online
        {
            //disable click
            return;

        }
        else 
        {
             //remove highlight
             //[(UITableView*)[self view] deselectRowAtIndexPath: [(UITableView*)[self view] indexPathForSelectedRow ] animated:NO];
             
             //start
             [appDelegate loadMore];
                          
             //spin
             UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
             spinner.frame = CGRectMake(0, 0, 24, 24);
             UITableViewCell *cell = [tableView cellForRowAtIndexPath:newIndexPath];
             cell.accessoryView = spinner;
             [spinner startAnimating];

        }
                
    }
    else 
    {
        //sound
        //[appDelegate playSound:SOUND_1];
            
        [appDelegate selectImage:newIndexPath.row showView:YES];

        //deselect
        [tableView deselectRowAtIndexPath:newIndexPath animated:YES];
        
        
        /*
        //skip double-click
        //[appDelegate setSwitching:YES];
        
        //screenshot
        [self performSelector:@selector(showScreenshot2:) withObject:[NSNumber numberWithInt:newIndexPath.row] afterDelay:CLICK_DELAY];
        
        //input
        //self.view.userInteractionEnabled = NO;
         */

    }   
}


- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath: (NSIndexPath *) indexPath 
{    

    BOOL isMore = NO;
    
    int totalItems = [appDelegate totalItems] ;
    int numArray = [[appDelegate nameArray] count];
    

    if(![appDelegate tableLoaded]) //start with load more
    {
        isMore = YES;
    }
    else if(indexPath.row == numRows-1) //last row
    {
        if(numArray < totalItems) //need to load more
        {
            isMore = YES;
        }
        
   }


    if(isMore)
    {
         return CELL_HEIGHT_MORE;
    }
    else 
    {
        return CELL_HEIGHT_NORMAL;
    }

}

- (void)refresh {
    NSLog(@"%@", @"TableViewController::refresh");

    [appDelegate refresh];
    
    //[self stopLoading];
    [self performSelector:@selector(stopLoading) withObject:nil afterDelay:0.0];
}


- (void)loadMore
{
    NSLog(@"%@", @"TableViewController::loadMore");
    
    //[self.refreshControl endRefreshing];
    
    if(USE_ANALYTICS == 1)
	{
        //[FlurryAnalytics logEvent:@"TableViewController::loadMore"];
	}
           
    //empty    
    [appDelegate fillTable];
}

- (void)loadMore2
{
    [self.refreshControl endRefreshing];

    NSLog(@"%@", @"TableViewController::loadMore2");

    [appDelegate loadMore];
}

- (void)dealloc {
    //[super dealloc];
}

//disabled pull to refresh
/*- (void)startLoading
{
    NSLog(@"%@", @"TableViewController::startLoading");

    //[self refresh];
    
     //refresh all rows
    [self.tableView reloadData];
    
}
*/
/*
- (void)stopLoading
{
}
*/

- (void) didReceiveMemoryWarning 
{
	NSLog(@"didReceiveMemoryWarning");
	[super didReceiveMemoryWarning];
}



// Override to support conditional editing of the table view.
// This only needs to be implemented if you are going to be returning NO
// for some items. By default, all items are editable.

- (BOOL) tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    if([appDelegate isDebug])
        return YES;
    else
        return NO;
}


// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        //get id
        NSString *idString = [[appDelegate idArray] objectAtIndex:indexPath.row];

        //add code here for when you hit delete
        if([appDelegate isDebug])
        {
             if(![appDelegate isOnline])
                    return;
            
            RIButtonItem *cancelItem = [RIButtonItem item];
            cancelItem.label = @"Cancel";
            cancelItem.action = ^
            {

            };
            
            RIButtonItem *deleteItem = [RIButtonItem item];
            deleteItem.label = @"Yes";
            deleteItem.action = ^
            {
               
                
                //get list
                NSURL * url_afn = [NSURL URLWithString:[NSString stringWithFormat: URL_API_DELETE, URL_KEY, idString]];
                NSURLRequest *request_afn = [[NSURLRequest alloc] initWithURL:url_afn];
                [AFJSONRequestOperation addAcceptableContentTypes:[NSSet setWithObject:@"text/html"]];
                AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request_afn
                                                                                                    success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON)
                                                     {
                                                        //good
                                                        
                                                        //refresh
                                                        //[appDelegate refresh];

                                                     }
                                                    
                                                    failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON)
                                                     {
                                                         //NSLog(@"Request Failed with Error: %@, %@", error, error.userInfo);
                                                         
                                                         //refresh
                                                        //[appDelegate refresh];
                                                     }];
                
                                            [operation setShouldExecuteAsBackgroundTaskWithExpirationHandler:^{
                                                                    NSLog(@"Request timed out.");
                                            }];
                [operation start];

            };

            [[[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"Delete"]  message:[NSString stringWithFormat:@"Are you sure you want to delete %@?", idString] cancelButtonItem:cancelItem otherButtonItems:deleteItem, nil] show];
        }
    }    
}

@end

