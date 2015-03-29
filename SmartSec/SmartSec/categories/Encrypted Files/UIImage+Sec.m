//
//  UIImage+Sec.m
//  SmartSec
//
//  Created by Olga Dalton on 25/03/15.
//  Copyright (c) 2015 Olga Dalton. All rights reserved.
//

#import "UIImage+Sec.h"
#import <objc/runtime.h>
#define IS_ENCRYPTED ([newPath hasSuffix:@".enc1"] || [newPath hasSuffix:@".enc2"])

@implementation UIImage (Sec)

- (instancetype)initWithContentsOfFileSwizzled:(NSString *)path
{
    NSString *newPath = [self encryptedFilePath:path];
    
    if (IS_ENCRYPTED)
    {
        NSData *data = [NSData dataWithContentsOfFile:path];
        self = [UIImage imageWithData:data];
        return self;
    }
    else return [self initWithContentsOfFileSwizzled:path];
}

- (NSString *)encryptedFilePath:(NSString *)path
{
    if ([[NSFileManager defaultManager] fileExistsAtPath:[path stringByAppendingString:@".enc1"]])
    {
        return [path stringByAppendingString:@".enc1"];
    }
    else if ([[NSFileManager defaultManager] fileExistsAtPath:[path stringByAppendingString:@".enc2"]])
    {
        return [path stringByAppendingString:@".enc2"];
    }
    
    return path;
}

#pragma mark -
#pragma mark - Swizzle

+ (void)load
{
    SEL originalMethods[] = {@selector(initWithContentsOfFile:)};
    
    SEL newMethods[] = {@selector(initWithContentsOfFileSwizzled:)};
    
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
