//
//  JailbreakCheck2.m
//  SmartSec
//
//  Created by Olga Dalton on 19/03/15.
//  Copyright (c) 2015 Olga Dalton. All rights reserved.
//

#import "JailbreakCheck2.h"
#import "UIApplication+Sec.h"
#import "UIViewController+Sec.h"
#import "NSObject+State.h"

#import "Defines.h"
#import "LOOCryptString.h"

// Inline functions
FORCE_INLINE void checkJailbreakActive(JailbreakCheck2 *selfRef);
FORCE_INLINE void jailbreak2Detected(JailbreakCheck2 *selfRef, JailbreakDetectionType type);

@implementation JailbreakCheck2

#pragma mark -
#pragma mark - BaseChecksTemplate

- (void)hookChecks
{
    [UIViewController addObserver:self];
    [UIApplication addObserver:self];
}

- (void)unhookChecks
{
    [UIViewController removeObserver:self];
    [UIApplication removeObserver:self];
}

#pragma mark -
#pragma mark - OnStateChangeListener

- (void)onStateChanged:(id)stateObject fromObject:(id)observedObject
{
    if (([stateObject isKindOfClass:[NSString class]]
         && [stateObject isEqualToString:NSStringFromSelector(@selector(viewWillAppear:))])
        || ![observedObject isKindOfClass:[UIViewController class]])
    {
#if ENABLE_CHECKS
        checkJailbreakActive(self);
#endif
    }
}

#pragma mark -
#pragma mark - Run checks

- (void)runChecks
{
#if ENABLE_CHECKS
    checkJailbreakActive(self);
#endif
}

void checkJailbreakActive(JailbreakCheck2 *selfRef)
{    
    if([[UIApplication sharedApplication] canOpenURL:
        [NSURL URLWithString:LOO_CRYPT_STR_N("cydia://package/com.com.com", 27)]])
    {
        jailbreak2Detected(selfRef, UrlScheme);
    }
    
    NSError *error;
    NSString *stringToBeWritten = @"0";
    [stringToBeWritten writeToFile:LOO_CRYPT_STR_N("/private/jailbreak.test", 23)
                        atomically:YES
                        encoding:NSUTF8StringEncoding error:&error];
    if (error == nil)
    {
        jailbreak2Detected(selfRef, WritablePath);
    }
}

void jailbreak2Detected(JailbreakCheck2 *selfRef, JailbreakDetectionType type)
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
