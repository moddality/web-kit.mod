/*
 * ShareViewController.h
 * Created by Xingli Chen on 2022-03-29
 * Copyright (C) Xingli. All rights reserved.
 */

#import <UIKit/UIKit.h>
#import <LinkPresentation/LPLinkMetadata.h>

@interface ShareViewController : UIViewController<UIActivityItemSource>

@property(nonatomic, strong) UIImage* thumbnail;

@end
