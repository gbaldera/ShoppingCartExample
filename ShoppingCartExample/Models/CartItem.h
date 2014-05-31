//
// Created by Jose Gustavo Rodriguez Baldera on 5/24/14.
// Copyright (c) 2014 Jose Gustavo Rodriguez Baldera. All rights reserved.
//

@class Product;


@interface CartItem : NSObject
@property (strong, nonatomic) Product *product;
@property (assign, nonatomic) int quantity;

- (id)initWithProduct:(Product *)product;
- (id)initWithProduct:(Product *)product andQuantity:(int)quantity;
@end