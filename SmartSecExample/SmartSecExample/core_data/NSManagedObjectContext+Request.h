//
//  NSManagedObjectContext+Request.h
//
//  Created by Olga Dalton on 1/22/13.
//  Copyright (c) 2013 Olga Dalton. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface NSManagedObjectContext (Request)

- (NSArray *)fetchObjectsForEntityName:(NSString *)newEntityName
                  andsortDescriptors:(NSArray *)sortDescriptors
                         andFetchLimit:(NSInteger)fetchLimit
                       withPredicate:(id)stringOrPredicate, ...;

- (void)deleteEntityInstances:(NSString *)entityName;

- (NSFetchRequest *)fetchRequestForEntityName:(NSString *)newEntityName
                            andsortDescriptors:(NSArray *)sortDescriptors
                                 andFetchLimit:(NSInteger)fetchLimit
                                 withPredicate:(id)stringOrPredicate, ...;

@end
