//
//  CryptoManager.m
//  SmartSec
//
//  Created by Olga Dalton on 20/03/15.
//  Copyright (c) 2015 Olga Dalton. All rights reserved.
//

#import "CryptoManager.h"
#import "Defines.h"

// Crypto
#import "RNCryptor.h"
#import "RNEncryptor.h"
#import "RNDecryptor.h"

// Quick & easy hash
#import "xxhash.h"

// Two separate keys for usage, when device is locked and no
static NSData *key = nil;
static NSData *lockedKey = nil;
static unsigned long long latestSessionHash = 0L;
static OnSessionPasswordRequired sessionPasswordRequiredCallback;

#define ENCRYPTION_KEY (useWhenLocked ? lockedKey : key)
#define ENCRYPTION_KEY_SAFE (useWhenLocked ? getEncryptionKey(YES) : getEncryptionKey(NO))
#define SESSION_KEY (sessionPasswordRequiredCallback ? sessionPasswordRequiredCallback() : nil)

// Inline functions
FORCE_INLINE NSData *keychainItemForIdentifier(NSString *identifier);
FORCE_INLINE NSMutableDictionary *keychainDictionaryForIdentifier(NSString *identifier);
FORCE_INLINE NSData *sessionKey();

@implementation CryptoManager

#pragma mark -
#pragma mark - Key handling

extern FORCE_INLINE void setSessionPasswordCallback(OnSessionPasswordRequired sessionPasswordCallback)
{
    sessionPasswordRequiredCallback = sessionPasswordCallback;
    lockedKey = nil;
    key = nil;
    
    if (latestSessionHash == 0
        && sessionPasswordRequiredCallback)
    {
        NSData *sessionKey = SESSION_KEY;
        latestSessionHash = XXH64([sessionKey bytes], [sessionKey length], 0);
    }
}

NSData *sessionKey()
{
    NSData *sessionPass = SESSION_KEY;
    
    if (![sessionPass length])
    {
        return nil;
    }
    
    unsigned long long hash = XXH64([sessionPass bytes], [sessionPass length], 0);
    
    if (hash != latestSessionHash)
    {
        latestSessionHash = hash;
        return nil;
    }
    
    if ([sessionPass length] < kRNCryptorAES256Settings.keySettings.keySize)
    {
        NSMutableData *tempData = [NSMutableData dataWithData:sessionPass];
        
        while ([tempData length] < kRNCryptorAES256Settings.keySettings.keySize)
        {
            [tempData appendData:[sessionPass subdataWithRange:NSMakeRange(0, MIN([sessionPass length], kRNCryptorAES256Settings.keySettings.keySize - [tempData length]))]];
        }
        
        return tempData;
    }
    else if ([sessionPass length] > kRNCryptorAES256Settings.keySettings.keySize)
    {
        return [sessionPass subdataWithRange:NSMakeRange(0, kRNCryptorAES256Settings.keySettings.keySize)];
    }
    
    return sessionPass;
}

// Lazy initialization
extern FORCE_INLINE NSData *getEncryptionKey(BOOL useWhenLocked)
{
    NSData *sessionPass = sessionKey();
    
    // If key in memory, return it
    if (key && !useWhenLocked)
    {
        if (sessionPass)
        {
            NSData *decryptedKey = [RNDecryptor decryptData:key
                                               withSettings:kRNCryptorAES256Settings
                                              encryptionKey:sessionPass
                                                    HMACKey:nil
                                                      error:nil];
            
            memset((void*)[sessionPass bytes], 0, [sessionPass length]);
            
            if (decryptedKey)
            {
                return decryptedKey;
            }
            // ELSE: will be retrieved again from the keychain
        }
        else
        {
            return key;
        }
    }
    else if (lockedKey && useWhenLocked)
    {
        if (sessionPass)
        {
            NSData *decryptedKey = [RNDecryptor decryptData:lockedKey
                                               withSettings:kRNCryptorAES256Settings
                                              encryptionKey:sessionPass
                                                    HMACKey:nil
                                                      error:nil];
            
            memset((void*)[sessionPass bytes], 0, [sessionPass length]);
            
            if (decryptedKey)
            {
                return decryptedKey;
            }
            // ELSE: will be retrieved again from the keychain
        }
        else
        {
            return lockedKey;
        }
    }
    
    // Otherwise, try to load it from the keychain
    // If missing, add new entry
    NSString *keychainItemKey = useWhenLocked ? kApplicationKeyChainLockedKey : kApplicationKeyChainKey;
    
    NSData *keychainItem = keychainItemForIdentifier(keychainItemKey);
    
    if (!keychainItem)
    {
        if (useWhenLocked)
        {
            lockedKey = [RNCryptor randomDataOfLength:32];
        }
        else
        {
            key = [RNCryptor randomDataOfLength:32];
        }
        
        NSMutableDictionary *keyDictionary = keychainDictionaryForIdentifier(keychainItemKey);
        NSMutableDictionary *valueDictionary = [keyDictionary mutableCopy];
        
        valueDictionary[(__bridge id)kSecValueData] =  ENCRYPTION_KEY;
        valueDictionary[(__bridge id)kSecAttrAccessible] = (__bridge id)(useWhenLocked ? kSecAttrAccessibleAfterFirstUnlock : kSecAttrAccessibleWhenUnlocked);
        valueDictionary[(__bridge id)kSecAttrCreationDate] = [NSDate date];
        
        OSStatus status = SecItemAdd((__bridge CFDictionaryRef)valueDictionary, NULL);
        
        // If the addition was successful, return.
        // Otherwise, attempt to update existing key or quit (return nil).
        if (status != errSecSuccess)
        {
            if (status == errSecDuplicateItem)
            {
                NSMutableDictionary *updateDictionary = [NSMutableDictionary dictionary];
                
                updateDictionary[(__bridge id)kSecAttrModificationDate] = [NSDate date];
                updateDictionary[(__bridge id)kSecValueData] = ENCRYPTION_KEY;
                
                OSStatus status = SecItemUpdate((__bridge CFDictionaryRef)keyDictionary,
                                                (__bridge CFDictionaryRef)updateDictionary);
                
                if (status != errSecSuccess)
                {
                    if (useWhenLocked)
                    {
                        lockedKey = nil;
                    }
                    else
                    {
                        key = nil;
                    }
                }
            }
            else
            {
                // Error, nil key, disable encryption
                if (useWhenLocked)
                {
                    lockedKey = nil;
                }
                else
                {
                    key = nil;
                }
            }
        }
    }
    else if (useWhenLocked)
    {
        lockedKey = keychainItem;
    }
    else
    {
        key = keychainItem;
    }
    
    sessionPass = sessionKey();
    
    NSData *returnKey = [[NSData alloc] initWithData:ENCRYPTION_KEY];
    
    if (sessionPass)
    {
        if (useWhenLocked)
        {
            NSData *encryptedKey = [RNEncryptor encryptData:lockedKey
                                    withSettings:kRNCryptorAES256Settings
                                   encryptionKey:sessionPass
                                         HMACKey:nil
                                              IV:[RNCryptor randomDataOfLength:kRNCryptorAES256Settings.IVSize]
                                           error:nil];
            
            lockedKey = encryptedKey;
        }
        else
        {
            NSData *encryptedKey = [RNEncryptor encryptData:key
                                    withSettings:kRNCryptorAES256Settings
                                   encryptionKey:sessionPass
                                         HMACKey:nil
                                              IV:[RNCryptor randomDataOfLength:kRNCryptorAES256Settings.IVSize]
                                           error:nil];
            
            key = encryptedKey;
        }

        memset((void*)[sessionPass bytes], 0, [sessionPass length]);
    }
    else
    {
        memset((void*)[lockedKey bytes], 0, [lockedKey length]);
        memset((void*)[key bytes], 0, [key length]);
        
        // Can't encrypt the key in memory, won't be saved in memory at all!
        // Will be retrieved each time when needed...
        lockedKey = nil;
        key = nil;
    }
    
    return returnKey;
}

NSMutableDictionary *keychainDictionaryForIdentifier(NSString *identifier)
{
    NSMutableDictionary *resultDict = [NSMutableDictionary dictionary];
    
    NSString *appName = APP_NAME;
    
    if (!appName)
    {
        // Needed for tests
        appName = @"com.olgadalton.smartsec";
    }
    
    resultDict[(__bridge id)kSecClass] = (__bridge id)kSecClassKey;
    resultDict[(__bridge id)kSecAttrApplicationLabel] = appName;
    resultDict[(__bridge id)kSecAttrApplicationTag] = identifier;
    resultDict[(__bridge id)kSecAttrKeyClass] = @(CSSM_ALGID_AES);
    resultDict[(__bridge id)kSecAttrKeySizeInBits] = @(256);
    resultDict[(__bridge id)kSecAttrEffectiveKeySize] = @(256);
    
    resultDict[(__bridge id)kSecAttrIsPermanent] = (__bridge id)kCFBooleanTrue;
    resultDict[(__bridge id)kSecAttrCanEncrypt] = (__bridge id)kCFBooleanTrue;
    resultDict[(__bridge id)kSecAttrCanDecrypt] = (__bridge id)kCFBooleanTrue;
    resultDict[(__bridge id)kSecAttrCanWrap] = (__bridge id)kCFBooleanFalse;
    resultDict[(__bridge id)kSecAttrCanUnwrap] = (__bridge id)kCFBooleanFalse;
    resultDict[(__bridge id)kSecAttrCanDerive] = (__bridge id)kCFBooleanFalse;
    resultDict[(__bridge id)kSecAttrCanSign] = (__bridge id)kCFBooleanFalse;
    resultDict[(__bridge id)kSecAttrCanVerify] = (__bridge id)kCFBooleanFalse;
    
    return resultDict;
}

NSData *keychainItemForIdentifier(NSString *identifier)
{
    //NSLog(@"Retrieve keychain item for identifier %@", identifier);
    
    NSMutableDictionary *searchDictionary = keychainDictionaryForIdentifier(identifier);
    searchDictionary[(__bridge id)kSecMatchLimit] = (__bridge id)kSecMatchLimitOne;
    searchDictionary[(__bridge id)kSecReturnData] = (__bridge id)kCFBooleanTrue;
    searchDictionary[(__bridge id)kSecReturnAttributes] = (__bridge id)kCFBooleanTrue;
    
    // Search.
    NSData *result = nil;
    CFDictionaryRef foundDict = NULL;
    OSStatus status = SecItemCopyMatching((__bridge CFDictionaryRef)searchDictionary, (CFTypeRef *)&foundDict);
    
    NSDictionary *keychainDictionary = (__bridge NSDictionary *)foundDict;
    
    /* After the application reinstallation, the old encryption key will be removed and replaced with a newly generated key. 
        Different modification dates mean that the application was reinstalled.
     */
    
    NSURL *documentsPath = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    
    // Documents directory gets recreated after the reinstallation
    NSDate *appCreationDate = [[[NSFileManager defaultManager] attributesOfItemAtPath:documentsPath.path error:nil] fileCreationDate];
    
    NSDate *keychainModificationDate = keychainDictionary[(__bridge id)kSecAttrModificationDate];
    
    if ([appCreationDate timeIntervalSince1970]
        - [keychainModificationDate timeIntervalSince1970] > 10)
    {
        // New installation, encryption key needs update
        return nil;
    }
    
    if (status == noErr) {
        result = keychainDictionary[(__bridge id)kSecValueData];
    } else {
        result = nil;
    }
    
    return result;
}

#pragma mark -
#pragma mark - Encryption

extern FORCE_INLINE NSData *getEncryptedDataWithoutHash(NSData *data, BOOL useWhenLocked)
{
    return getEncryptedDataAndHash(data, useWhenLocked, NO);
}

extern FORCE_INLINE NSData *getEncryptedData(NSData *data, BOOL useWhenLocked)
{
    return getEncryptedDataAndHash(data, useWhenLocked, YES);
}

// TODO: is HMAC needed?
extern NSData *getEncryptedDataAndHash(NSData *data, BOOL useWhenLocked, BOOL addHash)
{
    NSData *encryptionKey = ENCRYPTION_KEY_SAFE;
    
    NSError *error;
    NSData *encryptedData = (NSMutableData *)[RNEncryptor encryptData:data
                                        withSettings:kRNCryptorAES256Settings
                                       encryptionKey:encryptionKey
                                             HMACKey:nil
                                                  IV:[RNCryptor randomDataOfLength:kRNCryptorAES256Settings.IVSize]
                                               error:&error];
    
    memset((void*)[encryptionKey bytes], 0, [encryptionKey length]);
    
    if (!addHash)
    {
        return encryptedData;
    }
    
    unsigned long long hash = XXH64([encryptedData bytes], [encryptedData length], 0);
    
    NSString *hashString = [NSString stringWithFormat:@"%lld", hash];
    NSString *checkString = [NSString stringWithFormat:@"%02ld%@",
                             (unsigned long)[hashString length], hashString];
    
    NSMutableData *resultData = [NSMutableData dataWithData:[checkString dataUsingEncoding:NSUTF8StringEncoding]];
    [resultData appendData:encryptedData];
    
    return error ? nil : resultData;
}

extern FORCE_INLINE NSData *validateEncryptedData(NSData *data)
{
    // Validate that data has first two bytes (encoding hash length)
    if ([data length] >= 2)
    {
        NSInteger hashLen = [[[NSString alloc] initWithData:[data subdataWithRange:NSMakeRange(0, 2)] encoding:NSUTF8StringEncoding] integerValue];
        
        // Validate that data has enough room for hash
        if ([data length] >= hashLen + 2)
        {
            unsigned long long hash = [[[NSString alloc] initWithData:[data subdataWithRange:NSMakeRange(2, hashLen)] encoding:NSUTF8StringEncoding] longLongValue];
            
            NSData *encryptedData = [data subdataWithRange:NSMakeRange(2+hashLen, [data length]-hashLen-2)];
            
            // Validate that remaining data is not empty
            if ([encryptedData length])
            {
                unsigned long long realHash = XXH64([encryptedData bytes], [encryptedData length], 0);
                
                if (hash == realHash)
                {
                    return encryptedData;
                }
            }
        }
    }
    return nil;
}

extern FORCE_INLINE NSData *getDecryptedData(NSData *data, BOOL useWhenLocked)
{
    NSData *encryptionKey = ENCRYPTION_KEY_SAFE;
    
    NSError *error;
    NSData *decryptedData = [RNDecryptor decryptData:data
                                        withSettings:kRNCryptorAES256Settings
                                       encryptionKey:encryptionKey
                                             HMACKey:nil
                                               error:&error];
    
    memset((void*)[encryptionKey bytes], 0, [encryptionKey length]);
    
    return decryptedData;
}

@end
