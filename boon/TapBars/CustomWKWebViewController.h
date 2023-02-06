/*
 * CustomWKWebViewController.h
 * Created by Xingli Chen on 2022-03-29
 * Copyright (C) Xingli. All rights reserved.
 */

#import "BaseWKWebViewController.h"
#import "../BaseView/CustomWKWebView.h"
#import "BrowserWKWebView.h"
#import "ContentWKWebView.h"

@interface CustomWKWebViewController : BaseWKWebViewController

//@property(nonatomic, strong) WKUserScript *_montageUserScript;

- (ContentWKWebView *)wkWebView;
- (BrowserWKWebView *)browserWebView;

@end
