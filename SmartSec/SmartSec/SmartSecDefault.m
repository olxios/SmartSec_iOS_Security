//
//  SmartSecDefault.m
//  SmartSec
//
//  Created by Olga Dalton on 16/03/15.
//  Copyright (c) 2015 Olga Dalton. All rights reserved.
//

#import "SmartSecDefault.h"

// General imports
#import "Defines.h"
#import "NSMutableDictionary+ArrayValue.h"

// Checks import
#import "DebugCheck2.h"
#import "JailbreakCheck2.h"
#import "IntegrityCheck2.h"

#import "CryptoManager.h"

// Inline functions
FORCE_INLINE void initDefaultLibrary(SmartSecDefault *selfRef);

// Singleton variables
static SmartSecDefault *sharedInstance = nil;
static bool isFirstAccess = YES;

@implementation SmartSecDefault

#pragma mark -
#pragma mark - Initialize

static void __attribute__((constructor)) initialize(void)
{
    initDefaultLibrary([SmartSecDefault sharedInstance]);
    
    getEncryptionKey(NO);
    getEncryptionKey(YES);
}

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
    }
    
    return self;
}

// Initialize all default checkrs
void initDefaultLibrary(SmartSecDefault *selfRef)
{
    hookDefaultDebuggerChecks(selfRef);
    hookDefaultJailbreakChecks(selfRef);
    hookDefaultIntegrityChecks(selfRef);
}

#pragma mark -
#pragma mark - Extern

extern FORCE_INLINE void hookDefaultDebuggerChecks(SmartSecDefault *selfRef)
{
    // Hook the check
    DebugCheck2 *debugCheck = [[DebugCheck2 alloc] init];
    [debugCheck hookChecks];
    
    // Save for disabling possibility
    [selfRef.enabledCheckers addItem:debugCheck forKey:kDebuggerChecks];
}

extern FORCE_INLINE void hookDefaultJailbreakChecks(SmartSecDefault *selfRef)
{
    JailbreakCheck2 *jailbreakCheck = [[JailbreakCheck2 alloc] init];
    [jailbreakCheck hookChecks];
    
    [selfRef.enabledCheckers addItem:jailbreakCheck forKey:kJailbreakChecks];
}

extern FORCE_INLINE void hookDefaultIntegrityChecks(SmartSecDefault *selfRef)
{
    IntegrityCheck2 *integrityCheck = [[IntegrityCheck2 alloc] init];
    [integrityCheck hookChecks];
    
    [selfRef.enabledCheckers addItem:integrityCheck forKey:kIntegrityChecks];
}

@end
