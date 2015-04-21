# README #

This is an iOS framework, which incorporates multiple security controls into one framework. It was written for a Master's thesis about iOS application security as a proof-of-concept project. 

### List of implemented security controls ###

* Debugger controls
* Jailbreak controls
* Integrity controls, including application encryption presence check (64 and 32 bit)
* NSUserDefaults and File (writeToFile:, initWithContentsOfFile: methods) encryption
* NSValueTransformer subclass to support Core Data attributes encryption
* Protection against unintended data leakage through text fields and iOS screenshots
* SSL pinning and SSL certificate validation
* Protection against insecure data logging
* WebView and URL scheme whitelisting

### Framework architecture ###

The framework relies on Objective-C runtime to automatically inject validation logic. However, the framework does not change any system APIs behaviour, but only intercepts methods’ invocations, performs needed operations and proceeds with original implementation. **Each and every time the original method implementation will be called to ensure that nothing will break the application!**

The general architecture is depicted on this diagram:

![diagramme_new_v4.png](https://bitbucket.org/repo/KeGARn/images/9585466-diagramme_new_v4.png)

### How do I get set up? ###

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

### Advanced configuration ###

## 1. Choose the needed controls ##

Each control has a way to fully or partially disable/enable it. Additionally, some controls have custom settings, such jailbreak detection callbacks or file encryption threshold settings, and the possibility to partially disable it.

All global settings are described in the SmartSecConfig.h comments:



### Contribution ###

* Writing tests
* Code review
* Other guidelines