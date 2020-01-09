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
    var newProjectParent: ProjectGroup? = nil

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
    
    func newProject(parent: ProjectGroup?) {
        print("Add new project")
        newProject = true
        newProjectParent = parent
        
        if let parent = parent {
            outlineView.expandItem(parent)
        }
        
        outlineView.reloadData()
        if parent == nil {
            outlineView.scrollRowToVisible(0)
        }
    }

    @IBAction func addProjectAction(_ sender: NSButton) {
        newProject(parent: nil)
    }

    func projectEditItem(endEditing projectItem: ProjectEditCellView, text: String) {
        if (newProject == true) {
            newProject = false
            
            let projectName = text.trimmingCharacters(in: .whitespaces)
            
            if !projectName.isEmpty {
                let project = Project()
                project.name = projectName
                project.group = projectItem.newProjectParent
                project.wasUpdated()
                menuDelegate.changeActiveProject(project)
                
                print("Starting sync because new project was added")
                AppDelegate.main?.fileSync?.save()
            }
            
            outlineView.reloadData()
            
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
