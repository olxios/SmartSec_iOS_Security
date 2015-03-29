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

@implementation UIViewController (Sec)

#pragma mark -
#pragma mark - Swizzle

- (void)swizzledViewWillAppear:(BOOL)animated
{
    // call the real implementation
    [self swizzledViewWillAppear:animated];
    
    // notify observers that view has loaded
    [[self class] notifyObservers:NSStringFromSelector(@selector(viewWillAppear:)) fromObservedObject:self];
}

- (void)swizzledViewDidLoad
{
    // call the real implementation
    [self swizzledViewDidLoad];
    
    [[self class] notifyObservers:NSStringFromSelector(@selector(viewDidLoad)) fromObservedObject:self];
}

+ (void)load
{
    Method original, swizzled;
    
    // viewWillAppear called before subviews laid out
    original = class_getInstanceMethod(self, @selector(viewWillAppear:));
    swizzled = class_getInstanceMethod(self, @selector(swizzledViewWillAppear:));
    method_exchangeImplementations(original, swizzled);
    
    original = class_getInstanceMethod(self, @selector(viewDidLoad));
    swizzled = class_getInstanceMethod(self, @selector(swizzledViewDidLoad));
    method_exchangeImplementations(original, swizzled);

}

@end
