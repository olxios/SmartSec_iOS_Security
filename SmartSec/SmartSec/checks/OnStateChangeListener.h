//
//  OnStateChangeListener.h
//  SmartSec
//
//  Created by Olga Dalton on 01/03/15.
//  Copyright (c) 2015 Olga Dalton. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol OnStateChangeListener <NSObject>

- (void)onStateChanged:(id)stateObject fromObject:(id)observedObject;

@end
