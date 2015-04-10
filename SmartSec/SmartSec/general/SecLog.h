//
//  SecLog.h
//  SmartSec
//
//  Created by Olga Dalton on 07/04/15.
//  Copyright (c) 2015 Olga Dalton. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SecLog : NSObject

extern void SSLog(BOOL releaseLog, NSString *format, ...) NS_FORMAT_FUNCTION(2,3);

@end
