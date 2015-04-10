//
//  WKWebViewNavigationDelegate.m
//  SmartSec
//
//  Created by Olga Dalton on 10/04/15.
//  Copyright (c) 2015 Olga Dalton. All rights reserved.
//

#import "WKWebViewNavigationDelegate.h"
#import "URLWhitelist.h"

@implementation WKWebViewNavigationDelegate

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

@end
