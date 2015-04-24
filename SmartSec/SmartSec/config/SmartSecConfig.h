//
//  SmartSecConfig.h
//  SmartSec
//
//  Created by Olga Dalton on 22/03/15.
//  Copyright (c) 2015 Olga Dalton. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "Defines.h"

@interface SmartSecConfig : NSObject

/******* Callbacks  *******/

// Set jailbreak callback
// It will be called upon discovering the device jailbreak
// If the jailbreak callback is not provided,
// the jailbreak detection will exit the application
extern void onJailbreakDetected(OnJailbreakDetected jailbreakDetected);

// Integrity encryption check callback
// It will be called, if the application binary is not encrypted
// It is usually the case for debug builds or cracked applications
// Encryption will not be checked in Debug mode thought
extern void onMissingEncryption(OnEncryptionMissingDetected missingEncryptionDetected);

/******* Settings  *******/

// Debugger - enable/disable all possible debugger checks
extern void enableDebuggerChecks();
extern void disableDebuggerChecks();

// Jailbreak - enable/disable all possible jailbreak checks
extern void enableJailbreakChecks();
extern void disableJailbreakChecks();

// Integrity - enable/disable all possible integrity checks,
// including encryption detection check
extern void enableIntegrityChecks();
extern void disableIntegrityChecks();

// Disable controls partially for a specific subclass
extern void disableOnLoadControls(UIViewController *obj);

// NSUserDefaults encryption - enable/disable NSUserDefaults encryption globally
// If disabled, already encrypted values will stay encrypted until value rewriting
// Encrypted values will be retrieved normally, even if encryption is disabled
extern void enableNSUserDefaultsEncryption();
extern void disableNSUserDefaultsEncryption();

// File encryption - enable/disable encryption for data/string/object writing methods
// Already encrypted values will stay encrypted, if disabled
// Encrypts only data, which does not exceed threshold size
extern void enableFileEncryption();
extern void disableFileEncryption();

// File encryption settings
// Update file encryption threshold size
extern unsigned long long getThresholdFileSize();
extern void setThresholdFileSize(unsigned long long newFileSize);

// Textfields settings
// Enable/disable text fields securing globally for all fields
extern void disableSecureTextfields();
extern void enableSecureTextfields();

// Screenshots settings
// Enable/disable screenshots text fields protection globally
extern void disableAppScreenshotsProtection();
extern void enableAppScreenshotsProtection();

// SSL certificates validation config
// Set SSL certificates, which are allowed to fail validation
// It is useful for test environments,
// but it is highly recommended to setup SSL pinning for such certificates even in test mode
extern void allowInvalidCertificatesInTestMode(NSArray *domains);
extern void allowInvalidCertificatesInReleaseMode(NSArray *domains);

// SSL pinning config
// Setup SSL certificates to pin
// The input dictionary should have target hosts as keys
// and embedded certificate path or certificate public key + related information hash as values
// The hash way is recommended, but hide the hash string!
// You can set multiple certificates for one host

/*
 
 Example configuration with embedded certificate path and hash combined:
 
 NSDictionary *sslPinDictionary = @{@"twitter.com" :
                @[[[NSBundle mainBundle] pathForResource:@"random-org" ofType:@"der"],
                @"cfb6fe515a13f0f84e058865c62087e890d8f0ea9d6723f8fc6a2193d29ced51"]};
 
 pinSSLCertificatesWithDictionary(sslPinDictionary);
 
 */

extern void pinSSLCertificatesWithDictionary(NSDictionary *sslPinningDictionary);

/******* Setuping the framework  *******/

// mainReference is a reference to the main application function
// it is needed to check for application binary encryption presence
// sessionPasswordCallback is an optional callback,
// which should return some dynamically changing password, associated with a current user
// It is used for encryption keys memory protection

/*
 
Example configuration:
 
 setup(main, ^NSData *{
    return [User currentUser].sessionId;
 });
 
 */

extern void setup(const void * mainReference, OnSessionPasswordRequired sessionPasswordCallback);

@end
