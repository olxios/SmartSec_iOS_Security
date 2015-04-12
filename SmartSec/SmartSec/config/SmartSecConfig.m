//
//  SmartSecConfig.m
//  SmartSec
//
//  Created by Olga Dalton on 22/03/15.
//  Copyright (c) 2015 Olga Dalton. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <objc/runtime.h>

#import "SmartSecConfig.h"

#import "JailbreakCheck1.h"

#import "SmartSecConfigurable.h"
#import "SmartSecDefault.h"

#import "BaseChecksTemplate.h"
#import "IntegrityCheck2.h"
#import "IntegrityCheck1.h"

#import "NSUserDefaults+Sec.h"
#import "NSObject+State.h"

#import "UIApplication+SecText.h"
#import "UITextField+SecText.h"
#import "PinnedURLConnectionHandler.h"
#import "CryptoManager.h"

// static variables
static unsigned long long defaultThresholdSize = -1;

// inline functions
FORCE_INLINE NSArray *findChecksWithIdentifier(NSString *identifier);
FORCE_INLINE BOOL enableChecksWithIdentifier(NSString *identifier);
FORCE_INLINE void disableChecksWithIdentifier(NSString *identifier);

@implementation SmartSecConfig

#pragma mark -
#pragma mark - Setup

+ (void)setup:(const void *)mainReference sessionPasswordCallback:(OnSessionPasswordRequired)sessionPasswordCallback
{
    setSessionPasswordCallback(sessionPasswordCallback);
    
    NSArray *checks = findChecksWithIdentifier(kIntegrityChecks);
    
    for (id<BaseChecksTemplate> check in checks)
    {
        if ([check respondsToSelector:@selector(setMainReference:)])
        {
            [(id)check setMainReference:mainReference];
        }
    }
    
    [[SmartSecConfigurable sharedInstance] setup];
}

#pragma mark -
#pragma mark - Debugger checks

extern FORCE_INLINE void enableDebuggerChecks()
{
    if (!enableChecksWithIdentifier(kDebuggerChecks))
    {
        hookDefaultDebuggerChecks([SmartSecDefault sharedInstance]);
        hookConfigurableDebuggerChecks([SmartSecConfigurable sharedInstance]);
    }
}

extern FORCE_INLINE void disableDebuggerChecks()
{
    disableChecksWithIdentifier(kDebuggerChecks);
}

#pragma mark -
#pragma mark - Jailbreak checks
 
extern FORCE_INLINE void enableJailbreakChecks()
{
    if (!enableChecksWithIdentifier(kJailbreakChecks))
    {
        hookDefaultJailbreakChecks([SmartSecDefault sharedInstance]);
        hookConfigurableJailbreakChecks([SmartSecConfigurable sharedInstance]);
    }
}

extern FORCE_INLINE void disableJailbreakChecks()
{
    disableChecksWithIdentifier(kJailbreakChecks);
}

#pragma mark -
#pragma mark - Integrity checks

extern FORCE_INLINE void enableIntegrityChecks()
{
    if (!enableChecksWithIdentifier(kIntegrityChecks))
    {
        hookDefaultIntegrityChecks([SmartSecDefault sharedInstance]);
    }
}

extern FORCE_INLINE void disableIntegrityChecks()
{
    disableChecksWithIdentifier(kIntegrityChecks);
}

#pragma mark -
#pragma mark - NSUserDefaults encryption

extern void enableNSUserDefaultsEncryption()
{
    [NSUserDefaults setEncryptionDisabled:NO];
}

extern void disableNSUserDefaultsEncryption()
{
    [NSUserDefaults setEncryptionDisabled:YES];
}

#pragma mark -
#pragma mark - Callbacks

extern FORCE_INLINE void onMissingEncryption(OnEncryptionMissingDetected missingEncryptionDetected)
{
    NSArray *checks = findChecksWithIdentifier(kIntegrityChecks);
    
    for (id<BaseChecksTemplate> check in checks)
    {
        if ([check isKindOfClass:[IntegrityCheck2 class]])
        {
            IntegrityCheck2 *integrityCheck = (IntegrityCheck2 *)check;
            [integrityCheck setOnEncryptionMissingDetected:missingEncryptionDetected];
        }
    }
}

extern FORCE_INLINE void onJailbreakDetected(OnJailbreakDetected jailbreakDetected)
{
    NSArray *checks = findChecksWithIdentifier(kJailbreakChecks);
    
    for (id<BaseChecksTemplate> check in checks)
    {
        if ([check respondsToSelector:@selector(setJailbreakCallback:)])
        {
            [check performSelector:@selector(setJailbreakCallback:)
                        withObject:jailbreakDetected];
        }
    }
}

#pragma mark -
#pragma mark - Encryption settings

extern FORCE_INLINE void enableFileEncryption()
{
    [NSData setEncryptionDisabled:NO];
    [NSString setEncryptionDisabled:NO];
    [NSArray setEncryptionDisabled:NO];
    [NSDictionary setEncryptionDisabled:NO];
}

extern FORCE_INLINE void disableFileEncryption()
{
    [NSData setEncryptionDisabled:YES];
    [NSString setEncryptionDisabled:YES];
    [NSArray setEncryptionDisabled:YES];
    [NSDictionary setEncryptionDisabled:YES];
}

#pragma mark -
#pragma mark - TextField settings

extern FORCE_INLINE void disableSecureTextfields()
{
    [UITextField setCorrectionDisabled:YES];
}

extern FORCE_INLINE void enableSecureTextfields()
{
    [UITextField setCorrectionDisabled:NO];
}

#pragma mark -
#pragma mark - Screenshot settings

extern FORCE_INLINE void disableAppScreenshotsProtection()
{
    [UIApplication sharedApplication].screenshotsProtectionDisabled = YES;
}

extern FORCE_INLINE void enableAppScreenshotsProtection()
{
    [UIApplication sharedApplication].screenshotsProtectionDisabled = NO;
}

#pragma mark -
#pragma mark - File encryption threshold

extern FORCE_INLINE unsigned long long getThresholdFileSize()
{
    if (defaultThresholdSize == -1)
    {
        // Default threshold will be quite low to not cause overhead
        // occupying 1 / 1024 of all RAM
        // e.g for iPhone 6 (1 GB RAM) it will be around 1 MB
        unsigned long long totalMemory = [NSProcessInfo processInfo].physicalMemory;
        
        // Calculate threshold size
        defaultThresholdSize = totalMemory / 1024;
    }
    
    return defaultThresholdSize;
}

extern FORCE_INLINE void setThresholdFileSize(unsigned long long newFileSize)
{
    defaultThresholdSize = newFileSize;
}

#pragma mark -
#pragma mark - SSL handling

extern FORCE_INLINE void allowInvalidCertificatesInTestMode(NSArray *domains)
{
    allowInvalidCertificates(NO, domains);
}

extern FORCE_INLINE void allowInvalidCertificatesInReleaseMode(NSArray *domains)
{
    allowInvalidCertificates(YES, domains);
}

extern FORCE_INLINE void pinSSLCertificatesWithDictionary(NSDictionary *sslPinningDictionary)
{
    savedPinnedCertificates(sslPinningDictionary);
}

#pragma mark -
#pragma mark - Helper functions

NSArray *findChecksWithIdentifier(NSString *identifier)
{
    NSMutableArray *debuggerChecks = [SmartSecDefault sharedInstance].enabledCheckers[identifier];
    
    if (!debuggerChecks)
    {
        debuggerChecks = [NSMutableArray array];
    }
    
    [debuggerChecks addObjectsFromArray:[SmartSecConfigurable sharedInstance].enabledCheckers[identifier]];
    return debuggerChecks;
}

BOOL enableChecksWithIdentifier(NSString *identifier)
{
    NSArray *checks = findChecksWithIdentifier(identifier);
    
    if ([checks count])
    {
        for (id<BaseChecksTemplate> check in checks)
        {
            [check hookChecks];
        }
        
        return YES;
    }
    
    return NO;
}

void disableChecksWithIdentifier(NSString *identifier)
{
    NSArray *checks = findChecksWithIdentifier(identifier);
    
    for (id<BaseChecksTemplate> check in checks)
    {
        [check unhookChecks];
    }
    
    [[SmartSecDefault sharedInstance].enabledCheckers removeObjectForKey:identifier];
    [[SmartSecConfigurable sharedInstance].enabledCheckers removeObjectForKey:identifier];
}

@end
