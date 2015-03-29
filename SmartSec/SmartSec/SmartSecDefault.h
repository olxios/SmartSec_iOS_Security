//
//  SmartSecDefault.h
//  SmartSec
//
//  Created by Olga Dalton on 16/03/15.
//  Copyright (c) 2015 Olga Dalton. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SmartSecDefault : NSObject

@property (nonatomic, strong) NSMutableDictionary *enabledCheckers;

+ (instancetype)sharedInstance;

// C functions
extern void hookDefaultDebuggerChecks(SmartSecDefault *selfRef);
extern void hookDefaultJailbreakChecks(SmartSecDefault *selfRef);
extern void hookDefaultIntegrityChecks(SmartSecDefault *selfRef);

@end
