/*
 * CustomSearchBar.m
 * Created by Xingli Chen on 2022-03-28
 * Copyright (C) Xingli. All rights reserved.
 */

#import "CustomSearchBar.h"
#import "MyHelper.h"
#import "ContentWKWebView.h"

@implementation CustomSearchBar

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        self.delegate = self;
        self.searchBarStyle = UISearchBarStyleProminent;
        self.autocapitalizationType = UITextAutocapitalizationTypeNone;
        self.autocorrectionType = UITextAutocorrectionTypeYes;
        self.showsBookmarkButton = YES;
        if (@available(iOS 13.0, *)) {
            // Why not work for bookmark in iOS 15.0.
            [self setImage:[UIImage systemImageNamed:@"refresh"] forSearchBarIcon:UISearchBarIconBookmark state:UIControlStateNormal|UIControlStateSelected|UIControlStateHighlighted];
            [self setImage:[UIImage systemImageNamed:@"lock.fill"] forSearchBarIcon:UISearchBarIconSearch state:UIControlStateNormal];
        } else {
            // Fallback on earlier versions
            [self setImage:[UIImage imageNamed:@"refresh"] forSearchBarIcon:UISearchBarIconBookmark state:UIControlStateNormal];
            [self setImage:[UIImage imageNamed:@"lock.fill"] forSearchBarIcon:UISearchBarIconSearch state:UIControlStateNormal];
        }
    }
    return self;
}

- (UITextField*)textField
{
    UITextField* textField = nil;
    if (@available(iOS 13.0, *)) {
        return self.searchTextField;
    } else {
        // Fallback on earlier versions
        for (UIView* view in self.subviews)
        {
            if ([view isKindOfClass:[UITextField class]])
            {
                textField = (UITextField*)view;
                break;
            }
        }
    }
    return textField;
}

- (void)setLeftImage:(UIImage *)image
{
    self.textField.leftView = [self setImageView:image];
}

- (void)setRightImage:(UIImage *)image highLightedImage:(UIImage*)highLightedImage
{
    self.showsBookmarkButton = YES;
    UIButton* button = self.textField.rightView;
    [button setImage:image forState:UIControlStateNormal];
    [button setImage:highLightedImage forState:UIControlStateHighlighted];
}

- (UIImageView*)setImageView:(UIImage*)image
{
    UIImageView* imageView = [[UIImageView alloc] initWithImage:image];
    imageView.translatesAutoresizingMaskIntoConstraints = NO;
    [imageView.widthAnchor constraintEqualToConstant:20].active = YES;
    [imageView.heightAnchor constraintEqualToConstant:20].active = YES;
    imageView.tintColor = UIColor.grayColor;
    return imageView;
}


- (void)searchBarFinished
{
    [self resignFirstResponder];
    NSString* text = self.text;
    NSString* search_url = NSLocalizedString(@"TextSearchURL", nil);
    NSString* urlStr = [NSString stringWithFormat:search_url, text];

    if ([text isHttpURL]) {
        urlStr = [NSString stringWithFormat:@"%@", text];
    } else if ([text isDomain]) {
        urlStr = [NSString stringWithFormat:@"http://%@", text];
    }

    NSURL *url = [NSURL URLWithString:[urlStr stringByAddingPercentEncodingWithAllowedCharacters:NSCharacterSet.URLQueryAllowedCharacterSet]];
    [[ContentWKWebView sharedContentInstance] loadRequest:[NSURLRequest requestWithURL:url]];
}

#pragma mark UISearchBarDelegate Implementation

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [self searchBarFinished];
    self.showsCancelButton = NO;
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    self.showsCancelButton = YES;
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    self.showsCancelButton = NO;
}

 - (void)searchBarBookmarkButtonClicked:(UISearchBar *)searchBar
{
    [ContentWKWebView.sharedContentInstance reload];
}

@end
