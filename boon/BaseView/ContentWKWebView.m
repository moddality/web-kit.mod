//
//  ContentWKWebView.m
//  boon
//
//  Created by Benoit Marchant on 10/4/22.
//

#import <Foundation/Foundation.h>
#import "ContentWKWebView.h"
#import <Foundation/NSURLRequest.h>
#import <WebKit/WKWebsiteDataStore.h>
#import <AdSupport/ASIdentifierManager.h>
#import "Defaults.h"
#import "UserDefaults.h"
#import "FileStorage.h"
#import "KeyChain.h"

@interface ContentWKWebView()
@property(nonatomic, strong) WKUserScript *montageUserScript;
@end

static ContentWKWebView  *contentInstance = nil;

@implementation ContentWKWebView

+ (instancetype)sharedContentInstance
{
    if(contentInstance == nil) {
        contentInstance =  [[self alloc] init];
    }
    return contentInstance;
}

- (void)loadMontageUserScriptWithCompletionBlock:(void(^)(WKUserScript *value))completionBlock
{
    if(_montageUserScript == nil) {
        //Injecting montage in
//        NSLog(@"%@",[[NSBundle mainBundle] bundlePath]);
        NSString *montageScriptSourcePath1 = [[NSBundle mainBundle] pathForResource:@"montage" ofType: @"js" inDirectory:@"live-apps/boon/node_modules/montage"];
        NSString *montageScriptSourcePath2 = [[NSBundle mainBundle] pathForResource:@"Info" ofType: @"plist" inDirectory:nil];
        NSString *montageScriptSourcePath = [[NSBundle mainBundle] pathForResource:@"montage" ofType: @"js" inDirectory:@"WKWebViewBrowser/live-apps/boon/node_modules/montage"];
        NSString *montageScriptSource = [NSString stringWithContentsOfFile:montageScriptSourcePath encoding:NSUTF8StringEncoding error:nil];
        
        WKContentWorld *defaultClientWorld = [WKContentWorld defaultClientWorld];
        NSURL *montageScriptURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@node_modules/montage/montage.js",self.liveAppLocation]];
        
        
//        WKUserScript *montageLocationScript = [[WKUserScript alloc] initWithSource:[NSString stringWithFormat:@"globalThis.montageLocation = \"%@\";",self.montageLocation]
//                                                             injectionTime: WKUserScriptInjectionTimeAtDocumentStart
//                                                          forMainFrameOnly:NO
//                                                            inContentWorld:defaultClientWorld];
//        [self.configuration.userContentController addUserScript: montageLocationScript];

        
        
        //    NSURL *montageScriptURL = [NSURL URLWithString:@"https://d2c4o2204gsnpi.cloudfront.net/f489beb/index.html.bundle-0.js"];
        NSURLRequest *request = [NSURLRequest requestWithURL:montageScriptURL];
        __weak __typeof(self) weakSelf = self;
        NSURLSessionDataTask *task = [[self URLSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            typeof(self) strongSelf = weakSelf;

            if (!error) {
                // Option 1 (from answer above):
                NSString *montageScriptSource = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                //NSLog(@"%@", montageScriptSource);
                
                WKUserScript *montageScript = [[WKUserScript alloc] initWithSource:montageScriptSource
                                                                     injectionTime: WKUserScriptInjectionTimeAtDocumentStart
                                                                  forMainFrameOnly:NO
                                                                    inContentWorld:defaultClientWorld];
                strongSelf.montageUserScript = montageScript;
                [strongSelf.configuration.userContentController addUserScript:montageScript];
                completionBlock(montageScript);
                                
                
                // Option 2 (if getting JSON data)
                //            NSError *jsonError = nil;
                //            NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&jsonError];
                //            NSLog(@"%@", dictionary);
            }
            else {
                NSLog(@"Error: %@", [error localizedDescription]);
            }
            }];
            [task resume];
    }  else {
        completionBlock(_montageUserScript);
    }
}

- (WKNavigation*)loadRequest:(NSURLRequest*)request
{
    //This is where it should be the most natural to load montage in the de default
    [self loadMontageUserScriptWithCompletionBlock:^(WKUserScript *montageUserScript) {
        NSLog(@"montageUserScript loaded?");
    }];
    NSString *urlText = nil;
    if (request && request.URL) {
        urlText = request.URL.absoluteString;
    }
        
//    NSLog(@"loadRequest: %@ updateSearchBarTextBlock %@", self, urlText);
    self.updateSearchBarTextBlock(urlText);
    return [super loadRequest:request];
}

- (void)webView:(WKWebView *)webView didCommitNavigation:(WKNavigation *)navigation
{
    self.updateSearchBarTextBlock(self.URL.absoluteString);
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation
{
    // Latest is first.
    for (WKBackForwardListItem* item in self.loadedRequests)
    {
        if ([item.URL.absoluteString isEqualToString:self.URL.absoluteString])
        {
            [self.loadedRequests removeObject:item];
            break;
        }
    }
    [self.loadedRequests insertObject:self.backForwardList.currentItem atIndex:0];
    
    self.updateSearchBarTextBlock(self.URL.absoluteString);
    self.finishNavigationProgressBlock();
    self.updateHistoryNumber();
}

@end
