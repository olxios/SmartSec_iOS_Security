//
//  AppDelegate.m
//  SmartSecExample
//
//  Created by Olga Dalton on 15/02/15.
//  Copyright (c) 2015 Olga Dalton. All rights reserved.
//

#import "AppDelegate.h"
#import <SmartSec/SmartSec.h>

// need to add this, otherwise compiler gets angry :(
int main (int argc, char *argv[]);

@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
        
    disableDebuggerChecks();
    
    onJailbreakDetected(^(JailbreakDetectionType jailbreakDetectionType) {
        ReleaseLog(@"DEVICE JAILBROKEN!");
    });
    
    onMissingEncryption(^{
        ReleaseLog(@"ENCRYPTION MISSING! DO SOMETHING SMART...!");
    });
        
    //allowInvalidCertificatesInReleaseMode(@[@"kosmos.infohaiku.com"]);
    
    NSDictionary *sslPinDictionary = @{@"twitter.com" :
                                           @[[[NSBundle mainBundle] pathForResource:@"random-org" ofType:@"der"],
                                            /*[[NSBundle mainBundle] pathForResource:@"twitter" ofType:@"der"]]*/
                                             @"cfb6fe515a13f0f84e058865c62087e890d8f0ea9d6723f8fc6a2193d29ced51"]};
    
    pinSSLCertificatesWithDictionary(sslPinDictionary);
    
    setup(main, ^NSData *{
        // In real project use some actual user sessionId here, don't use a hardcoded password!!!
        // This password will be used only to safeguard memory, not used for actual encryption
        return [@"CurrentUserSessionId" dataUsingEncoding:NSUTF8StringEncoding];
    });
   
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {}

- (void)applicationDidEnterBackground:(UIApplication *)application {}

- (void)applicationWillEnterForeground:(UIApplication *)application {}

- (void)applicationDidBecomeActive:(UIApplication *)application {}

- (void)applicationWillTerminate:(UIApplication *)application {
    [self saveContext];
}

#pragma mark -
#pragma mark - URL Schemes

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    ReleaseLog(@"Calling Application Bundle ID: %@", sourceApplication);
    ReleaseLog(@"URL scheme:%@", [url scheme]);
    ReleaseLog(@"URL query: %@", [url query]);
    
    ReleaseLog(@"URL: %@", url);
    
    return YES;
}

#pragma mark -
#pragma mark - Core Data stack

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (NSURL *)applicationDocumentsDirectory {
    // The directory the application uses to store the Core Data store file. This code uses a directory named "com.olgadalton.SmartSecExample" in the application's documents directory.
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (NSManagedObjectModel *)managedObjectModel {
    // The managed object model for the application. It is a fatal error for the application not to be able to find and load its model.
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"SmartSecExample" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it.
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    // Create the coordinator and store
    
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"SmartSecExample.sqlite"];
    NSError *error = nil;
    NSString *failureReason = @"There was an error creating or loading the application's saved data.";
    NSDictionary *options = @{ NSSQLitePragmasOption : @{@"journal_mode" : @"DELETE"} }; // better for viewing data
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:options error:&error]) {
        // Report any error we got.
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        dict[NSLocalizedDescriptionKey] = @"Failed to initialize the application's saved data";
        dict[NSLocalizedFailureReasonErrorKey] = failureReason;
        dict[NSUnderlyingErrorKey] = error;
        error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        // Replace this with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}


- (NSManagedObjectContext *)managedObjectContext {
    // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.)
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        return nil;
    }
    _managedObjectContext = [[NSManagedObjectContext alloc] init];
    [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    return _managedObjectContext;
}

#pragma mark - Core Data Saving support

- (void)saveContext {
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        NSError *error = nil;
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

@end
