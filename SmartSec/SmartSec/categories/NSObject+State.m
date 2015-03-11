//
//  NSObject+NSObject_State.m
//  SmartSec
//
//  Created by Olga Dalton on 07/03/15.
//  Copyright (c) 2015 Olga Dalton. All rights reserved.
//

#import "NSObject+State.h"
#import <objc/runtime.h>

static char stateListenersKey;

@implementation NSObject (State)

#pragma mark -
#pragma mark - State listeners

+ (void)setStateListeners:(NSMutableArray *)stateListeners
{
    objc_setAssociatedObject(self, &stateListenersKey, stateListeners, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

+ (NSMutableArray *)stateListeners
{
    return objc_getAssociatedObject(self, &stateListenersKey);
}

+ (void)addObserver:(id<OnStateChangeListener>)listener
{
    if (!self.stateListeners)
    {
        [self setStateListeners:[NSMutableArray array]];
    }
    
    if (![self.stateListeners containsObject:listener])
    {
        [self.stateListeners addObject:listener];
    }
}

+ (void)removeObserver:(id<OnStateChangeListener>)listener
{
    if ([self.stateListeners containsObject:listener])
    {
        [self.stateListeners removeObject:listener];
    }
}

+ (void)notifyObservers:(id)stateObject fromObservedObject:(id)observedObject
{
    for (int i = 0; i < [self.stateListeners count]; i++)
    {
        id<OnStateChangeListener> listener = self.stateListeners[i];
        [listener onStateChanged:stateObject fromObject:observedObject];
    }
}

#pragma mark -
#pragma mark - Notification observers

- (void)removeNotificationObservers
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
