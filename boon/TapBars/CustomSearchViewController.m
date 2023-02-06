/*
 * CustomSearchViewController.m
 * Created by Xingli Chen on 2022-03-29
 * Copyright (C) Xingli. All rights reserved.
 */
    
#import "CustomSearchViewController.h"
#import "ShareViewController.h"
#import "CustomSearchBar.h"

@interface CustomSearchViewController()

@end

@implementation CustomSearchViewController

- (void)loadView
{
    self.obscuresBackgroundDuringPresentation = NO;
    self.hidesNavigationBarDuringPresentation = NO;
    self.dimsBackgroundDuringPresentation = NO;
    self.definesPresentationContext = YES;
    self.searchBar.delegate = self;
    self.searchBar.tintColor = UIColor.redColor;
    self.searchBar.showsBookmarkButton = YES;
    self.searchBar.searchBarStyle = UISearchBarStyleProminent;
    [self.searchBar setImage:[UIImage systemImageNamed:@"refresh"] forSearchBarIcon:UISearchBarIconBookmark state:UIControlStateNormal];
}

- (void)didPresentSearchController:(UISearchController *)searchController
{
    self.searchBar.showsBookmarkButton = YES;
}

- (void)didDismissSearchController:(UISearchController *)searchController
{
    self.searchBar.showsBookmarkButton = NO;
}

@end
