//
//  BaseManagedObject.m
//
//  Created by Olga Dalton on 22/01/14.
//  Copyright (c) 2014 Olga Dalton. All rights reserved.
//

#import "BaseManagedObject.h"
#import "NSManagedObjectContext+Request.h"
#import "AppDelegate.h"

@implementation BaseManagedObject

/**************************
 Basic init methods
 **************************/

+ (NSManagedObject *)insertNewObject
{
    NSManagedObject *obj = [NSEntityDescription insertNewObjectForEntityForName:[self entityName]
                                                   inManagedObjectContext:[DELEGATE managedObjectContext]];
    
    [DELEGATE saveContext];
    
    return obj;
}

+ (NSManagedObject *)insertNewObjectIfNeeded:(NSString *)objId
{
    NSManagedObject *obj = nil;
    
    NSArray *results = [[DELEGATE managedObjectContext] fetchObjectsForEntityName:[self entityName]
                                                               andsortDescriptors:nil
                                                                    andFetchLimit:-1
                                                                    withPredicate:[self entityPredicate], objId];
    
    if ([results count])
    {
        obj = results[0];
    }
    else
    {
        obj = [[self class] insertNewObject];
        [DELEGATE saveContext];
    }
    
    return obj;
}

+ (NSManagedObject *)itemWithID:(NSNumber *)itemID
{
    NSManagedObject *obj = nil;
    
    NSArray *results = [[DELEGATE managedObjectContext] fetchObjectsForEntityName:[self entityName]
                                                               andsortDescriptors:nil
                                                                    andFetchLimit:-1
                                                                    withPredicate:[self entityPredicate], itemID];
    
    if ([results count])
    {
        obj = results[0];
        return obj;
    }
    
    return nil;
}

/**************************
 Removal methods
 **************************/

+ (void)removeAll
{
    [[DELEGATE managedObjectContext] deleteEntityInstances:[self entityName]];
}

+ (void)removeAllWithPredicateString:(NSString *)predicate
{
    NSArray *results = [[DELEGATE managedObjectContext] fetchObjectsForEntityName:[self entityName]
                                                               andsortDescriptors:nil
                                                                    andFetchLimit:-1
                                                                    withPredicate:predicate];
    
    for (id obj in results)
    {
        [[DELEGATE managedObjectContext] deleteObject:obj];
    }
    
    [DELEGATE saveContext];
}

+ (void)removeAllExcept:(id)item
{
    NSArray *all = [self getAll];
    
    for (id obj in all)
    {
        if (![obj isEqual:item])
        {
            [[DELEGATE managedObjectContext] deleteObject:obj];
        }
    }
    
    [DELEGATE saveContext];
}

/**************************
 Get all entities
 **************************/

+ (NSArray *)getAll
{
    NSArray *results = [[DELEGATE managedObjectContext] fetchObjectsForEntityName:[self entityName]
                                                               andsortDescriptors:nil
                                                                    andFetchLimit:-1
                                                                    withPredicate:nil];
    
    return results;
}

/**************************
 Customize it in a subclass!
 **************************/

+ (NSString *)entityName
{
    return [[self class] description];
}

+ (NSString *)entityPredicate
{
    return @"itemID LIKE[c] %@";
}

+ (NSString *)entityIdentifier
{
    return @"itemID";
}

/**************************
 Custom queries
 **************************/

+ (NSArray *)queryEntityWithIDSort
{
    return [[self class] queryEntityWithIDSortAndPredicate:nil andValue: nil];
}

+ (NSArray *)queryEntityWithIDSortAndPredicate:(id)predicateString andValue:(id)predicateValue
{
    NSArray *sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:[self entityIdentifier]
                                                               ascending:YES
                                                                selector:@selector(compare:)]];
    
    NSArray *results = [[DELEGATE managedObjectContext] fetchObjectsForEntityName:[[self class] entityName]
                                                               andsortDescriptors:sortDescriptors
                                                                    andFetchLimit:-1
                                                                    withPredicate:predicateString, predicateValue];
    
    return results;
}

/**************************
 Total entities count
 **************************/

+ (long)allCount
{
    NSFetchRequest *request = [DELEGATE.managedObjectContext fetchRequestForEntityName:[self entityName]
                                                                    andsortDescriptors:nil
                                                                         andFetchLimit:-1
                                                                         withPredicate:nil];
    
    return [DELEGATE.managedObjectContext countForFetchRequest:request error:nil];
}

@end
