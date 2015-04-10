//
//  UIApplication+SecText.m
//  SmartSec
//
//  Created by Olga Dalton on 08/04/15.
//  Copyright (c) 2015 Olga Dalton. All rights reserved.
//

#import "UIApplication+SecText.h"
#import "UIApplication+TopController.h"
#import "UIView+SecText.h"
#import "CryptoManager.h"

#import <objc/runtime.h>

static char textFieldsDataKey;
static char screenshotsKey;

@implementation UIApplication (SecText)

#pragma mark - 
#pragma mark - Textfields

- (void)hideTextFieldsContent
{
    if (!self.screenshotsProtectionDisabled)
    {
        UIViewController *topController = [[UIApplication sharedApplication] topController];
        
        NSMapTable *mapTable = [NSMapTable mapTableWithKeyOptions:NSMapTableStrongMemory
                                                     valueOptions:NSMapTableWeakMemory];
        
        for (UITextField *textField in topController.view.textFields)
        {
            if (!textField.insecureEntry
                && textField.text)
            {
                NSData *encryptedData = getEncryptedDataWithoutHash([textField.text dataUsingEncoding:NSUTF8StringEncoding], NO);
                
                [mapTable setObject:textField forKey:encryptedData];
                textField.text = nil;
            }
        }
        
        [self setTextFieldsData:mapTable];
    }
}

- (void)showTextFieldsContent
{
    NSMapTable *mapTable = [self textFieldsData];
    
    if (mapTable)
    {
        NSEnumerator *keyEnumerator = [mapTable keyEnumerator];
        NSData *mapKey = nil;
        
        while ((mapKey = [keyEnumerator nextObject]))
        {
            UITextField *object = [mapTable objectForKey:mapKey];
            
            NSData *decryptedData = getDecryptedData(mapKey, NO);
            object.text = [[NSString alloc] initWithData:decryptedData encoding:NSUTF8StringEncoding];
        }
    }
}

#pragma mark -
#pragma mark - Data storage

- (void)setTextFieldsData:(NSMapTable *)data
{
    objc_setAssociatedObject(self, &textFieldsDataKey, data, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSMapTable *)textFieldsData
{
    return objc_getAssociatedObject(self, &textFieldsDataKey);
}

#pragma mark -
#pragma mark - Settings

- (void)setScreenshotsProtectionDisabled:(BOOL)screenshotsProtectionDisabled
{
    objc_setAssociatedObject(self, &screenshotsKey, @(screenshotsProtectionDisabled), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)screenshotsProtectionDisabled
{
    return [objc_getAssociatedObject(self, &screenshotsKey) boolValue];
}

@end
