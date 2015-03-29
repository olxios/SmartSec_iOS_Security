//
//  JailbreakCheck2.h
//  SmartSec
//
//  Created by Olga Dalton on 19/03/15.
//  Copyright (c) 2015 Olga Dalton. All rights reserved.
//

#import "BaseChecksTemplate.h"
#import "OnStateChangeListener.h"
#import "Defines.h"

@interface JailbreakCheck2 : NSObject <BaseChecksTemplate, OnStateChangeListener>

@property (nonatomic, copy) OnJailbreakDetected jailbreakCallback;

@end
