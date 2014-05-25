//
// Created by Jose Gustavo Rodriguez Baldera on 5/25/14.
// Copyright (c) 2014 Jose Gustavo Rodriguez Baldera. All rights reserved.
//

#import "Db.h"
#import "AppDelegate.h"


@implementation Db

+ (NSString *)getDatabasePath
{
    NSString *databasePath = [(AppDelegate *)[[UIApplication sharedApplication] delegate] databasePath];
    return databasePath;
}

@end