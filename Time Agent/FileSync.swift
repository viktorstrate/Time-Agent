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
        
        print("Saving to sync file...")
        
        var projectsJson: [Any] = []
        
        for p in Project.fetchRoots() {
            projectsJson.append(p.export())
        }
        
        let data = try! JSONSerialization.data(withJSONObject: projectsJson, options: .prettyPrinted)
        try! data.write(to: self.path)
        
        self.syncFinished()
    }
    
    func load() {
        
        print("Loading from sync file...")
        
        guard let data = try? Data(contentsOf: self.path) else {
            return
        }
        
        let json = try! JSONSerialization.jsonObject(with: data, options: [])
        
        // If not first sync
        if self.lastSync != nil {
            
            Model.context.sync(json as! [[String : Any]], inEntityNamed: "Project", predicate: nil, parent: nil) { (error) in
                if let error = error {
                    print("First sync error: \(error)")
                    return
                }
                
                print("Successfully synced new items")

                self.syncFinished()
            }
        } else {
            print("Syncing for the first time")
            
            var syncOptions = Sync.OperationOptions.all
            syncOptions.remove(Sync.OperationOptions.delete)
            syncOptions.remove(Sync.OperationOptions.deleteRelationships)
            
            Model.context.changes(json as! [[String: Any]], inEntityNamed: "Project", predicate: nil, parent: nil, parentRelationship: nil, operations: syncOptions) { (error) in
                if let error = error {
                    print("Initial sync error: \(error)")
                    return
                }
                
                self.syncFinished()
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
