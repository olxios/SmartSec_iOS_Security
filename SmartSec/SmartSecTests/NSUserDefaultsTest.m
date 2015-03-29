//
//  NSUserDefaultsTest.m
//  SmartSec
//
//  Created by Olga Dalton on 22/03/15.
//  Copyright (c) 2015 Olga Dalton. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import <SmartSec/SmartSec.h>
#import "SmartSecConfig.h"

@interface NSUserDefaultsTest : XCTestCase

@end

@implementation NSUserDefaultsTest

// TODO: optimize tests

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testEncryptedObject
{
    // Encrypted object for key
    NSString *object = @"Test object";
    NSString *testKey = @"testKey1";
    
    [[NSUserDefaults standardUserDefaults] setObject:object forKey:testKey];
    
    NSString *resultObject = [[NSUserDefaults standardUserDefaults] objectForKey:testKey];
    
    XCTAssertEqualObjects(object, resultObject);
    
    id plainObject = [[NSUserDefaults standardUserDefaults] plainObjectForKey:testKey];
    
    XCTAssertNotNil(plainObject);
    XCTAssertTrue([plainObject isKindOfClass:[NSData class]]);
    XCTAssertNotEqualObjects(object, plainObject);
    
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:testKey];
}

- (void)testRemoveObject
{
    NSString *object = @"Test object";
    NSString *testKey = @"testKey2";
    
    [[NSUserDefaults standardUserDefaults] setObject:object forKey:testKey];
    
    NSString *resultObject = [[NSUserDefaults standardUserDefaults] objectForKey:testKey];
    XCTAssertNotNil(resultObject);
    
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:testKey];
    
    resultObject = [[NSUserDefaults standardUserDefaults] objectForKey:testKey];
    XCTAssertNil(resultObject);
}

- (void)testPlainObject
{
    NSString *object = @"Test object";
    NSString *testKey = @"testKey3";
    
    [[NSUserDefaults standardUserDefaults] setPlainObject:object forKey:testKey];
    
    NSString *resultObject = [[NSUserDefaults standardUserDefaults] objectForKey:testKey];
    XCTAssertNotNil(resultObject);
    XCTAssertEqualObjects(object, resultObject);
    
    id plainObject = [[NSUserDefaults standardUserDefaults] plainObjectForKey:testKey];
    XCTAssertEqualObjects(plainObject, resultObject);
    
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:testKey];
}

- (void)testPlainData
{
    NSString *object = @"Test object";
    NSString *testKey = @"testKey4";
    
    NSData *testData = [object dataUsingEncoding:NSUTF8StringEncoding];
    
    [[NSUserDefaults standardUserDefaults] setPlainObject:testData forKey:testKey];
    
    NSString *resultObject = [[NSUserDefaults standardUserDefaults] objectForKey:testKey];
    XCTAssertNotNil(resultObject);
    XCTAssertEqualObjects(testData, resultObject);
    
    id plainObject = [[NSUserDefaults standardUserDefaults] plainObjectForKey:testKey];
    XCTAssertEqualObjects(plainObject, resultObject);
    
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:testKey];
}

- (void)testStringForKey
{
    NSString *object = @"Test object";
    NSString *testKey = @"testKey5";
    
    [[NSUserDefaults standardUserDefaults] setObject:object forKey:testKey];
    
    NSString *resultObject = [[NSUserDefaults standardUserDefaults] stringForKey:testKey];
    
    XCTAssertNotNil(resultObject);
    XCTAssertEqualObjects(object, resultObject);
    
    id plainObject = [[NSUserDefaults standardUserDefaults] plainObjectForKey:testKey];
    
    XCTAssertNotNil(plainObject);
    XCTAssertTrue([plainObject isKindOfClass:[NSData class]]);
    XCTAssertNotEqualObjects(object, plainObject);
    
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:testKey];
}

- (void)testArrayForKey
{
    NSArray *testArray = @[@(1), @(2), @(3), @(4)];
    NSString *testKey = @"testKey6";
    
    [[NSUserDefaults standardUserDefaults] setObject:testArray forKey:testKey];
    
    NSArray *resultObject = [[NSUserDefaults standardUserDefaults] arrayForKey:testKey];
    
    XCTAssertNotNil(resultObject);
    XCTAssertEqualObjects(testArray, resultObject);
    
    id plainObject = [[NSUserDefaults standardUserDefaults] plainObjectForKey:testKey];
    
    XCTAssertNotNil(plainObject);
    XCTAssertTrue([plainObject isKindOfClass:[NSData class]]);
    XCTAssertNotEqualObjects(testArray, plainObject);
    
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:testKey];
}

- (void)testDictionaryForKey
{
    NSDictionary *testDictionary = @{@(1) : @"Test", @(2) : @"Test2"};
    NSString *testKey = @"testKey7";
    
    [[NSUserDefaults standardUserDefaults] setObject:testDictionary forKey:testKey];
    
    NSDictionary *resultObject = [[NSUserDefaults standardUserDefaults] dictionaryForKey:testKey];
    
    XCTAssertNotNil(resultObject);
    XCTAssertEqualObjects(testDictionary, resultObject);
    
    id plainObject = [[NSUserDefaults standardUserDefaults] plainObjectForKey:testKey];
    
    XCTAssertNotNil(plainObject);
    XCTAssertTrue([plainObject isKindOfClass:[NSData class]]);
    XCTAssertNotEqualObjects(testDictionary, plainObject);
    
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:testKey];
}

- (void)testDataForKey
{
    NSData *testData = [@"test data" dataUsingEncoding:NSUTF8StringEncoding];
    NSString *testKey = @"testKey8";
    
    [[NSUserDefaults standardUserDefaults] setObject:testData forKey:testKey];
    
    NSData *resultObject = [[NSUserDefaults standardUserDefaults] dataForKey:testKey];
    
    XCTAssertNotNil(resultObject);
    XCTAssertEqualObjects(testData, resultObject);
    
    id plainObject = [[NSUserDefaults standardUserDefaults] plainObjectForKey:testKey];
    
    XCTAssertNotNil(plainObject);
    XCTAssertTrue([plainObject isKindOfClass:[NSData class]]);
    XCTAssertNotEqualObjects(testData, plainObject);
    
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:testKey];
}

- (void)testStringArrayForKey
{
    NSArray *testArray = @[@"test1", @"test2", @"test3", @"test4"];
    NSString *testKey = @"testKey9";
    
    [[NSUserDefaults standardUserDefaults] setObject:testArray forKey:testKey];
    
    NSArray *resultObject = [[NSUserDefaults standardUserDefaults] stringArrayForKey:testKey];
    
    XCTAssertNotNil(resultObject);
    XCTAssertEqualObjects(testArray, resultObject);
    
    id plainObject = [[NSUserDefaults standardUserDefaults] plainObjectForKey:testKey];
    
    XCTAssertNotNil(plainObject);
    XCTAssertTrue([plainObject isKindOfClass:[NSData class]]);
    XCTAssertNotEqualObjects(testArray, plainObject);
    
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:testKey];
}

- (void)testSetIntegerForKey
{
    NSInteger testInt = 7747474;
    NSString *testKey = @"testKey10";
    
    [[NSUserDefaults standardUserDefaults] setInteger:testInt forKey:testKey];
    
    NSInteger resultObject = [[NSUserDefaults standardUserDefaults] integerForKey:testKey];
    
    XCTAssertEqual(resultObject, testInt);
    
    id plainObject = [[NSUserDefaults standardUserDefaults] plainObjectForKey:testKey];
    
    XCTAssertNotNil(plainObject);
    XCTAssertTrue([plainObject isKindOfClass:[NSData class]]);
    XCTAssertNotEqualObjects(@(testInt), plainObject);
    
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:testKey];
}

- (void)testSetPlainIntegerForKey
{
    NSInteger testInt = 93933838;
    NSString *testKey = @"testKey11";
    
    [[NSUserDefaults standardUserDefaults] setPlainInteger:testInt forKey:testKey];
    
    NSInteger resultObject = [[NSUserDefaults standardUserDefaults] integerForKey:testKey];
    
    XCTAssertEqual(resultObject, testInt);
    
    NSNumber *plainObject = [[NSUserDefaults standardUserDefaults] plainObjectForKey:testKey];
    XCTAssertNotNil(plainObject);
    XCTAssertTrue([plainObject isKindOfClass:[NSNumber class]]);
    XCTAssertEqualObjects(@(testInt), plainObject);
    
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:testKey];
}

- (void)testSetFloatForKey
{
    float testFloat = 6.45f;
    NSString *testKey = @"testKey12";
    
    [[NSUserDefaults standardUserDefaults] setFloat:testFloat forKey:testKey];
    
    float resultObject = [[NSUserDefaults standardUserDefaults] floatForKey:testKey];
    
    XCTAssertEqual(resultObject, testFloat);
    
    id plainObject = [[NSUserDefaults standardUserDefaults] plainObjectForKey:testKey];
    
    XCTAssertNotNil(plainObject);
    XCTAssertTrue([plainObject isKindOfClass:[NSData class]]);
    XCTAssertNotEqualObjects(@(testFloat), plainObject);
    
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:testKey];
}

- (void)testSetPlainFloatForKey
{
    float testFloat = 6.47f;
    NSString *testKey = @"testKey13";
    
    [[NSUserDefaults standardUserDefaults] setPlainFloat:testFloat forKey:testKey];
    
    float resultObject = [[NSUserDefaults standardUserDefaults] floatForKey:testKey];
    
    XCTAssertEqual(resultObject, testFloat);
    
    NSNumber *plainObject = [[NSUserDefaults standardUserDefaults] plainObjectForKey:testKey];
    XCTAssertNotNil(plainObject);
    XCTAssertTrue([plainObject isKindOfClass:[NSNumber class]]);
    XCTAssertEqualObjects(@(testFloat), plainObject);
    
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:testKey];
}

- (void)testSetDoubleForKey
{
    double testDouble = 1.999999998;
    NSString *testKey = @"testKey14";
    
    [[NSUserDefaults standardUserDefaults] setDouble:testDouble forKey:testKey];
    
    double resultObject = [[NSUserDefaults standardUserDefaults] doubleForKey:testKey];
    
    XCTAssertEqual(resultObject, testDouble);
    
    id plainObject = [[NSUserDefaults standardUserDefaults] plainObjectForKey:testKey];
    
    XCTAssertNotNil(plainObject);
    XCTAssertTrue([plainObject isKindOfClass:[NSData class]]);
    XCTAssertNotEqualObjects(@(testDouble), plainObject);
    
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:testKey];
}

- (void)testSetPlainDoubleForKey
{
    double testDouble = 1.997999998;
    NSString *testKey = @"testKey15";
    
    [[NSUserDefaults standardUserDefaults] setPlainDouble:testDouble forKey:testKey];
    
    double resultObject = [[NSUserDefaults standardUserDefaults] doubleForKey:testKey];
    
    XCTAssertEqual(resultObject, testDouble);
    
    NSNumber *plainObject = [[NSUserDefaults standardUserDefaults] plainObjectForKey:testKey];
    
    XCTAssertNotNil(plainObject);
    XCTAssertTrue([plainObject isKindOfClass:[NSNumber class]]);
    XCTAssertEqualObjects(@(testDouble), plainObject);
    
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:testKey];
}

- (void)testSetBoolForKey
{
    BOOL testBool = YES;
    NSString *testKey = @"testKey16";
    
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:testKey];
    
    BOOL resultObject = [[NSUserDefaults standardUserDefaults] boolForKey:testKey];
    
    XCTAssertEqual(resultObject, testBool);
    
    id plainObject = [[NSUserDefaults standardUserDefaults] plainObjectForKey:testKey];
    
    XCTAssertNotNil(plainObject);
    XCTAssertTrue([plainObject isKindOfClass:[NSData class]]);
    XCTAssertNotEqualObjects(@(testBool), plainObject);
}

- (void)testSetPlainBoolForKey
{
    BOOL testBool = YES;
    NSString *testKey = @"testKey17";
    
    [[NSUserDefaults standardUserDefaults] setPlainBool:testBool forKey:testKey];
    
    BOOL resultObject = [[NSUserDefaults standardUserDefaults] boolForKey:testKey];
    
    XCTAssertEqual(resultObject, testBool);
    
    NSNumber *plainObject = [[NSUserDefaults standardUserDefaults] plainObjectForKey:testKey];
    XCTAssertNotNil(plainObject);
    XCTAssertTrue([plainObject isKindOfClass:[NSNumber class]]);
    XCTAssertEqualObjects(@(testBool), plainObject);
    
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:testKey];
}

- (void)testSetURLForKey
{
    NSURL *testUrl = [NSURL URLWithString:@"www.google.ee"];
    NSString *testKey = @"testKey12";
    
    [[NSUserDefaults standardUserDefaults] setURL:testUrl forKey:testKey];
    
    NSURL *resultObject = [[NSUserDefaults standardUserDefaults] URLForKey:testKey];
    
    XCTAssertEqualObjects(resultObject, testUrl);
    
    id plainObject = [[NSUserDefaults standardUserDefaults] plainObjectForKey:testKey];
    
    XCTAssertNotNil(plainObject);
    XCTAssertTrue([plainObject isKindOfClass:[NSData class]]);
    XCTAssertNotEqualObjects(testUrl, plainObject);
    
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:testKey];
}

// NSURL is internally saved as an archieved object
// Retrieving saved NSURL using objectForKey:
// and not URLForKey: should return bunch of data,
// which represents archieved NSURL object
// It is default behaviour in Apple classes
// and SmartSec follows same approach

- (void)testSetPlainURLForKey
{
    NSURL *object = [NSURL URLWithString:@"www.google.ee"];
    NSString *testKey = @"testKey13";
    
    [[NSUserDefaults standardUserDefaults] setPlainURL:object forKey:testKey];
    
    NSURL *resultObject = [[NSUserDefaults standardUserDefaults] URLForKey:testKey];
    XCTAssertNotNil(resultObject);
    XCTAssertEqualObjects(object, resultObject);
    
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:testKey];
}

- (void)testEncryptionSettings
{
    enableNSUserDefaultsEncryption();
    [[NSUserDefaults standardUserDefaults] setObject:@"test" forKey:@"encrypted1"];
    
    XCTAssertEqualObjects([[NSUserDefaults standardUserDefaults] objectForKey:@"encrypted1"], @"test");
    XCTAssertTrue([[[NSUserDefaults standardUserDefaults] plainObjectForKey:@"encrypted1"] isKindOfClass:[NSData class]]);
    XCTAssertNotEqualObjects([[NSUserDefaults standardUserDefaults] plainObjectForKey:@"encrypted1"], @"test");
    
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"encrypted1"];
    
    disableNSUserDefaultsEncryption();
    
    [[NSUserDefaults standardUserDefaults] setObject:@"test2" forKey:@"plaintext1"];
    
    XCTAssertEqualObjects([[NSUserDefaults standardUserDefaults] objectForKey:@"plaintext1"], @"test2");
    XCTAssertEqualObjects([[NSUserDefaults standardUserDefaults] plainObjectForKey:@"plaintext1"], @"test2");
    
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"plaintext1"];
    
    enableNSUserDefaultsEncryption();
    
    [[NSUserDefaults standardUserDefaults] setObject:@"test3" forKey:@"encrypted2"];
    
    XCTAssertEqualObjects([[NSUserDefaults standardUserDefaults] objectForKey:@"encrypted2"], @"test3");
    XCTAssertTrue([[[NSUserDefaults standardUserDefaults] plainObjectForKey:@"encrypted2"] isKindOfClass:[NSData class]]);
    XCTAssertNotEqualObjects([[NSUserDefaults standardUserDefaults] plainObjectForKey:@"encrypted2"], @"test3");
    
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"encrypted2"];
}

/*
- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}*/

@end
