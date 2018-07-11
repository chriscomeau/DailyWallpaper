//
//  IAPHelper.h
//  BingWallpaperiPhone
//
//  Created by Chris Comeau on 3/24/13.
//
//

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>

typedef void (^RequestProductsCompletionHandler)(BOOL success, NSArray * products);

UIKIT_EXTERN NSString *const IAPHelperProductPurchasedNotification;

@interface IAPHelper : NSObject <SKProductsRequestDelegate, SKPaymentTransactionObserver>

- (id)initWithProductIdentifiers:(NSSet *)productIdentifiers;
- (void)requestProductsWithCompletionHandler:(RequestProductsCompletionHandler)completionHandler;
- (void)buyProduct:(SKProduct *)product;
- (BOOL)productPurchased:(NSString *)productIdentifier;
- (void)restoreCompletedTransactions;

@end

