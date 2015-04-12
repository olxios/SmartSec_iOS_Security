//
//  Defines.h
//  SmartSec
//
//  Created by Olga Dalton on 10/03/15.
//  Copyright (c) 2015 Olga Dalton. All rights reserved.
//

/*
 Generally, functions are not inlined unless optimization is specified. For functions declared inline, this attribute inlines the function independent of any restrictions that otherwise apply to inlining. Failure to inline such a function is diagnosed as an error. Note that if such a function is called indirectly the compiler may or may not inline it depending on optimization level and a failure to inline an indirect call may or may not be diagnosed.
 */

// Defines
#define FORCE_INLINE inline __attribute__((always_inline))

#define ENABLE_CHECKS (!(DEBUG) && !(TARGET_IPHONE_SIMULATOR))

#define APP_NAME [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleIdentifier"]

// (See cssmtype.h and cssmapple.h on the Mac OS X SDK.)

enum {
    CSSM_ALGID_NONE =                   0x00000000L,
    CSSM_ALGID_VENDOR_DEFINED =         CSSM_ALGID_NONE + 0x80000000L,
    CSSM_ALGID_AES
};

// Enums
typedef enum {SymLinks, Files, UrlScheme, WritablePath} JailbreakDetectionType;

// Blocks
typedef void (^OnJailbreakDetected)(JailbreakDetectionType jailbreakDetectionType);
typedef void (^OnEncryptionMissingDetected)();
typedef NSData * (^OnSessionPasswordRequired)();

// Keys
static NSString *kDebuggerChecks = @"debuggerChecks";
static NSString *kJailbreakChecks = @"jailbreakChecks";
static NSString *kIntegrityChecks = @"integrityChecks";
static NSString *kApplicationKeyChainKey = @"applicationKeyChainKey";
static NSString *kApplicationKeyChainLockedKey = @"applicationKeyChainLockedKey";