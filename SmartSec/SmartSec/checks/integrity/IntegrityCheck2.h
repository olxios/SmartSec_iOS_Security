//
//  IntegrityCheck1.h
//  SmartSec
//
//  Created by Olga Dalton on 19/03/15.
//  Copyright (c) 2015 Olga Dalton. All rights reserved.
//

#import "BaseChecksTemplate.h"
#import "OnStateChangeListener.h"
#import "Defines.h"

@interface IntegrityCheck2 : NSObject <BaseChecksTemplate, OnStateChangeListener>

@property (nonatomic, copy) OnEncryptionMissingDetected onEncryptionMissingDetected;

extern void setMainReference(const void * mainReference);

@end
