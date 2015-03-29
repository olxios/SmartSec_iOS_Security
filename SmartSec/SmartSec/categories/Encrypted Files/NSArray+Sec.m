//
//  NSArray+Sec.m
//  SmartSec
//
//  Created by Olga Dalton on 25/03/15.
//  Copyright (c) 2015 Olga Dalton. All rights reserved.
//

#import "NSArray+Sec.h"
#import "NSData+Sec.h"

@implementation NSArray (Sec)

#pragma mark -
#pragma mark - Plaintext methods

- (BOOL)writePlaintextToFile:(NSString *)path atomically:(BOOL)useAuxiliaryFile
{
    return [[NSPropertyListSerialization dataWithPropertyList:self
                                                       format:NSPropertyListXMLFormat_v1_0
                                                      options:0
                                                        error:nil]
                                         writePlaintextToFile:path
                                                   atomically:useAuxiliaryFile];
}

- (BOOL)writePlaintextToURL:(NSURL *)url atomically:(BOOL)atomically
{
    return [[NSPropertyListSerialization dataWithPropertyList:self
                                                       format:NSPropertyListXMLFormat_v1_0
                                                      options:0
                                                        error:nil]
                                          writePlaintextToURL:url
                                                   atomically:atomically];
}

@end
