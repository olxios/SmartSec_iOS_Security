//
//  NSDictionaryTest.m
//  SmartSec
//
//  Created by Olga Dalton on 25/03/15.
//  Copyright (c) 2015 Olga Dalton. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import <SmartSec/SmartSec.h>

@interface NSDictionaryTest : XCTestCase

@end

@implementation NSDictionaryTest

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

- (NSDictionary *)testDictionary
{
    NSArray *testDictionaries = @[@{@"1" : @"2", @"2" : @"3"},
                                  @{@"dncd" : @"1", @"ncnnc" : @"2", @"nnnvn" : @"3"},
                                  @{@"8uhcc8d8d8" : @"x", @"ndjndi99" : @"y", @"jdjjd899" : @"z"},
                                  @{@"0" : @"0", @"0" : @"0", @"0" : @"0"}];
    
    return testDictionaries[arc4random()%[testDictionaries count]];
}

- (void)testWriteToFile
{
    NSDictionary *testDict = [self testDictionary];
    NSString *path = [self testDataPath:1];
    
    [testDict writeToFile:path atomically:YES];
    [self runStandardReadingTests:testDict onFile:path];
}

- (void)testWriteToURL
{
    NSDictionary *testDict = [self testDictionary];
    NSString *path = [self testDataPath:2];
    
    [testDict writeToURL:[NSURL fileURLWithPath:path] atomically:YES];
    [self runStandardReadingTests:testDict onFile:path];
}

- (void)testWritePlaintextToFile
{
    NSDictionary *testDict = [self testDictionary];
    NSString *path = [self testDataPath:3];
    
    [testDict writePlaintextToFile:path atomically:YES];
    
    [self runStandardReadingTests:testDict onFile:path];
}

- (void)testWritePlaintextToURL
{
    NSDictionary *testDict = [self testDictionary];
    NSString *path = [self testDataPath:3];
    
    [testDict writePlaintextToURL:[NSURL fileURLWithPath:path] atomically:YES];
    [self runStandardReadingTests:testDict onFile:path];
}

- (void)runStandardReadingTests:(NSDictionary *)correctData onFile:(NSString *)testFile
{
    NSDictionary *resultArray1 = [NSDictionary dictionaryWithContentsOfFile:testFile];
    NSDictionary *resultArray2 = [NSDictionary dictionaryWithContentsOfURL:[NSURL fileURLWithPath:testFile]];
    
    NSDictionary *resultArray3 = [[NSDictionary alloc] initWithContentsOfFile:testFile];
    NSDictionary *resultArray4 = [[NSDictionary alloc] initWithContentsOfURL:[NSURL fileURLWithPath:testFile]];
    
    XCTAssertEqualObjects(correctData, resultArray1);
    XCTAssertEqualObjects(correctData, resultArray2);
    XCTAssertEqualObjects(correctData, resultArray3);
    XCTAssertEqualObjects(correctData, resultArray4);
    
    BOOL removeResult = [[NSFileManager defaultManager] removeItemAtPath:testFile error:nil];
    XCTAssertTrue(removeResult);
}

@end
