//
//  MemoryCheck.m
//  SmartSec
//
//  Created by Olga Dalton on 12/04/15.
//  Copyright (c) 2015 Olga Dalton. All rights reserved.
//
//  Based on:
//
//  The Mobile Application Hacker's Handbook
//  By Dominic Chell,Tyrone Erasmus,Jon Lindsay,Shaun Colley,Ollie Whitehouse
//  https://books.google.ee/books?id=5gVhBgAAQBAJ&pg=PA149&hl=et&source=gbs_toc_r&cad=3#v=onepage&q&f=false

#import "MemoryCheck.h"
#import "Defines.h"
#import "LOOCryptString.h"

#import <dlfcn.h>
#import <objc/runtime.h>

// Declarations

FORCE_INLINE int endsWith(const char *str, const char *suffix);
FORCE_INLINE BOOL checkMethodImplementationHooked(IMP methodimp);
FORCE_INLINE BOOL checkClassHookedWithConfig(char * class_name, BOOL checkAllMethods);

// Implementations

extern FORCE_INLINE BOOL checkClassMethodHooked(char * class_name, SEL methodSelector)
{
    IMP methodImp = class_getMethodImplementation(objc_getClass(class_name), methodSelector);
    return checkMethodImplementationHooked(methodImp);
}

extern FORCE_INLINE BOOL checkClassHooked(char * class_name)
{
    return checkClassHookedWithConfig(class_name, NO);
}

extern FORCE_INLINE BOOL checkClassHookedWithAllMethods(char * class_name)
{
    return checkClassHookedWithConfig(class_name, YES);
}

BOOL checkClassHookedWithConfig(char * class_name, BOOL checkAllMethods)
{
    Class aClass = objc_getClass(class_name);
    Method *methods;
    unsigned int nMethods;
    
    IMP methodimp;
    Method m;
    if (!aClass) return NO;
    
    methods = class_copyMethodList(aClass, &nMethods);
    
    int max = (int)(nMethods / 20);
    
    // Pass through all class methods
    // If checkAllMethods == NO, select methods to check randomly
    for (int i = 0; i < nMethods; i+= (checkAllMethods ? 1 : (MAX((int)ceilf(arc4random()%(max ? max : 1)), 1))))
    {
        m = methods[i];
        
        methodimp = (void *) method_getImplementation(m);
        
        if (checkMethodImplementationHooked(methodimp))
        {
            free(methods);
            return YES;
        }
    }
    
    free(methods);
    return NO;
}

BOOL checkMethodImplementationHooked(IMP methodimp)
{
    if (!methodimp)
    {
        return NO;
    }
    
    Dl_info info;
    
    // Query DL_info from method implementation using dladdr
    int d = dladdr((const void *) methodimp, &info);
    
    if (!d)
    {
        // Requested symbol wasn't found
        return NO;
    }
    
    // Check image origin against legit origins
    if (strstr(info.dli_fname, [LOO_CRYPT_STR_N("/usr/lib/", 9) UTF8String]))
    {
        return NO;
    }
    
    if (strstr(info.dli_fname, [LOO_CRYPT_STR_N("/System/Library/Frameworks/", 27) UTF8String]))
    {
        return NO;
    }
    
    if (strstr(info.dli_fname, [LOO_CRYPT_STR_N("/System/Library/PrivateFrameworks/", 34) UTF8String]))
    {
        return NO;
    }
    
    if (strstr(info.dli_fname, [LOO_CRYPT_STR_N("/System/Library/Accessibility", 29) UTF8String]))
    {
        return NO;
    }
    
    if (strstr(info.dli_fname, [LOO_CRYPT_STR_N("/System/Library/TextInput", 25) UTF8String]))
    {
        return NO;
    }
    
    // Compose application path
    char appPath[512];
    snprintf(appPath, sizeof(appPath), "%s/%s/",
             [[[NSBundle mainBundle] resourcePath] UTF8String],
             [[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleName"] UTF8String]);
    
    if (endsWith(info.dli_fname, appPath) == 1)
    {
        return NO;
    }
    
    char appPathShort[512];
    
    snprintf(appPathShort, sizeof(appPathShort), "%s/%s",
             [[[NSBundle mainBundle] resourcePath] UTF8String],
             [[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleName"] UTF8String]);
    
    if (endsWith(info.dli_fname, appPathShort) == 1)
    {
        return NO;
    }
    
    // Check that a swizzled method origins from the security framework
    if (endsWith(info.dli_fname, [LOO_CRYPT_STR_N("/SmartSec.framework/SmartSec", 28) UTF8String])
        || endsWith(info.dli_fname, [LOO_CRYPT_STR_N("/SmartSec.framework/SmartSec/", 29) UTF8String]))
    {
        return NO;
    }
    
    if (info.dli_fname)
    {
        // At this point we should have mached at least something!
        // If nobody is hooking methods of course :)
        return YES;
    }
    
    return NO;
}

int endsWith(const char *str, const char *suffix)
{
    if (!str || !suffix)
        return 0;
    size_t lenstr = strlen(str);
    size_t lensuffix = strlen(suffix);
    if (lensuffix >  lenstr)
        return 0;
    return strncmp(str + lenstr - lensuffix, suffix, lensuffix) == 0;
}