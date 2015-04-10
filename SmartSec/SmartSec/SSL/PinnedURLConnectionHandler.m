//
//  PinnedURLConnectionHandler.m
//  SmartSec
//
//  Created by Olga Dalton on 08/04/15.
//  Copyright (c) 2015 Olga Dalton. All rights reserved.
//

#import "PinnedURLConnectionHandler.h"
#import <Security/Security.h>
#import <objc/runtime.h>
#import "Defines.h"
#import "SmartSec.h"
#import "NSString+Hash.h"

// Inline functions
FORCE_INLINE NSArray * allowedInvalidCertificateDomains();
FORCE_INLINE NSDictionary * pinnedCertificatesDictionary();
FORCE_INLINE NSArray * getCorrectKeysForDomain(NSString *domain);
FORCE_INLINE NSString * getCorrectKeyForItem(NSString *itemPath);

// SSL associated objects shared storage chars
static char incorrectTestCertsKey;
static char incorrectReleaseCertsKey;
static char pinnedSSLCertsKey;

/** This code is based on following resources:
 
 - OWASP SSL pinning implementation: https://www.owasp.org/index.php/Certificate_and_Public_Key_Pinning#iOS

 - Stackoverflow answer - how to pin the public key, not entire certificate: http://stackoverflow.com/questions/15728636/how-to-pin-the-public-key-of-a-certificate-on-ios

 - Some concepts from iSecPartners great implementation: https://github.com/iSECPartners/ssl-conservatory **/

@implementation PinnedURLConnectionHandler

#pragma mark -
#pragma mark - Challenge handler

+ (BOOL)authenticationChallengeValid:(NSURLAuthenticationChallenge *)authenticationChallenge
{
    if([authenticationChallenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust])
    {
        SecTrustRef serverTrust = authenticationChallenge.protectionSpace.serverTrust;
        
        NSString *domain = authenticationChallenge.protectionSpace.host;
        
        NSString *prefixedDomain = [domain hasPrefix:@"www."] ? domain : [NSString stringWithFormat:@"www.%@", domain];
        
        if (!serverTrust)
        {
            return NO;
        }
        
        SecTrustResultType trustResult;
        SecTrustEvaluate(serverTrust, &trustResult);
        
        /** kSecTrustResultUnspecified Indicates the evaluation succeeded
         and the certificate is implicitly trusted, but user intent was not
         explicitly specified.  This value may be returned by the **/
        
        /** kSecTrustResultRecoverableTrustFailure Indicates a trust policy
         failure which can be overridden by the user.  This value may be returned
         by the SecTrustEvaluate function but not stored as part of the user
         trust settings. **/
        
        if (trustResult == kSecTrustResultUnspecified // Certificate validation is OK
            || (trustResult == kSecTrustResultRecoverableTrustFailure
                // Or certificate is invalid, but among allowed certificates (e.g self-signed cert on the TEST server)
                && ([allowedInvalidCertificateDomains() containsObject:domain]
                    || [allowedInvalidCertificateDomains() containsObject:prefixedDomain])))
        {
            // SSL pinning enabled && setup
            // If the developer has provided empty pinning dictionary, it is considered as SSL pinning is not setup
            // Really, no point in prohibiting all valid SSL certs!
            if ([pinnedCertificatesDictionary() objectForKey:domain]
                || [pinnedCertificatesDictionary() objectForKey:prefixedDomain])
            {
                SecKeyRef actualKey = SecTrustCopyPublicKey(serverTrust);
                
                NSString *actualKeyHash = [[[((__bridge id) actualKey) description] secKeyDescription] sha256];
                
                NSArray *correctKeys = getCorrectKeysForDomain(domain);
                
                //ReleaseLog(@"Compare key %@ with keys %@", actualKeyHash, correctKeys);
                
                for (NSString *correctKey in correctKeys)
                {
                    if ([correctKey isEqualToString:actualKeyHash])
                    {
                        return YES;
                    }
                }
                
                return NO;
            }
            else
            // SSL pinning not enabled for the provided domain
            // If it is an invalid cert, it is not the best option, but this should be allowed
            // For invalid certs better to always pin them, especially in release mode!
            {
                return YES;
            }
        }
        else
        {
            return NO;
        }
    }
    else
    {
        [authenticationChallenge.sender performDefaultHandlingForAuthenticationChallenge:authenticationChallenge];
    }
    
    return YES;
}

#pragma mark -
#pragma mark - Settings

// SSL certificates validation config
extern FORCE_INLINE void allowInvalidCertificates(BOOL releaseMode, NSArray *domains)
{
    objc_setAssociatedObject([SmartSecConfig class], (releaseMode ? &incorrectReleaseCertsKey : &incorrectTestCertsKey), domains, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

// SSL pinning config
extern FORCE_INLINE void savedPinnedCertificates(NSDictionary *sslPinningDictionary)
{
    objc_setAssociatedObject([SmartSecConfig class], &pinnedSSLCertsKey, sslPinningDictionary, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

NSArray * allowedInvalidCertificateDomains()
{
#ifdef DEBUG
    return objc_getAssociatedObject([SmartSecConfig class], &incorrectTestCertsKey);
#else
    return objc_getAssociatedObject([SmartSecConfig class], &incorrectReleaseCertsKey);
#endif
}

NSDictionary * pinnedCertificatesDictionary()
{
    return objc_getAssociatedObject([SmartSecConfig class], &pinnedSSLCertsKey);
}

#pragma mark -
#pragma mark - Helper methods

NSArray * getCorrectKeysForDomain(NSString *domain)
{
    NSString *prefixedDomain = [domain hasPrefix:@"www."] ? domain :
                                [NSString stringWithFormat:@"www.%@", domain];
    
    NSArray *domainItems = pinnedCertificatesDictionary()[domain];
    
    if (domainItems == nil)
    {
        domainItems = pinnedCertificatesDictionary()[prefixedDomain];
    }
    
    if ([domainItems isKindOfClass:[NSString class]])
    {
        return @[getCorrectKeyForItem((NSString *) domainItems)];
    }
    
    NSMutableArray *expectedKeys = [NSMutableArray array];
    
    for (NSString *domainItem in domainItems)
    {
        if ([[NSFileManager defaultManager] fileExistsAtPath:domainItem isDirectory:0])
        {
            NSString *keyItem = getCorrectKeyForItem(domainItem);
            [expectedKeys addObject:keyItem];
        }
        else if ([domainItem length] == 64)
        {
            [expectedKeys addObject:domainItem];
        }
    }
    
    return expectedKeys;
}

NSString * getCorrectKeyForItem(NSString *itemPath)
{
    NSData *certData = [[NSData alloc] initWithContentsOfFile:itemPath];
    SecCertificateRef expectedCertificate = SecCertificateCreateWithData(NULL, (__bridge CFDataRef)certData);
    
    if (!expectedCertificate)
    {
        return nil;
    }
    
    SecKeyRef expectedKey = NULL;
    SecCertificateRef certRefs[1] = {expectedCertificate};
    CFArrayRef certArray = CFArrayCreate(kCFAllocatorDefault, (void *)certRefs, 1, NULL);
    SecPolicyRef policy = SecPolicyCreateBasicX509();
    SecTrustRef expTrust = NULL;
    OSStatus status = SecTrustCreateWithCertificates(certArray, policy, &expTrust);
    
    if (status == errSecSuccess)
    {
        expectedKey = SecTrustCopyPublicKey(expTrust);
    }
    
    CFRelease(expTrust);
    CFRelease(policy);
    CFRelease(certArray);
    
    // In iOS not possible to get key NSData without saving it to the keychain...
    // In Mac OSX there are export functions for that
    // Will use object description instead: it will containt key and related information
    NSString *keyDescriptionData = [NSString stringWithFormat:@"%@", [[(__bridge id)expectedKey description] secKeyDescription]];
    
    return [keyDescriptionData sha256];
}

@end
