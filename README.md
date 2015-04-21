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

The framework relies on Objective-C runtime to automatically inject validation logic. However, the framework does not change any system APIs behaviour, but only intercepts methods’ invocations, performs needed operations and proceeds with original implementation. **Each and every time the original method implementation will be called to ensure that nothing will break in the application!**

The general architecture is depicted on this diagram:

![diagramme_new_v4.png](https://bitbucket.org/repo/KeGARn/images/9585466-diagramme_new_v4.png)

### How do I get set up? ###

* Summary of set up
* Configuration
* Dependencies
* Database configuration
* How to run tests
* Deployment instructions

### Contribution ###

* Writing tests
* Code review
* Other guidelines