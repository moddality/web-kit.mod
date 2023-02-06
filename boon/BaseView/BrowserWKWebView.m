//
//  ContentWKWebView.m
//  boon
//
//  Created by Benoit Marchant on 10/4/22.
//

#import <Foundation/Foundation.h>
#import "BrowserWKWebView.h"
#import <Foundation/NSURLRequest.h>
#import <WebKit/WKWebsiteDataStore.h>
#import <AdSupport/ASIdentifierManager.h>
#import "Defaults.h"
#import "UserDefaults.h"
#import "FileStorage.h"
#import "KeyChain.h"

//@interface BrowserWKWebView()
//@property(nonatomic, strong) WKUserScript *montageUserScript;
//@end

static BrowserWKWebView  *browserInstance = nil;

@implementation BrowserWKWebView

+ (instancetype)sharedBrowserInstance
{
    if(browserInstance == nil) {
        browserInstance =  [[self alloc] init];
    }
    return browserInstance;
}

/*
 
    Also see: https://stackoverflow.com/questions/3834301/ios-forward-all-touches-through-a-view
 
     For passing touches from an overlay view to the views underneath, implement the following method in the UIView:

     Objective-C:

     - (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
         NSLog(@"Passing all touches to the next view (if any), in the view stack.");
         return NO;
     }

    A more subtle strategy would be to use our Montage's EventManager to know wether any listener handled the event.
    If none did, then clearly forward bellow to the contenWebView
 
     https://stackoverflow.com/questions/66866142/wkwebview-only-allow-the-click-event-within-dom-body-objective-c
     https://stackoverflow.com/questions/62761442/wkwebview-overlapping-status-bar-in-iphone-xr
     https://stackoverflow.com/questions/26256607/how-to-let-two-overlapping-views-to-receive-the-user-touch-events-ios
     https://medium.com/@nguyenminhphuc/how-to-pass-ui-events-through-views-in-ios-c1be9ab1626b
 
     https://medium.com/swlh/hittest-with-vs-point-inside-with-f6540ade58a3
     https://cdmana.com/2021/07/20210731024715619o.html
 
    Current implementation from: https://stackoverflow.com/questions/31038306/ios-wkwebview-get-rgba-pixel-color-from-point
 
    More on the transparency subject:
     https://stackoverflow.com/questions/13291919/detect-touches-only-on-non-transparent-pixels-of-uiimageview-efficiently
     https://exchangetuts.com/ios-wkwebview-get-rgba-pixel-color-from-point-1640761084563763
 
 */

- (UIView *)hitTest:(CGPoint)point
          withEvent:(UIEvent *)event;
{
//    UIView *contentResult = [self.contentWebView hitTest:point withEvent:event];
//    UIView *superResult = [super hitTest:point withEvent:event];
//
////    return superResult;
//    return contentResult;
    
    UIView* subview = [super hitTest:point withEvent:event];  // this should always be a webview

    if ([self isTransparent:[self convertPoint:point toView:self] fromView:self.layer]) // if point is transparent then let superview deal with it
    {
        //return [self superview];
        //return [self contentWebView];
        return [self.contentWebView hitTest:point withEvent:event];
    }

    return subview; // return webview

}

- (BOOL)isTransparent:(CGPoint)point fromView:(CALayer*)layer
{
    unsigned char pixel[4] = {0};

    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();

    CGContextRef context = CGBitmapContextCreate(pixel, 1, 1, 8, 4, colorSpace, (CGBitmapInfo)kCGImageAlphaPremultipliedLast);

    CGContextTranslateCTM(context, -point.x, -point.y);

    //[layer renderInContext:context];
    UIGraphicsPushContext(context);
    [self drawViewHierarchyInRect:self.bounds afterScreenUpdates:YES];
    UIGraphicsPopContext();

    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);

    return (pixel[0]/255.0 == 0) &&(pixel[1]/255.0 == 0) &&(pixel[2]/255.0 == 0) &&(pixel[3]/255.0 == 0) ;
}


@end
