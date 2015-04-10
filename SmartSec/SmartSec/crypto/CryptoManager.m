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

#define ENCRYPTION_KEY (useWhenLocked ? lockedKey : key)

// Inline functions
FORCE_INLINE NSData *keychainItemForIdentifier(NSString *identifier);
FORCE_INLINE NSMutableDictionary *keychainDictionaryForIdentifier(NSString *identifier);

// Encryption format
static const RNCryptorSettings kRNCryptorAES128Settings = {
    .algorithm = kCCAlgorithmAES128,
    .blockSize = kCCBlockSizeAES128,
    .IVSize = kCCBlockSizeAES128,
    .options = kCCOptionPKCS7Padding,
    .HMACAlgorithm = kCCHmacAlgSHA1,
    .HMACLength = CC_SHA1_DIGEST_LENGTH,
    
    .keySettings = {
        .keySize = kCCKeySizeAES128,
        .saltSize = 8,
        .PBKDFAlgorithm = kCCPBKDF2,
        .PRF = kCCPRFHmacAlgSHA1,
        .rounds = 10000
    },
    
    .HMACKeySettings = {
        .keySize = kCCKeySizeAES128,
        .saltSize = 8,
        .PBKDFAlgorithm = kCCPBKDF2,
        .PRF = kCCPRFHmacAlgSHA1,
        .rounds = 10000
    }
};

@implementation CryptoManager

#pragma mark -
#pragma mark - Key handling

extern FORCE_INLINE NSData *getEncryptionKey(BOOL useWhenLocked)
{
    // If key in memory, return it
    if (key && !useWhenLocked)
    {
        return key;
    }
    else if (lockedKey && useWhenLocked)
    {
        return lockedKey;
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
    
    return ENCRYPTION_KEY;
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
    NSError *error;
    NSData *encryptedData = (NSMutableData *)[RNEncryptor encryptData:data
                                        withSettings:kRNCryptorAES256Settings
                                       encryptionKey:ENCRYPTION_KEY
                                             HMACKey:nil
                                                  IV:[RNCryptor randomDataOfLength:kRNCryptorAES256Settings.IVSize]
                                               error:&error];
    
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
    NSError *error;
    NSData *decryptedData = [RNDecryptor decryptData:data
                                        withSettings:kRNCryptorAES256Settings
                                       encryptionKey:ENCRYPTION_KEY
                                             HMACKey:nil
                                               error:&error];
    
    return decryptedData;
}


@end
