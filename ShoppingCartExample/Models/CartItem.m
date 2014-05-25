//
// Created by Jose Gustavo Rodriguez Baldera on 5/24/14.
// Copyright (c) 2014 Jose Gustavo Rodriguez Baldera. All rights reserved.
//

#import "CartItem.h"
#import "Product.h"


@implementation CartItem

- (id)initWithProduct:(Product *)product
{
    return [self initWithProduct:product andQuantity:1];
}

- (id)initWithProduct:(Product *)product andQuantity:(int)quantity
{
    self = [super init];

    if(self)
    {
        self.product = product;
        self.quantity = quantity;
    }

    return self;
}


@end