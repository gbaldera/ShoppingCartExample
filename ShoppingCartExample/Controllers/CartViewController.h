//
//  CartViewController.h
//  ShoppingCartExample
//
//  Created by Jose Gustavo Rodriguez Baldera on 6/1/14.
//  Copyright (c) 2014 Jose Gustavo Rodriguez Baldera. All rights reserved.
//

#import "PayPalPaymentViewController.h"

@interface CartViewController : UITableViewController<PayPalPaymentDelegate>
- (instancetype)initWithCoder:(NSCoder *)aDecoder;
- (void)loadItems;
@end
