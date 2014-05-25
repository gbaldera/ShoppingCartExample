//
//  Product.m
//  ShoppingCartExample
//
//  Created by Jose Gustavo Rodriguez Baldera on 5/22/14.
//  Copyright (c) 2014 Jose Gustavo Rodriguez Baldera. All rights reserved.
//

#import "FMDatabase.h"
#import "Product.h"
#import "Db.h"


@implementation Product

- (id)initWithId:(int)productid name:(NSString *)name image:(NSString *)image andPrice:(double)price
{
    self = [super init];

    if(self)
    {
        self.id = productid;
        self.name = name;
        self.image = image;
        self.price = price;
    }

    return self;
}

+ (NSMutableArray *)listProducts
{
    NSMutableArray *products = [[NSMutableArray alloc] init];

    FMDatabase *db = [FMDatabase databaseWithPath:[Db getDatabasePath]];

    [db open];

    FMResultSet *results = [db executeQuery:@"SELECT * FROM products"];

    while([results next])
    {
        Product *product = [[Product alloc] init];

        product.id = [results intForColumn:@"id"];
        product.name = [results stringForColumn:@"name"];
        product.image = [results stringForColumn:@"image"];
        product.price = [results doubleForColumn:@"price"];

        [products addObject:product];
    }

    [db close];

    return products;
}


@end