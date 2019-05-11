//
//  ProjectViewController+DragDrop.swift
//  Time Agent
//
//  Created by Viktor Hundahl Strate on 11/05/2019.
//  Copyright © 2019 Viktor Hundahl Strate. All rights reserved.
//

import Cocoa

extension ProjectViewController {
    func tableView(_ tableView: NSTableView, pasteboardWriterForRow row: Int) -> NSPasteboardWriting? {
        let pbItem = NSPasteboardItem()
        
        let managedObj = tableViewTasks[row]
        
        pbItem.setString(managedObj.objectID.uriRepresentation().absoluteString, forType: NSPasteboard.PasteboardType("time-agent.task"))
        
        print("Drag URL: \(managedObj.objectID.uriRepresentation().absoluteString)")
        
        return pbItem
    }
}
