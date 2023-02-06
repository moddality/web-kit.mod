/*
 * HistoryWKWebViewController.m
 * Created by Xingli Chen on 2022-03-29
 * Copyright (C) Xingli. All rights reserved.
 */

#import "HistoryWKWebViewController.h"
#import "CustomWKWebView.h"

@interface  HistoryWKWebViewController()<UITableViewDelegate,UITableViewDataSource>

@property (strong, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation HistoryWKWebViewController

-(void)viewDidLoad
{
    [super viewDidLoad];
    //tableView
    _tableView.dataSource = self;
    _tableView.delegate = self;
}

#pragma mark - Private

- (UIView*)headerView
{
    UIView* view = [[UIView alloc] init];
    UIButton* homeButton = [UIButton buttonWithType:UIButtonTypeContactAdd];
    [homeButton addTarget:self action:@selector(backHome:) forControlEvents:UIControlEventTouchUpInside];
    homeButton.translatesAutoresizingMaskIntoConstraints = NO;
    UIButton* closeButton = [UIButton buttonWithType:UIButtonTypeClose];
    [closeButton addTarget:self action:@selector(closeView:) forControlEvents:UIControlEventTouchUpInside];
    closeButton.translatesAutoresizingMaskIntoConstraints = NO;
    UILabel* title = [[UILabel alloc] init];
    title.text = NSLocalizedString(@"History_title", nil);
    title.translatesAutoresizingMaskIntoConstraints = NO;
    title.textAlignment = NSTextAlignmentCenter;
    [view addSubview:homeButton];
    [view addSubview:closeButton];
    [view addSubview:title];
    [homeButton.leadingAnchor constraintEqualToAnchor:view.leadingAnchor constant:15.0].active = YES;
    [homeButton.centerYAnchor constraintEqualToAnchor:view.centerYAnchor].active = YES;
    [homeButton.bottomAnchor constraintEqualToAnchor:view.bottomAnchor constant:-10.0].active = YES;
    [closeButton.trailingAnchor constraintEqualToAnchor:view.trailingAnchor constant:-15.0].active = YES;
    [closeButton.centerYAnchor constraintEqualToAnchor:view.centerYAnchor].active = YES;
    [title.centerXAnchor constraintEqualToAnchor:view.centerXAnchor].active = YES;
    [title.centerYAnchor constraintEqualToAnchor:view.centerYAnchor].active = YES;
    return view;
}

#pragma mark - Actions

- (void)backHome:(id)sender
{
    self.loadRequest(nil);
}

- (void)closeView:(id)sender
{
    self.closeHistoryView();
}

#pragma mark - UITableViewDelegate

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    static NSString* identifier = @"cellIdentifier";
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
    }
    if (indexPath.row == 0)
    {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    WKBackForwardListItem* item = self.historyList[indexPath.row];
    NSString* title = [item.title stringByReplacingOccurrencesOfString:@"Search" withString:@"Bing"];
    cell.textLabel.text = title;
    cell.detailTextLabel.text = item.URL.absoluteString;
    return cell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.historyList.count;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // When click ,load the url.
    self.loadRequest(self.historyList[indexPath.row].URL);
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    return [self headerView];
}
@end
