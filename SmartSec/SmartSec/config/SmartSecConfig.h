//
//  SmartSecConfig.h
//  SmartSec
//
//  Created by Olga Dalton on 10/03/15.
//  Copyright (c) 2015 Olga Dalton. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SmartSecConfig : NSObject

@property (nonatomic) BOOL disableDebugChecks;
@property (nonatomic) BOOL disableIntegrityChecks;
@property (nonatomic) BOOL disableJailbreakChecks;

// TODO: add more options for other checks

@end
