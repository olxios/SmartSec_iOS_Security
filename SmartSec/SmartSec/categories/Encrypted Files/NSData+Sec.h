//
//  NSData+Sec.h
//  SmartSec
//
//  Created by Olga Dalton on 24/03/15.
//  Copyright (c) 2015 Olga Dalton. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSData (Sec)

- (BOOL)writePlaintextToFile:(NSString *)path atomically:(BOOL)useAuxiliaryFile;
- (BOOL)writePlaintextToURL:(NSURL *)url atomically:(BOOL)atomically;
- (BOOL)writePlaintextToFile:(NSString *)path options:(NSDataWritingOptions)writeOptionsMask error:(NSError **)errorPtr;
- (BOOL)writePlaintextToURL:(NSURL *)url options:(NSDataWritingOptions)writeOptionsMask error:(NSError **)errorPtr;

// Just for testing
+ (instancetype)plainDataWithContentsOfFile:(NSString *)path;

@end
