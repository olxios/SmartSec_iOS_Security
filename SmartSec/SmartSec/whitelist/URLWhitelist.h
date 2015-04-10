//
//  URLWhitelist.h
//  SmartSec
//
//  Created by Olga Dalton on 09/04/15.
//  Copyright (c) 2015 Olga Dalton. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface URLWhitelist : NSObject

extern BOOL urlMatches(NSURL *url);
extern BOOL sourceApplicationMatches(NSString *appBundleId);

@end
