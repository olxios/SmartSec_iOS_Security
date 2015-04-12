//
//  UIApplication+Delegate.m
//  SmartSec
//
//  Created by Olga Dalton on 07/03/15.
//  Copyright (c) 2015 Olga Dalton. All rights reserved.
//

#import "UIApplication+Sec.h"
#import "SmartSecConfigurable.h"
#import "NSObject+State.h"
#import "UIApplication+SecText.h"
#import "UIApplication+WhiteList.h"

#import <objc/runtime.h>
#include <spawn.h>

static IMP __original_Set_Delegate_IMP;

@implementation UIApplication(Sec)

#pragma mark -
#pragma mark - Swizzle

void swizzledSetDelegate(id self, SEL _cmd, id<UIApplicationDelegate> delegate)
{
    // call the real implementation
    ((void(*)(id,SEL,id))__original_Set_Delegate_IMP)(self, _cmd, delegate);
    
    // can initialize the library, when delegate is ready
    [SmartSecConfigurable sharedInstance];
    
    [self setupURLSchemeFilter];
    
    // add application state observer
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationDidEnterForeground)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationStateChanged)
                                                 name:UIApplicationWillResignActiveNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationDidEnterBackground)
                                                 name:UIApplicationDidEnterBackgroundNotification
                                               object:nil];
}

+ (void)load
{
    Method original;
    
    original = class_getInstanceMethod(self, @selector(setDelegate:));
    __original_Set_Delegate_IMP = method_setImplementation(original, (IMP)swizzledSetDelegate);
}

#pragma mark -
#pragma mark - Notifications

- (void)applicationStateChanged
{
    [[UIApplication class] notifyObservers:@(self.applicationState) fromObservedObject:self];
}

#pragma mark -
#pragma mark - Kill the application

+ (void)killMe
{
    // kill(getpid(), SIGKILL);
    // abort();
    exit(-1);
}

#pragma mark -
#pragma mark - Application Screenshots

- (void)applicationDidEnterBackground
{
    [[UIApplication sharedApplication] hideTextFieldsContent];
}

- (void)applicationDidEnterForeground
{
    [self applicationStateChanged];
    [[UIApplication sharedApplication] showTextFieldsContent];
}

@end
