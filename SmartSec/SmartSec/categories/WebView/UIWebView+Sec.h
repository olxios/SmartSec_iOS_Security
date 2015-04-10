//
//  UIWebView+Sec.h
//  SmartSec
//
//  Created by Olga Dalton on 10/04/15.
//  Copyright (c) 2015 Olga Dalton. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIWebView (Sec)

- (void)hookURLWhitelisting;
- (void)addWebViewDelegate;

@end
