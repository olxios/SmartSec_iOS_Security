//
//  PinnedURLConnectionHandler.h
//  SmartSec
//
//  Created by Olga Dalton on 08/04/15.
//  Copyright (c) 2015 Olga Dalton. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PinnedURLConnectionHandler : NSObject

+ (BOOL)authenticationChallengeValid:(NSURLAuthenticationChallenge *)authenticationChallenge;

// SSL certificates validation config
extern void allowInvalidCertificates(BOOL releaseMode, NSArray *domains);

// SSL pinning config
extern void savedPinnedCertificates(NSDictionary *sslPinningDictionary);

@end
