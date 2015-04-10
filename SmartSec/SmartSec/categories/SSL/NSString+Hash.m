//
//  NSString+Hash.m
//  SmartSec
//
//  Created by Olga Dalton on 08/04/15.
//  Copyright (c) 2015 Olga Dalton. All rights reserved.
//  From: http://stackoverflow.com/questions/6228092/how-can-i-compute-a-sha-2-ideally-sha-256-or-sha-512-hash-in-ios
//

#import "NSString+Hash.h"
#import <CommonCrypto/CommonCrypto.h>

@implementation NSString (Hash)

- (NSString *)sha256
{
    const char *cstr = [self cStringUsingEncoding:NSUTF8StringEncoding];
    NSData *data = [NSData dataWithBytes:cstr length:self.length];
    uint8_t digest[CC_SHA256_DIGEST_LENGTH];
    
    // This is an iOS5-specific method.
    // It takes in the data, how much data, and then output format, which in this case is an int array.
    CC_SHA256(data.bytes, (int)data.length, digest);
    
    NSMutableString* output = [NSMutableString stringWithCapacity:CC_SHA256_DIGEST_LENGTH * 2];
    
    // Parse through the CC_SHA256 results (stored inside of digest[]).
    for(int i = 0; i < CC_SHA256_DIGEST_LENGTH; i++) {
        [output appendFormat:@"%02x", digest[i]];
    }
    
    return output;
}

- (NSString *)secKeyDescription
{
    NSString *regexString = @"(, addr: 0x(?:.*))>";
    
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:regexString options:NSRegularExpressionCaseInsensitive error:NULL];
    
    NSArray *matches = [regex matchesInString:self options:0 range:NSMakeRange(0, [self length])];
    
    if ([matches count] == 1)
    {
        NSTextCheckingResult *matchResult = matches[0];
        NSString *match = [self substringWithRange:[matchResult range]];
        
        return [self stringByReplacingOccurrencesOfString:match withString:@""];
    }
    
    return self;
}

@end
