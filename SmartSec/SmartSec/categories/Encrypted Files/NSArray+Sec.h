//
//  NSArray+Sec.h
//  SmartSec
//
//  Created by Olga Dalton on 25/03/15.
//  Copyright (c) 2015 Olga Dalton. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSArray (Sec)

- (BOOL)writePlaintextToFile:(NSString *)path atomically:(BOOL)useAuxiliaryFile;
- (BOOL)writePlaintextToURL:(NSURL *)url atomically:(BOOL)atomically;

@end
