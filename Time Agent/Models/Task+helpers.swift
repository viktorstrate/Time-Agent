//
//  Task+helpers.swift
//  Time Agent
//
//  Created by Viktor Hundahl Strate on 12/01/2019.
//  Copyright © 2019 Viktor Hundahl Strate. All rights reserved.
//

import Cocoa

extension Task {
    convenience init(name: String, duration: TimeInterval, start: Date) {
        self.init()
        self.name = name
        self.duration = duration
        self.start = start
    }
    
    static func fetch(between start: Date, and end: Date) -> [Task] {
        
        let request = Task.fetchRequest() as NSFetchRequest<Task>
        request.returnsObjectsAsFaults = false
        request.sortDescriptors = [NSSortDescriptor.init(key: "start", ascending: true)]
        
        request.predicate = NSPredicate(format: "start >= %@ && start <= %@", start as NSDate, end as NSDate)
        
        do {
            return try Model.context.fetch(request)
        } catch {
            print("Task.fetchInRange(): Error fetching \(request.entityName ?? "Undefined")")
            return []
        }
    }
    
    static func fetchAll() -> [Task] {
        let request = Task.fetchRequest() as NSFetchRequest<Task>
        request.returnsObjectsAsFaults = false
        
        do {
            return try Model.context.fetch(request)
        } catch {
            print("Task.fetchAll(): Error fetching \(request.entityName ?? "Undefined")")
            return []
        }
    }
}
