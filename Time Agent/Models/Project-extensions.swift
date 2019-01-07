//
//  Project-extensions.swift
//  Time Agent
//
//  Created by Viktor Hundahl Strate on 06/01/2019.
//  Copyright © 2019 Viktor Hundahl Strate. All rights reserved.
//

import Cocoa

extension Project {
    func calculateTotalTime() -> TimeInterval {
        let tasks = self.tasks!.sortedArray(using: []) as! [Task]
        let taskTime = tasks.reduce(0) { (prev, task) -> Double in
            return prev + task.duration
        }
        
        return taskTime
    }
    
    // Sort projects by newest tasks
    static func sort(_ projects: [Project]) -> [Project] {
        
        let compareDates: (Any, Any) -> Bool = { (a, b) -> Bool in
            return (a as! Date).compare(b as! Date) == .orderedDescending
        }
        
        let taskSorter: (Any, Any) -> Bool = { (a, b) -> Bool in
            // Rigtig
            return compareDates((a as! Task).start!, (b as! Task).start!)
        }
        
        var sortedProjects = projects.sorted(by: { (a, b) -> Bool in
            let sortedA = a.tasks?.allObjects.sorted(by: taskSorter) as! [Task]
            let sortedB = b.tasks?.allObjects.sorted(by: taskSorter) as! [Task]
            
            let newestA = sortedA[0]
            let newestB = sortedB[0]
            
            // Er rigtig nok
            return compareDates(newestB.start!, newestA.start!)
        })
        
        return sortedProjects
    }
    
    static func fetchRoots() -> [Project] {
        let request = Project.fetchRequest() as NSFetchRequest<Project>
        request.returnsObjectsAsFaults = false
        request.sortDescriptors = [NSSortDescriptor.init(key: "creationDate", ascending: false)]
        request.predicate = NSPredicate(format: "group == nil", [])
        
        do {
            var result = try Model.context.fetch(request)
            
            result = Project.sort(result)
            
            return result
        } catch {
            print("Project.fetchRoots(): Error fetching \(request.entityName ?? "Undefined")")
            return []
        }
    }
}
