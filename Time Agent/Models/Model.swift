//
//  Model.swift
//  Time Agent
//
//  Created by Viktor Hundahl Strate on 26/11/2018.
//  Copyright © 2018 Viktor Hundahl Strate. All rights reserved.
//

import Cocoa

class Model: NSManagedObject {
    
    var test = 123
    
//    static var coreDataContext: NSManagedObjectContext = {
//        let appDelegate = NSApplication.shared.delegate as! AppDelegate
//        let context = appDelegate.persistentContainer.viewContext
//        return context
//    }()
    
    func delete() {
        let appDelegate = NSApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        context.delete(self)
    }
    
    func save() {
        let appDelegate = NSApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        do {
            try context.save()
        } catch {
            print("Error could not save project")
        }
    }
    
    static func fetchAllModels(name: String) -> [Model]? {
        let appDelegate = NSApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: name)
        request.returnsObjectsAsFaults = false
        
        do {
            let result = try context.fetch(request)
            return result as? [Model]
        } catch {
            print("Error fetching projects")
            return nil
        }
    }
}
