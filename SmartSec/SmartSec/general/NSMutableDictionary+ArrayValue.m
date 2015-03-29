//
//  NSMutableDictionary+ArrayValue.m
//  SmartSec
//
//  Created by Olga Dalton on 17/03/15.
//  Copyright (c) 2015 Olga Dalton. All rights reserved.
//

#import "NSMutableDictionary+ArrayValue.h"

@implementation NSMutableDictionary (ArrayValue)

- (void)addItem:(id)item forKey:(id)key
{
    NSMutableArray *array = self[key];
    
    if (array && [array isKindOfClass:[NSMutableArray class]])
    {
        [array addObject:item];
        self[key] = array;
    }
    else
    {
        array = [NSMutableArray array];
        [array addObject:item];
        self[key] = array;
    }
}

@end
