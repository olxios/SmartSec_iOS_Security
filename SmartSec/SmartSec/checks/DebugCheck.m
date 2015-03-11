//
//  DebugCheck.m
//  SmartSec
//
//  Created by Olga Dalton on 09/03/15.
//  Copyright (c) 2015 Olga Dalton. All rights reserved.
//

// General imports
#import "DebugCheck.h"
#import "Defines.h"
#import <UIKit/UIKit.h>

// Categories
#import "UIApplication+Sec.h"
#import "NSObject+State.h"

// Debugger checks
#import <dlfcn.h>
#import <sys/types.h>

#import <stdio.h>
#import <sys/types.h>
#import <unistd.h>
#import <sys/sysctl.h>
#import <stdlib.h>

// Inline functions
FORCE_INLINE void runChecks();
FORCE_INLINE void disable_debugger_check1();
FORCE_INLINE void disable_debugger_check2();

// Defines

typedef int (*ptrace_ptr_t)(int _request, pid_t _pid, caddr_t _addr, int _data);
#if !defined(PT_DENY_ATTACH)
#define PT_DENY_ATTACH 31 // define the code if not found
#endif

@implementation DebugCheck

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
    if ([self filterState:stateObject fromObject:observedObject])
    {
        runChecks();
    }
}

- (BOOL)filterState:(id)stateObject fromObject:(id)observedObject
{
    return [observedObject isKindOfClass:[UIViewController class]]
            || [observedObject isKindOfClass:[UIApplication class]];
}

#pragma mark -
#pragma mark - Run checks

- (void)runChecks
{
    runChecks();
}

void runChecks()
{
    #if !(DEBUG)
        NSLog(@"Debug checks!"); // TODO: remove me
        // Disable debugger only in the release mode!
        disable_debugger_check1(); // 1 = deny attach
        disable_debugger_check2(); // 2 = crash
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
