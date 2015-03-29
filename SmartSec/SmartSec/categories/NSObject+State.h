//
//  NSObject+NSObject_State.h
//  SmartSec
//
//  Created by Olga Dalton on 07/03/15.
//  Copyright (c) 2015 Olga Dalton. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OnStateChangeListener.h"

// Public notifications list: https://gist.github.com/hpique/7554209

@interface NSObject (State)

// class methods
+ (void)addObserver:(id<OnStateChangeListener>)listener;
+ (void)removeObserver:(id<OnStateChangeListener>)listener;
+ (void)notifyObservers:(id)stateObject fromObservedObject:(id)observedObject;

// instance methods
- (void)removeNotificationObservers;

// Disable/enable encryption globally
+ (void)setEncryptionDisabled:(BOOL)encryptionDisabled;
+ (BOOL)encryptionDisabled;

@end
