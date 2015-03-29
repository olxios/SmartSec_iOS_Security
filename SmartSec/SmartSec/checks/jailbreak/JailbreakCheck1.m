//
//  JailbreakCheck1.m
//  SmartSec
//
//  Created by Olga Dalton on 19/03/15.
//  Copyright (c) 2015 Olga Dalton. All rights reserved.
//

#import "JailbreakCheck1.h"

// General imports
#import "LOOCryptString.h"

// Categories imports
#import "UIApplication+Sec.h"
#import "NSObject+State.h"

// Jailbreak checks
#import <sys/stat.h>

// Inline functions
FORCE_INLINE void checkJailbreakSymLink(JailbreakCheck1 *selfRef, NSString *checkPath);
FORCE_INLINE void checkJailbreakPassive(JailbreakCheck1 *selfRef);
FORCE_INLINE void jailbreak1Detected(JailbreakCheck1 *selfRef, JailbreakDetectionType type);

@implementation JailbreakCheck1

#pragma mark -
#pragma mark - BaseChecksTemplate

- (void)hookChecks
{
    [UIViewController addObserver:self];
    [UIWindow addObserver:self];
}

- (void)unhookChecks
{
    [UIViewController removeObserver:self];
    [UIWindow removeObserver:self];
}

#pragma mark -
#pragma mark - OnStateChangeListener

- (void)onStateChanged:(id)stateObject fromObject:(id)observedObject
{
    if (([stateObject isKindOfClass:[NSString class]]
        && [stateObject isEqualToString:NSStringFromSelector(@selector(viewDidLoad))])
        || ![observedObject isKindOfClass:[UIViewController class]])
    {
#if ENABLE_CHECKS
        checkJailbreakPassive(self);
#endif
    }
}

#pragma mark -
#pragma mark - Run checks

- (void)runChecks
{
#if ENABLE_CHECKS
    checkJailbreakPassive(self);
#endif
}

void checkJailbreakPassive(JailbreakCheck1 *selfRef)
{    
    NSArray *linksChecks = @[LOO_CRYPT_STR_N("/Applications", 13),
                        LOO_CRYPT_STR_N("/usr/libexec", 12),
                        LOO_CRYPT_STR_N("/usr/share", 10),
                        LOO_CRYPT_STR_N("/Library/Wallpaper", 18),
                        LOO_CRYPT_STR_N("/usr/include", 12)];
    
    for (NSString *checkPath in linksChecks)
    {
        checkJailbreakSymLink(selfRef, checkPath);
    }
    
    NSArray *fileChecks = @[LOO_CRYPT_STR_N("/bin/bash", 9),
                            LOO_CRYPT_STR_N("/etc/apt", 8),
                            LOO_CRYPT_STR_N("/usr/sbin/sshd", 14),
                            LOO_CRYPT_STR_N("/Library/MobileSubstrate/MobileSubstrate.dylib", 46),
                            LOO_CRYPT_STR_N("/Applications/Cydia.app", 23),
                            LOO_CRYPT_STR_N("/bin/sh", 7),
                            LOO_CRYPT_STR_N("/var/cache/apt", 14),
                            LOO_CRYPT_STR_N("/var/tmp/cydia.log", 18)];
    
    for (NSString *checkPath in fileChecks)
    {
        checkJailbreakFile(selfRef, checkPath);
    }
}

/*
 If /Applications directory is a symbolic link as opposed to a directory
 you can be confident that the device is jailbroken.
 Source: The Mobile Application Hacker's Handbook
 By Dominic Chell,Tyrone Erasmus,Jon Lindsay,Shaun Colley,Ollie Whitehouse
 */

void checkJailbreakSymLink(JailbreakCheck1 *selfRef, NSString *checkPath)
{
    struct stat s;
    
    if (lstat([checkPath UTF8String], &s) == 0)
    {
        if (S_ISLNK(s.st_mode) == 1)
        {
            jailbreak1Detected(selfRef, SymLinks);
        }
    }
}

void checkJailbreakFile(JailbreakCheck1 *selfRef, NSString *checkPath)
{
    struct stat s;
        
    if (stat([checkPath UTF8String], &s) == 0)
    {
        jailbreak1Detected(selfRef, Files);
    }
}

void jailbreak1Detected(JailbreakCheck1 *selfRef, JailbreakDetectionType type)
{
    if (selfRef.jailbreakCallback)
    {
        selfRef.jailbreakCallback(type);
    }
    else
    {
        [UIApplication killMe];
        exit(-1); // extra call to kill the app
    }
}

@end
