//
//  UIApplication+SecText.h
//  SmartSec
//
//  Created by Olga Dalton on 08/04/15.
//  Copyright (c) 2015 Olga Dalton. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIApplication (SecText)

@property (nonatomic) BOOL screenshotsProtectionDisabled;

- (void)hideTextFieldsContent;
- (void)showTextFieldsContent;

@end
