//
//  SmartSecInit.h
//  SmartSec
//
//  Created by Olga Dalton on 15/02/15.
//  Copyright (c) 2015 Olga Dalton. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SmartSecConfig;

@interface SmartSecConfigurable : NSObject

@property (nonatomic, strong) NSMutableDictionary *enabledCheckers;

+ (instancetype)sharedInstance;
- (void)setup;

// C functions
extern void hookConfigurableDebuggerChecks(SmartSecConfigurable *selfRef);
extern void hookConfigurableJailbreakChecks(SmartSecConfigurable *selfRef);
extern void hookConfigurableIntegrityChecks(SmartSecConfigurable *selfRef);

@end
