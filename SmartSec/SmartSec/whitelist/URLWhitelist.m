//
//  URLWhitelist.m
//  SmartSec
//
//  Created by Olga Dalton on 09/04/15.
//  Copyright (c) 2015 Olga Dalton. All rights reserved.
//  **********************************************************
//  Inspired by a brilliant Cordova whitelisting implementation!
//  https://github.com/apache/cordova-ios


#import "URLWhitelist.h"
#import "LOOCryptString.h"
#import "Defines.h"
#import <objc/runtime.h>

#pragma mark -
#pragma mark - Model object

@interface WhiteListEntry : NSObject

@property (nonatomic, strong) NSRegularExpression *protocolPattern;
@property (nonatomic, strong) NSRegularExpression *domainPattern;
@property (nonatomic, strong) NSRegularExpression *resourcePattern;
@property (nonatomic, strong) NSNumber *port;

@end

@implementation WhiteListEntry

- (NSString *)description
{
    return [NSString stringWithFormat:@"Protocol %@, domain %@, resource %@, port %@",
            self.protocolPattern, self.domainPattern, self.resourcePattern, self.port];
}

@end

#pragma mark -
#pragma mark - Main object

@interface URLWhitelist()
{
    NSMutableArray *_whiteList;
}

@end

static char webViewWhiteListKey;
static char urlSchemeWhiteListKey;

FORCE_INLINE void initWhiteList(URLWhitelist *selfRef, NSString *listKey, BOOL urlSchemeList);
FORCE_INLINE WhiteListEntry * webViewWhiteListEntry(NSString *entry);
FORCE_INLINE WhiteListEntry * urlSchemesWhiteListEntry(NSString *entry);
FORCE_INLINE BOOL entryMatches(WhiteListEntry *entry, NSURL *url);

@implementation URLWhitelist

#pragma mark -
#pragma mark - Initialize

static void __attribute__((constructor)) initialize(void)
{
    URLWhitelist *webViewWhiteList = [[URLWhitelist alloc] initWebViewWhiteListWithKey:LOO_CRYPT_STR_N("WebAccessWhiteList", 18)];
    
    objc_setAssociatedObject([URLWhitelist class], &webViewWhiteListKey,
                             webViewWhiteList, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    URLWhitelist *urlSchemeWhiteList = [[URLWhitelist alloc] initURLSchemeWhiteListWithKey:LOO_CRYPT_STR_N("URLSchemesAccessWhiteList", 25)];
    
    objc_setAssociatedObject([URLWhitelist class], &urlSchemeWhiteListKey,
                             urlSchemeWhiteList, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

#pragma mark -
#pragma mark - Object init

- (instancetype)initWebViewWhiteListWithKey:(NSString *)key
{
    self = [super init];
    
    if (self)
    {
        initWhiteList(self, key, NO);
    }
    
    return self;
}

- (instancetype)initURLSchemeWhiteListWithKey:(NSString *)key
{
    self = [super init];
    
    if (self)
    {
        initWhiteList(self, key, YES);
    }
    
    return self;
}

#pragma mark -
#pragma mark - Parse whitelist

void initWhiteList(URLWhitelist *selfRef, NSString *listKey, BOOL urlSchemeList)
{
    selfRef->_whiteList = [NSMutableArray array];
    
    NSArray *declaredWhiteList = [[NSBundle mainBundle] objectForInfoDictionaryKey:listKey];
    
    for (NSString *item in declaredWhiteList)
    {
        if (urlSchemeList)
        {
            [selfRef->_whiteList addObject:urlSchemesWhiteListEntry(item)];
        }
        else
        {
            [selfRef->_whiteList addObject:webViewWhiteListEntry(item)];
        }
    }

    if (!urlSchemeList)
    {
        [selfRef->_whiteList addObjectsFromArray:@[webViewWhiteListEntry(@"file:///*"), webViewWhiteListEntry(@"content:///*")]];
    }
    
}

WhiteListEntry * webViewWhiteListEntry(NSString *entry)
{
    NSString *matchingRegex = @"^(?:([^:/?#]+):)?(?://([^/?:#]*))?(?::([1-9]{1,4}))?([^?#]*)(\\?([^#]*))?(#(.*))?";
    
    NSRegularExpression *regularExpression = [NSRegularExpression regularExpressionWithPattern:matchingRegex options:0 error:nil];
    
    NSArray *matchResults = [regularExpression matchesInString:entry
                                                        options:NSMatchingAnchored
                                                        range:NSMakeRange(0, [entry length])];
    
    WhiteListEntry *whiteListEntry = [[WhiteListEntry alloc] init];
    
    if ([matchResults count])
    {
        NSTextCheckingResult *firstMatch = matchResults[0];
        
        NSRange range;
        
        if ((range = [firstMatch rangeAtIndex:2]).location != NSNotFound)
        {
            NSString *domainPattern = [[[entry substringWithRange:range] stringByReplacingOccurrencesOfString:@"." withString:@"\\."] stringByReplacingOccurrencesOfString:@"*" withString:@".*"];
            
            if ([domainPattern length]
                && ![domainPattern isEqualToString:@"*"])
            {
                whiteListEntry.domainPattern = [NSRegularExpression regularExpressionWithPattern:[domainPattern stringByAppendingString:@"$"] options:NSRegularExpressionCaseInsensitive error:nil];
            }
        }
        
        if ((range = [firstMatch rangeAtIndex:4]).location != NSNotFound)
        {
            NSString *resourcePath = [[entry substringWithRange:range] stringByReplacingOccurrencesOfString:@"*" withString:@".*"];
            
            if ([resourcePath length] && ![resourcePath isEqualToString:@"*"])
            {
                whiteListEntry.resourcePattern = [NSRegularExpression regularExpressionWithPattern:[resourcePath stringByAppendingString:@"$"] options:NSRegularExpressionCaseInsensitive error:nil];
            }
        }
        
        if ((range = [firstMatch rangeAtIndex:1]).location != NSNotFound)
        {
            NSString *protocolPattern = [[entry substringWithRange:range] stringByReplacingOccurrencesOfString:@"*" withString:@".*"];
            
            if ([protocolPattern length] && ![protocolPattern isEqualToString:@"*"])
            {
                whiteListEntry.protocolPattern = [NSRegularExpression regularExpressionWithPattern:[protocolPattern stringByAppendingString:@"$"] options:NSRegularExpressionCaseInsensitive error:nil];
            }
            
            if ([protocolPattern isEqualToString:@"file"]
                || [protocolPattern isEqualToString:@"content"])
            {
                whiteListEntry.domainPattern = [NSRegularExpression regularExpressionWithPattern:@".*" options:NSRegularExpressionCaseInsensitive error:nil];
                
                whiteListEntry.resourcePattern = [NSRegularExpression regularExpressionWithPattern:@".*" options:NSRegularExpressionCaseInsensitive error:nil];
            }
        }
        
        if ((range = [firstMatch rangeAtIndex:3]).location != NSNotFound)
        {
            whiteListEntry.port = @([[entry substringWithRange:range] integerValue]);
        }
    }
    return whiteListEntry;
}

WhiteListEntry * urlSchemesWhiteListEntry(NSString *entry)
{
    WhiteListEntry *whiteListEntry = [[WhiteListEntry alloc] init];
    
    NSString *domainPattern = [[entry stringByReplacingOccurrencesOfString:@"." withString:@"\\."] stringByReplacingOccurrencesOfString:@"*" withString:@".*"];
    
    whiteListEntry.domainPattern = [NSRegularExpression regularExpressionWithPattern:[domainPattern stringByAppendingString:@"$"] options:NSRegularExpressionCaseInsensitive error:nil];
    
    return whiteListEntry;
}

#pragma mark -
#pragma mark - Actual matching

extern FORCE_INLINE BOOL urlMatches(NSURL *url)
{
    URLWhitelist *whiteList = objc_getAssociatedObject([URLWhitelist class], &webViewWhiteListKey);
    
    //NSLog(@"\n\n\n\n********************************\n");
    //NSLog(@"ENTRY: %@", whiteList->_whiteList);
    
    for (WhiteListEntry *entry in whiteList->_whiteList)
    {
        if (entryMatches(entry, url))
        {
            return YES;
        }
    }
    
    return [whiteList->_whiteList count] ? NO : YES;
}

extern FORCE_INLINE BOOL sourceApplicationMatches(NSString *appBundleId)
{
    URLWhitelist *whiteList = objc_getAssociatedObject([URLWhitelist class], &urlSchemeWhiteListKey);
    
    for (WhiteListEntry *entry in whiteList->_whiteList)
    {
        if (!entry.domainPattern || [[entry.domainPattern matchesInString:appBundleId options:NSMatchingAnchored range:NSMakeRange(0, [appBundleId length])] count])
        {
            return YES;
        }
    }
    
    return [whiteList->_whiteList count] ? NO : YES;
}

BOOL entryMatches(WhiteListEntry *entry, NSURL *url)
{
    if ([url isFileURL])
    {
        return YES;
    }
    else
    {
        NSString *scheme = [url scheme];
        
        if ([scheme isEqualToString:@"about"]
            || [scheme isEqualToString:@"tel"]
            || [scheme isEqualToString:@"data"])
        {
            return YES;
        }
    }
    
    BOOL protocolResult = (!entry.protocolPattern || ([url scheme] &&[[entry.protocolPattern matchesInString:[url scheme] options:NSMatchingAnchored range:NSMakeRange(0, [[url scheme] length])] count]));
    
    NSString *matchHost = [url host];
    
    if ([matchHost hasSuffix:@"/"])
    {
        matchHost = [matchHost substringToIndex:[matchHost length]-2];
    }
    
    BOOL domainResult = (!entry.domainPattern || (matchHost && [[entry.domainPattern matchesInString:matchHost options:NSMatchingAnchored range:NSMakeRange(0, [matchHost length])] count]));
    
    BOOL portResult = (!entry.port || [entry.port intValue] == [[url port] intValue]);
    
    BOOL resourceResult = (!entry.resourcePattern || ([url path] || [[entry.resourcePattern matchesInString:[url path] options:NSMatchingAnchored range:NSMakeRange(0, [[url path] length])] count]));
        
    return protocolResult && domainResult && portResult && resourceResult;
}

@end
