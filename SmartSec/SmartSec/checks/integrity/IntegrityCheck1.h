//
//  IntegrityCheck1.h
//  SmartSec
//
//  Created by Olga Dalton on 18/03/15.
//  Copyright (c) 2015 Olga Dalton. All rights reserved.
//

#import "BaseChecksTemplate.h"
#import "OnStateChangeListener.h"
#import "Defines.h"

@interface IntegrityCheck1 : NSObject <BaseChecksTemplate, OnStateChangeListener>

extern void check_class(char * class_name);
extern void check_class_all_methods(char * class_name);

@end
