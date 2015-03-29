//
//  NSUserDefaults+Sec.h
//  SmartSec
//
//  Created by Olga Dalton on 21/03/15.
//  Copyright (c) 2015 Olga Dalton. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSUserDefaults (Sec)

// Plain object = encryption disabled
- (void)setPlainObject:(id)value forKey:(NSString *)defaultName;

- (void)setPlainInteger:(NSInteger)value forKey:(NSString *)defaultName;
- (void)setPlainFloat:(float)value forKey:(NSString *)defaultName;
- (void)setPlainDouble:(double)value forKey:(NSString *)defaultName;
- (void)setPlainBool:(BOOL)value forKey:(NSString *)defaultName;

- (void)setPlainURL:(NSURL *)url forKey:(NSString *)defaultName;

// This method is for testing && validation only
- (id)plainObjectForKey:(NSString *)defaultName;

@end
