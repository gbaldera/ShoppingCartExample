//
//  AppDelegate.h
//  ShoppingCartExample
//
//  Created by Jose Gustavo Rodriguez Baldera on 5/22/14.
//  Copyright (c) 2014 Jose Gustavo Rodriguez Baldera. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) UITabBarController *tabBarController;
@property (nonatomic,strong) NSString *databasePath;

-(void) createAndCheckDatabase;
-(BOOL) addSkipBackupAttributeToItemAtURL;

-(void) setupTabBarItems;
-(void) updateCartTabBadge;

@end