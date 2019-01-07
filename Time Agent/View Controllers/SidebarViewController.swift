//
//  ProjectsTableViewController.swift
//  Time Agent
//
//  Created by Viktor Hundahl Strate on 19/08/2018.
//  Copyright © 2018 Viktor Hundahl Strate. All rights reserved.
//

import Cocoa

class SidebarViewController: NSViewController, NSOutlineViewDelegate, NSOutlineViewDataSource, ProjectsEditItemCellDelegate, NSMenuDelegate, ProjectsSidebarDelegate {
    
    var newProject = false
    var renameRow = -1
    var renameRowProject: Project? = nil
    var editTextField: NSTextField?
    var projectsDelegate: MenuViewProjectsDelegate?

    @IBOutlet weak var outlineView: NSOutlineView!
    @IBOutlet var projectContextMenu: NSMenu!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        outlineView.dataSource = self
        outlineView.delegate = self
        outlineView.menu = projectContextMenu
        outlineView.rowHeight = 24;
        
        projectContextMenu.delegate = self
        
    }
    
    @IBAction func addProjectAction(_ sender: NSButton) {
        print("Add new project")
        newProject = true
        outlineView.reloadData()
        outlineView.scrollRowToVisible(outlineView.numberOfRows-1)
    }
    
    func endEditing(text: String) {
        if (newProject == true) {
            newProject = false
            if !text.isEmpty {
//                let _ = ProjectModel.addProject(name: text)
                let project = Project(context: Model.context)
                project.name = text
                project.creationDate = Date()
                updateData()
            }
        } else {
            // Rename project
            fatalError("Not reimplemented yet")
//            let renamedRow = renameRow
//            renameRow = -1
//            outlineView.reloadData()
//
//            if !text.isEmpty {
            
//                guard let row = tableView(tableView, viewFor: nil, row: renamedRow) as? ProjectsItemCellView else {
//                    print("EndEditing: Error row not found")
//                    return
//                }
//
//                row.project = renameRowProject
//                renameRowProject = nil
//
//                row.project.name = text
                
//            } else {
//                renameRowProject = nil
//            }
        }
    }
    
    func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
        // Root
        if item == nil {
            let projects = Project.fetchRoots()
            
            if newProject {
                print("Got projects \(projects.count) plus new one")
                return projects.count + 1
            }
            
            print("Got projects \(projects.count)")
            return projects.count
        }
        
        return 1 // for testing
    }
    
    func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
        // Root
        if item == nil {
            if newProject && index == 0 {
                return "NewProject"
            }
            
            let projects = Project.fetchRoots()
            
            return projects[projectIndex(index)]
        }
        
        return "It is a child"
    }
    
    func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
        return false
    }
    
    func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
        if let project = item as? Project {
            
            let projectItem = outlineView.makeView(withIdentifier: NSUserInterfaceItemIdentifier("projectCell"), owner: nil) as! ProjectsItemCellView
            projectItem.project = project
            
            return projectItem
        }
        
        if let key = item as? String {
            if key == "NewProject" {
                
                let newProjectItem = outlineView.makeView(withIdentifier: NSUserInterfaceItemIdentifier("projectEditCell"), owner: nil) as! ProjectsEditItemCellView
                
                newProjectItem.delegate = self
                
                return newProjectItem
            }
        }
        
        return nil
    }
    
    func projectIndex(_ index: Int) -> Int {
        var projectIndex = index
        if newProject {
            projectIndex -= 1
        }
        return projectIndex
    }
    
    var previousSelection: IndexSet?
    
    func outlineViewSelectionDidChange(_ notification: Notification) {
        if previousSelection == nil {
            previousSelection = outlineView.selectedRowIndexes
        }
        
        // Only update if selection has changed
        if outlineView.selectedRowIndexes.elementsEqual(previousSelection!) {
            print("Selection equal")
            return
        } else {
            previousSelection = outlineView.selectedRowIndexes
        }
        
        if (outlineView.selectedRow < 0) {
            projectsDelegate?.changeActiveProject(nil)
            return
        }

        let projects = Model.fetchAll(request: Project.fetchRequest())
        let projectIndex = self.projectIndex(outlineView.selectedRow)
        let project = projects[projectIndex]
        
        projectsDelegate?.changeActiveProject(project)
    }
    
    // MARK: Core Data related functions
    
    func updateData() {
        do {
            try Model.context.save()
            let selected = outlineView.selectedRow
            outlineView.reloadData()
            outlineView.selectRowIndexes(IndexSet(arrayLiteral: selected), byExtendingSelection: false)
        } catch {
            print("Error saving data, after attempting to add a new project")
        }
    }
    
    // MARK: Right click menu
    
    @IBAction func projectMenuDeleteAction(_ sender: Any) {
        fatalError("Not reimplemented yet")
//        if (outlineView.clickedRow < 0) {
//            return
//        }
//
//        guard let row = tableView(tableView, viewFor: nil, row: tableView.clickedRow) as? ProjectsItemCellView else {
//            print("Error row not found")
//            return
//        }
//
//        print("Deleting project: " + (row.project.name ?? "Name not set"))
//        Model.delete(managedObject: row.project)
//        updateData()
    }
    
    @IBAction func projectMenuRenameAction(_ sender: Any) {
        fatalError("Not reimplemented yet")
//        if (outlineView.clickedRow < 0) {
//            return
//        }
//
//        guard let row = tableView(tableView, viewFor: nil, row: tableView.clickedRow) as? ProjectsItemCellView else {
//            print("Error row not found")
//            return
//        }
//
//        renameRow = outlineView.clickedRow
//        renameRowProject = row.project
//        outlineView.reloadData()
    }
    
    func menuWillOpen(_ menu: NSMenu) {
        var shouldCancel = false
        
        if (outlineView.clickedRow < 0) {
            shouldCancel = true
        } else {
            fatalError("Not reimplemented yet")
//            let view = tableView(tableView, viewFor: nil, row: tableView.clickedRow) as? ProjectsItemCellView
//            if (view == nil) {
//                shouldCancel = true
//            }
        }
        
        if (shouldCancel) {
            menu.cancelTracking()
        }
    }
    
    func projectsUpdated() {
        print("Projects updated...")
        updateData()
    }
}

protocol ProjectsSidebarDelegate {
    func projectsUpdated()
}
