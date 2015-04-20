//
//  NSURLConnection+Sec.m
//  SmartSec
//
//  Created by Olga Dalton on 08/04/15.
//  Copyright (c) 2015 Olga Dalton. All rights reserved.
//

#import "NSURLConnection+Sec.h"
#import "PinnedURLConnectionHandler.h"
#import "IntegrityCheck1.h"
#import "IntegrityCheck2.h"
#import "DebugCheck1.h"
#import <objc/runtime.h>

@implementation NSURLConnection (Sec)

#pragma mark -
#pragma mark - Init methods

- (instancetype)initWithRequestSwizzled:(NSURLRequest *)request delegate:(id)delegate startImmediately:(BOOL)startImmediately
{    
    [self setupDelegate:delegate];
    
    check_class_all_methods((char *)[NSStringFromClass([DebugCheck1 class]) UTF8String]);
    
    return [self initWithRequestSwizzled:request delegate:delegate startImmediately:startImmediately];
}

- (instancetype)initWithRequestSwizzled:(NSURLRequest *)request delegate:(id)delegate
{
    // Add validation logic to the NSURLConnection delegate
    [self setupDelegate:delegate];
    
    check_class_all_methods((char *)[NSStringFromClass([IntegrityCheck2 class]) UTF8String]);
    
    // Call the original method
    return [self initWithRequestSwizzled:request delegate:delegate];
}

#pragma mark -
#pragma mark - Use custom auth handling

- (void)setupDelegate:(id)delegate
{
    Method original;
    
    original = class_getInstanceMethod([delegate class], @selector(connection:willSendRequestForAuthenticationChallenge:));
    
    if (original)
    {
        SEL addedSelector = @selector(swizzledConnection:willSendRequestForAuthenticationChallenge:);
        class_addMethod([delegate class], addedSelector, [self methodForSelector:addedSelector], "B@:@@");
        
        Method swizzle = class_getInstanceMethod([delegate class], @selector(swizzledConnection:willSendRequestForAuthenticationChallenge:));
        method_exchangeImplementations(original, swizzle);
    }
    else
    {
        SEL addedSelector = @selector(connection:willSendRequestForAuthenticationChallenge:);
        class_addMethod([delegate class], addedSelector,
                                      [self methodForSelector:addedSelector], "B@:@@");
    }
}

#pragma mark -
#pragma mark - Swizzled methods

-(void)connection:(NSURLConnection *)connection willSendRequestForAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
{
    BOOL pinResult = [PinnedURLConnectionHandler authenticationChallengeValid:challenge];
    
    if (pinResult)
    {
        NSURLCredential *credential = [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust];
        [challenge.sender useCredential:credential
             forAuthenticationChallenge:challenge];
    }
    else
    {
        [challenge.sender cancelAuthenticationChallenge: challenge];
    }
}

-(void)swizzledConnection:(NSURLConnection *)connection willSendRequestForAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
{
    BOOL pinResult = [PinnedURLConnectionHandler authenticationChallengeValid:challenge];
    
    if (pinResult)
    {
        [self swizzledConnection:connection willSendRequestForAuthenticationChallenge:challenge];
    }
    else
    {
        [self swizzledConnection:connection willSendRequestForAuthenticationChallenge:challenge];
        [challenge.sender cancelAuthenticationChallenge: challenge];
    }
}

#pragma mark -
#pragma mark - Swizzle

+ (void)load
{
    Method original, swizzled;
    
    // 1. Find the original method
    original = class_getInstanceMethod(self, @selector(initWithRequest:delegate:));
    
    // 2. Find the replacement method
    swizzled = class_getInstanceMethod(self, @selector(initWithRequestSwizzled:delegate:));
    
    // 3. Exchange methods implementations
    method_exchangeImplementations(original, swizzled);
    
    original = class_getInstanceMethod(self, @selector(initWithRequest:delegate:startImmediately:));
    swizzled = class_getInstanceMethod(self, @selector(initWithRequestSwizzled:delegate:startImmediately:));
    method_exchangeImplementations(original, swizzled);
}

@end
