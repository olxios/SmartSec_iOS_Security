//
//  BaseChecksTemplate.h
//  SmartSec
//
//  Created by Olga Dalton on 01/03/15.
//  Copyright (c) 2015 Olga Dalton. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol BaseChecksTemplate <NSObject>

- (void)hookChecks;
- (void)unhookChecks;
- (void)runChecks;

@end
