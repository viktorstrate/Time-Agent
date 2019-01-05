//
//  ProjectsTableViewController.swift
//  Time Agent
//
//  Created by Viktor Hundahl Strate on 19/08/2018.
//  Copyright © 2018 Viktor Hundahl Strate. All rights reserved.
//

import Cocoa

class ProjectsTableViewController: NSViewController, NSTableViewDelegate, NSTableViewDataSource, ProjectsEditItemCellDelegate, NSMenuDelegate {
    
    var newProject = false
    var renameRow = -1
    var renameRowProject: ProjectModel? = nil
    var editTextField: NSTextField?
    var projectsDelegate: MenuViewProjectsDelegate?
    
    lazy var coreDataContext: NSManagedObjectContext = {
        let appDelegate = NSApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        return context
    }()

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
                let _ = ProjectModel.addProject(name: text)
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
        let projects = ProjectModel.fetchAll()
        
        if newProject {
            print("Got projects \(projects.count) plus new one")
            return projects.count + 1
        }
        
        print("Got projects \(projects.count)")
        return projects.count
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {

        let projects = ProjectModel.fetchAll()
        
        if newProject && row == projects.count || renameRow == row {
            let editItem = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier("projectEditCell"), owner: nil) as! ProjectsEditItemCellView
            
            editItem.delegate = self
            editItem.editingProject = renameRowProject

            editTextField = editItem.editTextField
            
            return editItem
        }
        
        let projectItem = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier("projectCell"), owner: nil) as! ProjectsItemCellView

        projectItem.project = projects[row]

        return projectItem
    }
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        let projects = ProjectModel.fetchAll()
        let project = projects[tableView.selectedRow]
        
        projectsDelegate?.changeActiveProject(project)
    }
    
    // MARK: Core Data related functions
    
    func updateData() {
        do {
            try coreDataContext.save()
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
        
        print("Deleting project: " + (row.project.managedObject.value(forKey: "name") as! String))
        row.project.delete()
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
}
