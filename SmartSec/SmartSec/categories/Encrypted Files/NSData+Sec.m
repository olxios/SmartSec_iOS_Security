//
//  NSData+Sec.m
//  SmartSec
//
//  Created by Olga Dalton on 24/03/15.
//  Copyright (c) 2015 Olga Dalton. All rights reserved.
//

#import "NSData+Sec.h"

#import <objc/runtime.h>
#import "CryptoManager.h"

#import "NSObject+State.h"
#import "SmartSecConfig.h"

#define USE_WHEN_LOCKED ([path hasSuffix:@".enc2"] ? YES : NO)
#define PATH_SUFFIX (useWhenLocked ? @".enc2" : @".enc1")
#define IS_ENCRYPTED ([path hasSuffix:@".enc1"] || [path hasSuffix:@".enc2"])

/*
 
 Supported && tested methods:
 
 - (BOOL)writeToFile:(NSString *)path atomically:(BOOL)useAuxiliaryFile;
 - (BOOL)writeToURL:(NSURL *)url atomically:(BOOL)atomically; // the atomically flag is ignored if the url is not of a type the supports atomic writes
 - (BOOL)writeToFile:(NSString *)path options:(NSDataWritingOptions)writeOptionsMask error:(NSError **)errorPtr;
 - (BOOL)writeToURL:(NSURL *)url options:(NSDataWritingOptions)writeOptionsMask error:(NSError **)errorPtr;
 
 + (instancetype)dataWithContentsOfFile:(NSString *)path options:(NSDataReadingOptions)readOptionsMask error:(NSError **)errorPtr;
 + (instancetype)dataWithContentsOfURL:(NSURL *)url options:(NSDataReadingOptions)readOptionsMask error:(NSError **)errorPtr;
 + (instancetype)dataWithContentsOfFile:(NSString *)path;
 + (instancetype)dataWithContentsOfURL:(NSURL *)url;
 - (instancetype)initWithContentsOfFile:(NSString *)path options:(NSDataReadingOptions)readOptionsMask error:(NSError **)errorPtr;
 - (instancetype)initWithContentsOfURL:(NSURL *)url options:(NSDataReadingOptions)readOptionsMask error:(NSError **)errorPtr;
 - (instancetype)initWithContentsOfFile:(NSString *)path;
 - (instancetype)initWithContentsOfURL:(NSURL *)url;
 
 */

@implementation NSData (Sec)

#pragma mark -
#pragma mark - Swizzled save methods

- (BOOL)swizzledWriteToFile:(NSString *)path atomically:(BOOL)useAuxiliaryFile
{
    NSData *encryptedData = [self encryptedDataAvailableLocked:NO];
    
    path = [self filePathToSave:path withSuffix:@".enc1"];
    
    return [encryptedData
            swizzledWriteToFile:path
            atomically:useAuxiliaryFile];
}

- (BOOL)swizzledWriteToFile:(NSString *)path options:(NSDataWritingOptions)writeOptionsMask error:(NSError **)errorPtr
{
    BOOL useWhenLocked = (writeOptionsMask != NSDataWritingFileProtectionComplete);
    
    path = [self filePathToSave:path withSuffix:PATH_SUFFIX];
    
    return [[self encryptedDataAvailableLocked:useWhenLocked] swizzledWriteToFile:path 
                                                                          options:writeOptionsMask
                                                                            error:errorPtr];
}

- (NSData *)encryptedDataAvailableLocked:(BOOL)useWhenLocked
{
    if (![NSData encryptionDisabled] // Encryption enabled
        && [self length] <= getThresholdFileSize()) // Data is not too big
    {
        return getEncryptedDataWithoutHash(self, useWhenLocked);
    }
    
    return self;
}

#pragma mark -
#pragma mark - Swizzled read methods

// Swizzled method name convention will be different here
// Because we need to assign to self,
// which can be done only in the method starting with init
- (instancetype)initWithContentsOfFileSwizzled:(NSString *)path options:(NSDataReadingOptions)readOptionsMask error:(NSError **)errorPtr
{
    path = [self encryptedFilePath:path];
    
    NSData *data = [self initWithContentsOfFileSwizzled:path options:readOptionsMask error:errorPtr];
    
    if (data && IS_ENCRYPTED)
    {
        // We need to assing data instance to self here
        // Otherwise self will be over-released,
        // because it is autoreleased here and in the calling method
        self = getDecryptedData(data, USE_WHEN_LOCKED);
    }
    
    return self;
}

- (instancetype)initWithContentsOfFileSwizzled:(NSString *)path
{
    path = [self encryptedFilePath:path];
    
    NSData *data = [self initWithContentsOfFileSwizzled:path];
    
    if (data && IS_ENCRYPTED)
    {
        self = getDecryptedData(data, USE_WHEN_LOCKED);
    }
    
    return self;
}

#pragma mark -
#pragma mark - Helper methods

- (NSString *)filePathToSave:(NSString *)path withSuffix:(NSString *)suffix
{
    if (![NSData encryptionDisabled])
    {
        return [path stringByAppendingString:suffix];
    }
    
    return path;
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
#pragma mark - Plaintext writing

- (BOOL)writePlaintextToFile:(NSString *)path atomically:(BOOL)useAuxiliaryFile
{
    return [self swizzledWriteToFile:path atomically:useAuxiliaryFile];
}

- (BOOL)writePlaintextToURL:(NSURL *)url atomically:(BOOL)atomically
{
    return [self swizzledWriteToFile:[url path] atomically:atomically];
}

- (BOOL)writePlaintextToFile:(NSString *)path options:(NSDataWritingOptions)writeOptionsMask error:(NSError **)errorPtr
{
    return [self swizzledWriteToFile:path options:writeOptionsMask error:errorPtr];
}

- (BOOL)writePlaintextToURL:(NSURL *)url options:(NSDataWritingOptions)writeOptionsMask error:(NSError **)errorPtr
{
    return [self swizzledWriteToFile:[url path] options:writeOptionsMask error:errorPtr];
}

#pragma mark -
#pragma mark - Test methods

+ (instancetype)plainDataWithContentsOfFile:(NSString *)path
{
    return [[self alloc] initWithContentsOfFileSwizzled:path];
}

#pragma mark -
#pragma mark - Swizzle

+ (void)load
{
    SEL originalMethods[] = {@selector(writeToFile:atomically:),
                            @selector(writeToFile:options:error:),
                            @selector(initWithContentsOfFile:options:error:),
                            @selector(initWithContentsOfFile:)};
    
    SEL newMethods[] = {@selector(swizzledWriteToFile:atomically:),
                        @selector(swizzledWriteToFile:options:error:),
                        @selector(initWithContentsOfFileSwizzled:options:error:),
                        @selector(initWithContentsOfFileSwizzled:)};
    
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
