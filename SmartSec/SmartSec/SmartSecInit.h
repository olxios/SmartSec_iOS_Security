//
//  SmartSecInit.h
//  SmartSec
//
//  Created by Olga Dalton on 15/02/15.
//  Copyright (c) 2015 Olga Dalton. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SmartSecConfig;

@interface SmartSecInit : NSObject

+ (SmartSecInit*)sharedInstance;
- (void)setConfig:(SmartSecConfig *)config;

@end
