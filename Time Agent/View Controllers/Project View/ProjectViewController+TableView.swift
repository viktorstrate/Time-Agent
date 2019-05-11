//
//  ProjectViewController+TableView.swift
//  Time Agent
//
//  Created by Viktor Hundahl Strate on 11/05/2019.
//  Copyright © 2019 Viktor Hundahl Strate. All rights reserved.
//

import Cocoa

extension ProjectViewController: NSTableViewDelegate, NSTableViewDataSource {
    func numberOfRows(in tableView: NSTableView) -> Int {
        
        guard let project = project else {
            return 0
        }
        
        guard let tasks = project.tasks else {
            print("ERROR: ProjectViewController -> viewFor tableColumn: Could not get project.tasks")
            return 0
        }
        
        print("Updating tableview tasks")
        tableViewTasks = tasks.sortedArray(using: [NSSortDescriptor(key: "archived", ascending: true), NSSortDescriptor(key: "start", ascending: false)]) as! [Task]
        
        
        print("Showing \(tasks.count) tasks")
        return tasks.count
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        let identifier = tableColumn!.identifier
        
        let cell = tableView.makeView(withIdentifier: identifier, owner: self) as! NSTableCellView
        
        var cellValue: String!
        
        let task = tableViewTasks[row]
        
        guard let start = task.start else {
            print("ERROR: ProjectViewController -> viewFor tableColumn: task.start is nil")
            return nil
        }
        
        switch identifier.rawValue {
        case "date":
            cellValue = ProjectViewController.dateFormatter.string(from: start)
            break
        case "task":
            cellValue = task.name
            break
        case "duration":
            cellValue = ProjectViewController.durationFormatter.string(from: task.duration)
            break
        default:
            cellValue = "Not defined"
        }
        
        if task.archived {
            cell.textField?.textColor = NSColor.disabledControlTextColor
        } else {
            cell.textField?.textColor = NSColor.controlTextColor
        }
        
        cell.textField?.stringValue = cellValue
        
        return cell
    }
}
