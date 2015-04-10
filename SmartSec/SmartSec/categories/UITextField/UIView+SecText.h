//
//  UIView+Sec.h
//  SmartSec
//
//  Created by Olga Dalton on 07/04/15.
//  Copyright (c) 2015 Olga Dalton. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (SecText)

@property (nonatomic, assign) IBInspectable BOOL insecureEntry;
@property (nonatomic, strong) NSHashTable *textFields;

- (void)addTextField:(UITextField *)textField;

@end
