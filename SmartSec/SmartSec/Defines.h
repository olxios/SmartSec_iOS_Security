//
//  Defines.h
//  SmartSec
//
//  Created by Olga Dalton on 10/03/15.
//  Copyright (c) 2015 Olga Dalton. All rights reserved.
//

/*
 Generally, functions are not inlined unless optimization is specified. For functions declared inline, this attribute inlines the function independent of any restrictions that otherwise apply to inlining. Failure to inline such a function is diagnosed as an error. Note that if such a function is called indirectly the compiler may or may not inline it depending on optimization level and a failure to inline an indirect call may or may not be diagnosed.
 */

#define FORCE_INLINE inline __attribute__((always_inline))