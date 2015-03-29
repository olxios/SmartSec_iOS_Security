//
//  NSArrayTest.m
//  SmartSec
//
//  Created by Olga Dalton on 25/03/15.
//  Copyright (c) 2015 Olga Dalton. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import <SmartSec/SmartSec.h>

@interface NSArrayTest : XCTestCase

@end

@implementation NSArrayTest

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

- (NSArray *)testArray
{
    NSArray *testArrays = @[@[@"1", @"2", @"3"],
                          @[@"dncd", @"ncnnc", @"nnnvn"],
                          @[@"8uhcc8d8d8", @"ndjndi99", @"jdjjd899"],
                          @[@"0", @"0", @"0"]];
    
    return testArrays[arc4random()%[testArrays count]];
}

- (void)testWriteToFile
{
    NSArray *testArray = [self testArray];
    NSString *path = [self testDataPath:1];
    
    [testArray writeToFile:path atomically:YES];
    [self runStandardReadingTests:testArray onFile:path];
}

- (void)testWriteToURL
{
    NSArray *testArray = [self testArray];
    NSString *path = [self testDataPath:2];
    
    [testArray writeToURL:[NSURL fileURLWithPath:path] atomically:YES];
    [self runStandardReadingTests:testArray onFile:path];
}

- (void)testWritePlaintextToFile
{
    NSArray *testArray = [self testArray];
    NSString *path = [self testDataPath:3];
    
    [testArray writePlaintextToFile:path atomically:YES];
    
    [self runStandardReadingTests:testArray onFile:path];
}

- (void)testWritePlaintextToURL
{
    NSArray *testArray = [self testArray];
    NSString *path = [self testDataPath:3];
    
    [testArray writePlaintextToURL:[NSURL fileURLWithPath:path] atomically:YES];
    [self runStandardReadingTests:testArray onFile:path];
}

- (void)runStandardReadingTests:(NSArray *)correctData onFile:(NSString *)testFile
{
    NSArray *resultArray1 = [NSArray arrayWithContentsOfFile:testFile];
    NSArray *resultArray2 = [NSArray arrayWithContentsOfURL:[NSURL fileURLWithPath:testFile]];
    
    NSArray *resultArray3 = [[NSArray alloc] initWithContentsOfFile:testFile];
    NSArray *resultArray4 = [[NSArray alloc] initWithContentsOfURL:[NSURL fileURLWithPath:testFile]];
    
    XCTAssertEqualObjects(correctData, resultArray1);
    XCTAssertEqualObjects(correctData, resultArray2);
    XCTAssertEqualObjects(correctData, resultArray3);
    XCTAssertEqualObjects(correctData, resultArray4);
    
    BOOL removeResult = [[NSFileManager defaultManager] removeItemAtPath:testFile error:nil];
    XCTAssertTrue(removeResult);
}

@end
