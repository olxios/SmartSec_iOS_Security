//
//  SecLog.m
//  SmartSec
//
//  Created by Olga Dalton on 07/04/15.
//  Copyright (c) 2015 Olga Dalton. All rights reserved.
//

#import "SecLog.h"

@implementation SecLog

#pragma mark -
#pragma mark - Logging

void SSLog(BOOL releaseLog, NSString *format, ...)
{
#ifndef DEBUG
    if (releaseLog)
    {
#endif
        va_list argumentList;
        va_start(argumentList, format);
        NSLogv(format, argumentList);
        va_end(argumentList);
#ifndef DEBUG
    }
#endif
}

@end
