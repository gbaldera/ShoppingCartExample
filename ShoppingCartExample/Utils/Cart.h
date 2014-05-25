//
//  Cart.h
//  ShoppingCartExample
//
//  Created by Jose Gustavo Rodriguez Baldera on 5/22/14.
//  Copyright (c) 2014 Jose Gustavo Rodriguez Baldera. All rights reserved.
//

#import "Product.h"

@class CartItem;

@interface Cart : NSObject
+(double)totalAmount;
+(int)totalProducts;
+(NSMutableArray *)contents;
+(CartItem *)getProduct:(int)productid;
+(BOOL)removeProduct:(Product *)product;
+(BOOL)addProduct:(Product *)product;
+(BOOL)addProduct:(Product *)product quantity:(int) quantity;
+(BOOL)exists:(Product *)product;
+(BOOL)isEmpty;
+(BOOL)clearCart;
@end