//
//  NSUserDefaults+Sec.m
//  SmartSec
//
//  Created by Olga Dalton on 21/03/15.
//  Copyright (c) 2015 Olga Dalton. All rights reserved.
//

#import "NSUserDefaults+Sec.h"
#import <objc/runtime.h>
#import "CryptoManager.h"
#import "NSObject+State.h"

/*
 
 Supported && Tested methods:
 
 - (id)objectForKey:(NSString *)defaultName; +
 - (void)setObject:(id)value forKey:(NSString *)defaultName; +
 - (void)removeObjectForKey:(NSString *)defaultName; +
 
 - (NSString *)stringForKey:(NSString *)defaultName; +
 - (NSArray *)arrayForKey:(NSString *)defaultName; +
 - (NSDictionary *)dictionaryForKey:(NSString *)defaultName; +
 - (NSData *)dataForKey:(NSString *)defaultName; +
 - (NSArray *)stringArrayForKey:(NSString *)defaultName; +
 
 - (NSInteger)integerForKey:(NSString *)defaultName; +
 - (float)floatForKey:(NSString *)defaultName; +
 - (double)doubleForKey:(NSString *)defaultName; +
 - (BOOL)boolForKey:(NSString *)defaultName; +
 - (NSURL *)URLForKey:(NSString *)defaultName NS_AVAILABLE(10_6, 4_0); +
 
 - (void)setInteger:(NSInteger)value forKey:(NSString *)defaultName; +
 - (void)setFloat:(float)value forKey:(NSString *)defaultName; +
 - (void)setDouble:(double)value forKey:(NSString *)defaultName; +
 - (void)setBool:(BOOL)value forKey:(NSString *)defaultName; +
 - (void)setURL:(NSURL *)url forKey:(NSString *)defaultName NS_AVAILABLE(10_6, 4_0); +
 
 */

@implementation NSUserDefaults (Sec)

#pragma mark -
#pragma mark - Swizzled methods

- (void)swizzledSetObject:(id)value forKey:(NSString *)defaultName
{
    if (![NSUserDefaults encryptionDisabled]
        && value
        && [[value class] conformsToProtocol:@protocol(NSCoding)])
    {
        NSData *valueData = value;
        
        if (![value isKindOfClass:[NSData class]])
        {
            // No need to encode objects in NSData format
            valueData = [NSKeyedArchiver archivedDataWithRootObject:value];
        }
        
        NSData *encryptedData = getEncryptedData(valueData, NO);
        [self swizzledSetObject:encryptedData forKey:defaultName];
    }
    else
    {
        [self swizzledSetObject:value forKey:defaultName];
    }
}

- (id)swizzledObjectForKey:(NSString *)defaultName
{
    NSData *object = [self swizzledObjectForKey:defaultName];
    
    if (object && [object isKindOfClass:[NSData class]])
    {
        NSData *encryptedData = validateEncryptedData(object);
        
        if (!encryptedData)
        {
            // This data field is not encrypted!
            // Just return the object
            return object;
        }
        
        NSData *decryptedData = getDecryptedData(encryptedData, NO);
                
        if (decryptedData)
        {
            id unarchieved = nil;
            
            @try
            {
                // http://stackoverflow.com/questions/17299396/nskeyedunarchiver-try-catch-needed
                // NSKeyedUnarchiver throws exceptions...
                unarchieved = [NSKeyedUnarchiver unarchiveObjectWithData:decryptedData];
                return unarchieved;
            }
            @catch (NSException *exception)
            {
                return decryptedData;
            }
        }
    }
    
    return object;
}

- (NSInteger)swizzledIntegerForKey:(NSString *)defaultName
{
    NSNumber *result = [self objectForKey:defaultName];
    
    if (result && [result isKindOfClass:[NSNumber class]])
    {
        return [result integerValue];
    }
    
    return [self swizzledIntegerForKey:defaultName];
}

- (float)swizzledFloatForKey:(NSString *)defaultName
{
    NSNumber *result = [self objectForKey:defaultName];
    
    if (result && [result isKindOfClass:[NSNumber class]])
    {
        return [result floatValue];
    }
    
    return [self swizzledFloatForKey:defaultName];
}

- (double)swizzledDoubleForKey:(NSString *)defaultName
{
    NSNumber *result = [self objectForKey:defaultName];
    
    if (result && [result isKindOfClass:[NSNumber class]])
    {
        return [result doubleValue];
    }
    
    return [self swizzledDoubleForKey:defaultName];
}

- (BOOL)swizzledBoolForKey:(NSString *)defaultName
{
    NSNumber *result = [self objectForKey:defaultName];
    
    if (result && [result isKindOfClass:[NSNumber class]])
    {
        return [result boolValue];
    }
    
    return [self swizzledBoolForKey:defaultName];
}

- (NSURL *)swizzledURLForKey:(NSString *)defaultName
{
    id decryptedObject = [self objectForKey:defaultName];
    
    if (decryptedObject
        && [decryptedObject isKindOfClass:[NSURL class]])
    {
        return decryptedObject;
    }
    else
    {
        @try
        {
            NSURL *result = [NSKeyedUnarchiver unarchiveObjectWithData:
                             [self swizzledObjectForKey:defaultName]];
            
            if (result && [result isKindOfClass:[NSURL class]])
            {
                return result;
            }
        }
        @catch (NSException *exception)
        {
            return [self swizzledURLForKey:defaultName];
        }
    }
}

#pragma mark -
#pragma mark - Encryption disabled methods

- (void)setPlainObject:(id)value forKey:(NSString *)defaultName
{
    [self swizzledSetObject:value forKey:defaultName];
}

- (void)setPlainInteger:(NSInteger)value forKey:(NSString *)defaultName
{
    [self swizzledSetObject:@(value) forKey:defaultName];
}

// NSURL is internally saved as an archieved object
// Retrieving saved NSURL using objectForKey:
// and not URLForKey: should return bunch of data,
// which represents archieved NSURL object
// It is default behaviour in Apple classes
// and SmartSec follows same approach

- (void)setPlainURL:(NSURL *)url forKey:(NSString *)defaultName
{
    NSData *archivedURL = [NSKeyedArchiver archivedDataWithRootObject:url];
    
    [self swizzledSetObject:archivedURL
                     forKey:defaultName];
}

- (void)setPlainFloat:(float)value forKey:(NSString *)defaultName
{
    [self swizzledSetObject:@(value) forKey:defaultName];
}

- (void)setPlainDouble:(double)value forKey:(NSString *)defaultName
{
    [self swizzledSetObject:@(value) forKey:defaultName];
}

- (void)setPlainBool:(BOOL)value forKey:(NSString *)defaultName
{
    [self swizzledSetObject:@(value) forKey:defaultName];
}

#pragma mark -
#pragma mark - Test methods

- (id)plainObjectForKey:(NSString *)defaultName
{
    return [self swizzledObjectForKey:defaultName];
}

#pragma mark - 
#pragma mark - Swizzle

+ (void)load
{
    SEL originalMethods[] = {@selector(setObject:forKey:),
                            @selector(objectForKey:),
                            @selector(integerForKey:),
                            @selector(floatForKey:),
                            @selector(doubleForKey:),
                            @selector(boolForKey:),
                            @selector(URLForKey:)};
    
    SEL newMethods[] = {@selector(swizzledSetObject:forKey:),
                        @selector(swizzledObjectForKey:),
                        @selector(swizzledIntegerForKey:),
                        @selector(swizzledFloatForKey:),
                        @selector(swizzledDoubleForKey:),
                        @selector(swizzledBoolForKey:),
                        @selector(swizzledURLForKey:)};
    
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
