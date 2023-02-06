/*
 * CustomWKWebView.h
 * Created by Xingli Chen on 2022-03-29
 * Copyright (C) Xingli. All rights reserved.
 */
    
#import <WebKit/WebKit.h>
#import <UIKit/UIKit.h>

@interface CustomWKWebView : WKWebView <WKNavigationDelegate,WKUIDelegate,NSURLSessionDelegate, WKURLSchemeHandler>

@property (class, nonatomic, copy) NSString *deviceId;

@property(nonatomic, copy) void (^updateSearchBarTextBlock)(NSString*);
@property(nonatomic, copy) void (^finishNavigationProgressBlock)(void);
@property(nonatomic, copy) void (^updateHistoryNumber)(void);
@property(nonatomic, copy) void (^saveHistory)(NSString*);
@property(nonatomic, strong) NSMutableArray* loadedRequests;
@property(nonatomic, readwrite, getter=isLoading) BOOL disableCache;
@property(nonatomic, strong) NSURLCredential *phrontServerCredentials;

@property(nonatomic, strong) NSString *liveAppLocation;
@property(nonatomic, strong) NSString *montageLocation;

@property(nonatomic, strong) NSURLSession *URLSession;

+ (instancetype)sharedContentInstance;
+ (instancetype)sharedBrowserInstance;

+ (NSString *)appleIFA;
+ (NSString *)appleIFV;
+ (NSString *)generateDeviceId;
+ (NSString *)uniqueIdFromKeychain;
+ (NSString *)uniqueIdFromNSUserDefaults;
+ (NSString *)uniqueIdFromArchive;

- (void)initialize;
- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;
- (id)copy NS_UNAVAILABLE;
- (id)mutableCopy NS_UNAVAILABLE;

- (NSURLCredential *)phrontLocalURLCredentialFromURLAuthenticationChallenge: (NSURLAuthenticationChallenge *) challenge;

- (void)loadStageInContentWorld: (WKContentWorld *)contentWorld;
- (void)loadScriptWithPath: (NSString *)path inContentWorld: (WKContentWorld *)contentWorld;
- (void)loadScriptWithSource: (NSString *)source fromPath:(NSString *)path inContentWorld: (WKContentWorld *)contentWorld;

@end
