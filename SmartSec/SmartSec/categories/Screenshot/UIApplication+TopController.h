//
//  UIApplication+TopController.h
//  SmartSec
//
//  Created by Olga Dalton on 07/04/15.
//  Copyright (c) 2015 Olga Dalton. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIApplication (TopController)

- (UIViewController *)topController;

- (UIWindow *)mainWindow;
- (UIWindow *)delegateWindow;

@end
