//
//  UIView+Sec.m
//  SmartSec
//
//  Created by Olga Dalton on 07/04/15.
//  Copyright (c) 2015 Olga Dalton. All rights reserved.
//

#import "UIView+SecText.h"
#import "UIViewController+SecText.h"
#import <objc/runtime.h>

static char textFieldsKey;

@implementation UIView (SecText)
@dynamic insecureEntry;

#pragma mark -
#pragma mark - Settings

- (void)setInsecureEntry:(BOOL)insecureEntry
{
    for (UITextField *textField in self.textFields)
    {
        textField.insecureEntry = insecureEntry;
    }
}

- (BOOL)insecureEntry
{
    return NO;
}

#pragma mark -
#pragma mark - Add Subview

- (void)swizzleAddSubview:(UIView *)view
{
    [self swizzleAddSubview:view];
    
    if (view.textFields)
    {
        [self addMultipleTextFields:view.textFields];
    }
    
    if ([view isKindOfClass:[UITextField class]])
    {
        [self addTextField:(UITextField *) view];
        
        // Each view will have access to all its direct
        // subviews-textfields and textfields, which are subviews of subviews
        if (self.superview)
        {
            [self.superview addTextField:(UITextField *) view];
        }
    }
}

- (void)addTextField:(UITextField *)textField
{
    if (!self.textFields)
    {
        NSHashTable *hashTable = [NSHashTable hashTableWithOptions:NSPointerFunctionsWeakMemory];
        [hashTable addObject:textField];
        
        self.textFields = hashTable;
    }
    else if (![self.textFields containsObject:textField])
    {
        [self.textFields addObject:textField];
    }
}

- (void)addMultipleTextFields:(NSHashTable *)textFields
{
    if (!self.textFields)
    {
        self.textFields = textFields;
    }
    else
    {
        for (NSObject *object in textFields)
        {
            if (![self.textFields containsObject:object])
            {
                [self.textFields addObject:object];
            }
        }
    }
}

#pragma mark -
#pragma mark - TextFields storage

// Will save from having to pass view hierarchy each time
- (void)setTextFields:(NSHashTable *)textFields
{
    objc_setAssociatedObject(self, &textFieldsKey, textFields, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSHashTable *)textFields
{
    return objc_getAssociatedObject(self, &textFieldsKey);
}

#pragma mark -
#pragma mark - Swizzle

+ (void)load
{
    Method original, swizzled;
    original = class_getInstanceMethod(self, @selector(addSubview:));
    swizzled = class_getInstanceMethod(self, @selector(swizzleAddSubview:));
    method_exchangeImplementations(original, swizzled);
}

@end
