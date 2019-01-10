//
//  ProjectGroup+helpers.swift
//  Time Agent
//
//  Created by Viktor Hundahl Strate on 10/01/2019.
//  Copyright © 2019 Viktor Hundahl Strate. All rights reserved.
//

import Cocoa

extension ProjectGroup {
    static func fetchRoots() -> [ProjectGroup] {
        let request = ProjectGroup.fetchRequest() as NSFetchRequest<ProjectGroup>
        request.returnsObjectsAsFaults = false
        request.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        request.predicate = NSPredicate(format: "parent == nil", [])
        
        do {
            let result = try Model.context.fetch(request)
            
            return result
        } catch {
            print("ProjectGroup.fetchRoots(): Error fetching \(request.entityName ?? "Undefined")")
            return []
        }
    }
}
