//
//  SidebarViewController+OutlineView.swift
//  Time Agent
//
//  Created by Viktor Hundahl Strate on 14/01/2019.
//  Copyright © 2019 Viktor Hundahl Strate. All rights reserved.
//

import Cocoa

extension SidebarViewController {
    func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
        // Root
        if item == nil {
            let projects = Project.fetchRoots()
            let groups = ProjectGroup.fetchRoots()
            
            var count = projects.count + groups.count
            
            if newProject {
                count = count + 1
            }
            
            return count
        }
        
        if let group = item as? ProjectGroup {
            let children = group.projects!.count + group.subgroups!.count
            
            return children
        }
        
        return 0
    }
    
    func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
        // Root
        if item == nil {
            if newProject && index == 0 {
                return "NewProject"
            }
            
            var i: Int = index
            
            if newProject {
                i = i - 1
            }
            
            let projects = Project.fetchRoots()
            let groups = ProjectGroup.fetchRoots()
            
            var combined: [NSManagedObject] = []
            combined.append(contentsOf: projects)
            combined.append(contentsOf: groups)
            
            return combined[i]
        }
        
        if let group = item as? ProjectGroup {
            let projects = group.projects!.allObjects as! [Project]
            let groups = group.subgroups!.allObjects as! [ProjectGroup]
            
            var combined: [NSManagedObject] = []
            combined.append(contentsOf: groups)
            combined.append(contentsOf: projects)
            
            return combined[index]
        }
        
        return "Did not know how to implement item"
    }
    
    func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
        if item is ProjectGroup {
            return true
        }
        
        return false
    }
    
    func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
        
        if let rowObject = item as? NSManagedObject, renameItem == rowObject {
            print("Found rename project or group")
            
            let renameView = outlineView.makeView(withIdentifier: NSUserInterfaceItemIdentifier("projectEditCell"), owner: self) as! ProjectEditCellView
            
            renameView.delegate = self
            renameView.editingObject = rowObject
            
            return renameView
        }
        
        if let project = item as? Project {
            let projectView = outlineView.makeView(withIdentifier: NSUserInterfaceItemIdentifier("projectCell"), owner: self) as! ProjectCellView
            projectView.project = project
            
            return projectView
        }
        
        if let group = item as? ProjectGroup {
            
            let groupItem = outlineView.makeView(withIdentifier: NSUserInterfaceItemIdentifier("groupCell"), owner: self) as! ProjectGroupCellView
            groupItem.group = group
            
            return groupItem
        }
        
        if let key = item as? String {
            if key == "NewProject" {
                
                let newProjectItem = outlineView.makeView(withIdentifier: NSUserInterfaceItemIdentifier("projectEditCell"), owner: nil) as! ProjectEditCellView
                
                newProjectItem.delegate = self
                
                return newProjectItem
            }
        }
        
        return nil
    }
}
