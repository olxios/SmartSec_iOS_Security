//
//  UIWindow+Sec.m
//  SmartSec
//
//  Created by Olga Dalton on 20/03/15.
//  Copyright (c) 2015 Olga Dalton. All rights reserved.
//

#import "UIWindow+Sec.h"
#import "NSObject+State.h"
#import <objc/runtime.h>

static IMP __original_Become_Key_Window_IMP;

@implementation UIWindow (Sec)

void swizzledBecomeKeyWindow(id self, SEL _cmd)
{
    // call the real implementation
    ((void(*)(id,SEL))__original_Become_Key_Window_IMP)(self, _cmd);
    
    // notify observers
    [[UIWindow class] notifyObservers:NSStringFromSelector(@selector(becomeKeyWindow)) fromObservedObject:self];
}

+ (void)load
{
    Method original;
    
    // viewWillAppear called before subviews laid out
    original = class_getInstanceMethod(self, @selector(becomeKeyWindow));
    
    __original_Become_Key_Window_IMP = method_setImplementation(original, (IMP)swizzledBecomeKeyWindow);
}

@end
