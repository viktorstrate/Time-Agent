//
//  Model.swift
//  Time Agent
//
//  Created by Viktor Hundahl Strate on 26/11/2018.
//  Copyright © 2018 Viktor Hundahl Strate. All rights reserved.
//

import Cocoa

class Model {
    
    static var context: NSManagedObjectContext = {
        return AppDelegate.main!.persistentContainer.viewContext
//        if let context = AppDelegate.main?.persistentContainer.viewContext {
//            return context
//        }
        
        // Setup mockup context
//        print("Making a mockup object context")
//        let managedObjectModel = NSManagedObjectModel.mergedModel(from: nil)!
//        let storeCoordinator = NSPersistentStoreCoordinator(managedObjectModel: managedObjectModel)
//        let store = try! storeCoordinator.addPersistentStore(ofType: NSInMemoryStoreType,
//                                                        configurationName: nil, at: nil, options: nil)
//
//        let managedObjectContext = NSManagedObjectContext(concurrencyType: NSManagedObjectContextConcurrencyType.privateQueueConcurrencyType)
//        managedObjectContext.persistentStoreCoordinator = storeCoordinator
//
//        return managedObjectContext
    }()
    
    static func delete(managedObject: NSManagedObject) {
        Model.context.delete(managedObject)
    }
    
    static func save() {
        do {
            try Model.context.save()
        } catch {
            print("Error could not save project")
        }
    }
    
    static func fetchAll<T>(request: NSFetchRequest<T>) -> [T] {
        
        request.returnsObjectsAsFaults = false
        
        do {
            let result = try Model.context.fetch(request)
            
            return result
        } catch {
            print("Model.fetchAll: Error fetching \(request.entityName ?? "Undefined")")
            return []
        }
    }
}
