//
//  AppDelegate.m
//  ShoppingCartExample
//
//  Created by Jose Gustavo Rodriguez Baldera on 5/22/14.
//  Copyright (c) 2014 Jose Gustavo Rodriguez Baldera. All rights reserved.
//

#import "AppDelegate.h"
#import "ProductsViewController.h"
#import "Cart.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];

    // Database setup
    NSString *documentDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    self.databasePath = [documentDir stringByAppendingPathComponent:kDatabaseName];

    [self createAndCheckDatabase];

    // Override point for customization after application launch.
    UINavigationController *productsViewController = [[UINavigationController alloc]
            initWithRootViewController:[[ProductsViewController alloc] init]];
    NSArray *tabControllers = [NSArray arrayWithObjects:productsViewController, nil];

    self.tabBarController = [[UITabBarController alloc]init];
    self.tabBarController.viewControllers = tabControllers;
    [self.tabBarController setSelectedIndex:0];

    self.window.rootViewController = self.tabBarController;

    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.

}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.

}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.

}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.

}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.

}

#pragma mark Database utilities methods

-(void) createAndCheckDatabase
{
    BOOL success;

    NSFileManager *fileManager = [NSFileManager defaultManager];
    success = [fileManager fileExistsAtPath:self.databasePath];

    if(success) return;

    NSString *databasePathFromApp = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:kDatabaseName];

    if([fileManager copyItemAtPath:databasePathFromApp toPath:self.databasePath error:nil]){
        [self addSkipBackupAttributeToItemAtURL]; // Prevent iCloud sync for the db file
    }
}

- (BOOL)addSkipBackupAttributeToItemAtURL
{
    NSURL *URL = [[NSURL alloc] initFileURLWithPath:self.databasePath];

    NSError *error = nil;
    BOOL success = [URL setResourceValue: [NSNumber numberWithBool: YES]
                                  forKey: NSURLIsExcludedFromBackupKey error: &error];
    if(!success){
        NSLog(@"Error excluding %@ from backup %@", [URL lastPathComponent], error);
    }
    return success;
}

- (void)updateCartTabBadge
{
    int total = [Cart totalProducts];
    UITabBarItem *cartTab = [self.tabBarController.tabBar.items objectAtIndex:0];

    if(total == 0)
        cartTab.badgeValue = nil;
    else
        cartTab.badgeValue = [NSString stringWithFormat:@"%d", total];
}


@end