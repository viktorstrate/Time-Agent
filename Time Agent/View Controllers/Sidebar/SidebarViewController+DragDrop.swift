//
//  SidebarViewController+DragDrop.swift
//  Time Agent
//
//  Created by Viktor Hundahl Strate on 10/01/2019.
//  Copyright © 2019 Viktor Hundahl Strate. All rights reserved.
//

import Cocoa

// Drag and drop outline view
// To rearrange projects and groups
extension SidebarViewController {
    
    func outlineView(_ outlineView: NSOutlineView, pasteboardWriterForItem item: Any) -> NSPasteboardWriting? {
        let pbItem = NSPasteboardItem()
        
        guard let managedObj = item as? NSManagedObject else {
            print("Drag drop: Item not a managed object")
            return nil
        }
        
        pbItem.setString(managedObj.objectID.uriRepresentation().absoluteString, forType: NSPasteboard.PasteboardType("time-agent.project"))
        
        print("Drag URL: \(managedObj.objectID.uriRepresentation().absoluteString)")
        
        return pbItem
    }
    
    func outlineView(_ outlineView: NSOutlineView, validateDrop info: NSDraggingInfo, proposedItem item: Any?, proposedChildIndex index: Int) -> NSDragOperation {
        
        guard let pasteboardTypes = info.draggingPasteboard.types else {
            print("Could not get pasteboard types")
            return []
        }
        
        let isProject = pasteboardTypes.contains(NSPasteboard.PasteboardType(rawValue: "time-agent.project"))
        let isTask = pasteboardTypes.contains(NSPasteboard.PasteboardType(rawValue: "time-agent.task"))
        
        if isProject {
            if item is ProjectGroup {
                return .move
            }
            
            if item is Project {
                return []
            }
            
            // For root
            return .move
        }
        
        if isTask {
            if item is Project {
                return .move
            }
            
            return []
        }
        
        return []
    }
    
    func outlineView(_ outlineView: NSOutlineView, acceptDrop info: NSDraggingInfo, item: Any?, childIndex index: Int) -> Bool {
        
        guard let pasteboardTypes = info.draggingPasteboard.types else {
            print("Could not get pasteboard types")
            return false
        }
        
        let isProject = pasteboardTypes.contains(NSPasteboard.PasteboardType(rawValue: "time-agent.project"))
        let isTask = pasteboardTypes.contains(NSPasteboard.PasteboardType(rawValue: "time-agent.task"))
        
        
        print("Move Action")
        
        if isTask {
            
            guard let project = item as? Project else {
                print("Could not convert outline item to Project")
                return false
            }
            
            info.enumerateDraggingItems(options: [], for: outlineView, classes: [NSString.self, NSPasteboardItem.self, NSURL.self], searchOptions: [:]) { (draggingItem, index, stopPtr) in
                
                let pbItem = draggingItem.item as! NSPasteboardItem
                
                let urlString = pbItem.string(forType: NSPasteboard.PasteboardType("time-agent.task"))!
                let url = URL(string: urlString)!
                
                let objId = Model.context.persistentStoreCoordinator!.managedObjectID(forURIRepresentation: url)!
                
                let object = (try? Model.context.existingObject(with: objId))
                
                guard let task = object as? Task else {
                    print("Could not convert pasteboard item to task")
                    return
                }
                
                task.project = project
            }
            
            updateData(keepSelection: false)
            AppDelegate.main.fileSync?.save()
            
            return true
        }
        
        if isProject {
            let group = item as? ProjectGroup
            
            print("Move to group \(group?.name ?? "Root")")
            
            info.enumerateDraggingItems(options: [], for: outlineView, classes: [NSString.self, NSPasteboardItem.self, NSURL.self], searchOptions: [:]) { (draggingItem, index, stopPtr) in
                
                let pbItem = draggingItem.item as! NSPasteboardItem
                
                let urlString = pbItem.string(forType: NSPasteboard.PasteboardType("time-agent.project"))!
                let url = URL(string: urlString)!
                
                let objId = Model.context.persistentStoreCoordinator!.managedObjectID(forURIRepresentation: url)!
                
                let object = (try? Model.context.existingObject(with: objId))
                
                if let project = object as? Project {
                    project.group = group
                    return
                }
                
                if let dragGroup = object as? ProjectGroup {
                    dragGroup.parent = group
                    return
                }
                
                print("Could not get either project or group: \(index)")
            }
            
            
            updateData(keepSelection: false)
            AppDelegate.main.fileSync?.save()
            
            return true
        }
        
        return false
    }
    
}
