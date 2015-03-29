//
//  IntegrityCheck1.m
//  SmartSec
//
//  Created by Olga Dalton on 18/03/15.
//  Copyright (c) 2015 Olga Dalton. All rights reserved.
//

#import "IntegrityCheck1.h"
#import "NSObject+State.h"
#import <UIKit/UIKit.h>

#import "LOOCryptString.h"
#import "UIApplication+Sec.h"

FORCE_INLINE void validateCodeSignature(IntegrityCheck1 *selfRef);
FORCE_INLINE void integrityProblems(IntegrityCheck1 *selfRef);

@implementation IntegrityCheck1

#pragma mark -
#pragma mark - BaseChecksTemplate

- (void)hookChecks
{
    [UIApplication addObserver:self];
}

- (void)unhookChecks
{
    [UIApplication removeObserver:self];
}

#pragma mark -
#pragma mark - OnStateChangeListener

- (void)onStateChanged:(id)stateObject fromObject:(id)observedObject
{    
#if ENABLE_CHECKS
    // Code signature && encryption checks
    validateCodeSignature(self);
#endif
}

#pragma mark -
#pragma mark - Run checks

- (void)runChecks
{
#if ENABLE_CHECKS
    // Code signature && encryption checks
    validateCodeSignature(self);
#endif
}

void validateCodeSignature(IntegrityCheck1 *selfRef)
{
    NSBundle *bundle = [NSBundle mainBundle];
    NSDictionary *info = [bundle infoDictionary];
    
    // This key can be only in a hacked app
    if ([info objectForKey:LOO_CRYPT_STR_N("SignerIdentity", 14)])
    {
        integrityProblems(selfRef);
    }
    else
    {
        // Check that signature exists
        
        if (![[NSFileManager defaultManager] fileExistsAtPath:[[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:LOO_CRYPT_STR_N("_CodeSignature", 14)]])
        {
            integrityProblems(selfRef);
        }
        else
        {
            // Last check if everything else is OK
            // It checks whether the info.plist was modified after the application installation
            NSString *plistPath = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:LOO_CRYPT_STR_N("Info.plist", 10)];
            NSDate *plistModificationDate = [[[NSFileManager defaultManager] attributesOfItemAtPath:plistPath error:nil] fileModificationDate];
            
            NSString *appPath = [[NSBundle mainBundle] executablePath];
            
            NSDate *appModificationDate = [[[NSFileManager defaultManager] attributesOfItemAtPath:appPath error:nil] fileModificationDate];
            
            if (plistModificationDate
                && appModificationDate
                && [plistModificationDate timeIntervalSince1970] > [appModificationDate timeIntervalSince1970])
            {
                integrityProblems(selfRef);
            } 
        }
    }
}

void integrityProblems(IntegrityCheck1 *selfRef)
{
    [UIApplication killMe];
    exit(-1); // extra call to kill the app
}

@end
