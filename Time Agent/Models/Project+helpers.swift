//
//  Project-extensions.swift
//  Time Agent
//
//  Created by Viktor Hundahl Strate on 06/01/2019.
//  Copyright © 2019 Viktor Hundahl Strate. All rights reserved.
//

import Cocoa

extension Project {
    
    convenience init(name: String) {
        self.init()
        self.name = name
    }
    
    func calculateTotalTime() -> TimeInterval {
        var tasks = self.tasks!.sortedArray(using: []) as! [Task]
        tasks = tasks.filter({ !$0.archived })
        
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
            return compareDates((a as! Task).start!, (b as! Task).start!)
        }
        
        let sortedProjects = projects.sorted(by: { (a, b) -> Bool in
            let sortedA = a.tasks?.allObjects.sorted(by: taskSorter) as! [Task]
            let sortedB = b.tasks?.allObjects.sorted(by: taskSorter) as! [Task]
            
            var newestA: Date, newestB: Date
            
            if sortedA.isEmpty {
                newestA = a.updatedAt!
            } else {
                newestA = sortedA[0].start!
            }
            
            if sortedB.isEmpty {
                newestB = b.updatedAt!
            } else {
                newestB = sortedB[0].start!
            }
            
            return compareDates(newestA, newestB)
        })
        
        return sortedProjects
    }
    
    static func fetchRoots() -> [Project] {
        let request = Project.fetchRequest() as NSFetchRequest<Project>
        request.returnsObjectsAsFaults = false
        request.sortDescriptors = [NSSortDescriptor.init(key: "updatedAt", ascending: false)]
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
