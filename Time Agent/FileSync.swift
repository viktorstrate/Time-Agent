//
//  FileSync.swift
//  Time Agent
//
//  Created by Viktor Hundahl Strate on 12/01/2019.
//  Copyright © 2019 Viktor Hundahl Strate. All rights reserved.
//

import Foundation
import Sync

class FileSync {
    let path: URL
    var lastSync: Date? {
        get {
            let time = UserDefaults.standard.double(forKey: "file-sync.lastSync")
            
            if time == 0 {
                return nil
            }
            
            return Date(timeIntervalSince1970: TimeInterval(exactly: time)!)
        }
        
        set {
            if let newDate = newValue {
                let time: Double = newDate.timeIntervalSince1970
                UserDefaults.standard.set(time, forKey: "file-sync.lastSync")
            } else {
                UserDefaults.standard.set(nil, forKey: "file-sync.lastSync")
            }
        }
    }
    
    init(path: URL) {
        self.path = path
//        self.dataStack = DataStack(modelName: "Time_Agent", storeType: .sqLite)
    }
    
    func sync() {
        // Load changes since last sync
        load()
        
        // Save local changes made since last sync
        save()
    }
    
    private func save() {
        var projectsJson: [Any] = []
        
        for p in Project.fetchRoots() {
            projectsJson.append(p.export())
        }
        
        let data = try! JSONSerialization.data(withJSONObject: projectsJson, options: .prettyPrinted)
        try! data.write(to: self.path)
        
        self.lastSync = Date()
    }
    
    private func load() {
        
        guard let data = try? Data(contentsOf: self.path) else {
            return
        }
        
        let json = try! JSONSerialization.jsonObject(with: data, options: [])
        
        print("Loading changes since \(String(describing: self.lastSync))")
        
        // First sync
        if let lastSync = self.lastSync {
            // Use predicate to only update elements changed since last sync
//            let filter = NSPredicate(format: "updatedAt > %@", argumentArray: [lastSync])
            
            // If created after last sync, ignore so it doesn't get deleted
            let filter = NSPredicate(format: "updatedAt < %@", argumentArray: [lastSync])
            
            Model.context.sync(json as! [[String : Any]], inEntityNamed: "Project", predicate: filter, parent: nil) { (error) in
                if let error = error {
                    print("First sync error: \(error)")
                    return
                }
                
                print("Successfully synced new items")

                let projects = Project.fetchRoots()
                
                for i in 0..<projects.count {
                    for j in i..<projects.count {
                        
                        let p1 = projects[i]
                        let p2 = projects[j]
                        
                        if p1 != p2 && p1.id == p2.id {
                            print("Found duplicate \(p1.name!) and \(p2.name!)")
                            let newest = p1.updatedAt! > p2.updatedAt! ? p1 : p2
                            let oldest = p1.updatedAt! > p2.updatedAt! ? p2 : p1
                            
                            if oldest.tasks!.count > 0 {
                                newest.tasks! = oldest.tasks!
                            }
                            
                            oldest.tasks! = []
                            Model.delete(managedObject: oldest)
                        }
                    }
                }
                
                Model.save()
                
            }
        } else {
            print("Syncing for the first time")
            
            //            Sync.changes(changes, inEntityNamed: entityName, predicate: nil, parent: nil, parentRelationship: nil, inContext: self, operations: .all, completion: completion)
            
            var syncOptions = Sync.OperationOptions.all
            syncOptions.remove(Sync.OperationOptions.delete)
            syncOptions.remove(Sync.OperationOptions.deleteRelationships)
            
            Model.context.changes(json as! [[String: Any]], inEntityNamed: "Project", predicate: nil, parent: nil, parentRelationship: nil, operations: syncOptions) { (error) in
                if let error = error {
                    print("Initial sync error: \(error)")
                    return
                }
            }
        }
    }
}