//
//  ProjectsTableViewController.swift
//  Time Agent
//
//  Created by Viktor Hundahl Strate on 19/08/2018.
//  Copyright © 2018 Viktor Hundahl Strate. All rights reserved.
//

import Cocoa

class ProjectsTableViewController: NSViewController, NSTableViewDelegate, NSTableViewDataSource, ProjectsEditItemCellDelegate, NSMenuDelegate, ProjectsSidebarDelegate {
    
    var newProject = false
    var renameRow = -1
    var renameRowProject: Project? = nil
    var editTextField: NSTextField?
    var projectsDelegate: MenuViewProjectsDelegate?

    @IBOutlet weak var tableView: NSTableView!
    @IBOutlet var projectContextMenu: NSMenu!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.menu = projectContextMenu
        tableView.rowHeight = 34
        
        projectContextMenu.delegate = self
        
    }
    
    @IBAction func addProjectAction(_ sender: NSButton) {
        print("Add new project")
        newProject = true
        tableView.reloadData()
        tableView.scrollRowToVisible(tableView.numberOfRows-1)
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
            let renamedRow = renameRow
            renameRow = -1
            tableView.reloadData()
            
            if !text.isEmpty {
                guard let row = tableView(tableView, viewFor: nil, row: renamedRow) as? ProjectsItemCellView else {
                    print("EndEditing: Error row not found")
                    return
                }
                
                row.project = renameRowProject
                renameRowProject = nil
                
                row.project.name = text
                
            } else {
                renameRowProject = nil
            }
        }
    }
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        let projects = Model.fetchAll(request: Project.fetchRequest())
        
        if newProject {
            print("Got projects \(projects.count) plus new one")
            return projects.count + 1
        }
        
        print("Got projects \(projects.count)")
        return projects.count
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {

        let projects = Model.fetchAll(request: Project.fetchRequest())
        
        if newProject && row == 0 || renameRow == row {
            let editItem = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier("projectEditCell"), owner: nil) as! ProjectsEditItemCellView
            
            editItem.delegate = self
            editItem.editingProject = renameRowProject

            editTextField = editItem.editTextField
            
            return editItem
        }
        
        let projectItem = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier("projectCell"), owner: nil) as! ProjectsItemCellView
        projectItem.project = projects[projectIndex(forRow: row)]

        return projectItem
    }
    
    func projectIndex(forRow row: Int) -> Int {
        var projectIndex = row
        if newProject {
            projectIndex -= 1
        }
        return projectIndex
    }
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        if (tableView.selectedRow < 0) {
            projectsDelegate?.changeActiveProject(nil)
            return
        }

        let projects = Model.fetchAll(request: Project.fetchRequest())
        let projectIndex = self.projectIndex(forRow: tableView.selectedRow)
        let project = projects[projectIndex]
        
        projectsDelegate?.changeActiveProject(project)
    }
    
    // MARK: Core Data related functions
    
    func updateData() {
        do {
            try Model.context.save()
            tableView.reloadData()
        } catch {
            print("Error saving data, after attempting to add a new project")
        }
    }
    
    // MARK: Right click menu
    
    @IBAction func projectMenuDeleteAction(_ sender: Any) {
        if (tableView.clickedRow < 0) {
            return
        }
        
        guard let row = tableView(tableView, viewFor: nil, row: tableView.clickedRow) as? ProjectsItemCellView else {
            print("Error row not found")
            return
        }
        
        print("Deleting project: " + (row.project.name ?? "Name not set"))
        Model.delete(managedObject: row.project)
        updateData()
    }
    
    @IBAction func projectMenuRenameAction(_ sender: Any) {
        if (tableView.clickedRow < 0) {
            return
        }
        
        guard let row = tableView(tableView, viewFor: nil, row: tableView.clickedRow) as? ProjectsItemCellView else {
            print("Error row not found")
            return
        }
        
        renameRow = tableView.clickedRow
        renameRowProject = row.project
        tableView.reloadData()
    }
    
    func menuWillOpen(_ menu: NSMenu) {
        var shouldCancel = false
        
        if (tableView.clickedRow < 0) {
            shouldCancel = true
        } else {
            let view = tableView(tableView, viewFor: nil, row: tableView.clickedRow) as? ProjectsItemCellView
            if (view == nil) {
                shouldCancel = true
            }
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
