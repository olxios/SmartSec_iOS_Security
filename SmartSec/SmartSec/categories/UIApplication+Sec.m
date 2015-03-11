//
//  UIApplication+Delegate.m
//  SmartSec
//
//  Created by Olga Dalton on 07/03/15.
//  Copyright (c) 2015 Olga Dalton. All rights reserved.
//

#import "UIApplication+Sec.h"
#import "SmartSecInit.h"
#import "NSObject+State.h"

#import <objc/runtime.h>
#include <spawn.h>

@implementation UIApplication(Sec)

#pragma mark -
#pragma mark - Swizzle

- (void)swizzledSetDelegate:(id<UIApplicationDelegate>)delegate
{
    // call the real implementation
    [self swizzledSetDelegate:delegate];
    
    // can initialize the library, when delegate is ready
    [SmartSecInit sharedInstance];
    
    // add application state observer
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationActive)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
}

+ (void)load
{
    Method original, swizzled;
    
    original = class_getInstanceMethod(self, @selector(setDelegate:));
    swizzled = class_getInstanceMethod(self, @selector(swizzledSetDelegate:));
    method_exchangeImplementations(original, swizzled);
}

#pragma mark -
#pragma mark - Notifications

- (void)applicationActive
{
    [[self class] notifyObservers:@(self.applicationState) fromObservedObject:self];
}

#pragma mark -
#pragma mark - Kill the application

+ (void)killMe
{
    // kill(getpid(), SIGKILL);
    // abort();
    exit(-1);
}

@end
