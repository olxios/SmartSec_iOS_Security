//
//  CoreDataBaseTransformer.h
//  SmartSec
//
//  Created by Olga Dalton on 23/03/15.
//  Copyright (c) 2015 Olga Dalton. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BaseCoreDataTransformer : NSValueTransformer

+ (void)setStringEncoding:(NSStringEncoding)encoding;

@end
