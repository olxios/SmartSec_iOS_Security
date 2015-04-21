# README #

This is an iOS framework, which incorporates multiple security controls into one framework. It was written for a Master's thesis about iOS application security as a proof-of-concept project. 

# List of implemented security controls #

* Debugger controls
* Jailbreak controls
* Integrity controls, including application encryption presence check (64 and 32 bit)
* NSUserDefaults and File (writeToFile:, initWithContentsOfFile: methods) encryption
* NSValueTransformer subclass to support Core Data attributes encryption
* Protection against unintended data leakage through text fields and iOS screenshots
* SSL pinning and SSL certificate validation
* Protection against insecure data logging
* WebView and URL scheme whitelisting

# Framework architecture #

The framework relies on Objective-C runtime to automatically inject validation logic. However, the framework does not change any system APIs behaviour, but only intercepts methods’ invocations, performs needed operations and proceeds with original implementation. **Each and every time the original method implementation will be called to ensure that nothing will break the application!**

The general architecture is depicted on this diagram:

![diagramme_new_v4.png](https://bitbucket.org/repo/KeGARn/images/9585466-diagramme_new_v4.png)

# How do I get set up? #

## 1. Add the framework to your project ##

* Copy this repository
* Drag the SmartSec.xcodeproj somewhere into your project
* Navigate to Build phases -> Link binary With libraries and add the SmartSec.framework from the WorkSpace group

![add_sec.png](https://bitbucket.org/repo/KeGARn/images/1040406618-add_sec.png)

## 2. Add needed imports ##

* Open your prefix file (YourProjectName.pch) and add following lines

```
#!objective-c

#import <SmartSec/SecImports.h>
#import <SmartSec/Crypto.h>
```

* Open your AppDelegate file and add the framework import:

```
#!objective-c

#import <SmartSec/SmartSec.h>
```

## 3. Setup the framework ##

* Into the application:didFinishLaunchingWithOptions: method (or any other suitable place) add framework setup:

```
#!objective-c

setup(main, ^NSData *{
    return [User currentUser].sessionId;
 });
```

You must add the main function declaration somewhere, otherwise compiler is angry:

```
#!objective-c

int main (int argc, char *argv[]);

```

**That's it for the basic configuration!**

# Advanced configuration #

## 1. Choose the needed controls ##

Each control has a way to fully or partially disable/enable it. Additionally, some controls have custom settings, such jailbreak detection callbacks or file encryption threshold settings, and the possibility to partially disable it.

All global settings are described in the SmartSecConfig.h comments:


```
#!objective-c

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
```

## 2. Setup Core Data encryption ##

* Open your data model and select attributes that you'd like to encrypt. Change their data types Transformable:

![Screen Shot 2015-04-21 at 16.39.36.png](https://bitbucket.org/repo/KeGARn/images/3585123529-Screen%20Shot%202015-04-21%20at%2016.39.36.png)

* Open the data model inspector and set transformer for the selected attribute to BaseCoreDataTransformer:

![Screen Shot 2015-04-21 at 16.40.09.png](https://bitbucket.org/repo/KeGARn/images/2519626067-Screen%20Shot%202015-04-21%20at%2016.40.09.png)

**Important! Make sure that you're not using scalar datatypes in NSManagedObject subclasses. Scalar types cannot be used as Transformable attributes.**

## 3. Setup whitelists ##

OWASP recommends to prohibit users to access arbitrary web content inside the application. To achieve this, all requests must be whitelisted. The security framework implements a whitelisting solution, which is based on the W3C Widget Access specification and should be familiar to users of Apache Cordova. By using wildcard identifier you can define complex request filters. Same whitelisting will also work for URL schemes source applications.

To setup whitelists add WebAccessWhiteList and URLSchemesAccessWhiteList arrays to the Info.plist file.

Example whitelist:

![Screen Shot 2015-04-21 at 16.45.31.png](https://bitbucket.org/repo/KeGARn/images/2858937584-Screen%20Shot%202015-04-21%20at%2016.45.31.png)

## 4. Setup logging ##

The framework will automatically disable NSLog logging in the release mode. If you still need to log something in the release mode, use ReleaseLog(...) function instead. Both are defined using pre-processing macros - to skip this control, skip the <SmartSec/SecImports.h> import.

### Contribution ###

* Writing tests
* Code review
* Other guidelines