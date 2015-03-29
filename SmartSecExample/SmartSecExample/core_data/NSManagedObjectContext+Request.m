//
//  NSManagedObjectContext+Request.m
//
//  Created by Olga Dalton on 1/22/13.
//  Copyright (c) 2013 Olga Dalton. All rights reserved.
//

#import "NSManagedObjectContext+Request.h"
#import <CoreData/CoreData.h>
#import "AppDelegate.h"

@implementation NSManagedObjectContext (Request)

// Convenience method to fetch the array of objects for a given Entity
// name in the context, optionally limiting by a predicate or by a predicate
// made from a format NSString and variable arguments.
//

- (NSFetchRequest *)fetchRequestForEntityName:(NSString *)newEntityName
                            andsortDescriptors:(NSArray *)sortDescriptors
                                 andFetchLimit:(NSInteger)fetchLimit
                                 withPredicate:(id)stringOrPredicate, ...
{
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:newEntityName inManagedObjectContext:self];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    if (sortDescriptors && [sortDescriptors count])
    {
        request.sortDescriptors = sortDescriptors;
    }
    
    [request setEntity:entity];
    
    if (fetchLimit > 0)
    {
        [request setFetchLimit:fetchLimit];
    }
    
    if (stringOrPredicate)
    {
        NSPredicate *predicate;
        if ([stringOrPredicate isKindOfClass:[NSString class]])
        {
            va_list variadicArguments;
            va_start(variadicArguments, stringOrPredicate);
            
            predicate = [NSPredicate predicateWithFormat:stringOrPredicate
                                               arguments:variadicArguments];
            va_end(variadicArguments);
        }
        else
        {
            predicate = (NSPredicate *)stringOrPredicate;
        }
        
        [request setPredicate:predicate];
    }
    
    return request;
}

- (NSArray *)fetchObjectsForEntityName:(NSString *)newEntityName
                    andsortDescriptors:(NSArray *)sortDescriptors
                         andFetchLimit:(NSInteger)fetchLimit
                         withPredicate:(id)stringOrPredicate, ...
{
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:newEntityName inManagedObjectContext:self];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    if (sortDescriptors && [sortDescriptors count])
    {
        request.sortDescriptors = sortDescriptors;
    }
    
    [request setEntity:entity];
    
    if (fetchLimit > 0)
    {
        [request setFetchLimit:fetchLimit];
    }
    
    if (stringOrPredicate)
    {
        NSPredicate *predicate;
        if ([stringOrPredicate isKindOfClass:[NSString class]])
        {
            va_list variadicArguments;
            va_start(variadicArguments, stringOrPredicate);
            
            predicate = [NSPredicate predicateWithFormat:stringOrPredicate
                                               arguments:variadicArguments];
            va_end(variadicArguments);
        }
        else
        {
            predicate = (NSPredicate *)stringOrPredicate;
        }
                
        [request setPredicate:predicate];
                
    }
    
    NSError *error = nil;
    NSArray *results = [self executeFetchRequest:request error:&error];
        
    if (error != nil)
    {
        return nil;
    }
    
    return results;
}

- (void)deleteEntityInstances:(NSString *)entityName
{
    NSFetchRequest *all = [[NSFetchRequest alloc] init];
    [all setEntity:[NSEntityDescription entityForName:entityName inManagedObjectContext:self]];
    [all setIncludesPropertyValues:NO]; //only fetch the managedObjectID
    
    NSError *error = nil;
    NSArray *items = [self executeFetchRequest:all error:&error];

    for (NSManagedObject *itm in items) {
        [self deleteObject:itm];
    }
    
    [DELEGATE saveContext];
}

@end
