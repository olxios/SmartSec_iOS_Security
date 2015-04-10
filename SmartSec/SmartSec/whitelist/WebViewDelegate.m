//
//  WebViewDelegate.m
//  SmartSec
//
//  Created by Olga Dalton on 10/04/15.
//  Copyright (c) 2015 Olga Dalton. All rights reserved.
//

#import "WebViewDelegate.h"
#import "URLWhitelist.h"

@implementation WebViewDelegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{    
    return urlMatches(request.URL);
}

@end
