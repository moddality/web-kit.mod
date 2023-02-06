/*
 * CustomWKWebView.m
 * Created by Xingli Chen on 2022-03-29
 * Copyright (C) Xingli. All rights reserved.
 */

#import "CustomWKWebView.h"
#import <Foundation/NSURLRequest.h>
#import <WebKit/WKWebsiteDataStore.h>
#import <AdSupport/ASIdentifierManager.h>
#import "Defaults.h"
#import "UserDefaults.h"
#import "FileStorage.h"
#import "KeyChain.h"

@interface CustomWKWebView()

//@property(nonatomic, strong) NSURLSession *URLSession;

@end

@implementation CustomWKWebView

static NSString *_deviceId = nil;
static NSMutableDictionary *_scriptsPendingExecution = nil;

+ (NSMutableDictionary *)scriptsPendingExecution {
    if(_scriptsPendingExecution == nil) {
        _scriptsPendingExecution = [[NSMutableDictionary alloc] init];
    }
    return _scriptsPendingExecution;
}




//+ (id)allocWithZone:(struct _NSZone *)zone
//{
//    static dispatch_once_t onceToken;
//    dispatch_once(&onceToken, ^{
//        contentInstance = [super allocWithZone:zone];
//    });
//    return contentInstance;
//}

#pragma mark - Unique Device Id
/*
    Started from https://github.com/lqd-io/liquid-sdk-ios/
    via https://medium.com/@miguelcma/persistent-cross-install-device-identifier-on-ios-using-keychain-ac9e4f84870f
    with https://medium.com/@silverizen/storing-a-device-id-in-the-keychain-23440c001379
 
 */
+ (NSString *)appleIFA {
    NSString *ifa = nil;
    Class ASIdentifierManagerClass = NSClassFromString(@"ASIdentifierManager");
    if (ASIdentifierManagerClass) { // a dynamic way of checking if AdSupport.framework is available
        SEL sharedManagerSelector = NSSelectorFromString(@"sharedManager");
        id sharedManager = ((id (*)(id, SEL))[ASIdentifierManagerClass methodForSelector:sharedManagerSelector])(ASIdentifierManagerClass, sharedManagerSelector);
        SEL advertisingIdentifierSelector = NSSelectorFromString(@"advertisingIdentifier");
        NSUUID *advertisingIdentifier = ((NSUUID* (*)(id, SEL))[sharedManager methodForSelector:advertisingIdentifierSelector])(sharedManager, advertisingIdentifierSelector);
        ifa = [advertisingIdentifier UUIDString];
    }
    return ifa;
}

+ (NSString *)appleIFV {
    if(NSClassFromString(@"UIDevice") && [UIDevice instancesRespondToSelector:@selector(identifierForVendor)]) {
        // only available in iOS >= 6.0
        return [[UIDevice currentDevice].identifierForVendor UUIDString];
    }
    return nil;
}

+ (NSString *)generateDeviceId {
    NSString *newUid;
    if ((newUid = [[self class] appleIFA])) {
        return newUid;
    }
    if ((newUid = [[self class] appleIFV])) {
        return newUid;
    }
    return [[NSUUID UUID] UUIDString];
}

+ (NSString *)uniqueIdFromKeychain {
    return [Keychain valueForKey:@"deviceId"];
}

+ (NSString *)uniqueIdFromNSUserDefaults {
    NSString *liquidUUIDKey = [NSString stringWithFormat:@"%@.%@", kBundle, @"UUID"];
    return [[NSUserDefaults standardUserDefaults]objectForKey:liquidUUIDKey];
}

+ (NSString *)uniqueIdFromArchive {
    return [[self class] unarchiveUniqueId];
}

+ (BOOL)archiveUniqueId:(NSString *)uniqueId allowUpdate:(BOOL)allowUpdate {
    if (!allowUpdate && [FileStorage fileExists:[self uniqueIdFile]]) {
        return NO;
    }
    NSLog(@"Saving Device UniqueId to disk");
    return [NSKeyedArchiver archiveRootObject:uniqueId toFile:[[self class] uniqueIdFile]];
}

+ (NSString *)unarchiveUniqueId {
    NSString *filePath = [[self class] uniqueIdFile];
    NSString *uniqueId = nil;
    @try {
        id object = [NSKeyedUnarchiver unarchiveObjectWithFile:filePath];
        uniqueId = [object isKindOfClass:[NSString class]] ? object : nil;
        NSLog(@"Loaded Device UID from disk");
    }
    @catch (NSException *exception) {
        NSLog(@"%@: Found invalid Device UID on cache. Destroying it...", [exception name]);
        [FileStorage deleteFileIfExists:filePath error:nil];
    }
    return uniqueId;
}

+ (NSString *)uniqueIdFile {
    return [FileStorage filePathForAllTokensWithExtension:@"device.unique_id"];
}


+ (NSString *)deviceId {
    if(_deviceId == nil ) {
        NSString *deviceId;
        if ((deviceId = [[self class] uniqueIdFromKeychain])) { // 1.
            NSLog(@"Retrieved Device UniqueId from Keychain: %@", deviceId);
            _deviceId = deviceId;
        }
        else if ((deviceId = [[self class] uniqueIdFromArchive])) { // 2.
            NSLog(@"Retrieved Device UniqueId from file: %@", deviceId);
            _deviceId = deviceId;
        }
        else if ((deviceId = [[self class] uniqueIdFromNSUserDefaults])) { // 3.
            NSLog(@"Retrieved Device UniqueId from NSUserDefaults: %@", deviceId);
            _deviceId = deviceId;
        } else {
            NSLog(@"No Device UniqueId found in cache (Keychain, file or NSUserDefaults). Generating a new one: %@", deviceId);
            _deviceId = [[self class] generateDeviceId]; // 4.
            [Keychain setValue:_deviceId forKey:@"device.unique_id" allowUpdate:NO]; // 1.
            [[self class] archiveUniqueId:_deviceId allowUpdate:NO]; // 2.
            [UserDefaults setObject:_deviceId forKey:@"UUID" allowUpdate:NO]; // 3.

        }
    }
    
    return _deviceId;
}

+ (void)setDeviceId {
}

- (instancetype)init
{
//    static dispatch_once_t onceToken;
//    dispatch_once(&onceToken, ^{
//        contentInstance = [super init];
//    });
    self = [super init];
    
    //TO BE ABLE TO DEBUG JS/CSS/HTML CODE
    self.disableCache = YES;
    return self;
//    return contentInstance;
}

//- (nonnull id)copyWithZone:(nullable NSZone *)zone
//{
//  return contentInstance;
//}
//
//- (nonnull id)mutableCopyWithZone:(nullable NSZone *)zone
//{
//  return contentInstance;
//}

- (void)initialize
{
    if (self)
    {
        // why can not be called in - (instancetype)init
        self.navigationDelegate = self;
        self.UIDelegate = self;
        self.allowsBackForwardNavigationGestures = YES;
        self.translatesAutoresizingMaskIntoConstraints = NO;
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.frame = [UIScreen mainScreen].bounds;
        NSData* historyData = [[NSUserDefaults standardUserDefaults] objectForKey:HISTORY];
        self.loadedRequests = [NSMutableArray arrayWithArray:[NSKeyedUnarchiver unarchiveObjectWithData:historyData]];
    }
}

- (void)loadStageInContentWorld: (WKContentWorld *)contentWorld {
    NSString* stagePath = @"live-apps/globalThis/stage-live";
    #if DEBUG
        stagePath = @"live-apps/globalThis/stage-local";
    #endif
    [self loadScriptWithPath: stagePath inContentWorld: contentWorld];

}

- (void)loadScriptWithPath: (NSString *)path inContentWorld: (WKContentWorld *)contentWorld
{
    NSString *fullPath = [[NSBundle mainBundle] pathForResource:path ofType: @"js" inDirectory:nil];
    NSString *source = [NSString stringWithContentsOfFile:fullPath encoding:NSUTF8StringEncoding error:nil];
    
    [self loadScriptWithSource:source fromPath:path inContentWorld:contentWorld];
}

- (void)loadScriptWithSource: (NSString *)source fromPath:(NSString *)path inContentWorld: (WKContentWorld *)contentWorld
{
    if(source != nil) {
        source = [NSString stringWithFormat:@"%@//# sourceURL=%@.js",source,path];
    }
    //# sourceURL=
    WKUserScript *script = [[WKUserScript alloc] initWithSource:source
                                                         injectionTime: WKUserScriptInjectionTimeAtDocumentStart
                                                      forMainFrameOnly:NO
                                                        inContentWorld:contentWorld];
    [self.configuration.userContentController addUserScript: script];
}



- (NSURLSession *)URLSession {
    if(_URLSession == nil) {
        NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
        _URLSession = [NSURLSession sessionWithConfiguration:sessionConfiguration delegate: self delegateQueue:nil];
    }
    return _URLSession;
}

- (NSURLCredential *)phrontLocalURLCredentialFromURLAuthenticationChallenge: (NSURLAuthenticationChallenge *) challenge {
    if([challenge.protectionSpace.host isEqualToString:@"phront.local"]) {
        
        if(!_phrontServerCredentials) {
            _phrontServerCredentials = [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust];
        }
        return _phrontServerCredentials;
    } else {
        return nil;
    }
}

- (void)URLSession:(NSURLSession *)session didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition, NSURLCredential *))completionHandler{
  if([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust]){
    if([challenge.protectionSpace.host isEqualToString:@"phront.local"]){
        completionHandler(NSURLSessionAuthChallengeUseCredential, [self phrontLocalURLCredentialFromURLAuthenticationChallenge: challenge]);
    } else {
        completionHandler(NSURLSessionAuthChallengeCancelAuthenticationChallenge, nil);
    }
  }
}



- (void)webView:(WKWebView *)webView didCommitNavigation:(WKNavigation *)navigation
{
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation
{
}

- (void)removeWebCache {
    
    //    if(self.disableCache) {
    //        NSURLRequest *cacheDisabledRequest = [[NSURLRequest alloc] initWithURL:request.URL cachePolicy:
    //                                              NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:20];
    //        request = cacheDisabledRequest;
    //    }

  if ([[UIDevice currentDevice].systemVersion floatValue] >= 9.0) {
    NSSet *websiteDataTypes= [NSSet setWithArray:@[
                            WKWebsiteDataTypeDiskCache,
                            //WKWebsiteDataTypeOfflineWebApplication
                            WKWebsiteDataTypeMemoryCache,
                            //WKWebsiteDataTypeLocal
                            WKWebsiteDataTypeCookies,
                            //WKWebsiteDataTypeSessionStorage,
                            //WKWebsiteDataTypeIndexedDBDatabases,
                            //WKWebsiteDataTypeWebSQLDatabases
                            ]];
    
    // All kinds of data
    //NSSet *websiteDataTypes = [WKWebsiteDataStore allWebsiteDataTypes];
    NSDate *dateFrom = [NSDate dateWithTimeIntervalSince1970:0];
    [[WKWebsiteDataStore defaultDataStore] removeDataOfTypes:websiteDataTypes modifiedSince:dateFrom completionHandler:^{
      
    }];
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
      
    //get the cache dictionary path and delete it
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSError *error;
    BOOL success = [fileManager removeItemAtPath:documentsPath error:&error];
    NSLog(@"%d",success);
    
  } else {
    //Delete cookies first
    NSHTTPCookie *cookie;
    NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    for (cookie in [storage cookies])
    {
      [storage deleteCookie:cookie];
    }
    
    NSString *libraryDir = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *bundleId = [[[NSBundle mainBundle] infoDictionary]
                objectForKey:@"CFBundleIdentifier"];
    NSString *webkitFolderInLib = [NSString stringWithFormat:@"%@/WebKit",libraryDir];
    NSString *webKitFolderInCaches = [NSString
                     stringWithFormat:@"%@/Caches/%@/WebKit",libraryDir,bundleId];
    NSString *webKitFolderInCachesfs = [NSString
                      stringWithFormat:@"%@/Caches/%@/fsCachedData",libraryDir,bundleId];
    NSError *error;
    /* iOS8. Storage path of 0 WebView cache*/
    [[NSFileManager defaultManager] removeItemAtPath:webKitFolderInCaches error:&error];
    [[NSFileManager defaultManager] removeItemAtPath:webkitFolderInLib error:nil];
    /* iOS7. Storage path of 0 WebView cache*/
    [[NSFileManager defaultManager] removeItemAtPath:webKitFolderInCachesfs error:&error];
    NSString *cookiesFolderPath = [libraryDir stringByAppendingString:@"/Cookies"];
    [[NSFileManager defaultManager] removeItemAtPath:cookiesFolderPath error:&error];
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
  }
    

}

#pragma mark - WKNavigationDelegate Implementation
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    //NSLog (@ "WebView start request");
    if(self.disableCache) {
        [self removeWebCache];
    }
  decisionHandler(WKNavigationActionPolicyAllow);
}


- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation
{
    // TODO: update search bar.
    NSLog (@ "WebView didStartProvisionalNavigation %@", navigation);

}

- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error
{
    // TODO: Update progress
    NSLog (@ "WebView didFailProvisionalNavigation %@ with error: %@", navigation, error);

}

  
- (void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error
{
    NSLog (@ "WebView didFailNavigation %@ with error: %@", navigation, error);
}

- (void)webView:(WKWebView *)webView requestDeviceOrientationAndMotionPermissionForOrigin:(WKSecurityOrigin *)origin initiatedByFrame:(WKFrameInfo *)frame decisionHandler:(void (^)(WKPermissionDecision))decisionHandler
{
    
}

/*
 * To allow the use of manually trusted certificates
 * From: https://developer.apple.com/forums/thread/15610
 *
 */


- (void)webView:(WKWebView *)webView didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential *credential))completionHandler {
    
    NSURLCredential *credentials;
    //https://git.gryphno.de/nephele/haikuwebkit/commit/d1e00bb3e2d55c7fae2ee43031e45c122b92d15e?style=split&whitespace=
    if([challenge.protectionSpace.host isEqualToString:@"phront.local"]){
        credentials = [self phrontLocalURLCredentialFromURLAuthenticationChallenge: challenge];
    } else {
        //NSLog(@"Allow all");
        SecTrustRef serverTrust = challenge.protectionSpace.serverTrust;
        CFDataRef exceptions = SecTrustCopyExceptions (serverTrust);
        SecTrustSetExceptions (serverTrust, exceptions);
        CFRelease (exceptions);
        credentials = [NSURLCredential credentialForTrust:serverTrust];
    }
    completionHandler (NSURLSessionAuthChallengeUseCredential, credentials);
}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler {
    NSHTTPURLResponse *response = (NSHTTPURLResponse *)navigationResponse.response;
    NSDictionary *headers = response.allHeaderFields;

    decisionHandler(WKNavigationResponsePolicyAllow);
}



#pragma mark - WKURLSchemeHandler Implementation

- (void)webView:(WKWebView *)webView
startURLSchemeTask:(id<WKURLSchemeTask>)urlSchemeTask
{
    NSURL *url = urlSchemeTask.request.URL;
    NSString *stringToLoad = url.path;

    if([stringToLoad hasPrefix:@"phront://"]) {
        NSString *urlString = [stringToLoad stringByReplacingOccurrencesOfString:@"phront://" withString: self.liveAppLocation];
        NSURL *actualUrl = [NSURL URLWithString:urlString];
        
        /*
         var data = Data()

         
         let urlResponse = URLResponse(url: localUrl, mimeType: mimeType, expectedContentLength: data.count, textEncodingName: nil)
         let httpResponse = HTTPURLResponse(url: localUrl, statusCode: 200, httpVersion: nil, headerFields: headers)
         if isMediaExtension(pathExtension: url.pathExtension) {
             urlSchemeTask.didReceive(urlResponse)
         } else {
             urlSchemeTask.didReceive(httpResponse!)
         }
         
         urlSchemeTask.didReceive(data)

         */
        
        NSURLRequest *request = [NSURLRequest requestWithURL:actualUrl];
        NSURLSessionDataTask *task = [[self URLSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            if (!error) {
                NSURLResponse *response2 = [[NSURLResponse alloc] initWithURL:url MIMEType:response.MIMEType expectedContentLength:data.length textEncodingName:nil];
                if(error){
                    [urlSchemeTask didFailWithError:error];
                }
                [urlSchemeTask didReceiveResponse:response2];
                [urlSchemeTask didReceiveData:data];
                [urlSchemeTask didFinish];
            }
            else {
                NSLog(@"Error: %@", [error localizedDescription]);
            }
            }];
        [task resume];
    }

}

- (void)webView:(WKWebView *)webView
stopURLSchemeTask:(id<WKURLSchemeTask>)urlSchemeTask
{
    NSLog(@"webView: DUNNO WHAT TO DO HERE TO stopURLSchemeTask");
}


//WKScriptMessageHandlerWithReply
- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message replyHandler:(void (^)(id _Nullable reply, NSString *_Nullable errorMessage))replyHandler {
    
    if([message.name isEqualToString:@"httpRequestDelegate"]) {
        /*
         (lldb) po message.body
         {
             async = 1;
             delegate = "<null>";
             listeners =     {
             };
             method = GET;
             readyState = 0;
             requestHeaders =     {
             };
             responseHeaders =     {
             };
             responseType = text;
             status = 0;
             upload = "<null>";
             url = "phront:///node_modules/bluebird/js/browser/bluebird.min.js";
             withCredentials = 0;
         }
         */
        
        NSString *method = [message.body objectForKey:@"method"];
        if([method isEqualToString:@"GET"]) {
            [self userContentController: userContentController sendGetMessage:message replyHandler:replyHandler];
        } else {
            replyHandler(nil, nil);
        }
        //NSLog(@"userContentController didReceiveScriptMessage %@",message.name);
    } else {
        replyHandler(nil, nil);
    }
}

- (void)userContentController:(WKUserContentController *)userContentController sendGetMessage:(WKScriptMessage *)message replyHandler:(void (^)(id _Nullable reply, NSString *_Nullable errorMessage))replyHandler {
    
    NSString *urlString = [message.body objectForKey:@"url"];
    if([urlString hasPrefix:@"phront://"]) {
        urlString = [urlString stringByReplacingOccurrencesOfString:@"phront://" withString: self.liveAppLocation];
    }
    NSURL *requestURL = [NSURL URLWithString:urlString];
    NSURLRequest *request = [NSURLRequest requestWithURL:requestURL];
    //NSString *factoryDisplayName = [message.body objectForKey:@"factoryDisplayName"];
    
    //__weak __typeof(self) weakSelf = self;

    //NSLog(@">>>>>>>>>>>> Load %@", urlString);

    NSURLSessionDataTask *task = [[self URLSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        //typeof(self) strongSelf = weakSelf;

        if (!error) {
            
            // Option 1 (from answer above):
            NSString *responseText = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            
            /*
                Attempt to eval the files with WKUserScript here vs eval in JS
                BUT BUT BUT
                We can't do this here, as dependencies have to be obtained and evaluated before a module can...
                SO... the only way would be, in montage/core/mr/browser.js     Require.Compiler = function (config) {..}
             
                To be able to invoke tha native side to do so. One hypothesis to be verified is that the passing of the code source via the bridge could cause performance issues. If we'd hold on the sources in the native side until we're ready to eval, then we can make this work
             */

            //NSLog(@"%@", responseText);

//            if([[[response URL] pathExtension] isEqual:@"js"]) {
//
//                if(factoryDisplayName) {
//                    NSLog(@">>>>>>>>>>>> factoryDisplayName %@", factoryDisplayName);
//                    NSString *source = [[NSString alloc] initWithFormat:@"globalThis.%@ = (function %@(require, exports, module, global) {%@//*/\n})\n//# sourceURL=%@",factoryDisplayName, factoryDisplayName, responseText, [[response URL] absoluteString]];
////                    WKUserScript *script = [[WKUserScript alloc] initWithSource:source
////                                                                  //injectionTime: WKUserScriptInjectionTimeAtDocumentStart
////                                                                  injectionTime: WKUserScriptInjectionTimeAtDocumentEnd
////                                                                      forMainFrameOnly:NO
////                                                                        inContentWorld:[WKContentWorld defaultClientWorld]];
//
//                    [[[self class] scriptsPendingExecution] setObject:source forKey:factoryDisplayName];
////                    [[[self class] scriptsPendingExecution] setObject:script forKey:factoryDisplayName];
////                    [strongSelf.configuration.userContentController addUserScript:script];
////                    source = @"WKUserScriptInjected";
//                }
//            }
            
            replyHandler(responseText, nil);
        }
        else {
            NSLog(@"Error: %@", [error localizedDescription]);
            replyHandler(nil, [error localizedDescription]);
        }
        }];
        [task resume];

    
}

- (void)userContentController:(WKUserContentController *)userContentController
      didReceiveScriptMessage:(WKScriptMessage *)message {
//    if([message.name isEqualToString:@"requireCompilerDelegate"]) {
//        NSLog(@">>>>>>>>>>>> requireCompilerDelegate %@",message.body);
////        WKUserScript *script = [[[self class] scriptsPendingExecution] objectForKey:message.body /*factoryDisplayName*/];
//        NSString *source = [[[self class] scriptsPendingExecution] objectForKey:message.body /*factoryDisplayName*/];
//        NSLog(@">>>>>>>>>>>> requireCompilerDelegate %@ source: %@",message.body, source);
//
//        WKUserScript *script = [[WKUserScript alloc] initWithSource:source
//                                                      injectionTime: WKUserScriptInjectionTimeAtDocumentStart
////                                                      injectionTime: WKUserScriptInjectionTimeAtDocumentEnd
//                                                          forMainFrameOnly:NO
//                                                            inContentWorld:[WKContentWorld defaultClientWorld]];
//
//        [self.configuration.userContentController addUserScript:script];
//        [[[self class] scriptsPendingExecution] removeObjectForKey:message.body /*factoryDisplayName*/];
//    }
}


@end
