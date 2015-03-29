//
//  NSStringTest.m
//  SmartSec
//
//  Created by Olga Dalton on 25/03/15.
//  Copyright (c) 2015 Olga Dalton. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "RNCryptor.h"
#import <SmartSec/SmartSec.h>

@interface NSStringTest : XCTestCase

@end

@implementation NSStringTest

- (void)setUp
{
    [super setUp];
}

- (void)tearDown
{
    [super tearDown];
}

- (NSString *)testDataPath:(NSInteger)identifier
{
    NSURL *documentsURL = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    
    NSString *path = [[documentsURL path] stringByAppendingPathComponent:[NSString stringWithFormat:@"daata_%ld.dat", (long) identifier]];
    
    return path;
}

- (NSString *)testString
{
    NSData *randomData = [RNCryptor randomDataOfLength:32];
    NSString *base64String = [randomData base64EncodedStringWithOptions:0];
    return base64String;
}

- (void)testWriteToFile
{
    NSString *testString = [self testString];
    NSString *path = [self testDataPath:1];
    
    [testString writeToFile:path
                 atomically:YES
                   encoding:NSUTF8StringEncoding
                      error:nil];
    
    [self runStandardReadingTests:testString onFile:path];
}

- (void)testWriteToURL
{
    NSString *testString = [self testString];
    NSString *path = [self testDataPath:2];
    
    [testString writeToURL:[NSURL fileURLWithPath:path]
                atomically:YES
                  encoding:NSUTF8StringEncoding error:nil];
    
    [self runStandardReadingTests:testString onFile:path];
}

- (void)testWritePlaintextToFile
{
    NSString *testString = [self testString];
    NSString *path = [self testDataPath:3];
    
    [testString writePlaintextToFile:path
                          atomically:YES
                            encoding:NSUTF8StringEncoding
                               error:nil];
    
    [self runStandardReadingTests:testString onFile:path];
}

- (void)testWritePlaintextToURL
{
    NSString *testString = [self testString];
    NSString *path = [self testDataPath:4];
    
    [testString writePlaintextToURL:[NSURL fileURLWithPath:path]
                         atomically:YES
                           encoding:NSUTF8StringEncoding
                              error:nil];
    
    [self runStandardReadingTests:testString onFile:path];
}

- (void)runStandardReadingTests:(NSString *)correctData onFile:(NSString *)testFile
{
    NSString *resultString1 = [NSString stringWithContentsOfFile:testFile encoding:NSUTF8StringEncoding error:nil];
    NSString *resultString2 = [NSString stringWithContentsOfURL:[NSURL fileURLWithPath:testFile] encoding:NSUTF8StringEncoding error:nil];
    
    NSString *resultString3 = [[NSString alloc] initWithContentsOfFile:testFile encoding:NSUTF8StringEncoding error:nil];
    NSString *resultString4 = [[NSString alloc] initWithContentsOfURL:[NSURL fileURLWithPath:testFile] encoding:NSUTF8StringEncoding error:nil];
    
    XCTAssertEqualObjects(correctData, resultString1);
    XCTAssertEqualObjects(correctData, resultString2);
    XCTAssertEqualObjects(correctData, resultString3);
    XCTAssertEqualObjects(correctData, resultString4);
    
    BOOL removeResult = [[NSFileManager defaultManager] removeItemAtPath:testFile error:nil];
    XCTAssertTrue(removeResult);
}

@end
