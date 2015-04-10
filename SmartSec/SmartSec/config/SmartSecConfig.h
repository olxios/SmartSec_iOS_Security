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

/******* Callbacks  *******/

// Jailbreak callback
extern void onJailbreakDetected(OnJailbreakDetected jailbreakDetected);

// Integrity encryption check callback
extern void onMissingEncryption(OnEncryptionMissingDetected missingEncryptionDetected);

/******* Settings  *******/

// Debugger
extern void enableDebuggerChecks();
extern void disableDebuggerChecks();

// Jailbreak
extern void enableJailbreakChecks();
extern void disableJailbreakChecks();

// Integrity
extern void enableIntegrityChecks();
extern void disableIntegrityChecks();

// NSUserDefaults encryption
extern void enableNSUserDefaultsEncryption();
extern void disableNSUserDefaultsEncryption();

// File encryption
extern void enableFileEncryption();
extern void disableFileEncryption();

// File encryption settings
extern unsigned long long getThresholdFileSize();
extern void setThresholdFileSize(unsigned long long newFileSize);

// Textfields settings
extern void disableSecureTextfields();
extern void enableSecureTextfields();

// Screenshots settings
extern void disableAppScreenshotsProtection();
extern void enableAppScreenshotsProtection();

// SSL certificates validation config
extern void allowInvalidCertificatesInTestMode(NSArray *domains);
extern void allowInvalidCertificatesInReleaseMode(NSArray *domains);

// SSL pinning config
extern void pinSSLCertificatesWithDictionary(NSDictionary *sslPinningDictionary);

/******* Setuping the framework  *******/

+ (void)setup:(const void *)mainReference;

@end
