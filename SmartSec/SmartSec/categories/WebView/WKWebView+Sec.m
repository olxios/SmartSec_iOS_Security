//
//  WKWebView+Sec.m
//  SmartSec
//
//  Created by Olga Dalton on 10/04/15.
//  Copyright (c) 2015 Olga Dalton. All rights reserved.
//

#import "WKWebView+Sec.h"
#import "URLWhitelist.h"
#import "WKWebViewNavigationDelegate.h"
#import <objc/runtime.h>

static char wkDelegateKey;

@implementation WKWebView (Sec)

#pragma mark -
#pragma mark - URL filter

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler
{
    NSURLRequest *request = navigationAction.request;
    
    BOOL whiteListResult = urlMatches(request.URL);
    
    if (whiteListResult)
    {
        decisionHandler(WKNavigationActionPolicyAllow);
    }
    else
    {
        decisionHandler(WKNavigationActionPolicyCancel);
    }
}

- (void)swizzledWebView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler
{
    NSURLRequest *request = navigationAction.request;
    
    BOOL whiteListResult = urlMatches(request.URL);
    
    if (whiteListResult)
    {
        [self swizzledWebView:webView decidePolicyForNavigationAction:navigationAction
              decisionHandler:decisionHandler];
    }
    else
    {
        decisionHandler(WKNavigationActionPolicyCancel);
    }
}

- (void)hookURLWhitelisting
{
    if (![self delegateHooked])
    {
        // Save hooking
        objc_setAssociatedObject(self, &wkDelegateKey, self.navigationDelegate, OBJC_ASSOCIATION_ASSIGN);
        
        Method original;
        
        original = class_getInstanceMethod([self.navigationDelegate class], @selector(webView:decidePolicyForNavigationAction:decisionHandler:));
        
        SEL addedSelector = @selector(swizzledWebView:decidePolicyForNavigationAction:decisionHandler:);
        
        if (original)
        {
            class_addMethod([self.navigationDelegate class], addedSelector, [self methodForSelector:addedSelector], method_getTypeEncoding(original));
            
            Method swizzle = class_getInstanceMethod([self.navigationDelegate class], @selector(swizzledWebView:decidePolicyForNavigationAction:decisionHandler:));
            method_exchangeImplementations(original, swizzle);
        }
        else
        {
            addedSelector = @selector(webView:decidePolicyForNavigationAction:decisionHandler:);
            
            Method newMethod = class_getInstanceMethod([self class], @selector(webView:decidePolicyForNavigationAction:decisionHandler:));
            
            class_addMethod([self.navigationDelegate class], addedSelector,
                            [self methodForSelector:addedSelector], method_getTypeEncoding(newMethod));
            
            // WKWebView requires update of the delegate,
            // otherwise it won't find the delegate method
            self.navigationDelegate = self.navigationDelegate;
        }
    }
}

- (void)addWebViewDelegate
{
    if (!self.navigationDelegate)
    {
        WKWebViewNavigationDelegate *delegate = [[WKWebViewNavigationDelegate alloc] init];
        objc_setAssociatedObject(self, &wkDelegateKey, delegate, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        self.navigationDelegate = delegate;
    }
}

#pragma mark -
#pragma mark - Hooking setup

- (BOOL)delegateHooked
{
    return [objc_getAssociatedObject(self, &wkDelegateKey) isEqual:self.navigationDelegate];
}

@end
