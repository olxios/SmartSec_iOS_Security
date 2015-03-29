//
//  IntegrityCheck1.m
//  SmartSec
//
//  Created by Olga Dalton on 19/03/15.
//  Copyright (c) 2015 Olga Dalton. All rights reserved.
//

#import "IntegrityCheck2.h"
#import "NSObject+State.h"
#import <UIKit/UIKit.h>
#import "UIApplication+Sec.h"

// Encryption checks imports
#import <dlfcn.h>
#import <mach-o/dyld.h>
#import <TargetConditionals.h>

#import "LOOCryptString.h"

// Inline functions
FORCE_INLINE void checkBinaryEncryption(IntegrityCheck2 *selfRef);
FORCE_INLINE void encryptionProblems(IntegrityCheck2 *selfRef);

@implementation IntegrityCheck2

#pragma mark -
#pragma mark - Custom setters

- (void)setMainReference:(const void *)mainReference
{
    _mainReference = mainReference;
    checkBinaryEncryption(self);
}

#pragma mark -
#pragma mark - BaseChecksTemplate

- (void)hookChecks
{
    [UIViewController addObserver:self];
    //[UINavigationController addObserver:self];
}

- (void)unhookChecks
{
    [UIViewController removeObserver:self];
    //[UINavigationController removeObserver:self];
}

#pragma mark -
#pragma mark - OnStateChangeListener

- (void)onStateChanged:(id)stateObject fromObject:(id)observedObject
{
    if ([stateObject isKindOfClass:[NSString class]]
        && [stateObject isEqualToString:NSStringFromSelector(@selector(viewDidLoad))])
    {
#if ENABLE_CHECKS
        // Code signature && encryption checks
        checkBinaryEncryption(self);
#endif
    }
}

#pragma mark -
#pragma mark - Run checks

- (void)runChecks
{
#if ENABLE_CHECKS
    // Code signature && encryption checks
    checkBinaryEncryption(self);
#endif
}

// If the binary is not encrypted, it is probably cracked
// Not working on simulator,
// but will be used only in the release mode anyway
// Based on Landon Fuller's great post:
// http://landonf.bikemonkey.org/2009/02/index.html
// Updated for usage in 64bit phones and integrated to Smartsec

void checkBinaryEncryption(IntegrityCheck2 *selfRef)
{    
    if (selfRef.mainReference == NULL)
    {
        return;
    }
    
    // Define needed vars
    const struct mach_header_64 *header64bits;
    const struct mach_header *header32bits;
    Dl_info dlinfo;
    
    // If main not found,
    // possibly some modifications made to the binary
    if (dladdr(selfRef.mainReference, &dlinfo) == 0
        || dlinfo.dli_fbase == NULL)
    {
        encryptionProblems(selfRef);
        return;
    }
    
    header32bits = dlinfo.dli_fbase;
    
    // Since 32bit phones are still supported and mach_header_64,
    // separate checks for 64 bits and 32 bits are needed
    // TODO: Eliminate copy-paste of this code
    if (header32bits->magic == MH_MAGIC_64)
    {
        header64bits = dlinfo.dli_fbase;
        
        // Compute binary size
        struct load_command *cmd = (struct load_command *) (header64bits+1);
        
        for (uint32_t i = 0; cmd != NULL && i < header64bits->ncmds; i++)
        {
            // If it's encryption segment,
            // check it futher
            
            if (cmd->cmd == LC_ENCRYPTION_INFO_64)
            {
                struct encryption_info_command *crypt_cmd = (struct encryption_info_command *) cmd;
                
                // Validate that encryption is present
                if (crypt_cmd->cryptid < 1)
                {
                    // No encryption present
                    // Something is wrong!
                    encryptionProblems(selfRef);
                    return;
                }
                else
                {
                    // Encryption is present
                    // Can proceed,
                    // as probably the app is not pirated
                    return;
                }
            }
            
            cmd = (struct load_command *) ((uint8_t *) cmd + cmd->cmdsize);
        }
    }
    else
    {
        // TODO: Test this on iPhone 4S

        struct load_command *cmd = (struct load_command *) (header32bits+1);
        
        for (uint32_t i = 0; cmd != NULL && i < header32bits->ncmds; i++)
        {
            if (cmd->cmd == LC_ENCRYPTION_INFO)
            {
                struct encryption_info_command *crypt_cmd = (struct encryption_info_command *) cmd;
                
                if (crypt_cmd->cryptid < 1)
                {
                    encryptionProblems(selfRef);
                    return;
                }
                else
                {
                    return;
                }
            }
            
            cmd = (struct load_command *) ((uint8_t *) cmd + cmd->cmdsize);
        }
    }
    
    encryptionProblems(selfRef);
}

FORCE_INLINE void encryptionProblems(IntegrityCheck2 *selfRef)
{
    if (selfRef.onEncryptionMissingDetected)
    {
        selfRef.onEncryptionMissingDetected();
    }
    else
    {
        [UIApplication killMe];
        exit(-1); // extra call to kill the app
    }
}

@end
