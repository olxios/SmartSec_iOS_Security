//
//  TestEntity1.h
//  SmartSecExample
//
//  Created by Olga Dalton on 29/03/15.
//  Copyright (c) 2015 Olga Dalton. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "BaseManagedObject.h"

@interface TestEntity1 : BaseManagedObject

@property (nonatomic, retain) NSNumber * attribute1;
@property (nonatomic, retain) NSData * attribute10;
@property (nonatomic, retain) NSNumber * attribute2;
@property (nonatomic, retain) NSNumber * attribute3;
@property (nonatomic, retain) NSDecimalNumber * attribute4;
@property (nonatomic, retain) NSNumber * attribute5;
@property (nonatomic, retain) NSNumber * attribute6;
@property (nonatomic, retain) NSString * attribute7;
@property (nonatomic, retain) NSNumber * attribute8;
@property (nonatomic, retain) NSDate * attribute9;
@property (nonatomic, retain) NSString * itemID;

@end
