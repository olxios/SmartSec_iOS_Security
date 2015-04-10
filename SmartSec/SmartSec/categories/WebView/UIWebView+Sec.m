//
//  UIWebView+Sec.m
//  SmartSec
//
//  Created by Olga Dalton on 10/04/15.
//  Copyright (c) 2015 Olga Dalton. All rights reserved.
//

#import "UIWebView+Sec.h"
#import "URLWhitelist.h"
#import "WebViewDelegate.h"
#import <objc/runtime.h>

static char delegateKey;

@implementation UIWebView (Sec)

#pragma mark -
#pragma mark - URL filter

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    return urlMatches(request.URL);
}

- (BOOL)swizzledWebView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    BOOL urlFilterResult = urlMatches(request.URL);
    
    if (urlFilterResult)
    {
        // If passes filter, continue with the original delegate method
        return [self swizzledWebView:webView shouldStartLoadWithRequest:request navigationType:navigationType];
    }
    
    return NO;
}

- (void)hookURLWhitelisting
{
    if (![self delegateHooked])
    {
        Method original;
        
        original = class_getInstanceMethod([self.delegate class], @selector(webView:shouldStartLoadWithRequest:navigationType:));
        
        SEL addedSelector = @selector(swizzledWebView:shouldStartLoadWithRequest:navigationType:);
        
        if (original)
        {
            class_addMethod([self.delegate class], addedSelector, [self methodForSelector:addedSelector], "B@:@@i");
            
            Method swizzle = class_getInstanceMethod([self.delegate class], @selector(swizzledWebView:shouldStartLoadWithRequest:navigationType:));
            method_exchangeImplementations(original, swizzle);
        }
        else
        {
            addedSelector = @selector(webView:shouldStartLoadWithRequest:navigationType:);
            
            class_addMethod([self.delegate class], addedSelector,
                            [self methodForSelector:addedSelector], "B@:@@i");
        }
        
        // Save hooking
        objc_setAssociatedObject(self, &delegateKey, self.delegate, OBJC_ASSOCIATION_ASSIGN);
    }
}

- (void)addWebViewDelegate
{
    if (!self.delegate)
    {
        WebViewDelegate *delegate = [[WebViewDelegate alloc] init];
        objc_setAssociatedObject(self, &delegateKey, delegate, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        self.delegate = delegate;
    }
}

#pragma mark -
#pragma mark - Hooking setup

- (BOOL)delegateHooked
{
    return [objc_getAssociatedObject(self, &delegateKey) isEqual:self.delegate];
}

@end
