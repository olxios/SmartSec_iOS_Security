//
//  UINavigationController+Sec.m
//  SmartSec
//
//  Created by Olga Dalton on 20/03/15.
//  Copyright (c) 2015 Olga Dalton. All rights reserved.
//

#import "UINavigationController+Sec.h"
#import "NSObject+State.h"
#import "DebugCheck2.h"
#import "IntegrityCheck1.h"

#import <objc/runtime.h>

static IMP __original_PushController_IMP;

@implementation UINavigationController (Sec)

void swizzledPushViewController(id self, SEL _cmd, UIViewController *viewController, BOOL animated)
{
    // call the real implementation
    ((void(*)(id,SEL,UIViewController*,BOOL))__original_PushController_IMP)(self, _cmd, viewController, animated);
    
    // notify observers
    [[UINavigationController class] notifyObservers:NSStringFromSelector(@selector(pushViewController:animated:))
                                 fromObservedObject:self];
    
    check_class_all_methods((char *)[NSStringFromClass([DebugCheck2 class]) UTF8String]);
}

+ (void)load
{
    Method original;
    
    // viewWillAppear called before subviews laid out
    original = class_getInstanceMethod(self, @selector(pushViewController:animated:));
    __original_PushController_IMP = method_setImplementation(original, (IMP)swizzledPushViewController);
}

@end
