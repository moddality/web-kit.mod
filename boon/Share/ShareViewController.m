/*
 * ShareViewController.m
 * Created by Xingli Chen on 2022-03-29
 * Copyright (C) Xingli. All rights reserved.
 */
    
#import "ShareViewController.h"
#import "ContentWKWebView.h"

@interface ShareViewController()

@end

@implementation ShareViewController

- (nullable id)activityViewController:(nonnull UIActivityViewController *)activityViewController itemForActivityType:(nullable UIActivityType)activityType {
    return ContentWKWebView.sharedContentInstance.URL;
}

- (nonnull id)activityViewControllerPlaceholderItem:(nonnull UIActivityViewController *)activityViewController {
    return [UIImage new];
}

- (LPLinkMetadata*)activityViewControllerLinkMetadata:(UIActivityViewController *)activityViewController
API_AVAILABLE(ios(13.0)){
    LPLinkMetadata* metadata = [[LPLinkMetadata alloc] init];
    metadata.URL = ContentWKWebView.sharedContentInstance.URL;
    metadata.title = ContentWKWebView. sharedContentInstance.backForwardList.currentItem.title;
    metadata.originalURL = ContentWKWebView.sharedContentInstance.URL;
    metadata.imageProvider = [[NSItemProvider alloc] initWithObject:self.thumbnail];
    metadata.iconProvider = [[NSItemProvider alloc] initWithObject:self.thumbnail];
    return metadata;
}

@end
