//
//  UIApplication+TopController.m
//  SmartSec
//
//  Created by Olga Dalton on 07/04/15.
//  Copyright (c) 2015 Olga Dalton. All rights reserved.
//

#import "UIApplication+TopController.h"

@implementation UIApplication (TopController)

- (UIWindow *)mainWindow
{
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    
    if (window.windowLevel != UIWindowLevelNormal)
    {
        return [self normalLevelWindow];
    }
    
    return window;
}

- (UIWindow *)delegateWindow
{
    UIWindow *window = [[UIApplication sharedApplication].delegate window];
    
    if (window.windowLevel != UIWindowLevelNormal)
    {
        return [self normalLevelWindow];
    }
    
    return window;
}

- (UIWindow *)normalLevelWindow
{
    NSArray *allWindows = [UIApplication sharedApplication].windows;
    
    for (UIWindow *window in allWindows)
    {
        if (window.windowLevel == UIWindowLevelNormal)
        {
            return window;
        }
    }
    
    return [UIApplication sharedApplication].keyWindow;
}

- (UIViewController *)topController
{
    UIWindow *topWindow = [self mainWindow];
    
    UIViewController *controller = topWindow.rootViewController;
    
    if (controller == nil)
    {
        topWindow = [self delegateWindow];
        controller = topWindow.rootViewController;
    }
    
    while (controller.presentedViewController)
    {
        controller = controller.presentedViewController;
    }
    
    if ([controller isKindOfClass:[UINavigationController class]])
    {
        UINavigationController *navigationController = (UINavigationController *) controller;
        
        if ([navigationController.viewControllers count])
        {
            controller = [navigationController.viewControllers lastObject];
            
            while (controller.presentedViewController)
            {
                controller = controller.presentedViewController;
            }
        }
    }
    
    return controller;
}

@end
