//
//  SmartSecInit.m
//  SmartSec
//
//  Created by Olga Dalton on 15/02/15.
//  Copyright (c) 2015 Olga Dalton. All rights reserved.
//

// General imports
#import "SmartSecInit.h"
#import "Defines.h"
#import "SmartSecConfig.h"
#import "NSObject+State.h"
#import <UIKit/UIKit.h>

// Checks imports
#import "DebugCheck.h"

// Inline functions
FORCE_INLINE void initLibrary();
FORCE_INLINE SmartSecConfig* defaultConfig();

// Interface
@interface SmartSecInit()
{
    SmartSecConfig *_config;
    
    // Checks
    DebugCheck *_debugCheck;
}

@end

@implementation SmartSecInit

// Singleton variables
static SmartSecInit *sharedInstance = nil;
static bool isFirstAccess = YES;

#pragma mark - 
#pragma mark - Initialize

static void __attribute__((constructor)) initialize(void) {
    // TODO: actions onload
}

+ (id)sharedInstance
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

- (id) init
{
    if (sharedInstance) {
        return sharedInstance;
    }
    
    if (isFirstAccess) {
        [self doesNotRecognizeSelector:_cmd];
    }
    
    self = [super init];
    
    if (self)
    {
        _config = defaultConfig();
        initLibrary(self);
    }
    
    return self;
}

- (void)setConfig:(SmartSecConfig *)config
{
    _config = config;
    initLibrary(self);
}

SmartSecConfig* defaultConfig() {
    
    SmartSecConfig *config = [[SmartSecConfig alloc] init];
    // TODO: setup settings here
    return config;
}

// Init library according to the configuration
// If no configuration provided, use the default one
void initLibrary(SmartSecInit *selfRef) {
    
    // Debug checks
    [selfRef->_debugCheck unhookChecks];
    selfRef->_debugCheck = nil;
    
    if (!selfRef->_config.disableDebugChecks)
    {
        selfRef->_debugCheck = [[DebugCheck alloc] init];
        [selfRef->_debugCheck hookChecks];
        [selfRef->_debugCheck runChecks];
    }
    
    // TODO: other checks
}

#pragma mark -
#pragma mark - Cleanup

- (void)dealloc
{
    [[UIApplication sharedApplication] removeNotificationObservers];
    [_debugCheck unhookChecks];
    
    // TODO: unhook other checks here as well
}

@end
