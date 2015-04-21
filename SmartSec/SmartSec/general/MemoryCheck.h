//
//  MemoryCheck.h
//  SmartSec
//
//  Created by Olga Dalton on 12/04/15.
//  Copyright (c) 2015 Olga Dalton. All rights reserved.
//

#import <Foundation/Foundation.h>

// Select randomly class methods and validate each method origin
// Returns YES, if method's image origin is unexpected
extern BOOL checkClassHooked(char * class_name);

// Same as previous, but validate each and every method
// Returns YES, if method's image origin is unexpected
extern BOOL checkClassHookedWithAllMethods(char * class_name);

// Validate a specific method for a specific class
// Returns YES, if method's image origin is unexpected
extern BOOL checkClassMethodHooked(char * class_name, SEL methodSelector);