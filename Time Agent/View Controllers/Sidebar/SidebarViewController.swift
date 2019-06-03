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

    // Project or Group currently being renamed
    var renameItem: NSManagedObject? = nil
    var editTextField: NSTextField?
    var menuDelegate: MenuViewProjectsDelegate!

    @IBOutlet weak var outlineView: NSOutlineView!
    @IBOutlet var projectContextMenu: NSMenu!

    override func viewDidLoad() {
        super.viewDidLoad()

        outlineView.dataSource = self
        outlineView.delegate = self
        outlineView.menu = projectContextMenu
        outlineView.rowHeight = 24;

        outlineView.action = #selector(outlineViewClicked)
        outlineView.registerForDraggedTypes([NSPasteboard.PasteboardType(rawValue: "time-agent.project"), NSPasteboard.PasteboardType(rawValue: "time-agent.task")])

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
                let project = Project()
                project.name = text
                project.wasUpdated()
                menuDelegate.changeActiveProject(project)
            }
            
//            updateData()
            outlineView.reloadData()
            
            
            print("Starting sync because new project was added")
//            AppDelegate.main.fileSync.sync(editProvoked: true)
            AppDelegate.main?.fileSync?.save()
        } else {
            // Rename project or group
            let renamedObject = renameItem!
            renameItem = nil

            if !text.isEmpty {
                if let renamedProject = renamedObject as? Project {
                    renamedProject.name = text
                    renamedProject.wasUpdated()
                    menuDelegate.changeActiveProject(renamedProject)
                }

                if let renamedGroup = renamedObject as? ProjectGroup {
                    renamedGroup.name = text
                    renamedGroup.wasUpdated()
                }
            }

//            updateData(keepSelection: false)
            outlineView.reloadData()
            
            let row = outlineView.row(forItem: renamedObject)
            outlineView.selectRowIndexes(IndexSet(arrayLiteral: row), byExtendingSelection: false)

            if let renamedProject = renamedObject as? Project {
                menuDelegate.changeActiveProject(renamedProject)
            }
            
            print("Starting sync because project was renamed")
//            AppDelegate.main.fileSync.sync(editProvoked: true)
            AppDelegate.main?.fileSync?.save()
        }
    }

    var previousSelection: IndexSet?

    @objc func outlineViewClicked() {
        // Deselect active project
        if outlineView.clickedRow == -1 {
            menuDelegate.changeActiveProject(nil)
            return
        }

        if outlineView.selectedRowIndexes.contains(outlineView.clickedRow) {
            if let project = outlineView.item(atRow: outlineView.clickedRow) as? Project {
                menuDelegate.changeActiveProject(project)
            }
        }
    }

    // MARK: Core Data related functions

    func updateData(keepSelection: Bool = true) {
        do {
            try Model.context.save()
            let selected = outlineView.selectedRowIndexes
            outlineView.reloadData()
            if keepSelection {
                outlineView.selectRowIndexes(selected, byExtendingSelection: false)
            }

        } catch {
            print("Error saving data")
        }
    }

    // MARK: Right click menu

    @IBAction func projectMenuDeleteAction(_ sender: Any) {

        if outlineView.clickedRow == -1 {
            return
        }

        if let project = outlineView.item(atRow: outlineView.clickedRow) as? Project {
            print("Deleting project: \(project.name!)")
            Model.delete(managedObject: project)
            updateData()
            menuDelegate.changeActiveProject(nil)
            
            print("Starting sync because a project was deleted")
//            AppDelegate.main.fileSync.sync(editProvoked: true)
            AppDelegate.main?.fileSync?.save()
            return
        }

        if let group = outlineView.item(atRow: outlineView.clickedRow) as? ProjectGroup {
            print("Deleting group: \(group.name!)")

            let sheet = NSStoryboard.main!.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier("sidebarDeleteGroupModal")) as! SidebarDeleteGroupModalViewController

            sheet.keepCallback = {
                Model.delete(managedObject: group)
                self.updateData()
                
                print("Starting sync because a group without projects was deleted")
//                AppDelegate.main.fileSync.sync(editProvoked: true)
                AppDelegate.main?.fileSync?.save()
            }

            sheet.deleteCallback = {
                
                var deleteGroup: ((ProjectGroup) -> Void)!
                deleteGroup = {group in
                    
                    let projects = group.projects!.allObjects as! [Project]
                    for project in projects {
                        Model.delete(managedObject: project)
                    }
                    
                    if let subgroups = group.subgroups {
                        for sub in subgroups.allObjects as! [ProjectGroup] {
                            
                            if let projects = sub.projects {
                                for project in projects.allObjects as! [Project] {
                                    print("Deleting project \(project.name!), in group \(sub.name!)")
                                    Model.delete(managedObject: project)
                                }
                            }
                            
                            deleteGroup(sub)
                        }
                        
                        self.menuDelegate.changeActiveProject(nil)
                        print("Deleting group \(group.name!)")
                        Model.delete(managedObject: group)
                    }
                }

                deleteGroup(group)

                self.updateData()
                
                print("Starting sync because a group with projects was deleted")
//                AppDelegate.main.fileSync.sync(editProvoked: true)
                AppDelegate.main?.fileSync?.save()
            }

            presentAsSheet(sheet)

            return
        }
    }

    @IBAction func projectMenuRenameAction(_ sender: Any) {

        if let item = outlineView.item(atRow: outlineView.clickedRow) as? NSManagedObject {
            renameItem = item
            outlineView.reloadData()
            
            if let project = item as? Project {
                menuDelegate.changeActiveProject(project)
            }
            
            return
        }
    }

    @IBAction func projectMenuGroupAction(_ sender: Any) {
        let projects = outlineView.selectedRowIndexes.filter({ (row) -> Bool in
            return outlineView.item(atRow: row) is Project
        }).map { (row) -> Project in
            return outlineView.item(atRow: row) as! Project
        }
        
        let groups = outlineView.selectedRowIndexes.filter({ (row) -> Bool in
            return outlineView.item(atRow: row) is ProjectGroup
        }).map { (row) -> ProjectGroup in
            return outlineView.item(atRow: row) as! ProjectGroup
        }

        let group = ProjectGroup()
        group.projects = NSSet(array: projects)
        group.subgroups = NSSet(array: groups)
        
        group.name = NSLocalizedString("New group", comment: "Default name for new groups")
//        group.parent = projects[0].group

        updateData(keepSelection: false)

        renameItem = group

        outlineView.reloadData()
    }

    func menuWillOpen(_ menu: NSMenu) {
        var shouldCancel = false

        if (outlineView.clickedRow == -1) {
            shouldCancel = true
        }

        let multipleSelected = outlineView.selectedRowIndexes.count > 1

        // Don't allow renaming of multiple projects
        menu.item(withTag: 0)!.isEnabled = !multipleSelected

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
