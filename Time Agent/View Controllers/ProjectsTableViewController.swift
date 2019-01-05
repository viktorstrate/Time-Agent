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
//                addProject(name: text)
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
        print("Got projects")
        
        guard let projects = ProjectModel.fetchAll() else {
            return 0
        }
        
        if newProject {
            return projects.count + 1
        }
        
        return projects.count
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        guard let projects = ProjectModel.fetchAll() else {
            return nil
        }
        
        if newProject && row == projects.count || renameRow == row {
            let editItem = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier("projectEditCell"), owner: nil) as! ProjectsEditItemCellView
            
            editItem.delegate = self
            editItem.editingProject = renameRowProject

            editTextField = editItem.editTextField
            
            return editItem
        }
        
        let projectItem = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier("projectCell"), owner: nil) as! ProjectsItemCellView
//        projectItem.title.stringValue = projects[row]
        projectItem.project = projects[row]

        return projectItem
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
    
//    func addProject(name: String) {
//
//        let entity = NSEntityDescription.entity(forEntityName: "Project", in: coreDataContext)
//        let newProject = NSManagedObject(entity: entity!, insertInto: coreDataContext)
//        newProject.setValue(name, forKey: "name")
//
//        do {
//            try coreDataContext.save()
//            tableView.reloadData()
//        } catch {
//            print("Error saving data, after attempting to add a new project")
//        }
//    }
//
//    func fetchAllProjects() -> [NSManagedObject]? {
//        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Project")
//        request.returnsObjectsAsFaults = false
//
//        do {
//            let result = try coreDataContext.fetch(request)
//            return result as? [NSManagedObject]
//        } catch {
//            print("Error fetching projects")
//            return nil
//        }
//    }
//
//    func deleteProject(project: NSManagedObject) {
//        do {
//            coreDataContext.delete(project)
//            try coreDataContext.save()
//            tableView.reloadData()
//        } catch {
//            print("Error could not delete project")
//        }
//    }
//
//    func renameProject(project: NSManagedObject, name: String) {
//        do {
//            project.setValue(name, forKey: "name")
//            try coreDataContext.save()
//            tableView.reloadData()
//        } catch {
//            print("Error could not rename project")
//        }
//    }
    
    // MARK: Right click menu
    
    @IBAction func projectMenuDeleteAction(_ sender: Any) {
        if (tableView.clickedRow < 0) {
            return
        }
        
        guard let row = tableView(tableView, viewFor: nil, row: tableView.clickedRow) as? ProjectsItemCellView else {
            print("Error row not found")
            return
        }
        
        print("Deleting project: " + (row.project.value(forKey: "name") as! String))
//        deleteProject(project: row.project)
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
