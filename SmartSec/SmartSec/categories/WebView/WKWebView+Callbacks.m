//
//  WKWebView+Callbacks.m
//  SmartSec
//
//  Created by Olga Dalton on 10/04/15.
//  Copyright (c) 2015 Olga Dalton. All rights reserved.
//

#import "WKWebView+Callbacks.h"
#import "WKWebView+Sec.h"
#import <objc/runtime.h>

@implementation WKWebView (Callbacks)

#pragma mark - 
#pragma mark - Replacement methods

- (WKNavigation *)swizzledLoadRequest:(NSURLRequest *)request
{
    [self addWebViewDelegate];
    return [self swizzledLoadRequest:request];
}

- (WKNavigation *)swizzledLoadHTMLString:(NSString *)string baseURL:(NSURL *)baseURL
{
    [self addWebViewDelegate];
    return [self swizzledLoadHTMLString:string baseURL:baseURL];
}

- (void)swizzledSetNavigationDelegate:(id<WKNavigationDelegate>)navigationDelegate
{
    [self swizzledSetNavigationDelegate:navigationDelegate];
    [self hookURLWhitelisting];
}

#pragma mark -
#pragma mark - Swizzle

+ (void)load
{
    SEL originalMethods[] = {@selector(loadRequest:),
        @selector(loadHTMLString:baseURL:),
        @selector(setNavigationDelegate:)};
    
    SEL newMethods[] = {@selector(swizzledLoadRequest:),
        @selector(swizzledLoadHTMLString:baseURL:),
        @selector(swizzledSetNavigationDelegate:)};
    
    Method originalMethod, swizzledMethod;
    
    for (int i = 0; i < (sizeof originalMethods) / (sizeof originalMethods[0]); i++)
    {
        SEL original = originalMethods[i];
        SEL new = newMethods[i];
        
        originalMethod = class_getInstanceMethod(self, original);
        swizzledMethod = class_getInstanceMethod(self, new);
        
        method_exchangeImplementations(originalMethod, swizzledMethod);
    }
}

@end
