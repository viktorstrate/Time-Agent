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
        
        print("Get pasteboard")
        
        guard let managedObj = item as? NSManagedObject else {
            print("Drag drop: Item not a managed object")
            return nil
        }
        
        pbItem.setString(managedObj.objectID.uriRepresentation().absoluteString, forType: NSPasteboard.PasteboardType("public.data"))
        
        print("Drag URL: \(managedObj.objectID.uriRepresentation().absoluteString)")
        
        print("pbItem is \(pbItem)")
        
        return pbItem
    }
    
    func outlineView(_ outlineView: NSOutlineView, validateDrop info: NSDraggingInfo, proposedItem item: Any?, proposedChildIndex index: Int) -> NSDragOperation {
        
        if item is ProjectGroup {
            return .move
        }
        
        if item is Project {
            return []
        }
        
        // For root
        return .move
    }
    
    func outlineView(_ outlineView: NSOutlineView, acceptDrop info: NSDraggingInfo, item: Any?, childIndex index: Int) -> Bool {
        
        print("Move Action")
        
        let group = item as? ProjectGroup
        
        print("Move to group \(group?.name ?? "Root")")
        
        info.enumerateDraggingItems(options: [], for: outlineView, classes: [NSString.self, NSPasteboardItem.self, NSURL.self], searchOptions: [:]) { (draggingItem, index, stopPtr) in
            
            let pbItem = draggingItem.item as! NSPasteboardItem
            
            let urlString = pbItem.string(forType: NSPasteboard.PasteboardType("public.data"))!
            let url = URL(string: urlString)!
            
            let objId = Model.context.persistentStoreCoordinator!.managedObjectID(forURIRepresentation: url)!
            
            guard let project = (try? Model.context.existingObject(with: objId)) as? Project else {
                print("Could not get project: \(index)")
                return
            }
            
            project.group = group
        }
        
        
        updateData(keepSelection: false)
        
        return true
    }
    
}
