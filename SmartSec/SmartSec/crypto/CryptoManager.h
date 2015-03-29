//
//  CryptoManager.h
//  SmartSec
//
//  Created by Olga Dalton on 20/03/15.
//  Copyright (c) 2015 Olga Dalton. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CryptoManager : NSObject

// Encrypted writeToFile: support
// NSData
// NSString
// NSArray
// NSDictionary

extern NSData *getEncryptionKey(BOOL useWhenLocked);
extern NSData *getEncryptedDataAndHash(NSData *data, BOOL useWhenLocked, BOOL addHash);
extern NSData *getEncryptedDataWithoutHash(NSData *data, BOOL useWhenLocked);
extern NSData *getEncryptedData(NSData *data, BOOL useWhenLocked);
extern NSData *getDecryptedData(NSData *data, BOOL useWhenLocked);
extern NSData *validateEncryptedData(NSData *data);

@end
