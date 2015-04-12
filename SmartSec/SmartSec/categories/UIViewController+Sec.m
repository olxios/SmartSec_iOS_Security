//
//  UIViewController+Sec.m
//  SmartSec
//
//  Created by Olga Dalton on 08/03/15.
//  Copyright (c) 2015 Olga Dalton. All rights reserved.
//

#import "UIViewController+Sec.h"
#import "NSObject+State.h"
#import <objc/runtime.h>

static IMP __original_DidLoad_IMP;
static IMP __original_WillAppear_IMP;

@implementation UIViewController (Sec)

#pragma mark -
#pragma mark - Swizzle

void swizzledViewWillAppear(id self, SEL _cmd, BOOL animated)
{
    // call the real implementation
    ((void(*)(id,SEL,BOOL))__original_WillAppear_IMP)(self, _cmd, animated);
    
    // notify observers that view has loaded
    [[UIViewController class] notifyObservers:NSStringFromSelector(@selector(viewWillAppear:)) fromObservedObject:self];
}

void swizzledViewDidLoad(id self, SEL _cmd)
{
    // call the real implementation
    ((void(*)(id,SEL))__original_DidLoad_IMP)(self, _cmd);
    
    [[UIViewController class] notifyObservers:NSStringFromSelector(@selector(viewDidLoad)) fromObservedObject:self];
}

+ (void)load
{
    Method original;
    
    // viewWillAppear called before subviews laid out
    original = class_getInstanceMethod(self, @selector(viewWillAppear:));
    __original_WillAppear_IMP = method_setImplementation(original, (IMP)swizzledViewWillAppear);

    original = class_getInstanceMethod(self, @selector(viewDidLoad));
    __original_DidLoad_IMP = method_setImplementation(original, (IMP)swizzledViewDidLoad);
}

@end
