//
//  LQDefaults.h
//  LiquidApp
//
//  Created by Liquid Data Intelligence, S.A. (lqd.io) on 3/28/14.
//  Copyright (c) 2014 Liquid Data Intelligence, S.A. All rights reserved.
//

#import <Foundation/Foundation.h>

#ifndef TARGET_OS_IOS
#define TARGET_OS_IOS TARGET_OS_IPHONE
#endif
#ifndef TARGET_OS_WATCH
#define TARGET_OS_WATCH 0
#endif
#ifndef TARGET_OS_TV
#define TARGET_OS_TV 0
#endif

#define LQ_WATCHOS TARGET_OS_WATCH
#define LQ_IOS TARGET_OS_IOS
#define LQ_TVOS TARGET_OS_TV
#define LQ_INAPP_MESSAGES_SUPPORT LQ_IOS

#define kLQVersion @"2.3.4"

#if LQ_WATCHOS
#define kBundle @"com.phront.watchos"
#else
#define kBundle @"com.phront.ios"
#endif

#define kLQNotificationLQDidReceiveValues @"io.lqd.ios.Notifications:LQDidReceiveValues"
#define kLQNotificationLQDidLoadValues @"io.lqd.ios.Notifications:DidLoadValues"
#define kLQNotificationLQDidIdentifyUser @"io.lqd.ios.Notifications:DidIdentifyUser"

#define kLQLogLevelPaths       9
#define kLQLogLevelHttpData    8
#define kLQLogLevelData        7
#define kLQLogLevelInfoVerbose 6
#define kLQLogLevelHttpError   5
#define kLQLogLevelInfo        4
#define kLQLogLevelError       3
#define kLQLogLevelWarning     2
#define kLQLogLevelDevMode     1
#define kLQLogLevelNone        0

#ifdef DEBUG
#    define kLQLogLevel kLQLogLevelError
#else
#    define kLQLogLevel kLQLogLevelNone
#endif

#define kLQSendFallbackValuesInDevelopmentMode YES
#define kLQEventTrackingModeEnabled NO

#define kLQErrorValueNotFound 1
#define kLQErrorNoUser 2

#define LQLog(level,...) if(level<=kLQLogLevel) NSLog(__VA_ARGS__)

#define INTERFACE_IS_PAD     (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
#define INTERFACE_IS_PHONE   (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
#define SYSTEM_VERSION_EQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define SYSTEM_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)

