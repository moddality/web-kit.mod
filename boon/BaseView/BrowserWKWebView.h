//
//  CustomWKWebView+ContentWKWebView_m.h
//  boon
//
//  Created by Benoit Marchant on 10/4/22.
//

#import <WebKit/WebKit.h>
#import <UIKit/UIKit.h>
#import "CustomWKWebView.h"
#import "ContentWKWebView.h"

@interface BrowserWKWebView : CustomWKWebView <WKNavigationDelegate,WKUIDelegate,NSURLSessionDelegate, WKURLSchemeHandler>

@property(nonatomic, strong) ContentWKWebView *contentWebView;

@end

