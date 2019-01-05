//
//  Model.swift
//  Time Agent
//
//  Created by Viktor Hundahl Strate on 26/11/2018.
//  Copyright © 2018 Viktor Hundahl Strate. All rights reserved.
//

import Cocoa

class Model {
    
    var managedObject: NSManagedObject
    
    init(_ managedObject: NSManagedObject) {
        self.managedObject = managedObject
    }
    
    static var coreDataContext: NSManagedObjectContext = {
        let appDelegate = NSApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        return context
    }()
    
    func delete() {
        Model.coreDataContext.delete(self.managedObject)
    }
    
    func save() {
        do {
            try Model.coreDataContext.save()
        } catch {
            print("Error could not save project")
        }
    }
    
    static func fetchAllModels(name: String) -> [Model]? {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: name)
        request.returnsObjectsAsFaults = false
        
        do {
            let result = try Model.coreDataContext.fetch(request)
            var models: [Model] = []
            
            for obj in result {
                let model = Model(obj as! NSManagedObject)
                models.append(model)
            }
            
            return models
        } catch {
            print("Error fetching projects")
            return nil
        }
    }
}
