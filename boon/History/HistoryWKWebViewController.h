/*
 * HistoryWKWebViewController.h
 * Created by Xingli Chen on 2022-03-29
 * Copyright (C) Xingli. All rights reserved.
 */

#import <WebKit/WebKit.h>
#import <UIKit/UIKit.h>

@interface HistoryWKWebViewController : UIViewController

@property(nonatomic, strong) NSMutableArray<WKBackForwardListItem*> *historyList;
@property(nonatomic, copy) void (^loadRequest)(NSURL*);
@property(nonatomic, copy) void (^closeHistoryView)(void);

@end
