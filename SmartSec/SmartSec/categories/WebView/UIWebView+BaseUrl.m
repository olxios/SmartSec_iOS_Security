//
//  UIWebView+BaseUrl.m
//  SmartSec
//
//  Created by Olga Dalton on 09/04/15.
//  Copyright (c) 2015 Olga Dalton. All rights reserved.
//

#import "UIWebView+BaseUrl.h"
#import "UIWebView+Sec.h"
#import <objc/runtime.h>

@implementation UIWebView (BaseUrl)

#pragma mark -
#pragma mark - Swizzled methods

- (void)swizzledLoadHTMLString:(NSString *)string baseURL:(NSURL *)baseURL
{
    NSURL *blankUrl = [NSURL URLWithString:@"about:blank"];
    
    [self swizzledLoadHTMLString:string
                         baseURL:baseURL ? baseURL : blankUrl];
    
    [self addWebViewDelegate];
}

- (void)swizzledLoadData:(NSData *)data MIMEType:(NSString *)MIMEType textEncodingName:(NSString *)textEncodingName baseURL:(NSURL *)baseURL
{
    NSURL *blankUrl = [NSURL URLWithString:@"about:blank"];
    
    [self swizzledLoadData:data MIMEType:MIMEType
          textEncodingName:textEncodingName
                   baseURL:baseURL ? baseURL : blankUrl];
    
    [self addWebViewDelegate];
}

- (void)swizzledLoadRequest:(NSURLRequest *)request
{
    [self swizzledLoadRequest:request];
    [self addWebViewDelegate];
}

- (void)swizzledSetDelegate:(id<UIWebViewDelegate>)delegate
{
    [self swizzledSetDelegate:delegate];
    [self hookURLWhitelisting];
}

#pragma mark -
#pragma mark - Swizzle

+ (void)load
{
    SEL originalMethods[] = {@selector(loadHTMLString:baseURL:),
        @selector(loadData:MIMEType:textEncodingName:baseURL:),
        @selector(loadRequest:),
        @selector(setDelegate:)};
    
    SEL newMethods[] = {@selector(swizzledLoadHTMLString:baseURL:),
        @selector(swizzledLoadData:MIMEType:textEncodingName:baseURL:),
        @selector(swizzledLoadRequest:),
        @selector(swizzledSetDelegate:)};
    
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
