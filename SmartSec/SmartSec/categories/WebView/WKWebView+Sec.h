//
//  WKWebView+Sec.h
//  SmartSec
//
//  Created by Olga Dalton on 10/04/15.
//  Copyright (c) 2015 Olga Dalton. All rights reserved.
//

#import <WebKit/WebKit.h>

@interface WKWebView (Sec)

- (void)hookURLWhitelisting;
- (void)addWebViewDelegate;

@end
