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

@implementation UIWindow (Sec)

- (void)swizzledBecomeKeyWindow
{
    [self swizzledBecomeKeyWindow];
    
    // notify observers
    [[self class] notifyObservers:NSStringFromSelector(@selector(becomeKeyWindow)) fromObservedObject:self];
}

+ (void)load
{
    Method original, swizzled;
    
    // viewWillAppear called before subviews laid out
    original = class_getInstanceMethod(self, @selector(becomeKeyWindow));
    swizzled = class_getInstanceMethod(self, @selector(swizzledBecomeKeyWindow));
    method_exchangeImplementations(original, swizzled);
}

@end
