//
//  NSDataTest.m
//  SmartSec
//
//  Created by Olga Dalton on 25/03/15.
//  Copyright (c) 2015 Olga Dalton. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "RNCryptor.h"
#import <SmartSec/SmartSec.h>

@interface NSDataTest : XCTestCase

@end

@implementation NSDataTest

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
    
    NSString *path = [[documentsURL path] stringByAppendingPathComponent:[NSString stringWithFormat:@"_data_%ld.dat", (long) identifier]];
    
    return path;
}

- (NSData *)testData
{
    return [RNCryptor randomDataOfLength:100];
}

- (void)testWriteToFile
{
    NSData *testData = [self testData];
    NSString *testFile = [self testDataPath:1];
    
    [testData writeToFile:testFile atomically:YES];
    [self runStandardReadingTests:testData onFile:testFile];
}

- (void)testWriteToFileWithOptions1
{
    NSData *testData = [self testData];
    NSString *testFile = [self testDataPath:2];
    
    [testData writeToFile:testFile options:NSDataWritingAtomic error:nil];
    [self runStandardReadingTests:testData onFile:testFile];
}

- (void)testWriteToFileWithOptions2
{
    NSData *testData = [self testData];
    NSString *testFile = [self testDataPath:3];
    
    [testData writeToFile:testFile options:NSDataWritingFileProtectionComplete error:nil];
    [self runStandardReadingTests:testData onFile:testFile];
}

- (void)testWriteToFileWithOptions3
{
    NSData *testData = [self testData];
    NSString *testFile = [self testDataPath:4];
    
    [testData writeToFile:testFile options:NSDataWritingFileProtectionNone error:nil];
    [self runStandardReadingTests:testData onFile:testFile];
}

- (void)testWriteToURL
{
    NSData *testData = [self testData];
    NSString *testFile = [self testDataPath:5];
    
    [testData writeToURL:[NSURL fileURLWithPath:testFile] atomically:YES];
    [self runStandardReadingTests:testData onFile:testFile];
}

- (void)testWriteToURLWithOptions1
{
    NSData *testData = [self testData];
    NSString *testFile = [self testDataPath:6];
    
    [testData writeToURL:[NSURL fileURLWithPath:testFile] options:NSDataWritingFileProtectionNone error:nil];
    [self runStandardReadingTests:testData onFile:testFile];
}

- (void)testWriteToURLWithOptions2
{
    NSData *testData = [self testData];
    NSString *testFile = [self testDataPath:7];
    
    [testData writeToURL:[NSURL fileURLWithPath:testFile] options:NSDataWritingFileProtectionComplete error:nil];
    [self runStandardReadingTests:testData onFile:testFile];
}

- (void)testWritePlaintextToFile
{
    NSData *testData = [self testData];
    NSString *testFile = [self testDataPath:8];
    
    [testData writePlaintextToFile: testFile atomically:YES];
    [self runPlaintextReadingTests:testData onFile:testFile];
}

- (void)testWritePlaintextToURL
{
    NSData *testData = [self testData];
    NSString *testFile = [self testDataPath:9];
    
    [testData writePlaintextToURL: [NSURL fileURLWithPath:testFile] atomically:YES];
    [self runPlaintextReadingTests:testData onFile:testFile];
}

- (void)testWritePlaintextToFileWithOptions1
{
    NSData *testData = [self testData];
    NSString *testFile = [self testDataPath:10];
    
    [testData writePlaintextToFile:testFile options:NSDataWritingFileProtectionComplete error:nil];
    [self runPlaintextReadingTests:testData onFile:testFile];
}

- (void)testWritePlaintextToFileWithOptions2
{
    NSData *testData = [self testData];
    NSString *testFile = [self testDataPath:11];
    
    [testData writePlaintextToFile:testFile options:NSDataWritingFileProtectionNone error:nil];
    [self runPlaintextReadingTests:testData onFile:testFile];
}

- (void)testWritePlaintextToURLWithOptions1
{
    NSData *testData = [self testData];
    NSString *testFile = [self testDataPath:12];
    
    [testData writePlaintextToURL: [NSURL fileURLWithPath:testFile] options:NSDataWritingFileProtectionComplete error:nil];
    [self runPlaintextReadingTests:testData onFile:testFile];
}

- (void)testWritePlaintextToURLWithOptions2
{
    NSData *testData = [self testData];
    NSString *testFile = [self testDataPath:12];
    
    [testData writePlaintextToURL: [NSURL fileURLWithPath:testFile] options:NSDataWritingFileProtectionNone error:nil];
    [self runPlaintextReadingTests:testData onFile:testFile];
}

- (void)runPlaintextReadingTests:(NSData *)correctData onFile:(NSString *)testFile
{
    NSData *resultData1 = [NSData dataWithContentsOfFile:testFile];
    NSData *resultData2 = [NSData dataWithContentsOfURL:[NSURL fileURLWithPath:testFile]];
    NSData *resultData3 = [NSData dataWithContentsOfFile:testFile
                                                 options:NSDataReadingMapped
                                                   error:nil];
    NSData *resultData4 = [NSData dataWithContentsOfURL:[NSURL fileURLWithPath:testFile]
                                                options:NSDataReadingUncached
                                                  error:nil];
    // Plain data
    NSData *plainData = [NSData plainDataWithContentsOfFile:testFile];
    
    XCTAssertEqualObjects(correctData, resultData1);
    XCTAssertEqualObjects(correctData, resultData2);
    XCTAssertEqualObjects(correctData, resultData3);
    XCTAssertEqualObjects(correctData, resultData4);
    XCTAssertEqualObjects(correctData, plainData);
    
    BOOL removeResult = [[NSFileManager defaultManager] removeItemAtPath:testFile error:nil];
    XCTAssertTrue(removeResult);
}

- (void)runStandardReadingTests:(NSData *)correctData onFile:(NSString *)testFile
{
    NSData *resultData1 = [NSData dataWithContentsOfFile:testFile];
    NSData *resultData2 = [NSData dataWithContentsOfURL:[NSURL fileURLWithPath:testFile]];
    NSData *resultData3 = [NSData dataWithContentsOfFile:testFile
                                                 options:NSDataReadingMapped
                                                   error:nil];
    NSData *resultData4 = [NSData dataWithContentsOfURL:[NSURL fileURLWithPath:testFile]
                                                options:NSDataReadingUncached
                                                  error:nil];
    
    NSData *resultData5 = [[NSData alloc] initWithContentsOfFile:testFile];
    NSData *resultData6 = [[NSData alloc] initWithContentsOfURL:[NSURL fileURLWithPath:testFile]];
    NSData *resultData7 = [[NSData alloc] initWithContentsOfFile:testFile
                                                 options:NSDataReadingMapped
                                                   error:nil];
    NSData *resultData8 = [[NSData alloc] initWithContentsOfURL:[NSURL fileURLWithPath:testFile]
                                                options:NSDataReadingUncached
                                                  error:nil];
    
    // Plain data
    NSData *plainData = [NSData plainDataWithContentsOfFile:testFile];
    
    XCTAssertEqualObjects(correctData, resultData1);
    XCTAssertEqualObjects(correctData, resultData2);
    XCTAssertEqualObjects(correctData, resultData3);
    XCTAssertEqualObjects(correctData, resultData4);
    XCTAssertEqualObjects(correctData, resultData5);
    XCTAssertEqualObjects(correctData, resultData6);
    XCTAssertEqualObjects(correctData, resultData7);
    XCTAssertEqualObjects(correctData, resultData8);
    XCTAssertNotEqualObjects(correctData, plainData);
    
    BOOL removeResult = [[NSFileManager defaultManager] removeItemAtPath:testFile error:nil];
    XCTAssertTrue(removeResult);
}

@end
