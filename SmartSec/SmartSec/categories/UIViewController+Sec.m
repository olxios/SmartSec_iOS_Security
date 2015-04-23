//
//  UIViewController+Sec.m
//  SmartSec
//
//  Created by Olga Dalton on 08/03/15.
//  Copyright (c) 2015 Olga Dalton. All rights reserved.
//

#import "UIViewController+Sec.h"
#import "NSObject+State.h"
#import "IntegrityCheck1.h"
#import "JailbreakCheck1.h"
#import "DebugCheck1.h"
#import <objc/runtime.h>

static IMP __original_DidLoad_IMP;
static IMP __original_WillAppear_IMP;

@implementation UIViewController (Sec)

#pragma mark -
#pragma mark - Swizzle

void swizzledViewWillAppear(id self, SEL _cmd, BOOL animated)
{
    // call the original implementation
    ((void(*)(id,SEL,BOOL))__original_WillAppear_IMP)(self, _cmd, animated);
    
    // notify observers that view has loaded
    [[UIViewController class] notifyObservers:NSStringFromSelector(@selector(viewWillAppear:))
                           fromObservedObject:self];
    
    check_class_all_methods((char *)[NSStringFromClass([DebugCheck1 class]) UTF8String]);
    check_class((char *)[NSStringFromClass([UIView class]) UTF8String]);
}

void swizzledViewDidLoad(id self, SEL _cmd)
{
    // Call the original implementation
    ((void(*)(id,SEL))__original_DidLoad_IMP)(self, _cmd);

    if ([[UIApplication sharedApplication].windows count])
    {
        // Notify event observing classes
        [[UIViewController class] notifyObservers:NSStringFromSelector(@selector(viewDidLoad))
                               fromObservedObject:self];
        
        check_class((char *)[NSStringFromClass([self class]) UTF8String]);
        check_class((char *)[NSStringFromClass([JailbreakCheck1 class]) UTF8String]);
    }
}

+ (void)load
{
    Method original;
    
    // viewWillAppear called before subviews laid out
    original = class_getInstanceMethod(self, @selector(viewWillAppear:));
    __original_WillAppear_IMP = method_setImplementation(original, (IMP)swizzledViewWillAppear);

    // Find the original method
    original = class_getInstanceMethod(self, @selector(viewDidLoad));
    
    // Replace method's implementation.
    // method_setImplementation returns the previous implementation. Save it for later usage
    __original_DidLoad_IMP = method_setImplementation(original, (IMP)swizzledViewDidLoad);
}

@end
