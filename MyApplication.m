//
//  MyApplication.m


#import "MyApplication.h"

@implementation MyApplication


-(BOOL)openURL:(NSURL *)url{
    /*if  ([self.delegate openURL:url])
        return YES;
    else
        return [super openURL:url];*/
    
    return [super openURL:url];
}


@end
