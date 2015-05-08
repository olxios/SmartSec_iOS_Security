//
//  TestEntity1.swift
//  SmartSecExample_Swift
//
//  Created by Olga Dalton on 08/05/15.
//  Copyright (c) 2015 Olga Dalton. All rights reserved.
//

import Foundation
import CoreData

//@objc(TestEntity1)

class TestEntity1: NSManagedObject {

    @NSManaged var attribute1: AnyObject
    @NSManaged var attribute2: AnyObject
    @NSManaged var attribute3: AnyObject
    @NSManaged var attribute4: AnyObject
    @NSManaged var attribute5: AnyObject
    @NSManaged var attribute6: AnyObject
    @NSManaged var attribute7: AnyObject
    @NSManaged var attribute8: AnyObject
    @NSManaged var attribute9: AnyObject
    @NSManaged var attribute10: AnyObject
    @NSManaged var itemID: String
    
    class func appDelegate() -> AppDelegate {
        return UIApplication.sharedApplication().delegate as! AppDelegate
    }
    
    class func insertNewObject() -> TestEntity1 {
        
        let obj: AnyObject = NSEntityDescription.insertNewObjectForEntityForName("TestEntity1", inManagedObjectContext: self.appDelegate().managedObjectContext!)
        self.appDelegate().saveContext()
        return obj as! TestEntity1
    }
    
    class func insertNewObjectIfNeeded(objId : String) -> TestEntity1 {
        
        var obj : TestEntity1;
        
        let context = self.appDelegate().managedObjectContext
        
        let entity = NSEntityDescription.entityForName("TestEntity1", inManagedObjectContext: context!)
        let request = NSFetchRequest()
        request.entity = entity
        
        let predicate = NSPredicate(format: "itemID LIKE %@", objId)
        request.predicate = predicate
        
        let results = context?.executeFetchRequest(request, error: nil)
        
        if results == nil || results?.count == 0 {
            obj = insertNewObject()
            self.appDelegate().saveContext()
        }
        else {
            obj = results![0] as! TestEntity1
        }
        
        return obj
    }
    
    class func itemWithID(objId : String) -> TestEntity1? {
        
        var obj : NSManagedObject;
        
        let context = self.appDelegate().managedObjectContext
        
        let entity = NSEntityDescription.entityForName("TestEntity1", inManagedObjectContext: context!)
        let request = NSFetchRequest()
        request.entity = entity
        
        let predicate = NSPredicate(format: "itemID LIKE %@", objId)
        request.predicate = predicate
        
        let results = context?.executeFetchRequest(request, error: nil)
        
        if results != nil && results?.count > 0 {
            return results![0] as? TestEntity1
        }

        return nil
    }
}
