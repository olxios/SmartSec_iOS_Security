//
//  BaseManagedObject.h
//
//  Created by Olga Dalton on 22/01/14.
//  Copyright (c) 2014 Olga Dalton. All rights reserved.
//

#import <CoreData/CoreData.h>

/**
 Base model object
 */
@interface BaseManagedObject : NSManagedObject

/**************************
 Basic init methods
 **************************/

/**
 Insert new object
 @return New object
 */
+ (NSManagedObject *)insertNewObject;

/**
 If object not found, insert new object
 @param objId Object ID to search for
 @return New object
 */
+ (NSManagedObject *)insertNewObjectIfNeeded:(NSString *)objId;

/**
 Find item
 @param itemID Item ID
 @return Object or nil
 */
+ (NSManagedObject *)itemWithID:(NSString *)itemID;

/**************************
 Removal methods
 **************************/

+ (void)removeAll;
+ (void)removeAllWithPredicateString:(NSString *)predicate;
+ (void)removeAllExcept:(id)item;

/**************************
 Get all entities
 **************************/

+ (NSArray *)getAll;

/**************************
 Customize it in a subclass!
 **************************/

+ (NSString *)entityName;
+ (NSString *)entityPredicate;
+ (NSString *)entityIdentifier;

/**************************
 Custom queries
**************************/

+ (NSArray *)queryEntityWithIDSort;
+ (NSArray *)queryEntityWithIDSortAndPredicate:(id)predicateString andValue:(id)predicateValue;

/**************************
 Total entities count
 **************************/

+ (long)allCount;

@end
