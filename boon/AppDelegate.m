//
/*
 * AppDelegate.m
 * Created by Xingli Chen on 2022-03-29
 * Copyright (C) Xingli. All rights reserved.
 */
    

#import "AppDelegate.h"
#import "TapBars/CustomWKWebViewController.h"
#import <WebKit/WKContentWorld.h>
#import <WebKit/WKUserScript.h>
#import <Foundation/NSBundle.h>
#import <Foundation/NSString.h>
#import <Foundation/NSURL.h>
#import <Foundation/NSURLRequest.h>
#import <Foundation/NSURLSession.h>

@interface AppDelegate () <UITabBarControllerDelegate>

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    CustomWKWebViewController *customWebviewController = [[CustomWKWebViewController alloc] init];

    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:customWebviewController];
    
    self.window.rootViewController = navigationController;
    self.window.backgroundColor = UIColor.whiteColor;
    [self.window makeKeyAndVisible];
    

    

    
    return YES;
}


@end
