//
//  SecImports.h
//  SmartSec
//
//  Created by Olga Dalton on 07/04/15.
//  Copyright (c) 2015 Olga Dalton. All rights reserved.
//

#import <SmartSec/SecLog.h>

/******
 NSLog defines
 
 NSLog works only in the debug mode
 To log in release mode, ReleaseLog should be used
 ******/
#define NSLog(...) SSLog(NO, __VA_ARGS__)
#define ReleaseLog(...) SSLog(YES, __VA_ARGS__)