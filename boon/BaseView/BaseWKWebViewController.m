/*
 * BaseWKWebViewController.m
 * Created by Xingli Chen on 2022-03-29
 * Copyright (C) Xingli. All rights reserved.
 */
    
#import "BaseWKWebViewController.h"

@implementation BaseWKWebViewController

- (void)loadView
{
    [super loadView];
    [self addSearchBar];
    [self addProgressBar];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

#pragma mark - Private Methods

- (void)addSearchBar
{
    if (self.searchBar == nil)
    {
        self.searchBar = [CustomSearchBar new];
        // Can not be displayed when put it in self.navigationController.navigationItem.titleView.
        self.navigationItem.titleView = self.searchBar;
        self.navigationController.navigationBar.translucent = YES;
    }
}

- (void)addProgressBar
{
    self.progressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
    [self.progressView setTrackTintColor:[UIColor colorWithWhite:1.0f alpha:0.0f]];
    [self.progressView setFrame:CGRectMake(0, self.navigationController.navigationBar.frame.size.height - self.progressView.frame.size.height, self.view.frame.size.width, self.progressView.frame.size.height)];
    [self.progressView setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin];
    [self.navigationController.navigationBar addSubview:self.progressView];
}

@end
