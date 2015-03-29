//
//  DebugCheck.m
//  SmartSec
//
//  Created by Olga Dalton on 09/03/15.
//  Copyright (c) 2015 Olga Dalton. All rights reserved.
//

// General imports
#import "DebugCheck1.h"
#import "Defines.h"
#import <UIKit/UIKit.h>

// Categories
#import "UIApplication+Sec.h"
#import "NSObject+State.h"

// Debugger checks
#import <dlfcn.h>
#import <sys/types.h>

// Inline functions
FORCE_INLINE void disable_debugger_check1();

// Defines
typedef int (*ptrace_ptr_t)(int _request, pid_t _pid, caddr_t _addr, int _data);
#if !defined(PT_DENY_ATTACH)
#define PT_DENY_ATTACH 31 // define the code if not found
#endif

@implementation DebugCheck1

#pragma mark -
#pragma mark - BaseChecksTemplate

- (void)hookChecks
{
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
    disable_debugger_check1();
#endif
}

#pragma mark -
#pragma mark - Run checks

- (void)runChecks
{
#if ENABLE_CHECKS
    disable_debugger_check1();
#endif
}

// Standard ptrace check
void disable_debugger_check1()
{    
    void* handle = dlopen(0, RTLD_GLOBAL | RTLD_NOW);
    ptrace_ptr_t ptrace_ptr = dlsym(handle, "ptrace");
    ptrace_ptr(PT_DENY_ATTACH, 0, 0, 0);
    dlclose(handle);
}

@end
