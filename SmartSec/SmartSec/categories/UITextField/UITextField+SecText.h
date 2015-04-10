//
//  UITextField+Sec.h
//  SmartSec
//
//  Created by Olga Dalton on 07/04/15.
//  Copyright (c) 2015 Olga Dalton. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UITextField (SecText)

@property (nonatomic, assign) IBInspectable BOOL insecureEntry;

+ (void)setCorrectionDisabled:(BOOL)correctionDisabled;

@end
