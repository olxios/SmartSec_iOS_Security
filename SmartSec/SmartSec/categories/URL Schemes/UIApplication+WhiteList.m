//
//  UIApplication+WhiteList.m
//  SmartSec
//
//  Created by Olga Dalton on 11/04/15.
//  Copyright (c) 2015 Olga Dalton. All rights reserved.
//

#import "UIApplication+WhiteList.h"
#import "URLWhitelist.h"
#import <objc/runtime.h>

static char applicationHookedKey;
@implementation UIApplication (WhiteList)

#pragma mark -
#pragma mark - Replacement method

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url
          sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    BOOL whiteListResult = sourceApplicationMatches(sourceApplication);
    
    if (whiteListResult)
    {
        if ([self respondsToSelector:@selector(application:handleOpenURL:)])
        {
            return [(id)self application:application handleOpenURL:url];
        }
        else
        {
            // What point to return YES here?
            // This method is called if delegate doesn't implement application:openURL:sourceApplication:annotation:
            // And now we also checked that it doesn't implement application:handleOpenURL:
            // So it is actually not handling URL schemes at all!!!
            return NO;
        }
    }
    
    return NO;
}

- (BOOL)swizzledApplication:(UIApplication *)application openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    BOOL whiteListResult = sourceApplicationMatches(sourceApplication);
    
    if (whiteListResult)
    {
        return [(id)self swizzledApplication:application openURL:url sourceApplication:sourceApplication annotation:annotation];
    }
    
    return NO;
}

#pragma mark -
#pragma mark - Swizzle

- (void)setupURLSchemeFilter
{    
    if (![self delegateHooked])
    {
        // Save hooking
        objc_setAssociatedObject(self, &applicationHookedKey, self.delegate, OBJC_ASSOCIATION_ASSIGN);
     
        Method original;
        
        original = class_getInstanceMethod([self.delegate class], @selector(application:openURL:sourceApplication:annotation:));
        
        SEL addedSelector = @selector(swizzledApplication:openURL:sourceApplication:annotation:);
        
        if (original)
        {
            class_addMethod([self.delegate class], addedSelector, [self methodForSelector:addedSelector], method_getTypeEncoding(original));
            
            Method swizzle = class_getInstanceMethod([self.delegate class], addedSelector);
            method_exchangeImplementations(original, swizzle);
        }
        else
        {
            addedSelector = @selector(application:openURL:sourceApplication:annotation:);
            
            Method newMethod = class_getInstanceMethod([self class], addedSelector);
            
            class_addMethod([self.delegate class], addedSelector,
                            [self methodForSelector:addedSelector], method_getTypeEncoding(newMethod));
        }
        
    }
}

#pragma mark -
#pragma mark - Hooking setup

- (BOOL)delegateHooked
{
    return !self.delegate || [objc_getAssociatedObject(self, &applicationHookedKey) isEqual:self.delegate];
}

@end
