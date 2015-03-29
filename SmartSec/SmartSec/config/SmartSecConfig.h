//
//  SmartSecConfig.h
//  SmartSec
//
//  Created by Olga Dalton on 22/03/15.
//  Copyright (c) 2015 Olga Dalton. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Defines.h"

@interface SmartSecConfig : NSObject

// Debugger
extern void enableDebuggerChecks();
extern void disableDebuggerChecks();

// Jailbreak
extern void enableJailbreakChecks();
extern void disableJailbreakChecks();

// Jailbreak callback
extern void onJailbreakDetected(OnJailbreakDetected jailbreakDetected);

// Integrity
extern void enableIntegrityChecks();
extern void disableIntegrityChecks();

// Integrity encryption check callback
extern void onMissingEncryption(OnEncryptionMissingDetected missingEncryptionDetected);

// NSUserDefaults encryption
extern void enableNSUserDefaultsEncryption();
extern void disableNSUserDefaultsEncryption();

// File encryption
extern void enableFileEncryption();
extern void disableFileEncryption();

// File encryption settings
extern unsigned long long getThresholdFileSize();
extern void setThresholdFileSize(unsigned long long newFileSize);

+ (void)setup:(const void *)mainReference;

@end
