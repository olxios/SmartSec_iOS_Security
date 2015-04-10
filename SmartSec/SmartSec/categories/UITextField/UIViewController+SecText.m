//
//  UIViewController+SecText.m
//  SmartSec
//
//  Created by Olga Dalton on 07/04/15.
//  Copyright (c) 2015 Olga Dalton. All rights reserved.
//

#import "UIViewController+SecText.h"
#import "UIView+SecText.h"

@implementation UIViewController (SecText)
@dynamic insecureEntry;

#pragma mark -
#pragma mark - Settings

- (void)setInsecureEntry:(BOOL)insecureEntry
{    
    self.view.insecureEntry = insecureEntry;
}

- (BOOL)insecureEntry
{
    return self.view.insecureEntry;
}

@end
