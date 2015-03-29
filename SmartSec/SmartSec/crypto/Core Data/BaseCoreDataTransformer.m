//
//  CoreDataBaseTransformer.m
//  SmartSec
//
//  Created by Olga Dalton on 23/03/15.
//  Copyright (c) 2015 Olga Dalton. All rights reserved.
//

#import "BaseCoreDataTransformer.h"
#import "CryptoManager.h"

#define ENCODED_HEADER(X) [NSString stringWithFormat:@"%02d", X]

static NSString *kValueKey = @"dataValue";
static NSString *kTypeKey = @"dataType";
static NSNumberFormatter *formatter = nil;
static NSNumberFormatter *decimalNumberFormatter = nil;
static NSStringEncoding defaultStringEncoding = NSUTF8StringEncoding;

@implementation BaseCoreDataTransformer

#pragma mark -
#pragma mark - Config

+ (void)setStringEncoding:(NSStringEncoding)encoding
{
    defaultStringEncoding = encoding;
}

#pragma mark -
#pragma mark - Transformable

+ (BOOL)allowsReverseTransformation
{
    return YES;
}

- (id)transformedValue:(id)value
{
    if ([value isKindOfClass:[NSNumber class]])
    {
        // Avoid using property lists (NSKeyedArchiver), as they are big
        NSString *numberString = [[self numberFormatter] stringFromNumber:value];
        return getEncryptedDataWithoutHash([self addClassHeaderToData:[numberString dataUsingEncoding:NSUTF8StringEncoding]
                                withClass:[NSNumber class]], NO);
    }
    else if ([value isKindOfClass:[NSDecimalNumber class]])
    {
        NSString *numberString = [[self decimalNumberFormatter] stringFromNumber:value];
        return getEncryptedDataWithoutHash([self addClassHeaderToData:[numberString dataUsingEncoding:NSUTF8StringEncoding]
                                withClass:[NSDecimalNumber class]], NO);
    }
    else if ([value isKindOfClass:[NSString class]])
    {
        return getEncryptedDataWithoutHash([self addClassHeaderToData:[value dataUsingEncoding:defaultStringEncoding]
                                withClass:[NSString class]], NO);
    }
    else if ([value isKindOfClass:[NSDate class]])
    {
        NSString *dateString = [[self numberFormatter] stringFromNumber:@([value timeIntervalSinceReferenceDate])];
        return getEncryptedDataWithoutHash([self addClassHeaderToData:[dateString dataUsingEncoding:NSUTF8StringEncoding]
                                withClass:[NSDate class]], NO);
    }
    else if ([value isKindOfClass:[NSData class]])
    {
        return getEncryptedDataWithoutHash(value, NO);
    }
    
    // This will crash because of unsupported value
    // Core data without transformers would also crash
    return nil;
}

- (id)reverseTransformedValue:(id)value
{
    if ([value isKindOfClass:[NSData class]])
    {
        Class dataClass = [self dataClass:value];
        
        NSData *data = getDecryptedData([self dataContent:value], NO);
        
        if (dataClass == [NSNumber class])
        {
            NSString *string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            return [[self numberFormatter] numberFromString:string];
        }
        else if (dataClass == [NSDecimalNumber class])
        {
            NSString *string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            return [[self decimalNumberFormatter] numberFromString:string];
        }
        else if (dataClass == [NSString class])
        {
            return [[NSString alloc] initWithData:value encoding:defaultStringEncoding];
        }
        else if (dataClass == [NSDate class])
        {
            NSString *string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            NSTimeInterval timeInterval = [string doubleValue];
            return [NSDate dateWithTimeIntervalSinceReferenceDate:timeInterval];
        }
        else if (dataClass == [NSData class])
        {
            return value;
        }
    }
    
    return nil;
}

#pragma mark -
#pragma mark - Helper methods

- (NSNumberFormatter *)numberFormatter
{
    if (!formatter)
    {
        formatter = [[NSNumberFormatter alloc] init];
    }
    
    return formatter;
}

- (NSNumberFormatter *)decimalNumberFormatter
{
    if (!decimalNumberFormatter)
    {
        decimalNumberFormatter = [[NSNumberFormatter alloc] init];
        decimalNumberFormatter.generatesDecimalNumbers = YES;
    }
    
    return decimalNumberFormatter;
}

- (NSData *)addClassHeaderToData:(NSData *)data withClass:(Class)class
{
    int classEncoding = [self classEncoding:class];
    NSData *encodedData = [ENCODED_HEADER(classEncoding) dataUsingEncoding:NSUTF8StringEncoding];
    NSMutableData *resultData = [NSMutableData dataWithData:encodedData];
    [resultData appendData:data];
    return resultData;
}

- (Class)dataClass:(NSData *)data
{
    // Validate that data has first two bytes (data type)
    if ([data length] >= 2)
    {
        int type = [[[NSString alloc] initWithData:[data subdataWithRange:NSMakeRange(0, 2)] encoding:NSUTF8StringEncoding] intValue];
        
        return [self encodedClass:type];
    }
    
    return nil;
}

- (NSData *)dataContent:(NSData *)data
{
    if ([data length] > 2)
    {
        return [data subdataWithRange:NSMakeRange(2, [data length] - 2)];
    }
    
    return nil;
}

- (int)classEncoding:(Class)class
{
    if (class == [NSNumber class])
    {
        return 1;
    }
    else if (class == [NSDecimalNumber class])
    {
        return 2;
    }
    else if (class == [NSString class])
    {
        return 3;
    }
    else if (class == [NSDate class])
    {
        return 4;
    }
    else if (class == [NSData class])
    {
        return 5;
    }
    
    // This class is not supported by Core Data
    return -1;
}

- (Class)encodedClass:(int)encoding
{
    switch (encoding)
    {
        case 1:
            return [NSNumber class];
            
        case 2:
            return [NSDecimalNumber class];
            
        case 3:
            return [NSString class];
            
        case 4:
            return [NSDate class];
            
        case 5:
            return [NSData class];
            
        default:
            return nil;
            break;
    }
}

@end
