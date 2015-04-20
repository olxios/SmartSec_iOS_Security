//
//  MemoryCheck.h
//  SmartSec
//
//  Created by Olga Dalton on 12/04/15.
//  Copyright (c) 2015 Olga Dalton. All rights reserved.
//

#import <Foundation/Foundation.h>

extern BOOL checkClassHooked(char * class_name);
extern BOOL checkClassHookedWithAllMethods(char * class_name);

extern BOOL checkClassMethodHooked(char * class_name, SEL methodSelector);