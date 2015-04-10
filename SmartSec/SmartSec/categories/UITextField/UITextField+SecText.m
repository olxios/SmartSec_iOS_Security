//
//  UITextField+Sec.m
//  SmartSec
//
//  Created by Olga Dalton on 07/04/15.
//  Copyright (c) 2015 Olga Dalton. All rights reserved.
//

#import "UITextField+SecText.h"
#import <objc/runtime.h>

static char correctionEnabledKey;

@implementation UITextField (SecText)
@dynamic insecureEntry;

#pragma mark -
#pragma mark - Settings

- (void)setInsecureEntry:(BOOL)insecureEntry
{
    self.autocorrectionType = insecureEntry ? UITextAutocorrectionTypeDefault : UITextAutocorrectionTypeNo;
}

- (BOOL)insecureEntry
{
    return !(self.autocorrectionType == UITextAutocorrectionTypeNo);
}

+ (BOOL)correctionDisabled
{
    return [objc_getAssociatedObject(self, &correctionEnabledKey) boolValue];
}

+ (void)setCorrectionDisabled:(BOOL)correctionDisabled
{
    objc_setAssociatedObject(self, &correctionEnabledKey, @(correctionDisabled), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

#pragma mark - 
#pragma mark - Default options

- (instancetype)initWithFrameSwizzled:(CGRect)frame
{    
    self = [self initWithFrameSwizzled:frame];
    
    if ([[self class] correctionDisabled])
    {
        self.autocorrectionType = UITextAutocorrectionTypeNo;
    }
    
    return self;
}

- (instancetype)initWithCoderSwizzled:(NSCoder *)aDecoder
{
    self = [self initWithCoderSwizzled:aDecoder];
    
    if ([[self class] correctionDisabled])
    {
        self.autocorrectionType = UITextAutocorrectionTypeNo;
    }
    
    return self;
}

- (BOOL)swizzledCanPerformAction:(SEL)action withSender:(id)sender
{
    if (![self insecureEntry]
        && ![[self class] correctionDisabled]
        && !(action == @selector(paste:)))
    {
        return NO;
    }
    
    return [self swizzledCanPerformAction:action withSender:sender];
}

#pragma mark -
#pragma mark - Swizzle

+ (void)load
{
    SEL originalMethods[] = {@selector(initWithFrame:),
                            @selector(initWithCoder:),
                            @selector(canPerformAction:withSender:)};
    
    SEL newMethods[] = {@selector(initWithFrameSwizzled:),
                        @selector(initWithCoderSwizzled:),
                        @selector(swizzledCanPerformAction:withSender:)};
    
    Method originalMethod, swizzledMethod;
    
    for (int i = 0; i < (sizeof originalMethods) / (sizeof originalMethods[0]); i++)
    {
        SEL original = originalMethods[i];
        SEL new = newMethods[i];
        
        originalMethod = class_getInstanceMethod(self, original);
        swizzledMethod = class_getInstanceMethod(self, new);
        
        method_exchangeImplementations(originalMethod, swizzledMethod);
    }
}

@end
