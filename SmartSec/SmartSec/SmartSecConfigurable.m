//
//  SmartSecInit.m
//  SmartSec
//
//  Created by Olga Dalton on 15/02/15.
//  Copyright (c) 2015 Olga Dalton. All rights reserved.
//

// General imports
#import "NSMutableDictionary+ArrayValue.h"
#import "SmartSecConfigurable.h"
#import "Defines.h"
#import "NSObject+State.h"
#import <UIKit/UIKit.h>

// Checks imports
#import "DebugCheck1.h"
#import "JailbreakCheck1.h"
#import "IntegrityCheck1.h"

// Inline functions
FORCE_INLINE void initConfigurableLibrary(SmartSecConfigurable *selfRef);
FORCE_INLINE void runChecksWithIdentifier(NSString *identifier, SmartSecConfigurable *selfRef);
FORCE_INLINE void removeChecksWithIdentifier(NSString *identifier, SmartSecConfigurable *selfRef);

@implementation SmartSecConfigurable

// Singleton variables
static SmartSecConfigurable *sharedInstance = nil;
static bool isFirstAccess = YES;

#pragma mark - 
#pragma mark - Initialize

+ (instancetype)sharedInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        isFirstAccess = NO;
        sharedInstance = [[super allocWithZone:NULL] init];
    });
    
    return sharedInstance;
}

#pragma mark - 
#pragma mark - Initialize

- (instancetype)init
{
    if (sharedInstance)
    {
        return sharedInstance;
    }
    
    if (isFirstAccess)
    {
        [self doesNotRecognizeSelector:_cmd];
    }
    
    self = [super init];
    
    if (self)
    {
        self.enabledCheckers = [NSMutableDictionary dictionary];
        initConfigurableLibrary(self);
    }
    
    return self;
}

- (void)setup
{
    runChecksWithIdentifier(kDebuggerChecks, self);
    runChecksWithIdentifier(kJailbreakChecks, self);
}

void initConfigurableLibrary(SmartSecConfigurable *selfRef)
{
    hookConfigurableDebuggerChecks(selfRef);
    hookConfigurableJailbreakChecks(selfRef);
    hookConfigurableIntegrityChecks(selfRef);
}

#pragma mark -
#pragma mark - Extern

extern FORCE_INLINE void hookConfigurableDebuggerChecks(SmartSecConfigurable *selfRef)
{
    removeChecksWithIdentifier(kDebuggerChecks, selfRef);
    
    // Hook the check
    DebugCheck1 *debugCheck = [[DebugCheck1 alloc] init];
    [debugCheck hookChecks];

    // Save for disabling possibility
    [selfRef.enabledCheckers addItem:debugCheck forKey:kDebuggerChecks];
}

extern FORCE_INLINE void hookConfigurableJailbreakChecks(SmartSecConfigurable *selfRef)
{
    removeChecksWithIdentifier(kJailbreakChecks, selfRef);
    
    // Hook the check
    JailbreakCheck1 *jailbreakCheck = [[JailbreakCheck1 alloc] init];
    [jailbreakCheck hookChecks];
    
    // Save for disabling possibility
    [selfRef.enabledCheckers addItem:jailbreakCheck forKey:kJailbreakChecks];
}

extern FORCE_INLINE void hookConfigurableIntegrityChecks(SmartSecConfigurable *selfRef)
{
    removeChecksWithIdentifier(kIntegrityChecks, selfRef);
    
    // Hook the check
    IntegrityCheck1 *integrityCheck = [[IntegrityCheck1 alloc] init];
    [integrityCheck hookChecks];
    
    // Save for disabling possibility
    [selfRef.enabledCheckers addItem:integrityCheck forKey:kIntegrityChecks];
}

#pragma mark -
#pragma mark - Helper methods

void runChecksWithIdentifier(NSString *identifier, SmartSecConfigurable *selfRef)
{
    for (id<BaseChecksTemplate> check in selfRef.enabledCheckers[identifier])
    {
        [check runChecks];
    }
}

void removeChecksWithIdentifier(NSString *identifier, SmartSecConfigurable *selfRef)
{
    for (id<BaseChecksTemplate> check in selfRef.enabledCheckers[identifier])
    {
        [check unhookChecks];
    }
    
    [selfRef.enabledCheckers removeObjectForKey:identifier];
}

#pragma mark -
#pragma mark - Cleanup

- (void)dealloc
{
    [[UIApplication sharedApplication] removeNotificationObservers];
}

@end
