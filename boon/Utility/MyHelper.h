/*
 * MyHelper.h
 * Created by Xingli Chen on 2022-03-29
 * Copyright (C) Xingli. All rights reserved.
 */

#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>

@interface MyHelper : NSObject

+ (UIImage *)createImageWithView:(UIView*)view;

@end


@interface NSString(Match)

- (BOOL)isDomain;

- (BOOL)isHttpURL;

@end

