//
//  NSMutableArrayTest.m
//  SmartSec
//
//  Created by Olga Dalton on 25/03/15.
//  Copyright (c) 2015 Olga Dalton. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import <SmartSec/SmartSec.h>
#import "CryptoManager.h"
#import "RNCryptor.h"

@interface NSMutableArrayTest : XCTestCase

@end

@implementation NSMutableArrayTest

- (void)setUp
{
    [super setUp];
    
    setSessionPasswordCallback(^NSData *{
        return [@"NSMutableArrayTest" dataUsingEncoding:NSUTF8StringEncoding];
    });
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

- (NSMutableArray *)testArray
{
    NSArray *testArrays = @[[@[@"1", @"2", @"3"] mutableCopy],
                            [@[@"dncd", @"ncnnc", @"nnnvn"] mutableCopy],
                            [@[@"8uhcc8d8d8", @"ndjndi99", @"jdjjd899"] mutableCopy],
                            [@[@"0", @"0", @"0"] mutableCopy]];
    
    return testArrays[arc4random()%[testArrays count]];
}

- (void)testWriteToFile
{
    NSMutableArray *testArray = [self testArray];
    NSString *path = [self testDataPath:1];
    
    [testArray writeToFile:path atomically:YES];
    [self runStandardReadingTests:testArray onFile:path];
}

- (void)testWriteToURL
{
    NSMutableArray *testArray = [self testArray];
    NSString *path = [self testDataPath:2];
    
    [testArray writeToURL:[NSURL fileURLWithPath:path] atomically:YES];
    [self runStandardReadingTests:testArray onFile:path];
}

- (void)testWritePlaintextToFile
{
    NSMutableArray *testArray = [self testArray];
    NSString *path = [self testDataPath:3];
    
    [testArray writePlaintextToFile:path atomically:YES];
    
    [self runStandardReadingTests:testArray onFile:path];
}

- (void)testWritePlaintextToURL
{
    NSMutableArray *testArray = [self testArray];
    NSString *path = [self testDataPath:3];
    
    [testArray writePlaintextToURL:[NSURL fileURLWithPath:path] atomically:YES];
    [self runStandardReadingTests:testArray onFile:path];
}

- (void)runStandardReadingTests:(NSArray *)correctData onFile:(NSString *)testFile
{
    NSMutableArray *resultArray1 = [NSMutableArray arrayWithContentsOfFile:testFile];
    NSMutableArray *resultArray2 = [NSMutableArray arrayWithContentsOfURL:[NSURL fileURLWithPath:testFile]];
    
    NSMutableArray *resultArray3 = [[NSMutableArray alloc] initWithContentsOfFile:testFile];
    NSMutableArray *resultArray4 = [[NSMutableArray alloc] initWithContentsOfURL:[NSURL fileURLWithPath:testFile]];
    
    XCTAssertEqualObjects(correctData, resultArray1);
    XCTAssertEqualObjects(correctData, resultArray2);
    XCTAssertEqualObjects(correctData, resultArray3);
    XCTAssertEqualObjects(correctData, resultArray4);
    
    BOOL removeResult = [[NSFileManager defaultManager] removeItemAtPath:testFile error:nil];
    XCTAssertTrue(removeResult);
}

@end
