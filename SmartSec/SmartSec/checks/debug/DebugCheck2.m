//
//  DebugCheck2.m
//  SmartSec
//
//  Created by Olga Dalton on 21/03/15.
//  Copyright (c) 2015 Olga Dalton. All rights reserved.
//

#import "DebugCheck2.h"

// General imports
#import "Defines.h"
#import <UIKit/UIKit.h>

// Categories
#import "UIApplication+Sec.h"
#import "NSObject+State.h"

// Debugger check imports
#import <stdio.h>
#import <sys/types.h>
#import <unistd.h>
#import <sys/sysctl.h>
#import <stdlib.h>

// Inline functions
FORCE_INLINE void disable_debugger_check2();

@implementation DebugCheck2

#pragma mark -
#pragma mark - BaseChecksTemplate

- (void)hookChecks
{
    // TODO: verify this one!
    [UIApplication addObserver:self];
    [UIViewController addObserver:self];
}

- (void)unhookChecks
{
    [UIApplication removeObserver:self];
    [UIViewController removeObserver:self];
}

#pragma mark -
#pragma mark - OnStateChangeListener

- (void)onStateChanged:(id)stateObject fromObject:(id)observedObject
{
#if ENABLE_CHECKS
    // Disable debugger only in the release mode!
    disable_debugger_check2();
#endif
}

#pragma mark -
#pragma mark - Run checks

- (void)runChecks
{
#if ENABLE_CHECKS
    // Disable debugger only in the release mode!
    disable_debugger_check2();
#endif
}

// Less standard process check
void disable_debugger_check2()
{    
    // This check is based on this post
    // http://www.coredump.gr/articles/ios-anti-debugging-protections-part-2/
    
    int name[4];
    struct kinfo_proc info;
    size_t info_size = sizeof(info);
    
    info.kp_proc.p_flag = 0;
    
    name[0] = CTL_KERN; // kernel specific information
    name[1] = KERN_PROC; // return a structure with process entities
    name[2] = KERN_PROC_PID; // select target process based on the process id
    name[3] = getpid(); // get current process id
    
    // -1 indicates some error
    if (sysctl(name, 4, &info, &info_size, NULL, 0) != -1)
    {
        BOOL isDebugged = ((info.kp_proc.p_flag & P_TRACED) != 0);
        
        if (isDebugged)
        {
            [UIApplication killMe];
            exit(-1); // extra call to kill the app
        }
    }
}

@end
