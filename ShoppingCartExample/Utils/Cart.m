//
//  Cart.m
//  ShoppingCartExample
//
//  Created by Jose Gustavo Rodriguez Baldera on 5/22/14.
//  Copyright (c) 2014 Jose Gustavo Rodriguez Baldera. All rights reserved.
//

#import "Cart.h"
#import "FMDatabase.h"
#import "CartItem.h"
#import "Db.h"


@interface Cart()
@end

@implementation Cart

+ (double)totalAmount
{
    double total = 0;

    NSMutableArray *contents = [self contents];

    for(CartItem *item in contents)
    {
        total += (item.product.price * item.quantity);
    }

    return total;
}

+ (int)totalProducts
{
    int total = 0;

    NSMutableArray *contents = [self contents];

    for(CartItem *item in contents)
    {
        total += item.quantity;
    }

    return total;
}

+ (NSMutableArray *)contents
{
    NSMutableArray *content = [[NSMutableArray alloc] init];

    FMDatabase *db = [FMDatabase databaseWithPath:[Db getDatabasePath]];

    [db open];

    FMResultSet *results = [db executeQuery:@"SELECT p.*, c.quantity FROM products p JOIN cart c ON p.id = c.productid"];

    while([results next])
    {
        Product *product = [[Product alloc] init];

        product.id = [results intForColumn:@"id"];
        product.name = [results stringForColumn:@"name"];
        product.image = [results stringForColumn:@"image"];
        product.price = [results doubleForColumn:@"price"];

        CartItem *item = [[CartItem alloc] initWithProduct:product andQuantity:[results intForColumn:@"quantity"]];

        [content addObject:item];
    }

    [db close];

    return content;
}

+ (CartItem *)getProduct:(int)productid
{
    CartItem *item = nil;

    FMDatabase *db = [FMDatabase databaseWithPath:[Db getDatabasePath]];

    [db open];

    FMResultSet *results = [db executeQuery:[NSString stringWithFormat:@"SELECT p.*, c.quantity FROM products p JOIN cart c ON p.id = c.productid where p.id = %d", productid]];

    while([results next])
    {
        Product *product = [[Product alloc] init];

        product.id = [results intForColumn:@"id"];
        product.name = [results stringForColumn:@"name"];
        product.image = [results stringForColumn:@"image"];
        product.price = [results doubleForColumn:@"price"];

        item = [[CartItem alloc] initWithProduct:product andQuantity:[results intForColumn:@"quantity"]];
    }

    [db close];

    return item;
}


+ (BOOL)removeProduct:(Product *)product
{
    FMDatabase *db = [FMDatabase databaseWithPath:[Db getDatabasePath]];
    BOOL success = NO;

    [db open];

    @try
    {
        success = [db executeUpdate:[NSString stringWithFormat:@"DELETE FROM cart where productid = %d", product.id]];
    }
    @catch (NSException *exception)
    {
        NSLog(@"Error: %@", [exception reason]);
    }
    @finally
    {
        [db close];
    }

    return success;
}

+ (BOOL)exists:(Product *)product
{
    CartItem *item = [self getProduct:product.id];
    return item != nil;
}

+ (BOOL)isEmpty
{
    return [self totalProducts] == 0;
}

+ (BOOL)clearCart
{
    FMDatabase *db = [FMDatabase databaseWithPath:[Db getDatabasePath]];
    BOOL success = NO;

    [db open];

    @try
    {
        success = [db executeUpdate:@"DELETE FROM cart"];
    }
    @catch (NSException *exception)
    {
        NSLog(@"Error: %@", [exception reason]);
    }
    @finally
    {
        [db close];
    }

    return success;
}

+ (BOOL)addProduct:(Product *)product
{
    return [self addProduct:product quantity:1];
}

+ (BOOL)addProduct:(Product *)product quantity:(int)quantity
{
    FMDatabase *db = [FMDatabase databaseWithPath:[Db getDatabasePath]];
    BOOL success = NO;

    [db open];

    @try
    {
        CartItem *item = [self getProduct:product.id];
        success = item ?
                [db executeUpdate:[NSString stringWithFormat:@"UPDATE cart set quantity = %d where productid = %d", quantity + item.quantity, product.id]] :
                [db executeUpdate:[NSString stringWithFormat:@"INSERT INTO cart (productid,quantity) VALUES (%d,%d)", product.id, quantity]];
    }
    @catch (NSException *exception)
    {
        NSLog(@"Error: %@", [exception reason]);
    }
    @finally
    {
        [db close];
    }

    return success;
}


@end