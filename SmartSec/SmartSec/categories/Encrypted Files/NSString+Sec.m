//
//  NSString+Sec.m
//  SmartSec
//
//  Created by Olga Dalton on 25/03/15.
//  Copyright (c) 2015 Olga Dalton. All rights reserved.
//

#import "NSString+Sec.h"
#import <objc/runtime.h>
#import "NSObject+State.h"
#import "SmartSecConfig.h"
#import "CryptoManager.h"

#define IS_ENCRYPTED ([path hasSuffix:@".enc1"])

@implementation NSString (Sec)

/*
 
 Supported && tested methods:
 
 - (BOOL)writeToURL:(NSURL *)url atomically:(BOOL)useAuxiliaryFile encoding:(NSStringEncoding)enc error:(NSError **)error;
 - (BOOL)writeToFile:(NSString *)path atomically:(BOOL)useAuxiliaryFile encoding:(NSStringEncoding)enc error:(NSError **)error;
 - (instancetype)initWithContentsOfURL:(NSURL *)url encoding:(NSStringEncoding)enc error:(NSError **)error;
 - (instancetype)initWithContentsOfFile:(NSString *)path encoding:(NSStringEncoding)enc error:(NSError **)error;
 + (instancetype)stringWithContentsOfURL:(NSURL *)url encoding:(NSStringEncoding)enc error:(NSError **)error;
 + (instancetype)stringWithContentsOfFile:(NSString *)path encoding:(NSStringEncoding)enc error:(NSError **)error;
 
 Not supported methods (deprecated):
 
 - (BOOL)writeToFile:(NSString *)path atomically:(BOOL)useAuxiliaryFile NS_DEPRECATED(10_0, 10_4, 2_0, 2_0);
 - (BOOL)writeToURL:(NSURL *)url atomically:(BOOL)atomically NS_DEPRECATED(10_0, 10_4, 2_0, 2_0);
 
 - (id)initWithContentsOfFile:(NSString *)path NS_DEPRECATED(10_0, 10_4, 2_0, 2_0);
 - (id)initWithContentsOfURL:(NSURL *)url NS_DEPRECATED(10_0, 10_4, 2_0, 2_0);
 + (id)stringWithContentsOfFile:(NSString *)path NS_DEPRECATED(10_0, 10_4, 2_0, 2_0);
 + (id)stringWithContentsOfURL:(NSURL *)url NS_DEPRECATED(10_0, 10_4, 2_0, 2_0);
 
 Not supported (cannot support due to encoding detection...)
 
 - (instancetype)initWithContentsOfURL:(NSURL *)url usedEncoding:(NSStringEncoding *)enc error:(NSError **)error;
 - (instancetype)initWithContentsOfFile:(NSString *)path usedEncoding:(NSStringEncoding *)enc error:(NSError **)error;
 + (instancetype)stringWithContentsOfURL:(NSURL *)url usedEncoding:(NSStringEncoding *)enc error:(NSError **)error;
 + (instancetype)stringWithContentsOfFile:(NSString *)path usedEncoding:(NSStringEncoding *)enc error:(NSError **)error;
 
 */

#pragma mark -
#pragma mark - Writing methods

- (BOOL)swizzledWriteToFile:(NSString *)path atomically:(BOOL)useAuxiliaryFile encoding:(NSStringEncoding)enc error:(NSError **)error
{
    path = [self filePathToSave:path withSuffix:@".enc1"];
    
    return [[self encryptedString:enc] swizzledWriteToFile:path
                                               atomically:useAuxiliaryFile
                                                 encoding:enc error:error];
}

#pragma mark -
#pragma mark - Reading methods

- (instancetype)initWithContentsOfFileSwizzled:(NSString *)path encoding:(NSStringEncoding)enc error:(NSError **)error
{
    path = [self encryptedFilePath:path];
    
    NSString *string = [self initWithContentsOfFileSwizzled:path encoding:enc error:error];
    
    if (string && IS_ENCRYPTED)
    {
        NSData *decryptedData = getDecryptedData([[NSData alloc] initWithBase64EncodedString:string options:0], NO);
        
        self = [[NSString alloc] initWithData:decryptedData encoding:enc];
    }
    
    return self;
}

#pragma mark -
#pragma mark - Helpers

- (NSString *)encryptedString:(NSStringEncoding)encoding
{
    if (![NSString encryptionDisabled] // Encryption enabled
        && [self lengthOfBytesUsingEncoding:encoding] <= getThresholdFileSize()) // Data is not too big
    {
        return [getEncryptedDataWithoutHash([self dataUsingEncoding:encoding], NO) base64EncodedStringWithOptions:0];
    }
    
    return self;
}

- (NSString *)filePathToSave:(NSString *)path withSuffix:(NSString *)suffix
{
    if (![NSString encryptionDisabled])
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
    
    return path;
}

#pragma mark -
#pragma mark - PlainText writing

- (BOOL)writePlaintextToURL:(NSURL *)url atomically:(BOOL)useAuxiliaryFile encoding:(NSStringEncoding)enc error:(NSError **)error
{
    if ([url isFileURL])
    {
        return [self swizzledWriteToFile:[url path] atomically:useAuxiliaryFile encoding:enc error:error];
    }
    
    return [self writeToURL:url atomically:useAuxiliaryFile encoding:enc error:error];
}

- (BOOL)writePlaintextToFile:(NSString *)path atomically:(BOOL)useAuxiliaryFile encoding:(NSStringEncoding)enc error:(NSError **)error
{
    return [self swizzledWriteToFile:path atomically:useAuxiliaryFile encoding:enc error:error];
}

#pragma mark -
#pragma mark - Swizzle

+ (void)load
{
    SEL originalMethods[] = {@selector(writeToFile:atomically:encoding:error:),
                            @selector(initWithContentsOfFile:encoding:error:)};
    
    SEL newMethods[] = {@selector(swizzledWriteToFile:atomically:encoding:error:),
                        @selector(initWithContentsOfFileSwizzled:encoding:error:)};
    
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
