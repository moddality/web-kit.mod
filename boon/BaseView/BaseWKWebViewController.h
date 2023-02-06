/*
 * BaseWKWebViewController.h
 * Created by Xingli Chen on 2022-03-29
 * Copyright (C) Xingli. All rights reserved.
 */

#import "CustomSearchBar.h"
#import "CustomWKWebView.h"
#import "HistoryWKWebViewController.h"
#import "MyHelper.h"

@interface BaseWKWebViewController : UIViewController<UISearchBarDelegate,UISearchControllerDelegate>

@property(nonatomic, strong) UIProgressView *progressView;
@property(nonatomic, strong) CustomSearchBar* searchBar;

@end
