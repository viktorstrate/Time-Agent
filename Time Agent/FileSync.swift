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
    
    var onSyncComplete: [(() -> Void)]
    
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
        self.onSyncComplete = []
    }
    
    func save() {
        NSLog("Saving to sync file...")
        
        var projectsJson: [Any] = []
        var groupsJson: [Any] = []
        
        for p in Project.fetchRoots() {
            projectsJson.append(p.export())
        }
        
        for g in ProjectGroup.fetchRoots() {
            groupsJson.append(g.export())
        }
        
        var jsonObj: [String: Any] = [:]
        jsonObj["projects"] = projectsJson
        jsonObj["groups"] = groupsJson
        
        do {
            let data = try JSONSerialization.data(withJSONObject: jsonObj, options: .prettyPrinted)
            try data.write(to: self.path)
            
            self.syncFinished()
        } catch {
            NSLog("ERROR: Could not sync to file")
        }
    }
    
    func load() {
        NSLog("Loading from sync file...")
        
        guard let data = try? Data(contentsOf: self.path) else {
            NSLog("Warn: Sync file does not exist, nothing to load, saving instead...")
            self.save()
            return
        }
        
        guard let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String : Any] else {
            NSLog("ERROR: Could not parse content of sync file")
            return
        }
        
        guard let projects = json["projects"] as? [[String: Any]] else {
            NSLog("ERROR: Could not get projects from synced file")
            return
        }
        
        guard let groups = json["groups"] as? [[String: Any]] else {
            NSLog("ERROR: Could not get groups from synced file")
            return
        }
        
        NSLog("Projects to sync: \(projects)")
        
        let rootProjectsPredicate = NSPredicate(format: "group == nil", argumentArray: [])
        let rootGroupsPredicate = NSPredicate(format: "parent == nil", argumentArray: [])
        
        // If not first sync
        if self.lastSync != nil {
            
            Model.context.sync(projects, inEntityNamed: "Project", predicate: rootProjectsPredicate, parent: nil) { (error) in
                if let error = error {
                    print("Root projects sync error: \(error)")
                    return
                }
                
                print("Successfully synced new root projects")
                
                Model.context.sync(groups, inEntityNamed: "ProjectGroup", predicate: rootGroupsPredicate, parent: nil) { (error) in
                    if let error = error {
                        print("Root groups sync error: \(error)")
                        return
                    }
                    
                    print("Successfully synced new groups")
                    
                    self.syncFinished()
                }
            }
        } else {
            NSLog("Syncing for the first time")
            
            var syncOptions = Sync.OperationOptions.all
            syncOptions.remove(Sync.OperationOptions.delete)
            syncOptions.remove(Sync.OperationOptions.deleteRelationships)
            
            Model.context.changes(projects, inEntityNamed: "Project", predicate: rootProjectsPredicate, parent: nil, parentRelationship: nil, operations: syncOptions) { (error) in
                if let error = error {
                    NSLog("Initial sync root projects error: \(error)")
                    return
                }
                
                print("Successfully synced initial new root projects")
                
                Model.context.changes(groups, inEntityNamed: "GroupProject", predicate: rootGroupsPredicate, parent: nil, parentRelationship: nil, operations: syncOptions) { (error) in
                    if let error = error {
                        NSLog("Initial sync root groups error: \(error)")
                        return
                    }
                    
                    NSLog("Successfully synced initial new groups")
                    self.syncFinished()
                    
                }
            }
        }
    }
    
    private func syncFinished() {
        self.lastSync = Date()
        
        for syncListener in self.onSyncComplete {
            syncListener()
        }
    }
}
