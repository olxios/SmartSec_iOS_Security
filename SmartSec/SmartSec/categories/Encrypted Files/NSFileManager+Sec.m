//
//  NSFileManager+Sec.m
//  SmartSec
//
//  Created by Olga Dalton on 24/03/15.
//  Copyright (c) 2015 Olga Dalton. All rights reserved.
//

#import "NSFileManager+Sec.h"
#import <objc/runtime.h>

@implementation NSFileManager (Sec)

#pragma mark -
#pragma mark - Swizzled methods

- (BOOL)swizzledRemoveItemAtPath:(NSString *)path error:(NSError **)error
{
    path = [self encryptedFilePath:path];
    return [self swizzledRemoveItemAtPath:path error:error];
}

- (NSString *)encryptedFilePath:(NSString *)path
{
    if ([self fileExistsAtPath:[path stringByAppendingString:@".enc1"]])
    {
        return [path stringByAppendingString:@".enc1"];
    }
    else if ([self fileExistsAtPath:[path stringByAppendingString:@".enc2"]])
    {
        return [path stringByAppendingString:@".enc2"];
    }
    
    return path;
}

#pragma mark -
#pragma mark - Swizzle

+ (void)load
{
    SEL originalMethods[] = {@selector(removeItemAtPath:error:)};
    
    SEL newMethods[] = {@selector(swizzledRemoveItemAtPath:error:)};
    
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
