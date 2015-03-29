//
//  UINavigationController+Sec.m
//  SmartSec
//
//  Created by Olga Dalton on 20/03/15.
//  Copyright (c) 2015 Olga Dalton. All rights reserved.
//

#import "UINavigationController+Sec.h"
#import "NSObject+State.h"

#import <objc/runtime.h>

@implementation UINavigationController (Sec)

- (void)swizzledPushViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    [self swizzledPushViewController:viewController animated:animated];
    
    // notify observers
    [[self class] notifyObservers:NSStringFromSelector(@selector(pushViewController:animated:))
               fromObservedObject:self];
}

+ (void)load
{
    Method original, swizzled;
    
    // viewWillAppear called before subviews laid out
    original = class_getInstanceMethod(self, @selector(pushViewController:animated:));
    swizzled = class_getInstanceMethod(self, @selector(swizzledPushViewController:animated:));
    method_exchangeImplementations(original, swizzled);
}

@end
